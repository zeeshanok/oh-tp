import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:oh_tp/models/sms_broadcaster.dart';
import 'package:oh_tp/models/user_role.dart';

class FirebaseUserRoleModel implements UserRoleModel {
  @override
  ValueNotifier<UserRoles> get currentUserRole => _currentUserRole;
  final _currentUserRole = ValueNotifier(UserRoles.unassigned);

  @override
  ValueNotifier<FirebaseControllerManager?> get controllerManager =>
      _controllerManager;
  final _controllerManager = ValueNotifier<FirebaseControllerManager?>(null);

  @override
  late SmsBroadcaster smsBroadcaster;

  late FirebaseAuth auth;

  late FirebaseDatabase database;
  late DatabaseReference activeSendersRef, controllersRef;

  bool _isController = false;
  bool _isActiveSender = false;

  FirebaseUserRoleModel() {
    smsBroadcaster = FirebaseSmsBroadcaster(this);
  }

  void _evaluateUserRole() {
    if (!_isActiveSender && !_isController) {
      _currentUserRole.value = UserRoles.unassigned;
    }
    if (!_isActiveSender && _isController) {
      _currentUserRole.value = UserRoles.controller;
    }
    if (_isActiveSender && !_isController) {
      _currentUserRole.value = UserRoles.activeSender;
    }
  }

  @override
  void initialise() {
    auth = FirebaseAuth.instance;
    database = FirebaseDatabase.instance;

    final uid = auth.currentUser!.uid;
    activeSendersRef = database.ref('active_senders/$uid');

    activeSendersRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        _isActiveSender = true;
      } else {
        // entry was deleted
        _isActiveSender = false;
      }
      _evaluateUserRole();
    });

    controllersRef = database.ref('controllers/$uid');

    controllersRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        _isController = true;
      } else {
        _isController = false;
      }
      _evaluateUserRole();
    });
  }

  @override
  Future<void> becomeActiveSender(String controllerId) async {
    if (_currentUserRole.value != UserRoles.unassigned) {
      await becomeUnassigned();
    }
    await activeSendersRef.set({
      "controllerId": controllerId,
    });
  }

  @override
  Future<bool> becomeController(String senderId) async {
    if (_currentUserRole.value != UserRoles.unassigned) {
      await becomeUnassigned();
    }
    final manager = FirebaseControllerManager(senderId: senderId);
    _controllerManager.value = manager;
    final result = await manager.requestSenderAccess();

    if (result == ControllerRequestStatus.accepted) {
      await controllersRef.set(senderId);
      return true;
    } else {
      debugPrint("They rejected us :(");
      return false;
    }
  }

  @override
  Future<void> becomeUnassigned() async {
    await controllersRef.remove();
    await activeSendersRef.remove();
  }

  @override
  Future<ControllerRequest> waitForNextControllerRequest() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final controllerRequestRef =
        FirebaseDatabase.instance.ref('controller_requests/$uid/controllerId');

    final event = await controllerRequestRef.onValue
        .firstWhere((event) => event.snapshot.exists);

    return FirebaseControllerRequest(
      controllerId: event.snapshot.value! as String,
    );
  }
}

class FirebaseControllerManager implements ControllerManager {
  final _controllerStatus = ValueNotifier(ControllerRequestStatus.waiting);
  @override
  ValueNotifier<ControllerRequestStatus> get controllerStatus =>
      _controllerStatus;

  final String _senderId;
  @override
  String get senderId => _senderId;

  FirebaseControllerManager({required String senderId}) : _senderId = senderId;

  @override
  Future<ControllerRequestStatus> requestSenderAccess() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final controllerRequestsRef =
        FirebaseDatabase.instance.ref('controller_requests/$_senderId');

    await controllerRequestsRef.set({
      "controllerId": uid,
    });

    debugPrint("waiting for accept");
    final event = await Future.any<DatabaseEvent>([
      Future.delayed(
          30.seconds,
          () => throw TimeoutException(
              "Sender did not respond in time (30 seconds)")),
      controllerRequestsRef
          .child('accepted')
          .onValue
          .firstWhere((event) => event.snapshot.exists),
    ]);
    _controllerStatus.value = (event.snapshot.value!) as bool
        ? ControllerRequestStatus.accepted
        : ControllerRequestStatus.rejected;
    await controllerRequestsRef.remove();
    return _controllerStatus.value;
  }
}

class FirebaseControllerRequest implements ControllerRequest {
  @override
  String get controllerId => _controllerId;
  final String _controllerId;

  late final DatabaseReference controllerRequestRef;

  FirebaseControllerRequest({required String controllerId})
      : _controllerId = controllerId {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    controllerRequestRef =
        FirebaseDatabase.instance.ref('controller_requests/$uid');
  }

  @override
  Future<void> accept() async {
    await controllerRequestRef.child('accepted').set(true);
    await GetIt.instance<UserRoleModel>().becomeActiveSender(_controllerId);
  }

  @override
  Future<void> reject() async {
    await controllerRequestRef.child('accepted').set(false);
  }
}

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:oh_tp/models/user_role.dart';

class FirebaseUserRoleModel implements UserRoleModel {
  final _currentUserRole = ValueNotifier(UserRoles.unassigned);
  @override
  ValueNotifier<UserRoles> get currentUserRole => _currentUserRole;

  final _controllerManager = ValueNotifier<FirebaseControllerManager?>(null);
  @override
  ValueNotifier<FirebaseControllerManager?> get controllerManager =>
      _controllerManager;

  late FirebaseAuth auth;

  late FirebaseDatabase database;
  late DatabaseReference activeSendersRef, controllersRef;

  @override
  void initialise() {
    auth = FirebaseAuth.instance;
    database = FirebaseDatabase.instance;
    final uid = auth.currentUser!.uid;
    activeSendersRef = database.ref('active_senders/$uid');

    activeSendersRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        _currentUserRole.value = UserRoles.activeSender;
      } else {
        // entry was deleted
        _currentUserRole.value = UserRoles.unassigned;
      }
    });

    controllersRef = database.ref('controllers/$uid');

    controllersRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        _currentUserRole.value = UserRoles.controller;
      } else {
        _currentUserRole.value = UserRoles.unassigned;
      }
    });
  }

  @override
  Future<void> becomeActiveSender() async {
    if (_currentUserRole.value != UserRoles.unassigned) {
      await becomeUnassigned();
    }
    await activeSendersRef.set("sir yes sir");
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

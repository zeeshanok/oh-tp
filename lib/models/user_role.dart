import 'package:flutter/foundation.dart';
import 'package:oh_tp/models/message_model.dart';
import 'package:oh_tp/models/sms_broadcaster.dart';

abstract class UserRoleModel {
  ValueNotifier<UserRoles> get currentUserRole;
  ValueNotifier<ControllerManager?> get controllerManager;

  SmsBroadcaster get smsBroadcaster;

  void initialise();

  Future<bool> becomeController(String senderId);
  Future<void> becomeActiveSender(String controllerId);
  Future<void> becomeUnassigned();

  Future<ControllerRequest> waitForNextControllerRequest();
}

enum UserRoles { controller, activeSender, unassigned }

/// Used by controllers
enum ControllerRequestStatus { waiting, accepted, rejected }

/// Manager class used by controllers to request access to a sender and receive
/// its sms broadcast
abstract class ControllerManager {
  String get senderId;
  ValueNotifier<ControllerRequestStatus> get controllerStatus;

  Stream<List<Message>> get messageStream;

  Future<ControllerRequestStatus> requestSenderAccess();

  void startReceivingSmsBroadcast();
  void stopReceivingSmsBroadcast();
}

/// The request sent from the controller in the point of view of the sender
abstract class ControllerRequest {
  String get controllerId;
  Future<void> accept();
  Future<void> reject();
}

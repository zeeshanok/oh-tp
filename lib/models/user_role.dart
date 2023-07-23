import 'package:flutter/foundation.dart';
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

enum ControllerRequestStatus { waiting, accepted, rejected }

abstract class ControllerManager {
  String get senderId;
  ValueNotifier<ControllerRequestStatus> get controllerStatus;

  Future<ControllerRequestStatus> requestSenderAccess();
}

abstract class ControllerRequest {
  String get controllerId;
  Future<void> accept();
  Future<void> reject();
}

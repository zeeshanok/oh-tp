import 'package:flutter/foundation.dart';

abstract class UserRoleModel {
  ValueNotifier<UserRoles> get currentUserRole;
  ValueNotifier<ControllerManager?> get controllerManager;

  void initialise();

  Future<bool> becomeController(String senderId);
  Future<void> becomeActiveSender();
  Future<void> becomeUnassigned();
}

enum UserRoles { controller, activeSender, unassigned }

enum ControllerRequestStatus { waiting, accepted, rejected }

abstract class ControllerManager {
  String get senderId;
  ValueNotifier<ControllerRequestStatus> get controllerStatus;

  Future<ControllerRequestStatus> requestSenderAccess();
}

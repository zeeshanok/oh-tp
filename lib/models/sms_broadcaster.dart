import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:oh_tp/models/message_model.dart';
import 'package:oh_tp/models/user_role.dart';

const kSMSQueryCount = 5;

abstract class SmsBroadcaster {
  void broadcastOnce();
  void start();
  void stop();
}

class FirebaseSmsBroadcaster implements SmsBroadcaster {
  Timer? _timer;

  final UserRoleModel userRoleModel;

  FirebaseSmsBroadcaster(this.userRoleModel);

  @override
  void broadcastOnce() async {
    if (userRoleModel.currentUserRole.value == UserRoles.activeSender) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final ref = FirebaseDatabase.instance.ref('active_senders/$uid/messages');

      final messages = await SmsQuery().querySms(
        count: kSMSQueryCount,
        kinds: [SmsQueryKind.inbox],
        sort: true,
      );

      final map = {
        for (var i = 0; i < messages.length; i++)
          i: Message.fromSMSMessage(messages[i]).toMap()
      };

      await ref.set(map);
      debugPrint("updated sms");
    } else {
      throw Exception("current user is not active sender");
    }
  }

  @override
  void start() {
    _timer = Timer.periodic(2.seconds, (t) => broadcastOnce());
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}

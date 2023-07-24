import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_hooks/get_it_hooks.dart';
import 'package:oh_tp/models/message_model.dart';
import 'package:oh_tp/models/user_role.dart';
import 'package:oh_tp/pages/receive_otp_dialog.dart';
import 'package:oh_tp/pages/send_otp_dialog.dart';
import 'package:oh_tp/utils.dart';
import 'package:oh_tp/widgets/default_dialog.dart';
import 'package:oh_tp/widgets/sms_item.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> msgs = [];

  Future<List<String>> getSMS() async {
    if (await Permission.sms.request().isGranted) {
      final query = SmsQuery();
      final msgs = await query
          .querySms(kinds: [SmsQueryKind.inbox], count: 8, sort: true);
      return msgs.map((e) => "${e.date} ${e.address}").toList();
    } else {
      throw Exception("permission to read sms wasnt granted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            child: ConfigurationSelector(),
          ),
        ),
      ),
    );
  }
}

class ConfigurationSelector extends HookWidget {
  const ConfigurationSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final role =
        useValueListenable(GetIt.instance<UserRoleModel>().currentUserRole);
    return AnimatedSwitcher(
        duration: 400.ms,
        child: role == UserRoles.unassigned
            ? Column(
                key: const ValueKey("config"),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Configuration required",
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => showAnimatedDialog(
                            context, (context) => const SendOTPDialog()),
                        icon: const Icon(Icons.wifi_tethering_rounded),
                        label: const Text("Send OTPs"),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          Permission.camera.request().then((e) {
                            if (e.isGranted) {
                              showAnimatedDialog(context,
                                  (context) => const ReceiveOTPDialog());
                            } else {
                              showSnackbarMessage(context,
                                  "Please provide permission to use the camera");
                            }
                          });
                        },
                        icon: const Icon(Icons.router_rounded),
                        label: const Text("Receive OTPs"),
                      )
                    ],
                  ),
                ],
              )
            : AssignedRoleView(role: role));
  }
}

class DetailedIconButton extends StatelessWidget {
  const DetailedIconButton(
      {super.key,
      required this.onPressed,
      required this.icon,
      required this.label,
      required this.details});

  final void Function()? onPressed;
  final Widget icon;
  final String label, details;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [icon, const SizedBox(width: 6), Text(label)],
          ),
          const SizedBox(height: 14),
          Text(
            details,
            style: Theme.of(context).textTheme.bodyLarge,
          )
        ],
      ),
    );
  }
}

class AssignedRoleView extends HookWidget {
  const AssignedRoleView({required this.role, Key? key})
      : assert(role != UserRoles.unassigned),
        super(key: key);

  final UserRoles role;

  @override
  Widget build(BuildContext context) {
    if (role == UserRoles.activeSender) {
      return const SmsSenderView();
    } else {
      return const SmsView();
    }
  }
}

class SmsSenderView extends HookWidget {
  const SmsSenderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      final broadcaster = GetIt.instance<UserRoleModel>().smsBroadcaster;
      Permission.sms.request().then(
            (value) => broadcaster.start(),
          );
      return broadcaster.stop;
    }, []);
    return const Text("Sending sms...");
  }
}

class SmsView extends HookWidget {
  const SmsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      final manager = GetIt.instance<UserRoleModel>().controllerManager.value!;
      manager.startReceivingSmsBroadcast();
      return manager.stopReceivingSmsBroadcast;
    }, []);

    final messages = useStream(
        GetIt.instance<UserRoleModel>().controllerManager.value!.messageStream,
        initialData: <Message>[]);

    return messages.hasData && messages.data!.isNotEmpty
        ? SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AnimateList(
                autoPlay: true,
                interval: 120.ms,
                effects: [
                  FadeEffect(duration: 400.ms),
                  SlideEffect(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  )
                ],
                children: [
                  for (var message in messages.data!) SmsItem(message: message)
                ],
              ),
            ),
          )
        : const CircularProgressIndicator();
  }
}

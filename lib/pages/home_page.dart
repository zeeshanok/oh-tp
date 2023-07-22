import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:get_it_hooks/get_it_hooks.dart';
import 'package:oh_tp/models/user_role.dart';
import 'package:oh_tp/pages/receive_otp_dialog.dart';
import 'package:oh_tp/pages/send_otp_dialog.dart';
import 'package:oh_tp/utils.dart';
import 'package:oh_tp/widgets/default_dialog.dart';
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
        body: Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConfigurationSelector(),
      ),
    ));
  }
}

class ConfigurationSelector extends HookWidget {
  const ConfigurationSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return useWatchX((UserRoleModel model) => model.currentUserRole) ==
            UserRoles.unassigned
        ? Column(
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
                          showAnimatedDialog(
                              context, (context) => const ReceiveOTPDialog());
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
        : const Text("you are useful!");
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

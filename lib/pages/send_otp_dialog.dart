import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:oh_tp/models/user_role.dart';
import 'package:oh_tp/widgets/default_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SendOTPDialog extends StatelessWidget {
  const SendOTPDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
        title: "Scan QR Code",
        content: FutureBuilder(
          future:
              GetIt.instance<UserRoleModel>().waitForNextControllerRequest(),
          builder: (context, snapshot) => snapshot.hasData
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("A device would like to connect to you"),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FilledButton.tonal(
                            onPressed: () {
                              snapshot.data!.reject();
                              Navigator.of(context).pop();
                            },
                            child: const Text("Reject")),
                        FilledButton(
                          onPressed: () {
                            snapshot.data!.accept();
                            Navigator.of(context).pop();
                          },
                          child: const Text("Accept"),
                        ),
                      ],
                    )
                  ],
                )
              : const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QRCode(),
                    Text(
                      "Select 'Receive OTPs' on your other device and scan this QR code",
                    )
                  ],
                ),
        ));
  }
}

class QRCode extends StatelessWidget {
  const QRCode({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return QrImageView(
      padding: const EdgeInsets.all(20),
      data: 'oh-tp $uid',
      dataModuleStyle: const QrDataModuleStyle(
        color: Colors.white,
        dataModuleShape: QrDataModuleShape.square,
      ),
      eyeStyle: const QrEyeStyle(
        color: Colors.white,
        eyeShape: QrEyeShape.square,
      ),
      size: 300,
    );
  }
}

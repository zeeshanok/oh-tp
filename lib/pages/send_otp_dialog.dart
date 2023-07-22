import 'package:flutter/material.dart';
import 'package:oh_tp/widgets/default_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SendOTPDialog extends StatelessWidget {
  const SendOTPDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultDialog(
        title: "Scan QR Code",
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QRCode(),
            Text(
              "Select 'Receive OTPs' on your other device and scan this QR code",
            )
          ],
        ));
  }
}

class QRCode extends StatelessWidget {
  const QRCode({super.key});

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      padding: const EdgeInsets.all(20),
      data: 'oh-tp 1ZAYQJxKU9PTc4h2ZYMtXCqSBL83',
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

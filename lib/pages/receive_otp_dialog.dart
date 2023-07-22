import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:get_it_hooks/get_it_hooks.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:oh_tp/models/user_role.dart';
import 'package:oh_tp/utils.dart';
import 'package:oh_tp/widgets/default_dialog.dart';

class ReceiveOTPDialog extends HookWidget {
  const ReceiveOTPDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = useMobileScannerController();
    final qrCodeText = useState<String?>(null);

    return DefaultDialog(
        content: SizedBox.square(
          dimension: 300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: MobileScanner(
              controller: controller,
              onDetect: (barcodes) async {
                for (var barcode in barcodes.barcodes) {
                  if (barcode.rawValue != null &&
                      barcode.rawValue!.startsWith("oh-tp ")) {
                    qrCodeText.value =
                        barcode.rawValue!.substring("oh-tp ".length);
                  }
                }
              },
              placeholderBuilder: (context, child) =>
                  const Icon(Icons.camera_alt_rounded),
            ),
          )
              .animate(
                target: qrCodeText.value == null ? 0 : 1,
                onComplete: (_) => controller.stop(),
              )
              .scaleXY(
                begin: 1,
                end: 0.8,
                duration: 200.ms,
                curve: Curves.easeInOutCubic,
              )
              .fadeOut()
              .swap(
                builder: (context, child) =>
                    const Center(child: CircularProgressIndicator()).animate(
                        onComplete: (_) {
                  GetIt.instance<UserRoleModel>()
                      .becomeController(qrCodeText.value!)
                      .then((value) {
                    if (!value) {
                      showSnackbarMessage(
                        context,
                        "Your connection request was rejected by the other device",
                      );
                    }
                    Navigator.of(context).pop();
                  });
                }).fadeIn(duration: 250.ms),
              ),
        ),
        title: "Scan QR Code");
  }
}

MobileScannerController useMobileScannerController() =>
    use(const _MobileScannerControllerHook());

class _MobileScannerControllerHook extends Hook<MobileScannerController> {
  const _MobileScannerControllerHook();

  @override
  _MobileScannerControllerHookState createState() =>
      _MobileScannerControllerHookState();
}

class _MobileScannerControllerHookState
    extends HookState<MobileScannerController, _MobileScannerControllerHook> {
  late final MobileScannerController controller;

  @override
  MobileScannerController build(BuildContext context) {
    return controller;
  }

  @override
  void initHook() {
    super.initHook();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

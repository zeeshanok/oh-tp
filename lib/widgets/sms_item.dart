import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it_hooks/get_it_hooks.dart';
import 'package:intl/intl.dart';
import 'package:oh_tp/models/message_model.dart';

class SmsItem extends HookWidget {
  const SmsItem({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final showContractedText = useState(true);
    final controller = useAnimationController();
    final expandAnim = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    useValueChanged<bool, void>(showContractedText.value, (_, __) async {
      if (!showContractedText.value) {
        await controller.animateTo(1, duration: 400.ms);
      } else {
        await controller.animateBack(0, duration: 300.ms);
      }
    });

    return GestureDetector(
      onTap: () => showContractedText.value = !showContractedText.value,
      child: AnimatedContainer(
        duration: 200.ms,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(15),
          color: Theme.of(context).colorScheme.background,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  message.address,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat.Hm().format(message.time.toLocal()),
                  style: const TextStyle(fontSize: 12, letterSpacing: 0.6),
                )
              ],
            ),
            const SizedBox(height: 4),
            Stack(children: [
              Text(
                message.content,
                style: const TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 1,
              ),
              Container(
                color: Theme.of(context).colorScheme.background,
                child: SizeTransition(
                  axis: Axis.vertical,
                  axisAlignment: -1,
                  sizeFactor: expandAnim,
                  child: Text(
                    message.content,
                    style: const TextStyle(fontSize: 18),
                    softWrap: true,
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

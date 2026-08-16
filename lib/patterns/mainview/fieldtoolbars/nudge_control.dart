import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/nudge_button.dart';

class NudgeControl extends StatelessWidget {
  final Offset initialOffset;
  final void Function(Offset newOffset) onNudged;

  const NudgeControl({
    required this.initialOffset,
    required this.onNudged,
    super.key
  });

  static const double _size = 39;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NudgeButton(
                icon: const Icon(Icons.arrow_drop_up, size: _size / 3,), 
                onNudge: () => onNudged(initialOffset.translate(0, HardwareKeyboard.instance.isShiftPressed ? -10 :-1)),
              )
            ],
          ),
          Row(
            children: [
              NudgeButton(
                icon: const Icon(Icons.arrow_left, size: _size / 3), 
                onNudge: () => onNudged(initialOffset.translate(HardwareKeyboard.instance.isShiftPressed ? -10 : -1, 0)),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onNudged(Offset.zero),
                  child: const Icon(Icons.center_focus_strong, size: _size / 3),
                ),
              ),
              NudgeButton(
                icon: const Icon(Icons.arrow_right, size: _size / 3), 
                onNudge: () => onNudged(initialOffset.translate(HardwareKeyboard.instance.isShiftPressed ? 10 : 1, 0)),
              )

            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NudgeButton(
                icon: const Icon(Icons.arrow_drop_down, size: _size / 3), 
                onNudge: () => onNudged(initialOffset.translate(0, HardwareKeyboard.instance.isShiftPressed ? 10 : 1)),
              )
            ],
          ),
        ],
      ),
    );
  }
}
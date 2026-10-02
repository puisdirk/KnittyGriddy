import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knitty_griddy/patterns/mainview/fieldtoolbars/nudge_button.dart';

class NudgeControl extends StatelessWidget {
  final Offset initialOffset;
  final double size;
  final void Function(Offset newOffset) onNudged;

  const NudgeControl({
    required this.initialOffset,
    this.size = 39,
    required this.onNudged,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NudgeButton(
                icon: Icon(Icons.arrow_drop_up, size: size / 3,), 
                onNudge: () => onNudged(initialOffset.translate(0, HardwareKeyboard.instance.isShiftPressed ? -10 :-1)),
              )
            ],
          ),
          Row(
            children: [
              NudgeButton(
                icon: Icon(Icons.arrow_left, size: size / 3), 
                onNudge: () => onNudged(initialOffset.translate(HardwareKeyboard.instance.isShiftPressed ? -10 : -1, 0)),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onNudged(Offset.zero),
                  child: Icon(Icons.center_focus_strong, size: size / 3),
                ),
              ),
              NudgeButton(
                icon: Icon(Icons.arrow_right, size: size / 3), 
                onNudge: () => onNudged(initialOffset.translate(HardwareKeyboard.instance.isShiftPressed ? 10 : 1, 0)),
              )

            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NudgeButton(
                icon: Icon(Icons.arrow_drop_down, size: size / 3), 
                onNudge: () => onNudged(initialOffset.translate(0, HardwareKeyboard.instance.isShiftPressed ? 10 : 1)),
              )
            ],
          ),
        ],
      ),
    );
  }
}
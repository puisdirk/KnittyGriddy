import 'package:flutter/material.dart';

class NudgeButton extends StatefulWidget {
  final Icon icon;
  final void Function() onNudge;
  
  const NudgeButton({
    required this.icon,
    required this.onNudge,
    super.key
  });

  @override
  State<NudgeButton> createState() => _NudgeButtonState();
}

class _NudgeButtonState extends State<NudgeButton> {
  bool isPressed = false;
  bool longTapActive = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Ignore tap if timer for long tap had triggered
          if (longTapActive) {
            setState(() => longTapActive = false);
          } else {
            widget.onNudge();
          }
        },
        onTapDown: (_) async {
          setState(() => isPressed = true);
          do {
            await Future.delayed(longTapActive ? const Duration(milliseconds: 50) : const Duration(milliseconds: 500));
            if (isPressed) {
              if (!longTapActive) {
                setState(() => longTapActive = true);
              }
              widget.onNudge();
            }
          } while (isPressed);
        },
        onTapUp: (_) {
          setState(() {
            longTapActive = false;
            isPressed = false;
          });
        },
        onTapCancel: () {
          setState(() {
            longTapActive = false;
            isPressed = false;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isPressed ? Colors.lightGreen : null,
          ),
          child: Center(
            child: widget.icon,
          ),
        ),
      ),
    );
  }
}
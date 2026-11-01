import 'package:flutter/material.dart';

class ButtonLoader extends StatelessWidget {
  final double size;
  final Color color;

  const ButtonLoader({
    super.key,
    this.size = 18.0,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}


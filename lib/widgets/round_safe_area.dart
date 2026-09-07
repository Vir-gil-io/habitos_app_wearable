import 'package:flutter/material.dart';

class RoundSafeArea extends StatelessWidget {
  final Widget child;
  const RoundSafeArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isRound = MediaQuery.of(context).size.aspectRatio == 1.0;
    // padding ~14% en pantallas redondas para evitar recortes en las esquinas
    final horizontalPad = isRound ? size.width * 0.14 : 16.0;
    final verticalPad = isRound ? size.height * 0.10 : 12.0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPad,
        vertical: verticalPad,
      ),
      child: child,
    );
  }
}
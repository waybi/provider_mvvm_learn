import 'package:flutter/material.dart';
import 'package:flutter_demo/ui/widget/activity_indicator.dart';

/// 由于app不管明暗模式,都是有底色
/// 所以将indicator颜色为亮色
class AppBarIndicator extends StatelessWidget {
  final double radius;

  AppBarIndicator({required this.radius});

  @override
  Widget build(BuildContext context) {
    return ActivityIndicator(
      brightness: Brightness.dark,
      radius: radius,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod_template/core/theme/app_preview.dart';

/// 全屏加载指示。
class LoadingView extends StatelessWidget {
  @AppPreview(name: '加载', group: 'common')
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

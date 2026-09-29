import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime expiryTime;
  final VoidCallback onExpire;

  const CountdownTimerWidget({
    super.key,
    required this.expiryTime,
    required this.onExpire,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateRemaining();
    });
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    if (now.isAfter(widget.expiryTime)) {
      _timer.cancel();
      if (mounted) {
        setState(() => _remainingSeconds = 0);
        widget.onExpire();
      }
    } else {
      if (mounted) {
        setState(() {
          _remainingSeconds = widget.expiryTime.difference(now).inSeconds;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      Formatters.formatTimer(_remainingSeconds),
      style: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}
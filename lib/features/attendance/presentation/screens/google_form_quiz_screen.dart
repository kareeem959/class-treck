import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../../auth/logic/auth_state.dart';
import '../../data/models/attendance_session_model.dart';
import '../../logic/attendance_cubit.dart';
import '../widgets/countdown_timer_widget.dart';
import 'punch_success_screen.dart';

class GoogleFormQuizScreen extends StatefulWidget {
  final AttendanceSessionModel session;

  const GoogleFormQuizScreen({super.key, required this.session});

  @override
  State<GoogleFormQuizScreen> createState() => _GoogleFormQuizScreenState();
}

class _GoogleFormQuizScreenState extends State<GoogleFormQuizScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    final String formUrl = widget.session.googleFormUrl ?? 'https://docs.google.com/forms';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onUrlChange: (UrlChange change) {
            final url = change.url ?? '';
            // When user submits a Google Form, the URL redirects to 'formResponse'
            if (url.contains('formResponse')) {
              _handleQuizSubmitted();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(formUrl));
  }

  void _handleQuizSubmitted() {
    final user = (context.read<AuthCubit>().state as Authenticated).user;

    // Update the record in Firestore
    context.read<AttendanceCubit>().submitQuiz(widget.session.id, user.uid);

    // Navigate to success screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PunchSuccessScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Quiz', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: CountdownTimerWidget(
                expiryTime: widget.session.expiryTime,
                onExpire: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Time is up! Session expired.'), backgroundColor: AppColors.error),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
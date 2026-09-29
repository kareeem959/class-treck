import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/countdown_timer_widget.dart';

class LiveAttendanceScreen extends StatelessWidget {
  final String sessionId;

  const LiveAttendanceScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Session', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('attendance_sessions').doc(sessionId).snapshots(),
        builder: (context, sessionSnapshot) {
          if (!sessionSnapshot.hasData) return const Center(child: CircularProgressIndicator());

          final sessionData = sessionSnapshot.data!.data() as Map<String, dynamic>?;
          if (sessionData == null) return const Center(child: Text('Session not found'));

          final expiryTime = DateTime.fromMillisecondsSinceEpoch(sessionData['expiryTime']);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                color: AppColors.primary.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Time Remaining:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    CountdownTimerWidget(
                      expiryTime: expiryTime,
                      onExpire: () {},
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('attendance_records')
                      .where('sessionId', isEqualTo: sessionId)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, recordsSnapshot) {
                    if (!recordsSnapshot.hasData) return const Center(child: CircularProgressIndicator());

                    final records = recordsSnapshot.data!.docs;

                    if (records.isEmpty) {
                      return const Center(child: Text('No students have punched in yet.'));
                    }

                    return ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final recordData = records[index].data() as Map<String, dynamic>;
                        final isPresent = recordData['status'] == 'present';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isPresent ? AppColors.secondary.withOpacity(0.2) : AppColors.error.withOpacity(0.2),
                            child: Icon(
                              isPresent ? Icons.check : Icons.close,
                              color: isPresent ? AppColors.secondary : AppColors.error,
                            ),
                          ),
                          title: Text(recordData['studentName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${recordData['distance'].toStringAsFixed(1)} meters away'),
                          trailing: Text(
                            isPresent ? 'Present' : 'Rejected',
                            style: TextStyle(
                              color: isPresent ? AppColors.secondary : AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
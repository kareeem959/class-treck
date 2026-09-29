import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/class_model.dart';

class ClassCard extends StatelessWidget {
  final ClassModel classData;
  final bool isTeacher;
  final VoidCallback onTap;

  const ClassCard({
    super.key,
    required this.classData,
    required this.isTeacher,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    classData.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.class_outlined, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isTeacher ? 'Join Code: ${classData.joinCode}' : 'Instructor: ${classData.teacherName}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
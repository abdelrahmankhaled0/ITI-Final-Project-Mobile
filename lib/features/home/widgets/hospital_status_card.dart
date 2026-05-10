import 'package:flutter/material.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';

class HospitalStatusCard extends StatelessWidget {
  final String hospitalName;
  final int queueNumber;
  final int waitMinutes;
  final double queueProgress;

  const HospitalStatusCard({
    super.key,
    required this.hospitalName,
    required this.queueNumber,
    required this.waitMinutes,
    required this.queueProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.primaryColor10,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Live Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'LIVE STATUS',
                          style: AppTextStyles.textStyle12.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            // backgroundColor: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hospitalName,
                    style: AppTextStyles.textStyle18.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              // Queue number box
              Column(
                children: [
                  Text(
                    'QUEUE',
                    style: AppTextStyles.textStyle12.copyWith(
                      color: AppColors.primaryColor3,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.lightColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$queueNumber',
                      style: AppTextStyles.textStyle22.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: queueProgress,
              minHeight: 7,
              backgroundColor: AppColors.primaryColor9,
              valueColor:
              const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              text: 'Estimated wait: ',
              style: AppTextStyles.textStyle13.copyWith(
                color: AppColors.neutralColor3,
              ),
              children: [
                TextSpan(
                  text: '$waitMinutes mins',
                  style: AppTextStyles.textStyle13.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
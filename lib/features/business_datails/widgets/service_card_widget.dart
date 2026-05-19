import 'package:flutter/material.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';

class ServiceCard extends StatelessWidget {
  final String serviceName;
  final bool isActive;
  final int currentTicket;
  final VoidCallback onBookTap;

  const ServiceCard({
    super.key,
    required this.serviceName,
    required this.isActive,
    required this.currentTicket,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkColor.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getServiceIcon(serviceName),
              color: AppColors.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: AppTextStyles.textStyle18.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Current Ticket: $currentTicket',
                  style: AppTextStyles.textStyle12.copyWith(
                    color: AppColors.neutralColor5,
                  ),
                ),


              ],
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 10,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isActive ? 'Available Now' : 'Closed',
                    style: AppTextStyles.textStyle10.copyWith(
                      color: isActive ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                     isActive? 'Next: 10:30 AM' : "",
                    style: AppTextStyles.textStyle10.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: isActive ? onBookTap : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.lightColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  elevation: 0,
                ),
                child: const Text('Book Now', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }


  IconData _getServiceIcon(String name) {
    if (name.toLowerCase().contains('hair')) return Icons.content_cut_rounded;
    if (name.toLowerCase().contains('skin')) return Icons.face_retouching_natural;
    if (name.toLowerCase().contains('cardio')) return Icons.favorite_rounded;
    return Icons.medical_services_outlined;
  }
}
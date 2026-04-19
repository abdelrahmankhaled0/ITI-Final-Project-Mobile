import 'package:flutter/material.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/models/clinic_model.dart';

class ClinicCard extends StatelessWidget {
  final ClinicModel clinic;

  const ClinicCard({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightColor,
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralColor.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overlays
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(48)),
                child: _buildImage(),
              ),
              // Rating badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.lightColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFC107), size: 14),
                      const SizedBox(width: 3),
                      Text(
                        clinic.rating.toString(),
                        style: AppTextStyles.textStyle12.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutralColor1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // High Demand badge
              if (clinic.isHighDemand)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'HIGH DEMAND',
                      style: AppTextStyles.textStyle11.copyWith(
                        color: AppColors.lightColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Info row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clinic.name,
                            style: AppTextStyles.textStyle16.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 13, color: AppColors.neutralColor5),
                              const SizedBox(width: 2),
                              Text(
                                clinic.distance,
                                style: AppTextStyles.textStyle13.copyWith(
                                  color: AppColors.neutralColor5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'WAIT TIME',
                          style: AppTextStyles.textStyle11.copyWith(
                            color: AppColors.neutralColor5,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${clinic.waitTimeMinutes}',
                                style: AppTextStyles.textStyle22.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: clinic.waitTimeMinutes > 30
                                      ? const Color(0xFFE53935)
                                      : AppColors.primaryColor,
                                ),
                              ),
                              TextSpan(
                                text: ' min',
                                style: AppTextStyles.textStyle13.copyWith(
                                  color: AppColors.neutralColor4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Center(
                  child: SizedBox(
                    width: 278,
                    height: 56,
                    child: clinic.canCheckInNow
                        ? ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.lightColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'Check-in Now',
                        style: AppTextStyles.textStyle16.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightColor,
                        ),
                      ),
                    )
                        : OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppColors.primaryColor8, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'Pre-register',
                        style: AppTextStyles.textStyle16.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Image.asset(
      clinic.imagePath,
      height: 224,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error);
      },
    );
  }
}

/// Compact horizontal card used for the last item (e.g. Northside Pediatrics)
class ClinicListTile extends StatelessWidget {
  final ClinicModel clinic;

  const ClinicListTile({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralColor.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Container(
              width: 96,
              height: 96,
              color: AppColors.neutralColor9,
              child: Image.asset(
                clinic.imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
              // const Icon(Icons.local_hospital_outlined,
              //     color: AppColors.neutralColor7),
            ),
          ),
          const SizedBox(width: 14),
          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clinic.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.textStyle15.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryColor1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.neutralColor5),
                    Flexible(
                      child: Text(
                        ' ${clinic.distance}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.textStyle12
                            .copyWith(color: AppColors.neutralColor5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.access_time_rounded,
                        size: 12, color: AppColors.neutralColor5),
                    Flexible(
                      child: Text(
                        ' ${clinic.waitTimeMinutes} min wait',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.textStyle12
                            .copyWith(color: AppColors.neutralColor5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Arrow button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor10,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(Icons.chevron_right_rounded,
                color: AppColors.primaryColor, size: 22),
          ),
        ],
      ),
    );
  }
}
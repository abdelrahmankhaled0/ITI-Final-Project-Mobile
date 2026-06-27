import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/home/data/models/clinic_model.dart';

class ClinicCard extends StatelessWidget {
  final ClinicModel clinic;

  const ClinicCard({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkColor.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(48),
                ),
                child: _buildImage(),
              ),
              // Rating Badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFC107),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
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
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clinic.name,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: AppColors.neutralColor5,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  clinic.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildWaitTimeInfo(),
                  ],
                ),
                const SizedBox(height: 20),
                _buildActionButton(context, clinic),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitTimeInfo() {
    final Color waitTimeColor = clinic.waitTime > 30
        ? const Color(0xFFE53935)
        : AppColors.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'WAIT TIME',
          style: AppTextStyles.textStyle11.copyWith(
            color: AppColors.neutralColor5,
            fontWeight: FontWeight.bold,
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${clinic.waitTime}',
                style: AppTextStyles.textStyle22.copyWith(
                  fontWeight: FontWeight.w900,
                  color: waitTimeColor,
                ),
              ),
              TextSpan(
                text: ' min',
                style: AppTextStyles.textStyle13.copyWith(
                  color: AppColors.neutralColor4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, ClinicModel clinic) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            context.push(
              '/home/details',
              extra: {
                'id': clinic.id,
                'name': clinic.name,
                'imageUrl': clinic.imageUrl,
                'address': clinic.address,
                'category': clinic.category,
                'waitTime': clinic.waitTime,
                'rating': clinic.rating,
                'lat': clinic.lat,
                'lng': clinic.lng,
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.lightColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: Text(
            'Show Services',
            style: AppTextStyles.textStyle16.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Image.network(
      clinic.imageUrl,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 200,
        color: AppColors.neutralColor9,
        child: Icon(Icons.business, color: AppColors.neutralColor7),
      ),
    );
  }
}

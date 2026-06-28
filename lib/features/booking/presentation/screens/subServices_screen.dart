import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taborq/core/services/remote/location_helper.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/business_datails/cubit/business_details_cubit.dart';
import 'package:taborq/features/business_datails/cubit/business_details_state.dart';
import 'package:taborq/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:taborq/features/booking/presentation/cubit/booking_state.dart';
import 'package:taborq/features/notifications/presentation/cubit/notification_cubit.dart';

class SubServicesScreen extends StatelessWidget {
  final String businessId;
  final String serviceId;
  final String serviceName;
  final String lat;
  final String lng;

  const SubServicesScreen({
    super.key,
    required this.businessId,
    required this.serviceId,
    required this.serviceName,
    required this.lat,
    required this.lng,
  });

  void _showStatusToast({
    required String message,
    required Color backgroundColor,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: context.read<BusinessDetailsCubit>().getServiceDetails(
        businessId,
        serviceId,
      ),
      builder: (context, serviceSnapshot) {
        if (serviceSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }

        final serviceData = serviceSnapshot.data?.data() ?? {};
        final List<String> chips = List<String>.from(
          serviceData['subServiceNames'] ?? [],
        );
        final String aboutText = serviceData['about'] ?? '';
        final int waitTime = serviceData['avgServiceTime'] ?? 0;
        final String imageUrl = (serviceData['imageUrl'] ?? '')
            .toString()
            .trim();

        return Scaffold(
          bottomNavigationBar: BlocConsumer<BookingCubit, BookingState>(
            listener: (context, state) {
              if (state is BookingSuccess) {
                _showStatusToast(
                  message:
                      "Successfully booked! Your number is: Q-${state.ticketCode}",
                  backgroundColor: Colors.green.shade700,
                );
              }

              if (state is BookingAlreadyBookedState) {
                context.read<BookingCubit>().startQueueListener(
                  businessId: businessId,
                  serviceId: serviceId,
                  userTurnNumber: state.ticketCode,
                  ticketId: state.ticketId,
                  avgServiceTime: state.avgServiceTime,
                  notificationCubit: context.read<NotificationCubit>(),
                  serviceName: state.serviceName,
                  businessName: state.businessName,
                );

                _showStatusToast(
                  message:
                      "You already have an active booking. Your ticket is Q-${state.ticketCode}.",
                  backgroundColor: Colors.orange.shade800,
                );
              }
            },
            builder: (context, state) {
              return SafeArea(
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 6,
                              shadowColor: AppColors.darkColor.withOpacity(
                                0.25,
                              ),
                            ),
                            onPressed: state is BookingLoading
                                ? null
                                : () {
                                    if (serviceData.isNotEmpty) {
                                      context
                                          .read<BookingCubit>()
                                          .bookQueuePlace(
                                            businessId: businessId,
                                            serviceId: serviceId,
                                            serviceName: serviceName,
                                            avgServiceTime: waitTime,
                                            notificationCubit: context
                                                .read<NotificationCubit>(),
                                          );
                                    }
                                  },
                            child: state is BookingLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    "Book Now",
                                    style: AppTextStyles.textStyle16.copyWith(
                                      color: AppColors.lightColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                backgroundColor: Colors.transparent,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  serviceName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                centerTitle: true,
                // actions: [
                //   IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                // ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholderImage(),
                              )
                            : _buildPlaceholderImage(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "PREMIUM WELLNESS",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        serviceName,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.neutralColor4,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "1221 Serenity Blvd, North District, Floor 4, Suite 200",
                              style: AppTextStyles.textStyle12.copyWith(
                                color: AppColors.neutralColor4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildDesignInfoCards(waitTime.toString()),
                      const SizedBox(height: 28),
                      if (chips.isNotEmpty) ...[
                        Text(
                          "Available Services",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: chips.map((treatmentName) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                // color: AppColors.lightColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.neutralColor9,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getChipIcon(treatmentName),
                                    size: 16,
                                    color: AppColors.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    treatmentName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: AppColors.primaryColor,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 28),
                      ],
                      if (aboutText.isNotEmpty) ...[
                        Text(
                          "About ",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          aboutText,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Text(
                        "Location Map",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStaticMapCard(lat, lng, context),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.neutralColor10,
      child: const Icon(
        Icons.broken_image,
        size: 64,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildDesignInfoCards(String waitTime) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.infoCardBg1,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.access_time_filled,
                  color: AppColors.neutralColor2,
                  size: 22,
                ),
                const Spacer(),
                Text(
                  waitTime,
                  style: AppTextStyles.textStyle20.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutralColor,
                  ),
                ),
                Text(
                  "MINS WAIT",
                  style: AppTextStyles.textStyle10.copyWith(
                    color: AppColors.neutralColor4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.infoCardBg2,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.verified,
                  color: AppColors.primaryColor,
                  size: 22,
                ),
                const Spacer(),
                Text(
                  "Certified",
                  style: AppTextStyles.textStyle16.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  "Experts",
                  style: AppTextStyles.textStyle16.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  "TOP 1% RATED",
                  style: AppTextStyles.textStyle10.copyWith(
                    color: AppColors.primaryColor4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getChipIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('consult')) return Icons.medical_services_outlined;
    if (lower.contains('x-ray') || lower.contains('ray')) {
      return Icons.document_scanner_outlined;
    }
    if (lower.contains('blood')) return Icons.biotech_outlined;
    if (lower.contains('vaccin')) return Icons.vaccines_outlined;
    return Icons.check_circle_outline;
  }

  Widget _buildStaticMapCard(String lat, String lng, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Prefer live coordinates from BusinessDetailsCubit if available
        final state = context.read<BusinessDetailsCubit>().state;
        double? latitude;
        double? longitude;

        if (state is BusinessDetailsLoaded) {
          latitude = state.latitude;
          longitude = state.longitude;
        }

        // If cubit didn't provide coordinates, fall back to provided route args
        if (latitude == null || longitude == null) {
          if (lat.isNotEmpty && lng.isNotEmpty) {
            latitude = double.tryParse(lat);
            longitude = double.tryParse(lng);
          }
        }

        if (latitude != null && longitude != null) {
          confirmOpenLocationOnMap(context, latitude, longitude);
        } else {
          _showStatusToast(
            message: 'Location coordinates not available',
            backgroundColor: Colors.red.shade700,
          );
        }
      },
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.neutralColor6.withOpacity(0.4),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: const Icon(
              Icons.location_on,
              color: AppColors.primaryColor,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

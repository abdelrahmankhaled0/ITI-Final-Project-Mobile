import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/business_datails/cubit/business_details_cubit.dart';
import 'package:taborq/features/subService_details/models/subService_model.dart';

class SubServicesScreen extends StatelessWidget {
  final String businessId;
  final String serviceId;
  final String serviceName;

  const SubServicesScreen({
    super.key,
    required this.businessId,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: context.read<BusinessDetailsCubit>().getServiceDetails(businessId, serviceId),
      builder: (context, serviceSnapshot) {
        if (serviceSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
          );
        }

        final serviceData = serviceSnapshot.data?.data() ?? {};
        final List<String> chips = List<String>.from(serviceData['subServiceNames'] ?? []);
        final String aboutText = serviceData['about'] ?? '';
        final int waitTime = serviceData['avgServiceTime'] ?? 0;
        final String imageUrl =  (serviceData['imageUrl'] ?? '').toString().trim();



        return Scaffold(
          backgroundColor: AppColors.lightColor,

          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(

            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 4,
                  shadowColor: AppColors.darkColor.withOpacity(0.3),
                ),
                onPressed: () {
                  if (serviceData.isNotEmpty) {
                    _showSpecialistsBottomSheet(context);
                  }
                },
                child: Text(
                  "Book Now",
                  style: AppTextStyles.textStyle16.copyWith(
                    color: AppColors.lightColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [

              SliverAppBar(
                backgroundColor: AppColors.lightColor,
                elevation: 0,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.neutralColor),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  serviceName,
                  style: AppTextStyles.textStyle24.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: AppColors.neutralColor),
                    onPressed: () {},
                  ),
                ],
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
                          imageUrl ,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                        )
                            : _buildPlaceholderImage(),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        "PREMIUM WELLNESS",
                        style: AppTextStyles.textStyle10.copyWith(
                          color: AppColors.neutralColor4,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),


                      Text(
                        serviceName,
                        style: AppTextStyles.textStyle24.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutralColor,
                        ),
                      ),
                      const SizedBox(height: 8),


                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.neutralColor4),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "1221 Serenity Blvd, North District, Floor 4, Suite 200",
                              style: AppTextStyles.textStyle12.copyWith(color: AppColors.neutralColor4),
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
                          style: AppTextStyles.textStyle16.copyWith(fontWeight: FontWeight.bold, color: AppColors.neutralColor),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: chips.map((treatmentName) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.lightColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.neutralColor9),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_getChipIcon(treatmentName), size: 16, color: AppColors.primaryColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    treatmentName,
                                    style: AppTextStyles.textStyle12.copyWith(
                                      color: AppColors.neutralColor2,
                                      fontWeight: FontWeight.w500,
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
                          "About the Clinic",
                          style: AppTextStyles.textStyle16.copyWith(fontWeight: FontWeight.bold, color: AppColors.neutralColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          aboutText,
                          style: AppTextStyles.textStyle14.copyWith(
                            color: AppColors.neutralColor3,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],


                      Text(
                        "Location Map",
                        style: AppTextStyles.textStyle16.copyWith(fontWeight: FontWeight.bold, color: AppColors.neutralColor),
                      ),
                      const SizedBox(height: 12),
                      _buildStaticMapCard(),
                      const SizedBox(height: 90),
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
      child: const Icon(Icons.broken_image, size: 64, color: AppColors.primaryColor),
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
                const Icon(Icons.access_time_filled, color: AppColors.neutralColor2, size: 22),
                const Spacer(),
                Text(
                  "$waitTime",
                  style: AppTextStyles.textStyle20.copyWith(fontWeight: FontWeight.bold, color: AppColors.neutralColor),
                ),
                Text(
                  "MINS WAIT",
                  style: AppTextStyles.textStyle10.copyWith(color: AppColors.neutralColor4, fontWeight: FontWeight.bold),
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
                const Icon(Icons.verified, color: AppColors.primaryColor, size: 22),
                const Spacer(),
                Text(
                  "Certified",
                  style: AppTextStyles.textStyle16.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
                Text(
                  "Experts",
                  style: AppTextStyles.textStyle16.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
                Text(
                  "TOP 1% RATED",
                  style: AppTextStyles.textStyle10.copyWith(color: AppColors.primaryColor4, fontWeight: FontWeight.bold),
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
    if (lower.contains('x-ray') || lower.contains('ray')) return Icons.document_scanner_outlined;
    if (lower.contains('blood')) return Icons.biotech_outlined;
    if (lower.contains('vaccin')) return Icons.vaccines_outlined;
    return Icons.check_circle_outline;
  }


  Widget _buildStaticMapCard() {
    return Container(
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
          child: const Icon(Icons.location_on, color: AppColors.primaryColor, size: 28),
        ),
      ),
    );
  }


  void _showSpecialistsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.lightColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 45, height: 5, decoration: BoxDecoration(color: AppColors.neutralColor8, borderRadius: BorderRadius.circular(2.5))),
            const SizedBox(height: 20),
            Text(
              "Select Specialist / Counter",
              style: AppTextStyles.textStyle18.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<ServiceModel>>(
                stream: context.read<BusinessDetailsCubit>().getSubServices(businessId, serviceId),
                builder: (context, subServiceSnapshot) {
                  if (subServiceSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
                  }
                  final items = subServiceSnapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Center(child: Text("No specialists available right now."));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: items.length,
                    itemBuilder: (context, index) => _SubServiceListTile(item: items[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubServiceListTile extends StatelessWidget {
  final ServiceModel item;
  const _SubServiceListTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neutralColor10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryColor.withOpacity(0.1),
            radius: 24,
            child: const Icon(Icons.person, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.serviceName, style: AppTextStyles.textStyle16.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Wait Time: ${item.avgServiceTime} mins", style: AppTextStyles.textStyle12.copyWith(color: AppColors.neutralColor4)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () {},
            child: Text("Select", style: AppTextStyles.textStyle12.copyWith(color: AppColors.lightColor)),
          )
        ],
      ),
    );
  }
}
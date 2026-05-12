import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/business_datails/widgets/service_card_widget.dart';


class BusinessDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> business;

  const BusinessDetailsScreen({
    super.key,
    required this.business,
  });

  @override
  Widget build(BuildContext context) {
    String businessId = business['id'];

    return Scaffold(
      backgroundColor: AppColors.lightColor,
      body: CustomScrollView(
        slivers: [

          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primaryColor,

            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(20),
              child: Container(
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.lightColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(48),
                  ),
                ),
              ),
            ),

            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                business['imageUrl'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                    ),
                  );
                },
              ),
            ),
          ),


          SliverToBoxAdapter(
            child: Container(
              color: AppColors.lightColor,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Hospital Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_hospital_outlined,
                          size: 14,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Hospital",
                          style: AppTextStyles.textStyle12.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          business['name'],
                          style: AppTextStyles.textStyle24.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Open Now",
                          style: AppTextStyles.textStyle10.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),


                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "4.8 (2,341 reviews)",
                        style: AppTextStyles.textStyle12.copyWith(
                          color: AppColors.neutralColor5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),


                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.neutralColor5,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "${business['address']} • 1.2 km away",
                          style: AppTextStyles.textStyle12.copyWith(
                            color: AppColors.neutralColor5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),


                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          Icons.access_time_rounded,
                          "Wait Time",
                          "15-20 min",
                        ),

                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade200,
                        ),

                        _buildInfoItem(
                          Icons.medical_services_outlined,
                          "Specialties",
                          "25",
                        ),

                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade200,
                        ),

                        _buildInfoItem(
                          Icons.local_parking_rounded,
                          "Parking",
                          "Available",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),


                  Text(
                    "Available Services",
                    style: AppTextStyles.textStyle18.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),


          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('businesses')
                .doc(businessId)
                .collection('services')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: AppColors.primaryColor,),
                    ),
                  ),
                );
              }

              var services = snapshot.data!.docs;

              if (services.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("No services available"),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      var serviceData =
                      services[index].data() as Map<String, dynamic>;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: ServiceCard(
                          serviceName: serviceData['serviceName'],
                          isActive: serviceData['isActive'],
                          currentTicket: serviceData['currentTicket'],
                          onBookTap: () {},
                        ),
                      );
                    },
                    childCount: services.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      IconData icon,
      String label,
      String value,
      ) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor,
          size: 24,
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: AppTextStyles.textStyle10.copyWith(
            color: AppColors.neutralColor5,
          ),
        ),

        Text(
          value,
          style: AppTextStyles.textStyle12.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
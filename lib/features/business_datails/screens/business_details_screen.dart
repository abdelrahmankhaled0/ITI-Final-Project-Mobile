// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:taborq/core/utils/app_colors.dart';
// import 'package:taborq/core/utils/app_text_styles.dart';
// import 'package:taborq/features/business_datails/widgets/service_card_widget.dart';
// import 'package:taborq/features/home/cubit/home_cubit.dart';
// import 'package:taborq/features/home/widgets/%20search_bar_widget.dart';
//
//
// class BusinessDetailsScreen extends StatelessWidget {
//   final Map<String, dynamic> business;
//
//   const BusinessDetailsScreen({
//     super.key,
//     required this.business,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     String businessId = business['id'];
//
//     return Scaffold(
//       backgroundColor: AppColors.lightColor,
//       body: CustomScrollView(
//         slivers: [
//
//           SliverAppBar(
//             expandedHeight: 240,
//             pinned: true,
//             elevation: 0,
//             backgroundColor: AppColors.primaryColor,
//
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(20),
//               child: Container(
//                 height: 20,
//                 decoration: const BoxDecoration(
//                   color: AppColors.lightColor,
//                   borderRadius: BorderRadius.vertical(
//                     top: Radius.circular(48),
//                   ),
//                 ),
//               ),
//             ),
//
//             flexibleSpace: FlexibleSpaceBar(
//               background: Image.network(
//                 business['imageUrl'],
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return const Center(
//                     child: Icon(
//                       Icons.broken_image,
//                       size: 50,
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//
//
//           SliverToBoxAdapter(
//             child: Container(
//               color: AppColors.lightColor,
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 10),
//
//                   // Hospital Tag
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(
//                           Icons.local_hospital_outlined,
//                           size: 14,
//                           color: AppColors.primaryColor,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           business["category"],
//                           style: AppTextStyles.textStyle12.copyWith(
//                             color: AppColors.primaryColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 12),
//
//
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           business['name'],
//                           style: AppTextStyles.textStyle24.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.green.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           "Open Now",
//                           style: AppTextStyles.textStyle10.copyWith(
//                             color: Colors.green,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 8),
//
//
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.star_rounded,
//                         color: Colors.amber,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         "${business["rating"]} (2,341 reviews)",
//                         style: AppTextStyles.textStyle12.copyWith(
//                           color: AppColors.neutralColor5,
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 8),
//
//
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.location_on_outlined,
//                         color: AppColors.neutralColor5,
//                         size: 18,
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           "${business['address']} • 1.2 km away",
//                           style: AppTextStyles.textStyle12.copyWith(
//                             color: AppColors.neutralColor5,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 24),
//
//
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: Colors.grey.shade200,
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         _buildInfoItem(
//                           Icons.access_time_rounded,
//                           "Wait Time",
//                           "${business['waitTime'] ?? '0'} min",
//                         ),
//
//                         Container(
//                           width: 1,
//                           height: 40,
//                           color: Colors.grey.shade200,
//                         ),
//
//                         _buildInfoItem(
//                           Icons.medical_services_outlined,
//                           "Specialties",
//                           "25",
//                         ),
//
//                         Container(
//                           width: 1,
//                           height: 40,
//                           color: Colors.grey.shade200,
//                         ),
//
//                         _buildInfoItem(
//                           Icons.local_parking_rounded,
//                           "Parking",
//                           "Available",
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 24),
//
//                   SearchBarWidget(
//                     onChanged: (value) =>
//                         context.read<HomeCubit>().searchClinics(value),
//                   ),
//
//                   const SizedBox(height: 24),
//
//                   Text(
//                     "Available Services",
//                     style: AppTextStyles.textStyle18.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ),
//           ),
//
//
//           StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('businesses')
//                 .doc(businessId)
//                 .collection('services')
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) {
//                 return const SliverToBoxAdapter(
//                   child: Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(20),
//                       child: CircularProgressIndicator(color: AppColors.primaryColor,),
//                     ),
//                   ),
//                 );
//               }
//
//               var services = snapshot.data!.docs;
//
//               if (services.isEmpty) {
//                 return const SliverToBoxAdapter(
//                   child: Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(20),
//                       child: Text("No services available"),
//                     ),
//                   ),
//                 );
//               }
//
//               return SliverPadding(
//                 padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
//                 sliver: SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                         (context, index) {
//                       var serviceData =
//                       services[index].data() as Map<String, dynamic>;
//
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 5),
//                         child: ServiceCard(
//                           serviceName: serviceData['serviceName'],
//                           isActive: serviceData['isActive'],
//                           currentTicket: serviceData['currentTicket'],
//                           onBookTap: () {},
//                         ),
//                       );
//                     },
//                     childCount: services.length,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoItem(
//       IconData icon,
//       String label,
//       String value,
//       ) {
//     return Column(
//       children: [
//         Icon(
//           icon,
//           color: AppColors.primaryColor,
//           size: 24,
//         ),
//
//         const SizedBox(height: 4),
//
//         Text(
//           label,
//           style: AppTextStyles.textStyle10.copyWith(
//             color: AppColors.neutralColor5,
//           ),
//         ),
//
//         Text(
//           value,
//           style: AppTextStyles.textStyle12.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taborq/core/routes/routes.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/business_datails/cubit/business_details_cubit.dart';
import 'package:taborq/features/business_datails/cubit/business_details_state.dart';
import 'package:taborq/features/business_datails/widgets/service_card_widget.dart';
import 'package:taborq/features/home/presentation/widgets/%20search_bar_widget.dart';


class BusinessDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> business;


  const BusinessDetailsScreen({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BusinessDetailsCubit(),
      child: Scaffold(
        backgroundColor: AppColors.lightColor,
        body: _BusinessDetailsContent(business: business),
      ),
    );
  }
}

class _BusinessDetailsContent extends StatelessWidget {
  final Map<String, dynamic> business;
  const _BusinessDetailsContent({required this.business});

  @override
  Widget build(BuildContext context) {
    String businessId = business['id'];

    return CustomScrollView(
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network(business['imageUrl'], fit: BoxFit.cover),
          ),
        ),


        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Category Tag
                _buildTag(business["category"]),
                const SizedBox(height: 12),

                // Name & Status
                _buildHeader(business['name']),
                const SizedBox(height: 8),

                // Rating & Location
                _buildRatingAndLocation(business['rating'], business['address']),
                const SizedBox(height: 24),


                _buildInfoBox(business),
                const SizedBox(height: 24),


                SearchBarWidget(
                  onChanged: (value) => context.read<BusinessDetailsCubit>().updateSearchQuery(value),
                ),

                const SizedBox(height: 24),
                Text("Available Services", style: AppTextStyles.textStyle18.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),


        BlocBuilder<BusinessDetailsCubit, BusinessDetailsState>(
          builder: (context, state) {
            String searchTerm = "";
            if (state is BusinessDetailsInitial) {
              searchTerm = state.searchQuery;
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('businesses')
                  .doc(businessId)
                  .collection('services')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppColors.primaryColor,)));
                }


                var filteredServices = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name = (data['serviceName'] ?? "").toString().toLowerCase();
                  return name.contains(searchTerm.toLowerCase());
                }).toList();

                if (filteredServices.isEmpty) {
                  return const SliverToBoxAdapter(child: Center(child: Text("No services match your search")));
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            var serviceDoc = filteredServices[index];
                            var serviceData = serviceDoc.data() as Map<String, dynamic>;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ServiceCard(
                            serviceName: serviceData['serviceName'],
                            isActive: serviceData['isActive'],
                            currentTicket: serviceData['currentTicket'],
                            onBookTap: () => {context.push(
                              '${AppRoutes.businessDetails}/${AppRoutes.subServices}',
                              extra: {
                                'businessId': businessId,
                                'serviceId': serviceDoc.id,
                                'serviceName': serviceData['serviceName'],
                              },
                            )}
                          ),
                        );
                      },
                      childCount: filteredServices.length,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }



  Widget _buildTag(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_hospital_outlined, size: 14, color: AppColors.primaryColor),
          const SizedBox(width: 4),
          Text(category, style: AppTextStyles.textStyle12.copyWith(color: AppColors.primaryColor)),
        ],
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(name, style: AppTextStyles.textStyle24.copyWith(fontWeight: FontWeight.bold))),
        _buildStatusTag(),
      ],
    );
  }

  Widget _buildStatusTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text("Open Now", style: AppTextStyles.textStyle10.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRatingAndLocation(dynamic rating, String address) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text("$rating (2,341 reviews)", style: AppTextStyles.textStyle12.copyWith(color: AppColors.neutralColor5)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: AppColors.neutralColor5, size: 18),
            const SizedBox(width: 4),
            Expanded(child: Text("$address • 1.2 km away", style: AppTextStyles.textStyle12.copyWith(color: AppColors.neutralColor5))),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBox(Map<String, dynamic> business) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.access_time_rounded, "Wait Time", "${business['waitTime'] ?? '0'} min"),
          _buildDivider(),
          _buildInfoItem(Icons.medical_services_outlined, "Category", business['category']),
          _buildDivider(),
          _buildInfoItem(Icons.local_parking_rounded, "Parking", "Available"),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(width: 1, height: 40, color: Colors.grey.shade200);

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.textStyle10.copyWith(color: AppColors.neutralColor5)),
        Text(value, style: AppTextStyles.textStyle12.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
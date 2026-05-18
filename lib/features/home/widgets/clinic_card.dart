// import 'package:flutter/material.dart';
// import 'package:taborq/core/utils/app_colors.dart';
// import 'package:taborq/core/utils/app_text_styles.dart';
// import 'package:taborq/features/home/models/clinic_model.dart';
//
//
// class ClinicCard extends StatelessWidget {
//   final ClinicModel clinic;
//
//   const ClinicCard({super.key, required this.clinic});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.lightColor,
//         borderRadius: BorderRadius.circular(48),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.neutralColor.withOpacity(0.07),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Image with overlays
//           Stack(
//             children: [
//               ClipRRect(
//                 borderRadius:
//                 const BorderRadius.vertical(top: Radius.circular(48)),
//                 child: _buildImage(),
//               ),
//               // Rating badge
//               Positioned(
//                 top: 12,
//                 right: 12,
//                 child: Container(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: AppColors.lightColor,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 6,
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.star_rounded,
//                           color: Color(0xFFFFC107), size: 14),
//                       const SizedBox(width: 3),
//                       Text(
//                         clinic.rating.toString(),
//                         style: AppTextStyles.textStyle12.copyWith(
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.neutralColor1,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // High Demand badge
//               if (clinic.isHighDemand)
//                 Positioned(
//                   bottom: 12,
//                   left: 12,
//                   child: Container(
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFE53935),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Text(
//                       'HIGH DEMAND',
//                       style: AppTextStyles.textStyle11.copyWith(
//                         color: AppColors.lightColor,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           // Info row
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             clinic.name,
//                             style: AppTextStyles.textStyle16.copyWith(
//                               fontWeight: FontWeight.w700,
//                               color: AppColors.primaryColor1,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               Icon(Icons.location_on_outlined,
//                                   size: 13, color: AppColors.neutralColor5),
//                               const SizedBox(width: 2),
//                               Text(
//                                 clinic.distance,
//                                 style: AppTextStyles.textStyle13.copyWith(
//                                   color: AppColors.neutralColor5,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           'WAIT TIME',
//                           style: AppTextStyles.textStyle11.copyWith(
//                             color: AppColors.neutralColor5,
//                             letterSpacing: 0.5,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         RichText(
//                           text: TextSpan(
//                             children: [
//                               TextSpan(
//                                 text: '${clinic.waitTimeMinutes}',
//                                 style: AppTextStyles.textStyle22.copyWith(
//                                   fontWeight: FontWeight.w800,
//                                   color: clinic.waitTimeMinutes > 30
//                                       ? const Color(0xFFE53935)
//                                       : AppColors.primaryColor,
//                                 ),
//                               ),
//                               TextSpan(
//                                 text: ' min',
//                                 style: AppTextStyles.textStyle13.copyWith(
//                                   color: AppColors.neutralColor4,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 14),
//                 Center(
//                   child: SizedBox(
//                     width: 278,
//                     height: 56,
//                     child: clinic.canCheckInNow
//                         ? ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primaryColor,
//                         foregroundColor: AppColors.lightColor,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                       ),
//                       child: Text(
//                         'Check-in Now',
//                         style: AppTextStyles.textStyle16.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.lightColor,
//                         ),
//                       ),
//                     )
//                         : OutlinedButton(
//                       onPressed: () {},
//                       style: OutlinedButton.styleFrom(
//                         side: BorderSide(
//                             color: AppColors.primaryColor8, width: 1.5),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                       ),
//                       child: Text(
//                         'Pre-register',
//                         style: AppTextStyles.textStyle16.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildImage() {
//     return Image.asset(
//       clinic.image,
//       height: 224,
//       width: double.infinity,
//       fit: BoxFit.cover,
//       errorBuilder: (context, error, stackTrace) {
//         return const Icon(Icons.error);
//       },
//     );
//   }
// }
//
// /// Compact horizontal card used for the last item (e.g. Northside Pediatrics)
// class ClinicListTile extends StatelessWidget {
//   final ClinicModel clinic;
//
//   const ClinicListTile({super.key, required this.clinic});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: AppColors.lightColor,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.neutralColor.withOpacity(0.06),
//             blurRadius: 12,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Thumbnail
//           ClipRRect(
//             borderRadius: BorderRadius.circular(32),
//             child: Container(
//               width: 96,
//               height: 96,
//               color: AppColors.neutralColor9,
//               child: Image.asset(
//                 clinic.image,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return const Icon(Icons.error);
//                 },
//               ),
//               // const Icon(Icons.local_hospital_outlined,
//               //     color: AppColors.neutralColor7),
//             ),
//           ),
//           const SizedBox(width: 14),
//           // Text info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   clinic.name,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: AppTextStyles.textStyle15.copyWith(
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.primaryColor1,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Icon(Icons.location_on_outlined,
//                         size: 12, color: AppColors.neutralColor5),
//                     Flexible(
//                       child: Text(
//                         ' ${clinic.distance}',
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: AppTextStyles.textStyle12
//                             .copyWith(color: AppColors.neutralColor5),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Icon(Icons.access_time_rounded,
//                         size: 12, color: AppColors.neutralColor5),
//                     Flexible(
//                       child: Text(
//                         ' ${clinic.waitTime} min wait',
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: AppTextStyles.textStyle12
//                             .copyWith(color: AppColors.neutralColor5),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           // Arrow button
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: AppColors.primaryColor10,
//               borderRadius: BorderRadius.circular(100),
//             ),
//             child: const Icon(Icons.chevron_right_rounded,
//                 color: AppColors.primaryColor, size: 22),
//           ),
//         ],
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:taborq/core/utils/app_colors.dart';
// import 'package:taborq/core/utils/app_text_styles.dart';
// import 'package:taborq/features/home/models/clinic_model.dart';
//
// class ClinicCard extends StatelessWidget {
//   final ClinicModel clinic;
//
//   const ClinicCard({super.key, required this.clinic});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.lightColor,
//         borderRadius: BorderRadius.circular(48),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.neutralColor.withOpacity(0.07),
//             blurRadius: 16,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Stack(
//             children: [
//               ClipRRect(
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
//                 child: _buildImage(),
//               ),
//               // Rating badge
//               Positioned(
//                 top: 12,
//                 right: 12,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   decoration: BoxDecoration(
//                     color: AppColors.lightColor,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 6,
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14),
//                       const SizedBox(width: 3),
//                       Text(
//                         clinic.rating.toString(),
//                         style: AppTextStyles.textStyle12.copyWith(
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.neutralColor1,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // High Demand badge - منطق مبني على وقت الانتظار كمثال
//               if (clinic.waitTime > 30)
//                 Positioned(
//                   bottom: 12,
//                   left: 12,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFE53935),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Text(
//                       'HIGH DEMAND',
//                       style: AppTextStyles.textStyle11.copyWith(
//                         color: AppColors.lightColor,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             clinic.name,
//                             style: AppTextStyles.textStyle16.copyWith(
//                               fontWeight: FontWeight.w700,
//                               color: AppColors.primaryColor1,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               Icon(Icons.location_on_outlined, size: 13, color: AppColors.neutralColor5),
//                               const SizedBox(width: 2),
//                               Text(
//                                 clinic.address, // تم التغيير من distance لـ address بناءً على المودل
//                                 style: AppTextStyles.textStyle13.copyWith(
//                                   color: AppColors.neutralColor5,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Text(
//                           'WAIT TIME',
//                           style: AppTextStyles.textStyle11.copyWith(
//                             color: AppColors.neutralColor5,
//                             letterSpacing: 0.5,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         RichText(
//                           text: TextSpan(
//                             children: [
//                               TextSpan(
//                                 text: '${clinic.waitTime}', // تم التغيير لـ waitTime
//                                 style: AppTextStyles.textStyle22.copyWith(
//                                   fontWeight: FontWeight.w800,
//                                   color: clinic.waitTime > 30
//                                       ? const Color(0xFFE53935)
//                                       : AppColors.primaryColor,
//                                 ),
//                               ),
//                               TextSpan(
//                                 text: ' min',
//                                 style: AppTextStyles.textStyle13.copyWith(
//                                   color: AppColors.neutralColor4,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 14),
//                 Center(
//                   child: SizedBox(
//                     width: 278,
//                     height: 56,
//                     child: clinic.waitTime < 40 // مثال منطقي للتبديل بين الزرار كـ Check-in أو Pre-register
//                         ? ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primaryColor,
//                         foregroundColor: AppColors.lightColor,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                       ),
//                       child: Text(
//                         'Check-in Now',
//                         style: AppTextStyles.textStyle16.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.lightColor,
//                         ),
//                       ),
//                     )
//                         : OutlinedButton(
//                       onPressed: () {},
//                       style: OutlinedButton.styleFrom(
//                         side: BorderSide(color: AppColors.primaryColor8, width: 1.5),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(50),
//                         ),
//                       ),
//                       child: Text(
//                         'Pre-register',
//                         style: AppTextStyles.textStyle16.copyWith(
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.primaryColor,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildImage() {
//     return Image.network(
//       clinic.image, // استخدام network بدلاً من asset
//       height: 224,
//       width: double.infinity,
//       fit: BoxFit.cover,
//       errorBuilder: (context, error, stackTrace) {
//         return Container(
//           height: 224,
//           color: AppColors.neutralColor9,
//           child: const Icon(Icons.broken_image_outlined, size: 40),
//         );
//       },
//     );
//   }
// }
//
// class ClinicListTile extends StatelessWidget {
//   final ClinicModel clinic;
//
//   const ClinicListTile({super.key, required this.clinic});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: AppColors.lightColor,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.neutralColor.withOpacity(0.06),
//             blurRadius: 12,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(32),
//             child: Container(
//               width: 96,
//               height: 96,
//               color: AppColors.neutralColor9,
//               child: Image.network(
//                 clinic.image,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return const Icon(Icons.error);
//                 },
//               ),
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   clinic.name,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: AppTextStyles.textStyle15.copyWith(
//                     fontWeight: FontWeight.w700,
//                     color: AppColors.primaryColor1,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Icon(Icons.location_on_outlined, size: 12, color: AppColors.neutralColor5),
//                     Flexible(
//                       child: Text(
//                         ' ${clinic.address}',
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: AppTextStyles.textStyle12.copyWith(color: AppColors.neutralColor5),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Icon(Icons.access_time_rounded, size: 12, color: AppColors.neutralColor5),
//                     Flexible(
//                       child: Text(
//                         ' ${clinic.waitTime} min',
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: AppTextStyles.textStyle12.copyWith(color: AppColors.neutralColor5),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: AppColors.primaryColor10,
//               borderRadius: BorderRadius.circular(100),
//             ),
//             child: const Icon(Icons.chevron_right_rounded, color: AppColors.primaryColor, size: 22),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/home/models/clinic_model.dart';

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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
                child: _buildImage(),
              ),
              // Rating Badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.lightColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 16),
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
                            style: AppTextStyles.textStyle16.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded,
                                  size: 14, color: AppColors.neutralColor5),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  clinic.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.textStyle13.copyWith(
                                    color: AppColors.neutralColor5,
                                  ),
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
          onPressed: () {context.push('/home/details', extra: {
            'id': clinic.id,
            'name': clinic.name,
            'imageUrl': clinic.imageUrl,
            'address': clinic.address,
            'category': clinic.category,
            'waitTime': clinic.waitTime,
            'rating': clinic.rating,
          });},
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
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:taborq/core/utils/app_text_styles.dart';
// import 'package:taborq/features/subService_details/models/subService_model.dart';
//
// class SubServiceCard extends StatelessWidget {
//   final SubServiceModel item;
//   const SubServiceCard({required this.item});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
//       ),
//       child: Row(
//         children: [
//           // Icon or Image
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(color: const Color(0xFF42706B), borderRadius: BorderRadius.circular(12)),
//             child: const Icon(Icons.medical_services_outlined, color: Colors.white),
//           ),
//           const SizedBox(width: 16),
//           // Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(item.name, style: AppTextStyles.textStyle16.copyWith(fontWeight: FontWeight.bold)),
//                 Text(item.subtitle, style: AppTextStyles.textStyle12.copyWith(color: Colors.grey)),
//               ],
//             ),
//           ),
//           // Status and Button
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(item.status, style: TextStyle(color: item.status.contains('Available') ? Colors.green : Colors.orange, fontSize: 10)),
//               const SizedBox(height: 8),
//               ElevatedButton(
//                 onPressed: () {
//                   // هنا نفتح عملية الحجز النهائية (Booking Operation)
//                   _startBookingOperation(context, item);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF42706B),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 child: const Text("Book Now", style: TextStyle(fontSize: 12, color: Colors.white)),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
//
//   void _startBookingOperation(BuildContext context, SubServiceModel item) {
//     // فتح الـ Bottom Sheet أو صفحة تأكيد الحجز النهائية
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => const Center(child: Text("Final Booking Operation Here")),
//     );
//   }
// }
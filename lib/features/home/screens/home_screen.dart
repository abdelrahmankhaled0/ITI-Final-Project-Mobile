import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/features/home/cubit/home_cubit.dart';
import 'package:taborq/features/home/cubit/home_state.dart';
import 'package:taborq/features/home/widgets/%20search_bar_widget.dart';
import 'package:taborq/features/home/widgets/category_chips.dart';
import 'package:taborq/features/home/widgets/clinic_card.dart';
import 'package:taborq/features/home/widgets/hospital_status_card.dart';
import 'package:taborq/features/home/widgets/section_header.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // final clinics = DummyData.nearbyClinics;
//
//     return Scaffold(
//       backgroundColor: AppColors.lightColor,
//       body: SafeArea(
//         child: CustomScrollView(
//           slivers: [
//             // ── App Bar ──────────────────────────────────────────────
//             SliverAppBar(
//               backgroundColor: AppColors.lightColor,
//               surfaceTintColor: Colors.transparent,
//               floating: true,
//               automaticallyImplyLeading: false,
//               snap: true,
//               elevation: 0,
//               titleSpacing: 20,
//               title: Row(
//                 children: [
//                   const Icon(
//                     Icons.arrow_back_ios_new_rounded,
//                     color: AppColors.primaryColor,
//                     size: 18,
//                   ),
//                   const SizedBox(width: 4),
//                   RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text: 'Serene\n',
//                           style: AppTextStyles.textStyle16.copyWith(
//                             color: AppColors.primaryColor,
//                             fontWeight: FontWeight.w700,
//                             height: 1.2,
//                           ),
//                         ),
//                         TextSpan(
//                           text: 'Concierge',
//                           style: AppTextStyles.textStyle16.copyWith(
//                             color: AppColors.primaryColor,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               actions: [
//                 Padding(
//                   padding: const EdgeInsets.only(right: 20),
//                   child: Icon(
//                     Icons.search_rounded,
//                     color: AppColors.primaryColor,
//                     size: 24,
//                   ),
//                 ),
//               ],
//             ),
//
//             // ── Body ─────────────────────────────────────────────────
//             SliverPadding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               sliver: SliverList(
//                 delegate: SliverChildListDelegate([
//                   const SizedBox(height: 8),
//
//                   // Welcome / headline
//                   Text(
//                     'WELCOME BACK',
//                     style: AppTextStyles.textStyle12.copyWith(
//                       color: AppColors.neutralColor4,
//                       letterSpacing: 1.2,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text: 'Find your care\n',
//                           style: AppTextStyles.textStyle28.copyWith(
//                             color: AppColors.primaryColor1,
//                             fontWeight: FontWeight.w800,
//                             height: 1.25,
//                           ),
//                         ),
//                         TextSpan(
//                           text: 'without the wait.',
//                           style: AppTextStyles.textStyle28.copyWith(
//                             color: AppColors.primaryColor,
//                             fontWeight: FontWeight.w800,
//                             fontStyle: FontStyle.italic,
//                             height: 1.25,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 20),
//
//                   // Search bar
//                   const SearchBarWidget(),
//
//                   const SizedBox(height: 16),
//
//                   // Category chips
//                   const CategoryChips(),
//
//                   const SizedBox(height: 20),
//
//                   // Hospital live status card
//                   HospitalStatusCard(
//                     hospitalName: DummyData.hospitalName,
//                     queueNumber: DummyData.hospitalQueue,
//                     waitMinutes: DummyData.hospitalWaitMinutes,
//                     queueProgress: DummyData.hospitalQueueProgress,
//                   ),
//
//                   const SizedBox(height: 28),
//
//                   // Nearby clinics header
//                   SectionHeader(
//                     title: 'Nearby Clinics',
//                     actionLabel: 'View Map',
//                     onAction: () {},
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   // Large clinic cards (first 2)
//                   ...clinics
//                       .take(2)
//                       .map(
//                         (clinic) => Padding(
//                           padding: const EdgeInsets.only(bottom: 16),
//                           child: ClinicCard(clinic: clinic),
//                         ),
//                       ),
//
//                   // List tile for remaining clinics
//                   ...clinics
//                       .skip(2)
//                       .map(
//                         (clinic) => Padding(
//                           padding: const EdgeInsets.only(bottom: 12),
//                           child: ClinicListTile(clinic: clinic),
//                         ),
//                       ),
//
//                   const SizedBox(height: 16),
//                 ]),
//               ),
//             ),
//           ],
//         ),
//       ),
//
//       // FAB
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {},
//         backgroundColor: AppColors.primaryColor,
//         elevation: 4,
//         shape: const CircleBorder(),
//         child: const Icon(
//           Icons.add_rounded,
//           color: AppColors.lightColor,
//           size: 28,
//         ),
//       ),
//     );
//   }
// }

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SearchBarWidget(
                    onChanged: (value) {
                      context.read<HomeCubit>().searchClinics(value);
                    },
                  ),

                  const SizedBox(height: 16),
                  const CategoryChips(),
                  const SizedBox(height: 20),

                  HospitalStatusCard(
                    hospitalName: "Main Hospital",
                    queueNumber: 12,
                    waitMinutes: 45,
                    queueProgress: 0.6,
                  ),

                  const SizedBox(height: 28),
                  SectionHeader(
                    title: 'Nearby Clinics',
                    actionLabel: 'View Map',
                  ),
                  const SizedBox(height: 16),

                  BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is HomeSuccess) {
                        if (state.clinics.isEmpty) {
                          return const Center(child: Text("No clinics found"));
                        }

                        return Column(
                          children: [
                            ...state.clinics
                                .take(2)
                                .map(
                                  (clinic) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: ClinicCard(clinic: clinic),
                                  ),
                                ),

                            // ...state.clinics.skip(2).map((clinic) => Padding(
                            //   padding: const EdgeInsets.only(bottom: 12),
                            //   child: ClinicListTile(clinic: clinic),
                            // )),
                          ],
                        );
                      } else if (state is HomeError) {
                        return Center(child: Text(state.message));
                      }
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

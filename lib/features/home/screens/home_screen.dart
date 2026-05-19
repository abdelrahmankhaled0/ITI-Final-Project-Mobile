import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/core/utils/app_text_styles.dart';
import 'package:taborq/features/home/cubit/home_cubit.dart';
import 'package:taborq/features/home/cubit/home_state.dart';
import 'package:taborq/features/home/widgets/%20search_bar_widget.dart';
import 'package:taborq/features/home/widgets/category_chips.dart';
import 'package:taborq/features/home/widgets/clinic_card.dart';
import 'package:taborq/features/home/widgets/home_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.lightColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String name = user?.displayName?.trim().isNotEmpty == true
              ? user!.displayName!
              : "User";
          String? image;

          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            name = data['name'] ?? name;
            image = data['imageUrl'];
          }

          return CustomScrollView(
            slivers: [
              // 1. AppBar
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.primaryColor,
                automaticallyImplyLeading: false,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(48),
                  ),
                ),
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    var top = constraints.biggest.height;
                    bool isCollapsed =
                        top <=
                        (kToolbarHeight +
                            MediaQuery.of(context).padding.top +
                            20);

                    return FlexibleSpaceBar(
                      centerTitle: false,
                      titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
                      title: isCollapsed
                          ? Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primaryColor5,
                                  radius: 18,
                                  backgroundImage: image != null
                                      ? NetworkImage(image)
                                      : null,
                                  child: image == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 18,
                                          color: AppColors.lightColor,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  name,
                                  style: AppTextStyles.textStyle16.copyWith(
                                    color: AppColors.lightColor,
                                  ),
                                ),
                                const Spacer(),
                                const Padding(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Icon(
                                    Icons.notifications_none_rounded,
                                    color: AppColors.lightColor,
                                  ),
                                ),
                              ],
                            )
                          : null,
                      background: HomeHeader(
                        userName: name,
                        profileImage: image,
                      ),
                    );
                  },
                ),
              ),

              // 2. Search Bar
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: SearchBarWidget(
                    onChanged: (value) =>
                        context.read<HomeCubit>().searchClinics(value),
                  ),
                ),
              ),

              // 3. Bloc Logic for Categories & List
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeSuccess) {
                    return SliverMainAxisGroup(
                      slivers: [
                        // Categories
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            child: CategoryChips(
                              categories: state.categories,
                              selectedCategory: context
                                  .read<HomeCubit>()
                                  .currentCategory,
                            ),
                          ),
                        ),
                        // Title "Near you"
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Text(
                                  "Near you",
                                  style: TextStyle(
                                    color: AppColors.darkColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.location_on_outlined,
                                    color: AppColors.neutralColor5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
                          sliver: SliverList.builder(
                            itemCount: state.clinics.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ClinicCard(clinic: state.clinics[index]),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  // Loading State
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

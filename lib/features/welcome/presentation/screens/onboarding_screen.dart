import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:taborq/core/routes/navigations.dart';
import 'package:taborq/core/routes/routes.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/features/welcome/data/models/onboarding_model.dart';
import 'package:taborq/features/welcome/presentation/cubit/welcome_cubit.dart';
import 'package:taborq/features/welcome/presentation/cubit/welcome_states.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;
  final pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WelcomeCubit, WelcomeStates>(
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Spacer(),
                      TextButton(
                        style: TextButton.styleFrom(),
                        onPressed: () {
                          AppNavigations.pushReplacementTo(
                            context,
                            AppRoutes.login,
                          );
                        },
                        child: Text(
                          "Skip",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                    ],
                  ),
                  Gap(10),
                  Expanded(
                    flex: 3,
                    child: PageView.builder(
                      physics: const BouncingScrollPhysics(),
                      controller: pageController,
                      itemCount: onboardingModel.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        var item = onboardingModel[index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image(image: AssetImage(item.imageURL)),
                              ),
                            ),
                            const Gap(20),
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(color:AppColors.primaryColor ),
                            ),
                            const Gap(10),
                            Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const Gap(30),

                  SmoothPageIndicator(
                    effect: WormEffect(
                      dotWidth: 20,
                      dotHeight: 5,
                      activeDotColor: AppColors.primaryColor,
                    ),
                    controller: pageController,
                    count: onboardingModel.length,
                  ),

                  const Gap(40),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(400, 50),
                    ),
                    onPressed: () {
                      if (state is WelcomeLoadingState) return;

                      if (currentIndex == onboardingModel.length - 1) {
                        AppNavigations.pushReplacementTo(
                          context,
                          AppRoutes.login,
                        );
                      } else {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: ConditionalBuilder(
                      condition: state is WelcomeLoadingState,
                      builder: (context) {
                        return SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        );
                      },
                      fallback: (context) {
                        return Text(
                          currentIndex == onboardingModel.length - 1
                              ? "Get Started"
                              : "Next",
                        );
                      },
                    ),
                  ),
                  const Gap(20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

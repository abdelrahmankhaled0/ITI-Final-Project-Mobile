import 'package:flutter/material.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:taborq/core/routes/navigations.dart';
import 'package:taborq/core/routes/routes.dart';
import 'package:taborq/core/utils/app_colors.dart';
import 'package:taborq/features/welcome/data/models/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

int currentIndex = 0;
var pageController = PageController();

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightColor,
      appBar: AppBar(
        backgroundColor: AppColors.lightColor,
        actions: [
          TextButton(
            onPressed: () {
              AppNavigations.pushReplacementTo(context, AppRoutes.login);
            },
            child: Text(
              "Skip",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.darkColor,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                
                physics: BouncingScrollPhysics(),
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
                    children: [
                      Image(
                        image: AssetImage(item.imageURL),
                        // width: 300,
                        // height: 300,
                        fit: BoxFit.cover,
                      ),
                      Gap(10),
                      Text(
                        item.title,
                        style: TextStyle(
                          color: AppColors.primaryColor3,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      Text(
                        textAlign: TextAlign.center,
                        item.description,
                        style: TextStyle(
                          color: AppColors.darkColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Gap(20),
                      SmoothPageIndicator(
                        effect: WormEffect(
                          dotWidth: 20,
                          dotHeight: 5,
                          activeDotColor: AppColors.primaryColor,
                        ),
                        controller: pageController,
                        count: onboardingModel.length,
                      ),
                      Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(
                            MediaQuery.widthOf(context) * 0.8,
                            40,
                          ),
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: AppColors.lightColor,
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          currentIndex == onboardingModel.length - 1
                              ? AppNavigations.pushReplacementTo(
                                  context,
                                  AppRoutes.login,
                                )
                              : pageController.nextPage(
                                  duration: Duration(seconds: 1),
                                  curve: Curves.ease,
                                );
                        },
                        child: currentIndex == onboardingModel.length - 1
                            ? Text("Get Started", style: TextStyle())
                            : Text("Next"),
                      ),
                    ],
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

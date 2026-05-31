import 'package:taborq/core/utils/app_images.dart';

class OnboardingModel {
  OnboardingModel({
    required this.imageURL,
    required this.title,
    required this.description,
  });
  final String imageURL;
  final String title;
  final String description;
}

List<OnboardingModel> onboardingModel = [
  OnboardingModel(
    imageURL: AppImages.onboarding1,
    title: "No More Long Queues",
    description: "Save time by booking your turn directly from your phone.",
  ),
  OnboardingModel(
    imageURL: AppImages.onboarding2,
    title: "Track Your Turn Live",
    description:
        "Stay updated with live queue status and estimated waiting time.",
  ),
  OnboardingModel(
    imageURL: AppImages.onboarding3,
    title: "Smart Reminders",
    description: "We’ll notify you when it’s almost your turn to arrive.",
  ),
];

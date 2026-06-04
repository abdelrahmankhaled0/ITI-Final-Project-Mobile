import 'package:taborq/features/home/data/models/clinic_model.dart';


abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<ClinicModel> clinics;
  final List<String> categories;
  HomeSuccess({required this.clinics , required this.categories});
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
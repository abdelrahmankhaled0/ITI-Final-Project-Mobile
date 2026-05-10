import 'package:taborq/features/home/models/clinic_model.dart';


abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<ClinicModel> clinics;
  HomeSuccess({required this.clinics});
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
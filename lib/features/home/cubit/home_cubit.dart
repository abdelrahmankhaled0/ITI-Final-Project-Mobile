import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/features/home/cubit/home_state.dart';
import 'package:taborq/features/home/models/clinic_model.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  List<ClinicModel> _allClinics = [];
  String _currentQuery = "";
  String _currentCategory = "All Care";

  String get currentCategory => _currentCategory;

  void getClinics() {
    emit(HomeLoading());
    FirebaseFirestore.instance.collection('businesses').snapshots().listen((event) {
      _allClinics = event.docs
          .map((doc) => ClinicModel.fromFirestore(doc.data(), doc.id))
          .toList();
      _applyFilter();
    }).onError((error) {
      emit(HomeError(error.toString()));
    });
  }

  void _applyFilter() {
    // استخراج التصنيفات مع التأكد أنها ليست null
    List<String> dynamicCategories = ['All Care'];
    final uniqueCategories = _allClinics
        .map((e) => e.category)
        .where((cat) => cat.isNotEmpty) // التأكد من أن التصنيف ليس فارغاً
        .toSet()
        .toList();

    dynamicCategories.addAll(uniqueCategories);

    List<ClinicModel> filtered = _allClinics;

    // فلترة بالتصنيف
    if (_currentCategory != "All Care") {
      filtered = filtered.where((clinic) =>
      clinic.category.toLowerCase() == _currentCategory.toLowerCase()).toList();
    }

    // فلترة بالبحث
    if (_currentQuery.isNotEmpty) {
      filtered = filtered.where((clinic) =>
      clinic.name.toLowerCase().contains(_currentQuery.toLowerCase()) ||
          clinic.address.toLowerCase().contains(_currentQuery.toLowerCase())).toList();
    }

    // القوة هنا: نرسل دائماً القائمتين حتى لو فارغتين، المهم ليس null
    emit(HomeSuccess(
      clinics: List.from(filtered),
      categories: List.from(dynamicCategories),
    ));
  }

  void searchClinics(String query) {
    _currentQuery = query;
    _applyFilter();
  }

  void filterByCategory(String category) {
    _currentCategory = category;
    _applyFilter();
  }
}
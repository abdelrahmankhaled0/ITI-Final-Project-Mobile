import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/features/home/presentation/cubit/home_state.dart';
import 'package:taborq/features/home/data/models/clinic_model.dart';

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
      // 👈 تمت إضافة الفلترة هنا لاستبعاد الاشتراكات المنتهية فوراً
          .where((clinic) => clinic.subscriptionStatus.toLowerCase() != 'expired')
          .toList();

      _applyFilter();
    }).onError((error) {
      emit(HomeError(error.toString()));
    });
  }

  void _applyFilter() {
    List<String> dynamicCategories = ['All Care'];

    final uniqueCategories = _allClinics
        .map((e) => e.category)
        .where((cat) => cat.isNotEmpty)
        .toSet()
        .toList();

    dynamicCategories.addAll(uniqueCategories);

    List<ClinicModel> filtered = _allClinics;

    if (_currentCategory != "All Care") {
      filtered = filtered.where((clinic) =>
      clinic.category.toLowerCase() == _currentCategory.toLowerCase()).toList();
    }

    if (_currentQuery.isNotEmpty) {
      filtered = filtered.where((clinic) =>
      clinic.name.toLowerCase().contains(_currentQuery.toLowerCase()) ||
          clinic.address.toLowerCase().contains(_currentQuery.toLowerCase())).toList();
    }

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
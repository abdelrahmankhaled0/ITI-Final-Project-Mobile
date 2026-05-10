import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/features/home/cubit/home_state.dart';
import 'package:taborq/features/home/models/clinic_model.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  List<ClinicModel> _allClinics = [];

  void getClinics() {
    emit(HomeLoading());
    FirebaseFirestore.instance.collection('hospitals').snapshots().listen((event) {
      _allClinics = event.docs.map((doc) => ClinicModel.fromFirestore(doc.data(), doc.id)).toList();
      emit(HomeSuccess(clinics: _allClinics));
    }).onError((error) {
      emit(HomeError(error.toString()));
    });
  }

  void searchClinics(String query) {
    if (query.isEmpty) {
      emit(HomeSuccess(clinics: _allClinics));
    } else {
      final filtered = _allClinics.where((clinic) {
        return clinic.name.toLowerCase().contains(query.toLowerCase()) ||
            clinic.address.toLowerCase().contains(query.toLowerCase());
      }).toList();
      emit(HomeSuccess(clinics: filtered));
    }
  }
}
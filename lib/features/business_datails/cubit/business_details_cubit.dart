import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/features/subService_details/models/subService_model.dart';
import 'business_details_state.dart';

class BusinessDetailsCubit extends Cubit<BusinessDetailsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BusinessDetailsCubit() : super(BusinessDetailsInitial());

  void updateSearchQuery(String query) {
    emit(BusinessDetailsInitial(searchQuery: query));
  }


  Stream<DocumentSnapshot<Map<String, dynamic>>> getServiceDetails(String businessId, String serviceId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('services')
        .doc(serviceId)
        .snapshots();
  }


  Stream<List<ServiceModel>> getSubServices(String businessId, String serviceId) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('services')
        .doc(serviceId)
        .collection('subServices')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ServiceModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  void bookTicket(String serviceId) {
    // Logic for booking
  }
}
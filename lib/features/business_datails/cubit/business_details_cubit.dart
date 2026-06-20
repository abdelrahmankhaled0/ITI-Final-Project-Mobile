import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/features/booking/data/models/ticket_model.dart';
import 'business_details_state.dart';

class BusinessDetailsCubit extends Cubit<BusinessDetailsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _businessSubscription;

  BusinessDetailsCubit() : super(BusinessDetailsInitial());

  void updateSearchQuery(String query) {
    emit(BusinessDetailsInitial(searchQuery: query));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getServiceDetails(
    String businessId,
    String serviceId,
  ) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('services')
        .doc(serviceId)
        .snapshots();
  }

  Stream<List<TicketModel>> getSubServices(
    String businessId,
    String serviceId,
  ) {
    return _firestore
        .collection('businesses')
        .doc(businessId)
        .collection('services')
        .doc(serviceId)
        .collection('subServices')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TicketModel.fromFirestore(doc.data()))
              .toList(),
        );
  }

  void bookTicket(String serviceId) {
    // Logic for booking
  }

  /// Start listening to the parent business document to obtain live location data.
  void listenToBusiness(String businessId) {
    // cancel previous subscription if any
    _businessSubscription?.cancel();
    emit(BusinessDetailsLoading());

    _businessSubscription = _firestore
        .collection('businesses')
        .doc(businessId)
        .snapshots()
        .listen(
          (doc) {
            final data = doc.data() ?? <String, dynamic>{};

            // Safe extraction of nested `location` map
            double? lat;
            double? lng;
            final location = data['location'];
            if (location is Map<String, dynamic>) {
              final dynamic latRaw = location['lat'];
              final dynamic lngRaw = location['lng'];

              if (latRaw is num) lat = latRaw.toDouble();
              if (lngRaw is num) lng = lngRaw.toDouble();

              if (lat == null) {
                lat = double.tryParse(latRaw?.toString() ?? '');
              }
              if (lng == null) {
                lng = double.tryParse(lngRaw?.toString() ?? '');
              }
            }

            emit(
              BusinessDetailsLoaded(
                business: data,
                latitude: lat,
                longitude: lng,
              ),
            );
          },
          onError: (error) {
            emit(BusinessDetailsError(error.toString()));
          },
        );
  }

  @override
  Future<void> close() {
    _businessSubscription?.cancel();
    return super.close();
  }
}

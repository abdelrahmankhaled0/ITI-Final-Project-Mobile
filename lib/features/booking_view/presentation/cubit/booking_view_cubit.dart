import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/booking_view_model.dart';
import '../../../../core/services/remote/firebase_services.dart';
import 'booking_view_states.dart';

class BookingViewCubit extends Cubit<BookingViewStates> {
  BookingViewCubit() : super(BookingViewInitialState());

  static BookingViewCubit get(context) => BlocProvider.of(context);

  List<BookingViewModel> tickets = [];

  Future<void> getTicketsByUserId() async {
    emit(BookingViewLoadingState());

    try {
      final snapshot = await FirebaseServices.getTicketsByUserId();

      tickets = snapshot.docs
          .map((doc) => BookingViewModel.fromJson(doc.data()))
          .toList();

      emit(BookingViewSuccessState(tickets));
    } catch (e) {
      emit(BookingViewErrorState(e.toString()));
    }
  }

  deleteTicketById(BookingViewModel ticket) async {
    try {
      emit(BookingViewLoadingState());
      await FirebaseServices.deleteQueueById(
        ticketId: ticket.ticId,
        queuesId: ticket.businessId,
        servicesId: ticket.serviceId,
      );
      tickets.removeWhere((item) => item.ticId == ticket.ticId);
      emit(BookingViewSuccessState(tickets));
    } on Exception catch (e) {
      emit(BookingViewErrorState(e.toString()));
    }
  }
}

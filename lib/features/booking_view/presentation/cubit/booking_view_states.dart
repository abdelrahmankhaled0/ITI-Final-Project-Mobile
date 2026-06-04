// import 'package:taborq/features/booking_view/data/models/booking_view_model.dart';

// class BookingViewStates {}

// class BookingViewInitialState extends BookingViewStates {}

// class BookingViewLoadingState extends BookingViewStates {}

// class BookingViewSuccessState extends BookingViewStates {
//   final List<BookingViewModel> tickets;

//   BookingViewSuccessState(this.tickets);
// }

// class BookingViewErrorState extends BookingViewStates {
//   final String error;

//   BookingViewErrorState(this.error);
// }

import '../../data/models/booking_view_model.dart';

abstract class BookingViewStates {}

class BookingViewInitialState extends BookingViewStates {}

class BookingViewLoadingState extends BookingViewStates {}

class BookingViewSuccessState extends BookingViewStates {
  final List<BookingViewModel> tickets;

  BookingViewSuccessState(this.tickets);
}

class BookingViewErrorState extends BookingViewStates {
  final String errorMessage;

  BookingViewErrorState(this.errorMessage);
}

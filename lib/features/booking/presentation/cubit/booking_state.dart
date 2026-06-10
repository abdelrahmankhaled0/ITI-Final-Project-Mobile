abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final int ticketCode;
  final bool
  isAlreadyBooked; // true لو كان حاجز قبل كده، false لو حجز جديد فعلياً

  BookingSuccess({required this.ticketCode, required this.isAlreadyBooked});
}

class BookingFailure extends BookingState {
  final String errorMessage;

  BookingFailure({required this.errorMessage});
}

class BookingQueueCompleted extends BookingState {}

class BookingQueueUpdated extends BookingState {
  BookingQueueUpdated({
    required this.currentlyInService,
    required this.peopleAhead,
    required this.estimatedWaitingTime,
  });
  final int currentlyInService;
  final int peopleAhead;
  final int estimatedWaitingTime;
}

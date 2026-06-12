abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingAlreadyBookedState extends BookingState {
  final int ticketCode;
  final String businessName;
  final String serviceName;
  final int avgServiceTime;

  BookingAlreadyBookedState({
    required this.ticketCode,
    required this.businessName,
    required this.serviceName,
    required this.avgServiceTime,
  });
}

class BookingSuccess extends BookingState {
  final int ticketCode;
  final bool
  isAlreadyBooked; // true لو كان حاجز قبل كده، false لو حجز جديد فعلياً
  final String businessName;
  final String serviceName;
  final int avgServiceTime;

  BookingSuccess({
    required this.ticketCode,
    required this.isAlreadyBooked,
    required this.businessName,
    required this.serviceName,
    required this.avgServiceTime,
  });
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

abstract class BusinessDetailsState {}

class BusinessDetailsInitial extends BusinessDetailsState {
  final String searchQuery;
  BusinessDetailsInitial({this.searchQuery = ""});
}

class BusinessDetailsLoading extends BusinessDetailsState {}

class BusinessDetailsLoaded extends BusinessDetailsState {
  final Map<String, dynamic> business;
  final double? latitude;
  final double? longitude;

  BusinessDetailsLoaded({
    required this.business,
    this.latitude,
    this.longitude,
  });
}

class BusinessDetailsError extends BusinessDetailsState {
  final String message;
  BusinessDetailsError(this.message);
}

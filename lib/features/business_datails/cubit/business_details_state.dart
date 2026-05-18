abstract class BusinessDetailsState {}

class BusinessDetailsInitial extends BusinessDetailsState {
  final String searchQuery;
  BusinessDetailsInitial({this.searchQuery = ""});
}

class BusinessDetailsLoading extends BusinessDetailsState {}


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taborq/features/welcome/presentation/cubit/welcome_states.dart';

class WelcomeCubit extends Cubit<WelcomeStates> {
  WelcomeCubit() : super(WelcomeInitialState());
  
}

import 'package:admin/blocs/auth/auth_event.dart';
import 'package:admin/blocs/auth/auth_state.dart';
import 'package:admin/repositories/local_auth_repository.dart';
import 'package:admin/repositories/local_order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  static const String validPhone = '0671071613'; // Example valid phone number
  final LocalAuthRepository? authRepository;

  LoginBloc({
    this.authRepository,
  }) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<FetchCustomers>(_onFetchCustomers);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      // Simulate network delay
      await Future.delayed(Duration(seconds: 1));

      if (event.phone != validPhone) {
        emit(LoginError('Invalid phone number'));
        return;
      }

      if (event.name.isEmpty) {
        emit(LoginError('Name cannot be empty'));
        return;
      }

      final user = await authRepository!.getUserByPhone(event.phone);

      emit(LoginSuccess());
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }

  Future _onFetchCustomers(
    FetchCustomers event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final customers = await authRepository!.fetchCustomers();
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}

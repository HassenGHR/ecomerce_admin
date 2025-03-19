import 'package:admin/models/user_model.dart';

abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

class CustomersLoaded extends LoginState {
  final List<UserModel> customers;
  CustomersLoaded(this.customers);
}

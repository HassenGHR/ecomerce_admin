abstract class LoginEvent {
  const LoginEvent();
}

class LoginSubmitted extends LoginEvent {
  final String name;
  final String phone;
  LoginSubmitted(this.name, this.phone);
}

class FetchCustomers extends LoginEvent {}

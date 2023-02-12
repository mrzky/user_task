part of 'user_bloc.dart';

@immutable
abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> initialData;
  final List<User> data;
  UserLoaded(this.initialData, this.data);
}

class UserSearchInitialData extends UserState {
  final List<User> data;
  UserSearchInitialData(this.data);
}

class UserTodosLoaded extends UserState {
  final List<Todos> data;

  UserTodosLoaded(this.data);
}

class UserError extends UserState {}

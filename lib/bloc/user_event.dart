part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class GetUsers extends UserEvent {}

class SaveUser extends UserEvent {
  final String name;
  final String email; 

  SaveUser(this.name, this.email);
}

class GetUserTodos extends UserEvent {
  final int userId;

  GetUserTodos(this.userId);
}

class SortUsers extends UserEvent {
  final List<User> initialData;
  final List<User> users;
  SortUsers(this.initialData, this.users);
}

class DeleteUser extends UserEvent {
  final List<User> initialData;
  final List<User> users;
  final User user;
  DeleteUser(this.initialData, this.users, this.user);
}

class SearchUser extends UserEvent {
  final List<User> initialData;
  final List<User> users;
  final String query;
  SearchUser(this.initialData, this.users, this.query);
}
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:user_task/data/models/user_model.dart';
import 'package:user_task/data/models/todos_model.dart';
import 'package:user_task/data/repositories/user_repo.dart';

import '../data/models/user_model.dart';
import '../data/services/api_service.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  // late List<User> data;
  // final UserRepo userRepo;

  UserBloc() : super(UserInitial()) {
    on<UserEvent>((event, emit) async {
      // get users event
      if (event is GetUsers) {
        emit(UserLoading());
        final data = await APIClient().get(UserRepo.getAll());
        emit(UserLoaded(data, data));
        // emit(UserSearchInitialData(data));
      }

      // get user todos
      if (event is GetUserTodos) {
        emit(UserLoading());
        final data = await APIClient().get(UserRepo.getTodos(event.userId));
        emit(UserTodosLoaded(data));
      }

      if (event is SortUsers) {
        final data = event.users
          ..sort(
              (a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
        emit(UserLoaded(event.initialData, data));
      }

      if (event is EditUser) {
        emit(UserLoading());
        var body = {
          'name': event.name,
          'email': event.email,
        };
        final succeed =
            await APIClient().put(UserRepo.updateUser(event.userId, body));
        if (succeed) {
          var index = event.initialData
              .indexWhere((element) => element.id == event.userId);
          event.initialData[index].name = event.name;
          event.initialData[index].email = event.email;
          emit(UserLoaded(event.initialData, event.initialData));
        } else {
          UserError();
        }
        // emit(UserSearchInitialData(data));
      }

      if (event is DeleteUser) {
        emit(UserLoading());
        final succeed =
            await APIClient().delete(UserRepo.deleteUser(event.user.id ?? 0));
        if (succeed) {
          event.users.remove(event.user);
          event.initialData.remove(event.user);
          emit(UserLoaded(event.initialData, event.users));
        } else {
          UserError();
        }
      }

      if (event is SearchUser) {
        if (event.query.isEmpty) {
          emit(UserLoaded(event.initialData, event.initialData));
          return;
        }
        final data = event.initialData
            .where((item) =>
                item.name!.toLowerCase().contains(event.query.toLowerCase()))
            .toList();
        emit(UserLoaded(event.initialData, data));
      }
    });
  }
}

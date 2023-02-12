import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_task/bloc/user_bloc.dart';
import 'package:user_task/data/models/todos_model.dart';
import 'package:user_task/data/models/user_model.dart';

import 'components/error_view.dart';
import 'components/loading_view.dart';
import 'components/no_data_view.dart';

class UserDetail extends StatefulWidget {
  const UserDetail({super.key, required this.user});

  final User user;

  @override
  State<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends State<UserDetail> {

  @override
  Widget build(BuildContext context) {

    return scaffoldView();
  }
  
  Widget scaffoldView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail User"),
      ),
      body: renderUserData(),
    );
  }

  Widget renderUserData() {
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(children: [
              const Text("Name: "),
              Text(widget.user.name ?? "")
            ]),
             Row(children: [
              const Text("Username: "),
              Text(widget.user.username ?? "")
            ]),
             Row(children: [
              const Text("Email: "),
              Text(widget.user.email ?? "")
            ]),
             Row(children: [
              const Text("Address: "),
              Text("${widget.user.address?.street ?? ""}, ${widget.user.address?.suite ?? ""}, ${widget.user.address?.city ?? ""}"),
            ]),
            renderTodos()
          ],
        ),
      ),
    );
  }

  Widget renderTodos() {
    return BlocProvider<UserBloc>(
      create: (context) => UserBloc()..add(GetUserTodos(widget.user.id ?? 0)),
      child: renderListTodos(),
    );
  }

  Widget renderListTodos() {
    return BlocConsumer<UserBloc, UserState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is UserTodosLoaded) {
              return renderListView(state.data);
            }

            if (state is UserLoading) {
              return const LoadingView();
            }

            if (state is UserError) {
              return const ErrorView();
            }

            return const NoDataView();
          },
        );
  }

  Widget renderListView(List<Todos> todos) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: todos.length,
      itemBuilder: (BuildContext context, int index) {
        return Material(
          child: ListTile(
            title: Text(
              todos[index].title ?? "",
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: Row(children: [
              if (todos[index].completed ?? false)...[
                const Text("Task Completed", style: TextStyle(color: Colors.green),),
               ] else ...[
                const Text("Task Not Completed", style: TextStyle(color: Colors.red),),
               ]
            ],),
            trailing: Column(children: [
              if (todos[index].completed ?? false)...[
                const Icon(Icons.check, color: Colors.green,),
               ] else ...[
                const Icon(Icons.close, color: Colors.red,),
               ]
            ],)
          ),
        );
      },
    );
  }
}
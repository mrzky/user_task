import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:user_task/views/user_detail.dart';

import '../bloc/user_bloc.dart';
import '../data/models/user_model.dart';
import 'components/error_view.dart';
import 'components/loading_view.dart';
import 'components/no_data_view.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {

  TextEditingController editingController = TextEditingController();

  List<User> userList = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("User Task"),
            actions: [
              IconButton(
                onPressed: () {
                  if (state is UserLoaded) {
                    BlocProvider.of<UserBloc>(context)
                        .add(SortUsers(state.initialData, state.data));
                    debugPrint("sort");
                  }
                },
                icon: const Icon(Icons.sort),
              ),
            ],
          ),
          body: renderBody(state),
        );
      },
    );
  }

  Widget renderBody(UserState state) {


    if (state is UserLoaded) {
      return renderMainView(state.initialData, state.data);
    }

    if (state is UserLoading) {
      return const LoadingView();
    }

    if (state is UserError) {
      return const ErrorView();
    }

    return const NoDataView();
  }

  Widget renderMainView(List<User> initialData, List<User> users) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              BlocProvider.of<UserBloc>(context).add(SearchUser(initialData, userList, value));
            },
            controller: editingController,
            decoration: const InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)))),
          ),
        ),
        Expanded(child: renderListView(initialData, users))
      ],
    );
  }

  Widget renderListView(List<User> initialData, List<User> users) {
    return RefreshIndicator(
      onRefresh: () { 
        return Future.delayed(const Duration(seconds: 0), () {
          BlocProvider.of<UserBloc>(context).add(GetUsers());
        });
      },
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (BuildContext context, int index) {
          return Slidable(
            key: ValueKey(index),
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (sideableContext) {
                    deleteDialog(context, initialData, users, users[index], index);
                    debugPrint('delete');
                  },
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
                SlidableAction(
                  onPressed: (context) {
                    debugPrint('edit');
                  },
                  backgroundColor: const Color(0xFF21B7CA),
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  label: 'Edit',
                ),
              ],
            ),
            child: ListTile(
              leading: const Icon(
                Icons.person,
                color: Colors.cyan,
                size: 45,
              ),
              title: Text(
                users[index].name ?? "",
                style: const TextStyle(fontSize: 20),
              ),
              subtitle: Text(
                users[index].email ?? "",
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserDetail(user: users[index])));
              },
            ),
          );
        },
      ),
    );
  }

  void deleteDialog(
      BuildContext context, List<User> initialData, List<User> users, User user, int index) {
    showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("Are you sure?"),
            content: Text("Delete '${user.name ?? ""}'?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    BlocProvider.of<UserBloc>(context)
                        .add(DeleteUser(initialData, users, index));
                  },
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ))
            ],
          );
        });
  }
}

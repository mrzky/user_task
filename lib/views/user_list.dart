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
  final editingController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  int userId = 0;

  List<User> userList = [];

  @override
  void dispose() {
    editingController.dispose();
    super.dispose();
  }

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
              BlocProvider.of<UserBloc>(context)
                  .add(SearchUser(initialData, userList, value));
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
      child: ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (BuildContext context, int index) {
          return Slidable(
            key: ValueKey(index),
            startActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (slidableContext) {
                    deleteDialog(context, initialData, users, users[index]);
                    debugPrint('delete');
                  },
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
                SlidableAction(
                  onPressed: (slidableContext) {
                    setState(() {
                      name = users[index].name ?? '';
                      email = users[index].email ?? '';
                      userId = users[index].id ?? 0;
                    });
                    showEditForm(context, initialData, users[index].id ?? 0);
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

  void deleteDialog(BuildContext context, List<User> initialData,
      List<User> users, User user) {
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
                        .add(DeleteUser(initialData, users, user));
                  },
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ))
            ],
          );
        });
  }

  void showEditForm(BuildContext context, List<User> users, int userId) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            height: 300,
            child: Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Center(
                    child: Text(
                      "EDIT",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  renderNameField(),
                  renderEmailField(),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40)),
                    onPressed: () {
                      final isValid = formKey.currentState!.validate();
                      // FocusScope.of(context).unfocus();

                      if (isValid) {
                        formKey.currentState!.save();
                        Navigator.of(sheetContext).pop();
                        BlocProvider.of<UserBloc>(context)
                        .add(EditUser(users, userId, name, email));
                      }
                    },
                    child: const Text("SAVE"),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget renderNameField() => TextFormField(
    initialValue: name,
        decoration: const InputDecoration(
          icon: Icon(Icons.person),
          labelText: 'Name',
          helperText: 'Input Name',
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        validator: (value) {
          if (value!.length < 4) {
            return 'Enter at least 4 characters';
          } else {
            return null;
          }
        },
        maxLength: 30,
        onSaved: (value) => setState(() => name = value ?? ''),
      );

  Widget renderEmailField() => TextFormField(
    initialValue: email,
        decoration: const InputDecoration(
          icon: Icon(Icons.email),
          labelText: 'Email',
          helperText: 'Input Email',
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        validator: (value) {
          if (value!.length < 4) {
            return 'Enter at least 4 characters';
          } else {
            return null;
          }
        },
        maxLength: 30,
        onSaved: (value) => setState(() => email = value ?? ''),
      );
}

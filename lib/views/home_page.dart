import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_task/views/user_list.dart';

import '../bloc/user_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserBloc>(
      create: (context) => UserBloc()..add(GetUsers()),
      child: const UserList(),
    );
  }
}

/*
- check https://jsonplaceholder.typicode.com/
- build list of users
  * show it in list 
  * with sort, filter and load more function
  * choose which field that you think good to show in the list
- actions
  * show >> open detail page
  * edit >> open edit page
  * delete >> show confirmation to delete the user, if yes delete the user and remove from list
- detail page
  * show all todos of the user (read only)
- edit page
  * show form to edit the user
*/

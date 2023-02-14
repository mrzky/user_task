import 'package:user_task/data/services/api_service.dart';
import '../models/todos_model.dart';
import '../models/user_model.dart';
import '../config/constant.dart';


class UserRepo {

  static APIService<List<User>> getAll() {
    return APIService(
      url: Uri.https(baseUrl, "/users"),
      parse: (response) {
        return userFromJson(response.body);
      }
    );
  }

  static APIService<List<Todos>> getTodos(int userId) {

    var params = {
      'userId': userId.toString()
    };

    return APIService(
      url: Uri.https(baseUrl, "/todos", params),
      parse: (response) {
        return todosFromJson(response.body);
      }
    );
  }

  static APIService<bool> updateUser(int userId, dynamic body) {

    return APIService(
      url: Uri.https(baseUrl, "/users/$userId"),
      body: body,
      parse: (response) {
        return true;
      }
    );
  }

  static APIService<bool> deleteUser(int userId) {

    return APIService(
      url: Uri.https(baseUrl, "/users/$userId"),
      parse: (response) {
        return true;
      }
    );
  }

}
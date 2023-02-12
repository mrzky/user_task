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

}



import 'package:AXMPAY/database/database.dart';
import 'package:AXMPAY/models/user_model.dart';

class UserRepository {

  final AdvancedLocalStorage  _storage = AdvancedLocalStorage.instance;

  Future<int> insertUser(UserData user) async {
    return await _storage.insert('userdatatable', user.toMap());
  }


  Future<UserData?> getUserById(int id) async {
    final results = await _storage.queryTyped(
      'userdatatable',
      where: 'id = ?',
      whereArgs: [id],
      fromMap: UserData.fromMap,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateUser(UserData user) async {
    return await _storage.update(
      'userdatatable',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteItem(int id) async {
    return await _storage.delete(
      'userdatatable',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


}
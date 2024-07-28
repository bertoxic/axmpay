import 'package:flutter/foundation.dart';
import '../config/config.dart';

class ConfigProvider extends ChangeNotifier {
  Config? _config;

  Config? get config => _config;

  Future<void> loadConfig() async {
    _config = await Config.load();
    notifyListeners();
  }
}
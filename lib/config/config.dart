import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  final String mongoDbUri;
  final String databaseName;
  final String userCollection;
  final String port;

  Config({
    required this.mongoDbUri,
    required this.databaseName,
    required this.userCollection,
    required this.port,
  });
  static Future<Config> load() async {
    try {
      // First, try to load using the default method
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print("Error loading .env file: $e");

      // If that fails, try to load it as an asset
      try {
      //  String contents = await rootBundle.loadString('assets/.env');
        await dotenv.load(fileName: ".env");
      } catch (e) {
        print("Error loading .env as asset: $e");
        rethrow;
      }
    }
    return Config(
      mongoDbUri: dotenv.env['MONGODB_URI'] ?? '',
      databaseName: dotenv.env['DATABASE_NAME'] ?? '',
      userCollection: dotenv.env['USER_COLLECTION'] ?? '',
      port: dotenv.env['PORT'] ?? '',
    );
  }
}
//   static Future<Config> load() async {
//     await dotenv.load(fileName: ".env");
//     print("xxxxxxxxxxxxxxx");
//     return Config(
//       mongoDbUri: dotenv.env['MONGODB_URI'] ?? '',
//       databaseName: dotenv.env['DATABASE_NAME'] ?? '',
//       userCollection: dotenv.env['USER_COLLECTION'] ?? '',
//       port: dotenv.env['PORT'] ?? '',
//     );
//   }
// }

import 'package:fintech_app/providers/Custom_Widget_State_Provider.dart';
import 'package:fintech_app/providers/user_service_provider.dart';
import 'package:fintech_app/ui/widgets/custom_responsive_sizes/responsive_size.dart';
import 'package:fintech_app/utils/globalErrorHandler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fintech_app/providers/authentication_provider.dart';
import 'package:fintech_app/providers/config_provider.dart';
import 'package:fintech_app/routes/router.dart';
import 'package:fintech_app/services/api_service.dart';
final ColorScheme colorScheme = ColorScheme(
  primary: const Color(0xff462eb4), // Primary color used for app bars, buttons, etc.
  primaryContainer:  const Color(0xFFFFFFFF), // A darker variant of the primary color
  secondary: Colors.amber, // Secondary color used for accents
  secondaryContainer: Colors.amber.shade700, // A darker variant of the secondary color
  surface: Colors.white, // The background color for cards, menus, etc.
  background: const Color(0xFFE8E8F3), // The main background color of the app
  error: Colors.red, // The color used for error states
  onPrimary: Colors.white, // The color used for text/icons on primary color
  onSecondary: const Color(0x78241A7A), // The color used for text/icons on secondary color
  onSurface: const Color(0xB20E1C49), // The color used for text/icons on surface color
  onBackground: const Color(0xEAFFFFFF), // The color used for text/icons on background color
  onError: Colors.red, // The color used for text/icons on error color
  brightness: Brightness.light, // Specifies whether the color scheme is dark or light
);
void main() async{WidgetsFlutterBinding.ensureInitialized();
// void main() =>runApp(MyApp() as Function({dynamic child, dynamic providers}));

final configProvider = ConfigProvider();
await configProvider.loadConfig();
  runApp(MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (context) => AuthenticationProvider(
            apiService: Provider.of<ApiService>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<CustomWidgetStateProvider>(create: (_) => CustomWidgetStateProvider<String>()),
        ChangeNotifierProvider<ConfigProvider>(create: (context)=>ConfigProvider()),
        ChangeNotifierProvider<UserServiceProvider>(create: (context)=>UserServiceProvider())
      ],
      child:  const GlobalErrorHandler(child: MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig:  route,
      theme: ThemeData(
    elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(


      // No primary or onPrimary colors specified
    ),
    ), colorScheme: colorScheme,
    ),
    builder: (context, child) {
    return GlobalErrorHandler(child: child!);},
    );
  }
}


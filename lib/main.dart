import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopify/models/user_data.dart';
import 'package:shopify/providers/setting.dart';
import 'package:shopify/screens/admin/tabs_admin.dart';
import 'package:shopify/screens/client/tabs.dart';
import 'package:shopify/screens/login_signup.dart';
import 'package:shopify/widgets/status_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shopify/providers/user_data.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:shopify/models/status_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

var kColorScheme =
    ColorScheme.fromSeed(seedColor: const Color.fromARGB(197, 255, 166, 2))
        .copyWith(
  primary: Colors.orange,
  onTertiary: Colors.white,
  secondary: Colors.black,
  // màu của CircularProgressIndicator
  scrim: const Color.fromARGB(255, 0, 0, 0),

  // màu của border trong detail product
  onSurface: const Color.fromARGB(255, 211, 211, 209),
);

var dColorScheme =
    ColorScheme.fromSeed(seedColor: const Color.fromARGB(197, 255, 166, 2))
        .copyWith(
  primary: Colors.orange,
  onTertiary: Colors.black,
  secondary: Colors.white,
  // màu của CircularProgressIndicator
  scrim: const Color.fromARGB(255, 255, 255, 255),

  // màu của border trong detail product
  onSurface: const Color.fromARGB(255, 255, 152, 0),
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? dm = prefs.getBool("darkMode");

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then(
    (_) {
      runApp(
        ProviderScope(
          child: MyApp(
            darkMode: dm ?? false,
          ),
        ),
      );
    },
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key, required this.darkMode});
  final bool darkMode;
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  Color getColor(Set<WidgetState> states) {
    const Set<WidgetState> interactiveStates = <WidgetState>{
      WidgetState.pressed,
      WidgetState.hovered,
      WidgetState.selected,
    };
    if (states.any(interactiveStates.contains)) {
      return kColorScheme.primary;
    }
    return kColorScheme.onTertiary;
  }

  @override
  void initState() {
    Future.microtask(() {
      if (widget.darkMode != ref.watch(darkMode)) {
        ref.read(darkMode.notifier).state = widget.darkMode;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: kColorScheme,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: kColorScheme.onTertiary,
        checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStateProperty.all(kColorScheme.onTertiary),
          fillColor: WidgetStateProperty.resolveWith(getColor),
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: kColorScheme.onTertiary,
          surfaceTintColor: Colors.transparent,
          headerForegroundColor: kColorScheme.secondary,
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return kColorScheme.secondary.withOpacity(0.3);
            }
            return kColorScheme.secondary;
          }),
          dayStyle: const TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
          yearStyle: const TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: kColorScheme.onTertiary,
          hourMinuteColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return kColorScheme.primary;
            }
            return kColorScheme.onTertiary;
          }),
          hourMinuteTextColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return kColorScheme.onTertiary;
            }
            return kColorScheme.secondary;
          }),
          dialBackgroundColor: kColorScheme.onTertiary,
          dialHandColor: kColorScheme.primary,
          dialTextColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return kColorScheme.onTertiary;
            }
            return kColorScheme.secondary;
          }),
          entryModeIconColor: kColorScheme.secondary,
          helpTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kColorScheme.secondary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(kColorScheme.primary),
            textStyle: WidgetStateProperty.all(
              TextStyle(
                color: kColorScheme.onTertiary,
                fontSize: 18,
              ),
            ),
          ),
        ),
        bottomAppBarTheme: const BottomAppBarTheme(),
        appBarTheme: AppBarTheme(
          color: kColorScheme.onTertiary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: kColorScheme.secondary,
          ),
        ),
        iconTheme: IconThemeData(
          color: kColorScheme.secondary,
        ),
        outlinedButtonTheme: const OutlinedButtonThemeData(
          style: ButtonStyle(
              // overlayColor: WidgetStateProperty.all(
              //   Colors.transparent,
              // ),
              ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.black,
          contentTextStyle: TextStyle(
              fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            elevation: WidgetStateProperty.all(0),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
            backgroundColor: WidgetStateProperty.all(
              Colors.transparent,
            ),
          ),
        ),
        cardTheme: const CardTheme(
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
          bodySmall: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: kColorScheme.onTertiary,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: dColorScheme,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: dColorScheme.onTertiary,
        checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStateProperty.all(dColorScheme.onTertiary),
          fillColor: WidgetStateProperty.resolveWith(getColor),
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: dColorScheme.onTertiary,
          surfaceTintColor: Colors.transparent,
          headerForegroundColor: dColorScheme.secondary,
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return dColorScheme.secondary.withOpacity(0.3);
            }
            return dColorScheme.secondary;
          }),
          dayStyle: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
          yearStyle: const TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: dColorScheme.onTertiary,
          hourMinuteColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return dColorScheme.primary;
            }
            return dColorScheme.onTertiary;
          }),
          hourMinuteTextColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return dColorScheme.onTertiary;
            }
            return dColorScheme.secondary;
          }),
          dialBackgroundColor: dColorScheme.onTertiary,
          dialHandColor: dColorScheme.primary,
          dialTextColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return dColorScheme.onTertiary;
            }
            return dColorScheme.secondary;
          }),
          entryModeIconColor: dColorScheme.secondary,
          helpTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: dColorScheme.secondary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(dColorScheme.primary),
            textStyle: WidgetStateProperty.all(
              TextStyle(
                color: dColorScheme.onTertiary,
                fontSize: 18,
              ),
            ),
          ),
        ),
        bottomAppBarTheme: const BottomAppBarTheme(),
        appBarTheme: AppBarTheme(
          color: dColorScheme.onTertiary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: dColorScheme.secondary,
          ),
        ),
        iconTheme: IconThemeData(
          color: dColorScheme.secondary,
        ),
        outlinedButtonTheme: const OutlinedButtonThemeData(
          style: ButtonStyle(
              // overlayColor: WidgetStateProperty.all(
              //   Colors.transparent,
              // ),
              ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.white,
          contentTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            elevation: WidgetStateProperty.all(0),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            padding: WidgetStateProperty.all(EdgeInsets.zero),
            backgroundColor: WidgetStateProperty.all(
              Colors.transparent,
            ),
          ),
        ),
        cardTheme: const CardTheme(
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
          bodySmall: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: dColorScheme.onTertiary,
          unselectedItemColor: Colors.white,
        ),
      ),
      themeMode: ref.watch(darkMode) ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const StatusPage(type: StatusPageEnum.loading, err: "");
          } else if (snapshot.hasError) {
            return StatusPage(
                type: StatusPageEnum.error, err: snapshot.error.toString());
          } else if (!snapshot.hasData) {
            Future.microtask(() {
              ref.read(userData.notifier).state = {};
            });
            return const LoginSignUp();
          }
          final String uidUser = snapshot.data!.uid;
          final userDataProviderAsync = ref.watch(userDataProvider(uidUser));
          return userDataProviderAsync.when(
            data: (value) {
              Future.microtask(() {
                ref.read(userData.notifier).state = UserData(
                  uid: uidUser,
                  username: value["username"],
                  role: value["role"],
                  email: value["email"],
                  avatar: value["avatar"],
                ).getUserData();
              });
              if (value["role"] == "admin") {
                return const TabsAdminScreen();
              }
              return const TabsScreen();
            },
            error: (error, stackStrace) {
              return StatusPage(
                type: StatusPageEnum.error,
                err: error.toString(),
              );
            },
            loading: () {
              return const StatusPage(type: StatusPageEnum.loading, err: "");
            },
          );
        },
      ),
    );
  }
}

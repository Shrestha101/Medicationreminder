import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project/providers/init_provider.dart';
import 'package:project/screens/auth/login_screen.dart';
//import 'package:project/screens/home/alarms_screen.dart';
import 'package:project/utils/config.dart';
//import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
//import 'package:project/models/alarm.dart';
// import 'package:project/providers/alarm_list_provider.dart';
// /import 'package:project/providers/permission_provider.dart';
// import 'package:project/services/alarm_file_handler.dart';
// import 'package:project/services/alarm_polling_worker.dart';
// import 'package:project/providers/alarm_state.dart';
// import 'package:project/views/alarm_observer.dart';
// import 'package:project/views/home_screen.dart';
// import 'package:project/views/permission_request_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

final configurations = Configurations();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  //await AndroidAlarmManager.initialize();

  //final AlarmState alarmState = AlarmState();
  ////final List<Alarm> alarms = await AlarmFileHandler().read() ?? [];
  //final SharedPreferences preference = await SharedPreferences.getInstance();

  //// When entering the app, it should start searching for alarms.
  //AlarmPollingWorker().createPollingWorker(alarmState);

  if (kIsWeb) {
    print("WEB");
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: configurations.apiKey,
        appId: configurations.appId,
        authDomain: configurations.authDomain,
        storageBucket: configurations.storageBucket,
        messagingSenderId: configurations.messagingSenderId,
        projectId: configurations.projectId,
      ),
    );
  } else {
    await Firebase.initializeApp();
    print("MOBILE");
  }
  /*runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => alarmState),
      ChangeNotifierProvider(create: (context) => InitProvider()),
      ChangeNotifierProvider(
        create: (context) => PermissionProvider(preference),
      ),
    ],
    child: LoginScreen(),
  ));*/
  runApp(InitProvider());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Android Alarm Demo',
      theme: ThemeData(useMaterial3: true),
      home: LoginScreen(),
    );
  }
}


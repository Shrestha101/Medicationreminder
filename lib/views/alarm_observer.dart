import 'package:flutter/material.dart';
import 'package:project/models/alarm.dart';
import 'package:project/providers/alarm_list_provider.dart';
import 'package:project/providers/alarm_state.dart';
import 'package:provider/provider.dart';
import 'package:project/services/alarm_polling_worker.dart';
import 'package:project/views/alarm_screen.dart';

class AlarmObserver extends StatefulWidget {
  final Widget child;

  const AlarmObserver({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AlarmObserver> createState() => _AlarmObserverState();
}

class _AlarmObserverState extends State<AlarmObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        AlarmPollingWorker().createPollingWorker(context.read<AlarmState>());
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlarmState>(builder: (context, state, child) {
      Widget? alarmScreen;

      if (state.isFired) {
        final callbackId = state.callbackAlarmId!;
        //Alarm? alarm = context.read<AlarmListProvider>().getAlarmBy(callbackId);
        //if (alarm != null) {
        //  alarmScreen = AlarmScreen(alarm: alarm);
        //}
      }
      return IndexedStack(
        index: alarmScreen != null ? 0 : 1,
        children: [
          alarmScreen ?? Container(),
          widget.child,
        ],
      );
    });
  }
}

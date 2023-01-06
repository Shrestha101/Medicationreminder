import 'package:flutter/cupertino.dart';
import 'package:project/services/alarm_flag_manager.dart';
import 'package:project/providers/alarm_state.dart';

class AlarmPollingWorker {
  static final AlarmPollingWorker _instance = AlarmPollingWorker._();

  factory AlarmPollingWorker() {
    return _instance;
  }

  AlarmPollingWorker._();

  bool _running = false;

  /// Start alarm flag search.
  Future<void> createPollingWorker(AlarmState alarmState) async {
    if (_running) return;

    debugPrint('Starts polling worker');
    _running = true;
    final int? callbackAlarmId = await _poller(10);
    _running = false;

    if (callbackAlarmId != null) {
      if (!alarmState.isFired) {
        alarmState.fire(callbackAlarmId);
      }
      await AlarmFlagManager().clear();
    }
  }

  /// If an alarm flag is found, the Id of the alarm is returned. If there is no flag, `null` is returned.
  Future<int?> _poller(int iterations) async {
    int? alarmId;
    int iterator = 0;

    await Future.doWhile(() async {
      alarmId = await AlarmFlagManager().getFiredId();
      if (alarmId != null || iterator++ >= iterations) return false;
      await Future.delayed(const Duration(milliseconds: 25));
      return true;
    });
    return alarmId;
  }
}

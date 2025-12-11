import 'package:firebase_database/firebase_database.dart';

/// Firebase Realtime Database command writer.
/// commands/tracking: "START"/"STOP"
/// commands/main_light: "ON"/"OFF"
/// commands/sub_light: "ON"/"OFF"
class CommandService {
  static DatabaseReference get _commandsRef =>
      FirebaseDatabase.instance.ref('commands');

  static Future<void> setTracking(bool start) {
    return _commandsRef.update({'tracking': start ? 'START' : 'STOP'});
  }

  static Future<void> setMainLight(bool on) {
    return _commandsRef.update({'main_light': on ? 'ON' : 'OFF'});
  }

  static Future<void> setSubLight(bool on) {
    return _commandsRef.update({'sub_light': on ? 'ON' : 'OFF'});
  }
}

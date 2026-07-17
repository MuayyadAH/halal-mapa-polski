import 'dart:developer' as developer;

/// Thin logger abstraction. Swap the body when a real logger lands.
class Log {
  const Log(this._name);

  final String _name;

  void info(String message) => developer.log(message, name: _name);

  void warn(String message) => developer.log('WARN: $message', name: _name);

  void error(String message, [Object? error, StackTrace? stack]) =>
      developer.log(
        'ERROR: $message',
        name: _name,
        error: error,
        stackTrace: stack,
      );
}

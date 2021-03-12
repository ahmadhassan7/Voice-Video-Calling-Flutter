import 'dart:async';

class ThemeStream{

  final _themeController = StreamController<Map<String, bool>>();
  get changeTheme => _themeController.sink.add;
  get darkThemeEnabled => _themeController.stream;





}
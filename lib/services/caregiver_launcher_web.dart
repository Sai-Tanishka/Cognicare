import 'package:web/web.dart' as web;

Future<bool> openCaregiverDashboard() async {
  web.window.location.assign('http://127.0.0.1:8081');
  return true;
}
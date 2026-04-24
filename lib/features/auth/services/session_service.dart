import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/storage/prefs_service.dart';
import '../../../routes/route_names.dart';

class SessionService {

  static Future<String> resolveStartRoute() async {

    final user =
        FirebaseAuth.instance.currentUser;

    if(user == null) {
      return RouteNames.login;
    }

    final lastActive =
    await PrefsService.getLastActive();

    if(lastActive == null) {

      await PrefsService.updateLastActive();

      return RouteNames.home;
    }

    final diff =
    DateTime.now()
        .difference(lastActive);

    if(diff.inDays >= 90) {

      await FirebaseAuth
          .instance
          .signOut();

      await PrefsService
          .clearSession();

      return RouteNames.login;
    }

    await PrefsService.updateLastActive();

    return RouteNames.home;
  }
}
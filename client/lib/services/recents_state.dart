import 'package:flutter/cupertino.dart';
import '../services/database.dart' show getRecentActivity;

class RecentsState extends ChangeNotifier with NavigatorObserver {
  String uid = "";
  Future<List<dynamic>> recentlyViewed = Future.value([]);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == "/home" || route.settings.name == "/") {
      reloadRecents();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute?.settings.name == "/home" ||
        previousRoute?.settings.name == "/") {
      reloadRecents();
    }
  }

  void update(String newUID) {
    print("UPDATEDDD");
    uid = newUID;
  }

  void reloadRecents() {
    print("uid: $uid");
    if (uid != "") {
      recentlyViewed = getRecentActivity(uid);
    }
    notifyListeners();
  }
}

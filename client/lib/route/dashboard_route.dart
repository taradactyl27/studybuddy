import 'package:flutter/material.dart';

class DashboardPageRoute extends MaterialPageRoute {
  DashboardPageRoute({builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

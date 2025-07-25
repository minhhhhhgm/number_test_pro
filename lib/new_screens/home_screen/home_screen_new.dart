import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numbers/di/service_locator.dart';
import 'package:numbers/new_screens/game_screen/game_screen.dart';
import 'package:numbers/new_screens/home_screen/bloc/home_bloc.dart';
import 'package:numbers/new_screens/rank_screen/rank_screen.dart';
import 'package:numbers/new_screens/setting_screen/setting_screen.dart';
import 'package:numbers/utils/app_colors.dart';
import 'package:numbers/utils/game_config.dart';

part './widgets/body.dart';
part './widgets/body_home.dart';
part 'widgets/bottom_navigation_bar.dart';
part 'widgets/game_mode.dart';

class HomeScreenNew extends StatelessWidget {
  const HomeScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(HomeState()),
      child: _Body(),
    );
  }
}

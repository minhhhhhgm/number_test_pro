import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numbers/di/service_locator.dart';
import 'package:numbers/new_screens/game_screen/bloc/game_bloc.dart';
import 'package:numbers/new_screens/game_screen/bloc/game_event.dart';
import 'package:numbers/new_screens/game_screen/bloc/game_state.dart';
import 'package:numbers/schema/BlockSchema.dart';
import 'package:numbers/service/sound_service.dart';
import 'package:numbers/utils/game_config.dart';

part 'widgets/body.dart';
part 'widgets/header.dart';
part 'widgets/number_blocks.dart';
part 'widgets/tool_helper_widget.dart';

class GameScreen extends StatelessWidget {
  const GameScreen(
      {super.key,
      required this.textColor,
      required this.borderColor,
      required this.backgroundColorCountDown,
      required this.foregroundColorCountDown,
      required this.backgroundColor});

  final Color textColor,
      borderColor,
      backgroundColorCountDown,
      foregroundColorCountDown,
      backgroundColor;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc()..add(GameStarted()),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: _Body(
          textColor: textColor,
          borderColor: borderColor,
          backgroundColorCountDown: backgroundColorCountDown,
          foregroundColorCountDown: foregroundColorCountDown,
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numbers/di/service_locator.dart';
import 'package:numbers/new_screens/game_screen/bloc/game_bloc.dart';
import 'package:numbers/new_screens/game_screen/bloc/game_event.dart';
import 'package:numbers/new_screens/game_screen/bloc/game_state.dart';
import 'package:numbers/schema/BlockSchema.dart';
import 'package:numbers/service/sound_service.dart';
import 'package:numbers/utils/theme_color.dart';

part 'widgets/body.dart';
part 'widgets/header.dart';
part 'widgets/number_blocks.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc()..add(GameStarted()),
      child: Scaffold(
        backgroundColor: Color(0xFFe9fab5),
        body: _Body(),
      ),
    );
  }
}

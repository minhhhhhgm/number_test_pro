import 'dart:async';
import 'package:numbers/service/LeaderboardService.dart';
import 'package:numbers/store/BestScoreStore.dart';
import 'package:numbers/store/RecentScoreStore.dart';
import 'package:numbers/schema/BlockSchema.dart';
import 'package:numbers/screens/GameScreen/summaryModel.dart';
import 'package:numbers/utils/Config.dart';
import 'package:numbers/widgets/bgGradient.dart';
import 'package:numbers/provider/BlockDataStream.dart';
import 'package:flutter/material.dart';
import 'headerInfo.widget.dart';
import 'numberBlocks.widget.dart';
import 'targetBlock.widget.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BlockSchema blockSchema;
  late List<BlockSchema> blocks;
  late int currentTotal;
  late Timer gameTimerObject;
  int secCounter = gameDuration;
  bool isTimeUp = false;
  Map<String, int> gameHistory = {
    "total": 0,
    "success": 0,
    "fail": 0,
    "score": 0,
    "selectedBlocks": 0,
    "tmpSelectedBlocks": 0
  };
  BlockDataStream blockDataStream = BlockDataStream();

  @override
  void initState() {
    super.initState();
    this.initTimer();
    this.fillBlocksData();
    this.listenBlockChanges();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: double.infinity,
          decoration: bgBoxDecoration(),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                headerInfo(this.secCounter, this.gameHistory),
                SizedBox(
                  height: 10,
                ),
                buildTargetBlock(
                    title: 'Target', targetValue: this.blockSchema.target),
                buildNumberBlocks()
              ],
            ),
          ),
        ),
      ),
    );
  }

  void initTimer() {
    this.gameTimerObject = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        this.secCounter--;
        if (this.secCounter < 1) {
          this.postGameWorks();
        }
      });
    });
  }

  void postGameWorks() {
    this.isTimeUp = true;
    this.gameTimerObject.cancel();
    showSummary(context, gameHistory);
    updateScores();
  }

  void calculateScore() {
    num score = (gameHistory['selectedBlocks'] ?? 0 * costs['block']) +
        (gameHistory['success'] ?? 0 * costs['success']) +
        (gameHistory['fail'] ?? 0 * costs['fail']);
    gameHistory['score'] = score as int > 0 ? (score) : 0;
  }

  void updateScores() {
    RecentScoreStore().updateRecentScore(gameHistory['score'] ?? 0);
    BestScoreStore().updateScore(gameHistory['score'] ?? 0);
    LeaderboardService().setData(gameHistory);
  }

  void fillBlocksData() {
    if (isTimeUp) {
      return;
    }
    setState(() {
      gameHistory['total']! + 1;
      currentTotal = 0;
      blockSchema = BlockSchema();
      blocks = blockSchema.getBlocks();
    });
  }

  void listenBlockChanges() {
    blockDataStream.stream.listen((Map<String, int> blockData) {
      setState(() {
        _validateBlocks(blockData);
      });
    });
  }

  void _validateBlocks(blockData) {
    int selectedIndex = blockData['index'];

    if (blocks[selectedIndex].isSelected) {
      return;
    }

    blocks[selectedIndex].isSelected = true;

    gameHistory['tmpSelectedBlocks']! + 1;

    currentTotal += blockData['value'] as int;

    if (currentTotal < blockSchema.target) {
      _changeBlockColor(selectedIndex, Colors.green);
      if (!isThereChanceToMakeItCorrect()) {
        _wrongAnswer(selectedIndex);
        return;
      }
    } else if (currentTotal == blockSchema.target) {
      _correctAnswer(selectedIndex);
    } else {
      _wrongAnswer(selectedIndex);
    }
  }

  void _wrongAnswer(selectedIndex) {
    gameHistory['fail']! + 1;
    gameHistory['tmpSelectedBlocks'] = 0; //reset
    calculateScore();
    _changeBlockColor(selectedIndex, Colors.red);
    _showStatusAlert('Wrong !!!', Icons.clear, Colors.red, false);
    _closePopUpAndShuffle();
  }

  void _correctAnswer(selectedIndex) {
    gameHistory['success']! + 1;
    gameHistory['selectedBlocks'] =
        gameHistory['selectedBlocks']! + gameHistory['tmpSelectedBlocks']!;
    gameHistory['tmpSelectedBlocks'] = 0; //reset
    calculateScore();
    _changeBlockColor(selectedIndex, Colors.green);
    _showStatusAlert('Correct !!!', Icons.check, Colors.green, true);
    _closePopUpAndShuffle();
  }

  void _closePopUpAndShuffle() {
    Timer(Duration(seconds: 1), () {
      if (isTimeUp) {
        return;
      }
      Navigator.of(context).pop();
      fillBlocksData();
    });
  }

  bool isThereChanceToMakeItCorrect() {
    bool chance = false;

    for (var i = 0; i < blocks.length; i++) {
      if (blocks[i].isSelected) {
        continue;
      }

      if (currentTotal + blocks[i].value <= this.blockSchema.target) {
        chance = true;
      }
    }

    return chance;
  }

  void _changeBlockColor(selectedIndex, Color color) {
    this.blocks[selectedIndex].color = color;
  }

  Container buildNumberBlocks() {
    return Container(
      // alignment: Alignment.centerLeft,
      alignment: Alignment(0.0, 0.0),
      // color: Colors.grey,
      padding: const EdgeInsets.all(30),
      child: Wrap(spacing: 40, runSpacing: 40, children: _generateBlocks(9)),
    );
  }

  List<Widget> _generateBlocks(int size) {
    List<Widget> blocks = [];

    for (var i = 0; i < size; i++) {
      blocks.add(numberBlock(
        
          bgColor: this.blocks[i].color,
          index: this.blocks[i].index,
          value: this.blocks[i].value,
          blockDataStream: this.blockDataStream));
    }

    return blocks;
  }

  Future<void> _showStatusAlert(
      String title, IconData icon, Color color, bool isSuccess) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0),
          content: Container(
            width: 100,
            height: 100,
            child: Icon(
              icon,
              color: color,
              size: 100,
            ),
          ),
        );
      },
    );
  }
}

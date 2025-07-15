import 'dart:async';
import 'dart:math';
import 'package:numbers/service/LeaderboardService.dart';
import 'package:numbers/service/SoundService.dart';
import 'package:numbers/service/AchievementService.dart';
import 'package:numbers/service/ShareService.dart';
import 'package:numbers/store/BestScoreStore.dart';
import 'package:numbers/store/RecentScoreStore.dart';
import 'package:numbers/schema/BlockSchema.dart';
import 'package:numbers/schema/DailyChallenge.dart';
import 'package:numbers/screens/GameScreen/summaryModel.dart';
import 'package:numbers/utils/Config.dart';
import 'package:numbers/widgets/bgGradient.dart';
import 'package:numbers/provider/BlockDataStream.dart';
import 'package:flutter/material.dart';
import 'headerInfo.widget.dart';
import 'numberBlocks.widget.dart';
import 'targetBlock.widget.dart';

enum PowerUpType {
  doubleScore, // X2 điểm
  addTime, // Thêm thời gian
  skipLevel, // Bỏ qua màn
  revealBlock, // Hiển thị 1 block đúng
}

class GameScreen extends StatefulWidget {
  final String gameMode;
  const GameScreen({Key? key, this.gameMode = ''}) : super(key: key);

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
  int hintCount = 0;
  bool isDoubleScoreActive = false;
  bool isRevealBlockActive = false;
  int? revealedBlockIndex;
  bool isDailyChallenge = false;
  DailyChallenge? currentChallenge;
  int challengeAttempts = 0;
  int maxChallengeAttempts = 3;
  Map<String, int> gameHistory = {
    "total": 0,
    "success": 0,
    "fail": 0,
    "score": 0,
    "selectedBlocks": 0,
    "tmpSelectedBlocks": 0
  };
  BlockDataStream blockDataStream = BlockDataStream();
  
  // Sound and Achievement services
  final SoundService _soundService = SoundService();
  final AchievementService _achievementService = AchievementService();
  
  // Game tracking
  bool _usedHints = false;
  int _powerUpsUsed = 0;
  int _gameStartTime = 0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    if (widget.gameMode == 'daily') {
      _checkDailyChallenge();
      isDailyChallenge = true;
    }
    this.initTimer();
    this.fillBlocksData();
    this.listenBlockChanges();
  }

  Future<void> _initializeServices() async {
    await _soundService.initialize();
    await _achievementService.initialize();
    await _achievementService.onGameStart();
    _gameStartTime = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  void dispose() {
    gameTimerObject.cancel();
    blockDataStream.dispose();
    _soundService.dispose();
    super.dispose();
  }

  void _checkDailyChallenge() {
    String today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    
    // TODO: Load challenge từ local storage hoặc server
    // Nếu chưa có challenge cho hôm nay, tạo mới
    if (currentChallenge?.id != today) {
      currentChallenge = DailyChallenge.generateDailyChallenge(today);
      challengeAttempts = 0;
      // TODO: Save challenge và attempts vào local storage
    }
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
                SizedBox(height: 10),
                headerInfo(this.secCounter, this.gameHistory),
                headerInfo(this.secCounter, this.gameHistory),

                headerInfo(this.secCounter, this.gameHistory),

                headerInfo(this.secCounter, this.gameHistory),

                SizedBox(height: 100),
                if (isDailyChallenge && currentChallenge != null)
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '🎯 Thử thách ngày',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
                        ),
                        SizedBox(height: 8),
                        Text(currentChallenge!.description),
                        SizedBox(height: 4),
                        Text('Thời gian: ${currentChallenge!.timeLimit}s'),
                        SizedBox(height: 4),
                        Text('Lượt còn lại: ${maxChallengeAttempts - challengeAttempts}'),
                        SizedBox(height: 4),
                        Text('Phần thưởng: ${currentChallenge!.reward} coin'),
                      ],
                    ),
                  ),
                buildTargetBlock(
                    title: 'Target', targetValue: this.blockSchema.target),
                if (!isDailyChallenge || currentChallenge?.type != ChallengeType.noHint)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.lightbulb_outline),
                        label: Text('Gợi ý'),
                        onPressed: hintCount < 2 ? showHint : null,
                      ),
                    ],
                  ),
                SizedBox(height: 10),
                if (!isDailyChallenge || currentChallenge?.type != ChallengeType.powerUpDisabled)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPowerUpButton(
                        PowerUpType.doubleScore,
                        Icons.star,
                        'X2 Điểm',
                        isDoubleScoreActive ? Colors.orange : Colors.grey,
                      ),
                      _buildPowerUpButton(
                        PowerUpType.addTime,
                        Icons.timer,
                        '+20s',
                        Colors.blue,
                      ),
                      _buildPowerUpButton(
                        PowerUpType.skipLevel,
                        Icons.skip_next,
                        'Bỏ qua',
                        Colors.red,
                      ),
                      _buildPowerUpButton(
                        PowerUpType.revealBlock,
                        Icons.visibility,
                        'Reveal',
                        isRevealBlockActive ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                buildNumberBlocks(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPowerUpButton(
      PowerUpType type, IconData icon, String label, Color color) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label, style: TextStyle(fontSize: 12)),
      onPressed: () => _usePowerUp(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size(60, 40),
      ),
    );
  }

  void _usePowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.doubleScore:
        _activateDoubleScore();
        break;
      case PowerUpType.addTime:
        _addTime();
        break;
      case PowerUpType.skipLevel:
        _skipLevel();
        break;
      case PowerUpType.revealBlock:
        _revealBlock();
        break;
    }
  }

  void _activateDoubleScore() async {
    if (mounted) {
      setState(() {
        isDoubleScoreActive = true;
      });
    }
    await _soundService.playPowerUp();
    _powerUpsUsed++;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('X2 Điểm đã được kích hoạt!')),
    );
  }

  void _addTime() async {
    if (mounted) {
      setState(() {
        secCounter += 20; // Thêm 20 giây
      });
    }
    await _soundService.playPowerUp();
    _powerUpsUsed++;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm 20 giây!')),
    );
  }

  void _skipLevel() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bỏ qua màn này?'),
        content: Text('Bạn có chắc muốn bỏ qua màn hiện tại?'),
        actions: [
          TextButton(
            child: Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Bỏ qua'),
            onPressed: () async {
              Navigator.pop(context);
              await _soundService.playPowerUp();
              _powerUpsUsed++;
              fillBlocksData(); // Sang màn mới
            },
          ),
        ],
      ),
    );
  }

  void _revealBlock() async {
    if (isRevealBlockActive) return;
    
    // Lấy 1 số bất kỳ trong tổ hợp đúng
    List<int> correctNumbers = List.from(blockSchema.correctCombination);
    if (correctNumbers.isEmpty) return;
    int randomCorrectNumber =
        correctNumbers[Random().nextInt(correctNumbers.length)];
    
    // Tìm index của số này trong danh sách block
    int? blockIndex;
    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i].value == randomCorrectNumber && !blocks[i].isSelected) {
        blockIndex = i;
        break;
      }
    }
    
    if (blockIndex != null && mounted) {
      setState(() {
        isRevealBlockActive = true;
        revealedBlockIndex = blockIndex;
        blocks[blockIndex ?? 0].isRevealed = true;
      });
      
      await _soundService.playPowerUp();
      _powerUpsUsed++;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã hiển thị 1 block đúng!')),
      );
    }
  }

  void showHint() async {
    hintCount++;
    _usedHints = true;
    await _achievementService.onHintUsed();
    
    List<int> hintNumbers;
    if (hintCount == 1) {
      // Lần đầu: gợi ý 2 số
      hintNumbers = List.from(blockSchema.correctCombination)..shuffle();
      hintNumbers = hintNumbers.take(2).toList();
    } else if (hintCount == 2) {
      // Lần 2: gợi ý nốt số còn lại
      hintNumbers = List.from(blockSchema.correctCombination);
    } else {
      // Đã gợi ý hết, không làm gì
      return;
    }

    // Tìm index các số này trong danh sách block hiện tại
    List<int> hintIndexes = [];
    for (int i = 0; i < blocks.length; i++) {
      if (hintNumbers.contains(blocks[i].value) && !hintIndexes.contains(i)) {
        hintIndexes.add(i);
        if (hintIndexes.length == hintNumbers.length) break;
      }
    }

    if (mounted) {
      setState(() {
        for (int i = 0; i < blocks.length; i++) {
          blocks[i].isHint = hintIndexes.contains(i);
        }
      });
    }
    
    await _soundService.playHint();
  }

  void clearHint() {
    if (mounted) {
      setState(() {
        for (int i = 0; i < blocks.length; i++) {
          blocks[i].isHint = false;
          blocks[i].isRevealed = false;
        }
      });
    }
  }

  void initTimer() {
    int timeLimit = isDailyChallenge ? currentChallenge!.timeLimit : gameDuration;
    this.gameTimerObject = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          this.secCounter--;
          if (this.secCounter < 1) {
            this.postGameWorks();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void postGameWorks() async {
    this.isTimeUp = true;
    this.gameTimerObject.cancel();
    await _soundService.playGameOver();
    await _achievementService.onGameLoss();
    
    if (isDailyChallenge) {
      _showChallengeFailed();
    } else {
      showSummary(context, gameHistory);
      updateScores();
    }
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
    if (isTimeUp || !mounted) return;
    setState(() {
      gameHistory['total']! + 1;
      currentTotal = 0;
      if (isDailyChallenge && currentChallenge != null) {
        // Sử dụng target từ challenge
        blockSchema = BlockSchema.withTarget(currentChallenge!.target);
      } else {
        blockSchema = BlockSchema();
      }
      blocks = blockSchema.getBlocks();
      hintCount = 0;
      clearHint();
      
      // Reset power-up
      isDoubleScoreActive = false;
      isRevealBlockActive = false;
      revealedBlockIndex = null;
    });
  }

  void listenBlockChanges() {
    blockDataStream.stream.listen((Map<String, int> blockData) {
      if (mounted) {
        setState(() {
          _validateBlocks(blockData);
        });
      }
    });
  }

  void _validateBlocks(blockData) async {
    int selectedIndex = blockData['index'];

    if (blocks[selectedIndex].isSelected) {
      return;
    }

    // Kiểm tra luật challenge
    if (isDailyChallenge && currentChallenge != null) {
      if (currentChallenge!.type == ChallengeType.evenOnly && blocks[selectedIndex].value % 2 != 0) {
        _showChallengeRuleViolation('Chỉ được chọn số chẵn!');
        return;
      }
      if (currentChallenge!.type == ChallengeType.oddOnly && blocks[selectedIndex].value % 2 == 0) {
        _showChallengeRuleViolation('Chỉ được chọn số lẻ!');
        return;
      }
    }

    blocks[selectedIndex].isSelected = true;
    await _soundService.playBlockSelect();

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

  void _showChallengeRuleViolation(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _wrongAnswer(selectedIndex) async {
    gameHistory['fail']! + 1;
    gameHistory['tmpSelectedBlocks'] = 0; //reset
    calculateScore();
    _changeBlockColor(selectedIndex, Colors.red);
    
    await _soundService.playWrong();
    await _achievementService.onGameLoss();
    
    if (isDailyChallenge) {
      challengeAttempts++;
      if (challengeAttempts >= maxChallengeAttempts) {
        _showChallengeFailed();
      } else {
        _showStatusAlert('Sai! Lượt còn lại: ${maxChallengeAttempts - challengeAttempts}', Icons.clear, Colors.red, false);
      }
    } else {
      _showStatusAlert('Wrong !!!', Icons.clear, Colors.red, false);
    }
    
    _closePopUpAndShuffle();
  }

  void _showChallengeFailed() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Hết lượt thử thách!'),
        content: Text('Bạn đã hết ${maxChallengeAttempts} lượt cho thử thách hôm nay. Hãy thử lại vào ngày mai!'),
        actions: [
          TextButton(
            child: Text('Về trang chủ'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _correctAnswer(selectedIndex) async {
    gameHistory['success']! + 1;
    gameHistory['selectedBlocks'] =
        gameHistory['selectedBlocks']! + gameHistory['tmpSelectedBlocks']!;
    gameHistory['tmpSelectedBlocks'] = 0; //reset
    
    // Áp dụng X2 điểm nếu đang active
    if (isDoubleScoreActive) {
      gameHistory['selectedBlocks'] = gameHistory['selectedBlocks']! * 2;
      isDoubleScoreActive = false; // Reset sau khi dùng
    }
    
    calculateScore();
    _changeBlockColor(selectedIndex, Colors.green);
    
    // Calculate game time for achievements
    int gameTime = (DateTime.now().millisecondsSinceEpoch - _gameStartTime) ~/ 1000;
    int timeLeft = secCounter;
    
    await _soundService.playCorrect();
    await _achievementService.onGameWin(
      score: gameHistory['score'] ?? 0,
      timeLeft: timeLeft,
      usedHints: _usedHints,
      powerUpsUsed: _powerUpsUsed,
    );
    
    // Check special achievements
    await _achievementService.checkComebackKing(timeLeft);
    await _achievementService.checkLuckyStreak(gameTime);
    
    if (isDailyChallenge) {
      await _achievementService.onDailyChallengeCompleted();
      _showChallengeCompleted();
    } else {
      await _soundService.playLevelComplete();
      _showStatusAlert('Correct !!!', Icons.check, Colors.green, true);
      _closePopUpAndShuffle();
    }
  }

  void _showChallengeCompleted() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('🎉 Hoàn thành thử thách!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chúc mừng! Bạn đã hoàn thành thử thách ngày hôm nay.'),
            SizedBox(height: 16),
            Text('Phần thưởng: ${currentChallenge!.reward} coin'),
            SizedBox(height: 8),
            Text('Điểm số: ${gameHistory['score']}'),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Chia sẻ'),
            onPressed: () async {
              await _soundService.playButtonClick();
              await ShareService().shareDailyChallenge(
                gameHistory['score'] ?? 0,
                currentChallenge?.description ?? 'Thử thách ngày',
              );
            },
          ),
          TextButton(
            child: Text('Về trang chủ'),
            onPressed: () async {
              await _soundService.playButtonClick();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
    
    // TODO: Cộng coin, lưu thành tích, cập nhật leaderboard
  }

  void _closePopUpAndShuffle() {
    Timer(Duration(seconds: 1), () {
      if (isTimeUp || !mounted) {
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
      alignment: Alignment(0.0, 0.0),
      padding: const EdgeInsets.all(30),
      child: Wrap(spacing: 40, runSpacing: 40, children: _generateBlocks(12)),
    );
  }

  List<Widget> _generateBlocks(int size) {
    List<Widget> blocks = [];

    for (var i = 0; i < size; i++) {
      blocks.add(numberBlock(
          bgColor: this.blocks[i].color,
          index: this.blocks[i].index,
          value: this.blocks[i].value,
          blockDataStream: this.blockDataStream,
          isHint: this.blocks[i].isHint,
          isRevealed: this.blocks[i].isRevealed));
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

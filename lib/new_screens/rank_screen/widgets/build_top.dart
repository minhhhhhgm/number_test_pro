part of '../rank_screen.dart';

class _BuildTop extends StatelessWidget {
  const _BuildTop({required this.top3});

  final List<RankModel> top3;

  @override
  Widget build(BuildContext context) {
    final RankModel? first = top3.length >= 1 ? top3[0] : null;
    final RankModel? second = top3.length >= 2 ? top3[1] : null;
    final RankModel? third = top3.length >= 3 ? top3[2] : null;

    const Color firstPlaceColor = Color(0xFF5B6E64);
    const Color secondPlaceColor = Color(0xFFB17A6D);
    const Color thirdPlaceColor = Color(0xFFEDAC4D);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (second != null)
          _buildPodiumColumn(
            player: second,
            rank: 2,
            height: 70,
            barColor: secondPlaceColor,
            avatarRadius: 30,
            rankChange: 2,
            topText: '2',
            avatar: _buildPlayerAvatar(second.name,
                radius: 30, isCurrentPlayer: second.isCurrentPlayer),
          ),
        const SizedBox(width: 10),
        if (first != null)
          _buildPodiumColumn(
            player: first,
            rank: 1,
            height: 100,
            barColor: firstPlaceColor,
            avatarRadius: 35,
            isWinner: true,
            topText: '1',
            avatar: _buildPlayerAvatar(first.name,
                radius: 35, isCurrentPlayer: first.isCurrentPlayer),
          ),
        const SizedBox(width: 10),
        if (third != null)
          _buildPodiumColumn(
            player: third,
            rank: 3,
            height: 50,
            barColor: thirdPlaceColor,
            avatarRadius: 30,
            rankChange: 2,
            topText: '3',
            avatar: _buildPlayerAvatar(third.name,
                radius: 30, isCurrentPlayer: third.isCurrentPlayer),
          ),
      ],
    );
  }

  Widget _buildPodiumColumn({
    required RankModel player,
    required int rank,
    required double height,
    required Color barColor,
    required double avatarRadius,
    required String topText,
    required Widget avatar,
    int? rankChange,
    bool isWinner = false,
  }) {
    final bool isCurrent = player.isCurrentPlayer;

    return Animate(
      key: ValueKey('${player.id}_${player.isCurrentPlayer}'),
      effects: isCurrent
          ? [
              ShakeEffect(
                duration: 800.ms,
                hz: 4,
                offset: const Offset(2, 2),
                curve: Curves.easeInOut,
              ),
              TintEffect(
                color: Colors.orange.withOpacity(0.1),
                duration: 800.ms,
              ),
            ]
          : [],
      onPlay: (controller) =>
          controller.repeat(period: Duration(seconds: 3), count: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isWinner)
              Column(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 50),
                  const SizedBox(height: 5),
                ],
              ),
            avatar,
            const SizedBox(height: 5),
            Text(
              player.name,
              style: TextStyle(
                color: player.isCurrentPlayer
                    ? Colors.blueAccent.withOpacity(0.5)
                    : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                Text(
                  '${player.highScore}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                Image.asset(
                  'assets/icon/star.png',
                  width: 16,
                  height: 16,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Container(
              width: 80,
              height: height,
              decoration: BoxDecoration(
                color: isCurrent ? Colors.lightBlueAccent : barColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              alignment: Alignment.center,
              child: Text(
                topText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerAvatar(
    String playerName, {
    double radius = 24.0,
    Color? backgroundColor,
    required bool isCurrentPlayer, // ✅ thêm tham số
  }) {
    final Random random = Random(playerName.hashCode);
    final Color avatarColor = backgroundColor ??
        Color.fromRGBO(
          random.nextInt(200) + 50,
          random.nextInt(200) + 50,
          random.nextInt(200) + 50,
          1,
        );

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isCurrentPlayer
            ? Border.all(color: Colors.blueAccent, width: 3) // ✅ viền xanh
            : null,
        boxShadow: isCurrentPlayer
            ? [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.5), // ✅ glow effect
                  spreadRadius: 2,
                  blurRadius: 8,
                ),
              ]
            : [],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: avatarColor,
        child: Text(
          playerName.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: isCurrentPlayer
                ? Colors.black.withOpacity(0.5)
                : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class FireGlowDemoScreen extends StatelessWidget {
  const FireGlowDemoScreen({super.key});

  // Hàm tạo danh sách BoxShadow cho hiệu ứng lửa
  List<BoxShadow> _createFireGlowShadows(double animationValue) {
    // animationValue sẽ dao động từ 0.0 đến 1.0
    return [
      BoxShadow(
        color: Colors.red.withOpacity(
            0.6 + (0.2 * animationValue)), // Đỏ mạnh, độ mờ thay đổi
        spreadRadius: 3.0 + (2.0 * animationValue), // Độ lan rộng nhấp nháy
        blurRadius: 15.0 + (10.0 * animationValue), // Độ mờ nhấp nháy
        offset: const Offset(0, 0),
      ),
      BoxShadow(
        color: Colors.orange
            .withOpacity(0.5 + (0.2 * animationValue)), // Cam, lớp giữa
        spreadRadius: 2.0 + (1.5 * animationValue),
        blurRadius: 10.0 + (7.0 * animationValue),
        offset: const Offset(0, 0),
      ),
      BoxShadow(
        color: Colors.yellow
            .withOpacity(0.4 + (0.2 * animationValue)), // Vàng, lớp trong
        spreadRadius: 1.0 + (1.0 * animationValue),
        blurRadius: 5.0 + (3.0 * animationValue),
        offset: const Offset(0, 0),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fire Glow Demo'),
        backgroundColor: Colors.grey.shade900,
      ),
      backgroundColor: Colors.black, // Nền đen để hiệu ứng glow nổi bật
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500), // 1 giây cho 1 chu kỳ
          curve: Curves.easeInOutSine, // Đường cong mượt mà
          // repeat: true;  // Không có thuộc tính repeat trực tiếp ở đây,
          // chúng ta sẽ sử dụng callback `onEnd` để lặp lại animation.
          onEnd: () {
            // Khi animation kết thúc, bạn có thể kích hoạt lại nó
            // Đây là một ví dụ đơn giản, trong thực tế bạn có thể cần State để quản lý
            // Tuy nhiên, `TweenAnimationBuilder` tự động lặp lại nếu target là giá trị cuối cùng
            // và bạn muốn chuyển đổi giữa 2 giá trị. Để lặp lại vô hạn, chúng ta cần dùng AnimationController
            // hoặc trick `onEnd` với setState.
            // Nhưng cách đơn giản nhất để demo là để nó chạy 1 lần.
            // Để nó lặp lại, chúng ta sẽ làm nó ở ví dụ nâng cao hơn một chút.

            // Để lặp lại liên tục với TweenAnimationBuilder, bạn có thể thay đổi `end`
            // thành `0.0` khi nó kết thúc ở `1.0` và ngược lại.
            // Nhưng đó sẽ làm phức tạp `StatelessWidget`.
            // Để đơn giản, hãy hình dung nó đang nhấp nháy 1 lần.
            // Trong ứng dụng thật, nó sẽ nằm trong StatefulWidget hoặc Bloc
            // nơi bạn có thể reset animation.

            // Để demo lặp lại vô hạn trong StatelessWidget, cách "hack" đơn giản nhất
            // là dùng một key thay đổi để buộc nó rebuild và reset animation.
            // Tuy nhiên, điều này không phải là cách tốt nhất cho production.
            // Tôi sẽ giữ nó chạy một chu kỳ cho demo đơn giản này.
          },
          builder: (context, animationValue, child) {
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade900, // Màu nền của widget
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.red.shade700, // Border chính màu đỏ
                  width: 3,
                ),
                // Áp dụng hiệu ứng lửa ở đây
                boxShadow: _createFireGlowShadows(animationValue),
              ),
              alignment: Alignment.center,
              child: const Text(
                'GLOWING!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FireGlowDemoScreen2 extends StatefulWidget {
  const FireGlowDemoScreen2({super.key});

  @override
  State<FireGlowDemoScreen2> createState() => _FireGlowDemoScreenState2();
}

class _FireGlowDemoScreenState2 extends State<FireGlowDemoScreen2> {
  bool _isGlowing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The widget we want to animate
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(20),
                // Border and boxShadow will be animated by .animate()
              ),
              alignment: Alignment.center,
              child: const Text(
                'GLOWING!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                .animate(
                  // Use `key` to reset animation when _isGlowing changes
                  key: ValueKey(_isGlowing),
                  onPlay: (controller) {
                    if (_isGlowing) {
                      controller.repeat(); // Loop the animation
                    } else {
                      controller.stop(); // Stop the animation
                      // Optionally reset to default state if you want
                      // controller.reset();
                    }
                  },
                )
                // Custom effect for border animation
                .custom(
                  duration: 800.ms,
                  builder: (context, value, child) {
                    // value will go from 0.0 to 1.0 (and back based on chaining)
                    // Interpolate border properties manually
                    final Color beginColor = Colors.red.shade700;
                    final Color endColor = Colors.orange.shade700;
                    final double beginWidth = 2;
                    final double endWidth = 2;

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color.lerp(beginColor, endColor,
                              value)!, // Interpolate color
                          width: beginWidth +
                              (endWidth - beginWidth) *
                                  value, // Interpolate width
                        ),
                      ),
                      child: child,
                    );
                  },
                )
                // Chain the reverse border animation
                .then(delay: 400.ms)
                .custom(
                  duration: 800.ms,
                  builder: (context, value, child) {
                    final Color beginColor = Colors.orange.shade700;
                    final Color endColor = Colors.red.shade700;
                    final double beginWidth = 2;
                    final double endWidth = 3;

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color.lerp(beginColor, endColor, value)!,
                          width: beginWidth + (endWidth - beginWidth) * value,
                        ),
                      ),
                      child: child,
                    );
                  },
                )
                // BoxShadow effect for the fire glow
                .boxShadow(
                  borderRadius: BorderRadius.circular(29),
                  begin: BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 5,
                      spreadRadius: 0),
                  end: BoxShadow(
                      color: Colors.yellow.withOpacity(0.4),
                      blurRadius: 5,
                      spreadRadius: 2),
                  duration: 1000.ms,
                  curve: Curves.easeInOutSine,
                )
                .then(delay: 500.ms)
                .boxShadow(
                  borderRadius: BorderRadius.circular(29),
                  begin: BoxShadow(
                      color: Colors.red.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 5),
                  end: BoxShadow(
                      color: Colors.orange.withOpacity(0.4),
                      blurRadius: 3,
                      spreadRadius: 0),
                  duration: 1000.ms,
                  curve: Curves.easeInOutSine,
                )
            // Only show the animated version if _isGlowing is true
            // Otherwise, show a default Container
            ,

            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isGlowing = !_isGlowing;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isGlowing ? Colors.red.shade700 : Colors.blueGrey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _isGlowing ? 'TẮT HIỆU ỨNG' : 'BẬT HIỆU ỨNG',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Nhấn nút để bật/tắt hiệu ứng lửa rực cháy!',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            )
          ],
        ),
      ),
    );
  }
}

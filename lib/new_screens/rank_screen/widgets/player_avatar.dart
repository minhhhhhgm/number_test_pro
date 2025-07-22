part of '../rank_screen.dart';

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar(
      {this.radius = 24, this.backgroundColor, required this.playerName});

  final double radius;
  final Color? backgroundColor;
  final String playerName;

  @override
  Widget build(BuildContext context) {
    final Random random = Random(playerName.hashCode);
    final Color avatarColor = backgroundColor ??
        Color.fromRGBO(
          random.nextInt(200) + 50,
          random.nextInt(200) + 50,
          random.nextInt(200) + 50,
          1,
        );
    return CircleAvatar(
      radius: radius,
      backgroundColor: avatarColor,
      child: Text(
        playerName.substring(0, 1).toUpperCase(),
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

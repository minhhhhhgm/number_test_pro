part of '../home_screen_new.dart';

class _GameMode extends StatelessWidget {
  const _GameMode(
      {required this.titleGame,
      required this.descriptionGame,
      required this.iconGamePath,
      required this.backgroundColor,
      required this.borderColor,
      required this.gameMode,
      this.onTap});

  final String titleGame;
  final String descriptionGame;
  final String iconGamePath;
  final Color backgroundColor;
  final Color borderColor;
  final GameDifficulty gameMode;

  final Function(GameDifficulty gameMode)? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(gameMode);
        }
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              width: 4,
              color: borderColor,
            ),
            borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleGame,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    descriptionGame,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Text('play'.tr())
                      ],
                    ),
                  )
                ],
              ),
            ),
            Image.asset(
              iconGamePath,
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}

part of '../game_screen.dart';

class _ToolHelperWidget extends StatelessWidget {
  const _ToolHelperWidget({required this.borderColor});

  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(16)),
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconCustom(
              onTap: () {
                context.read<GameBloc>().add(AddTime());
              },
              icon: Icons.more_time),
          SizedBox(
            width: 30,
          ),
          IconCustom(
              onTap: () {
                context.read<GameBloc>().add(HintUsed());
              },
              icon: Icons.lightbulb_outline),
          SizedBox(
            width: 30,
          ),
          IconCustom(
              onTap: () {
                context.read<GameBloc>().add(NextTurn());
              },
              icon: Icons.skip_next),
        ],
      ),
    );
  }

  Widget IconCustom({IconData? icon, required Function() onTap}) {
    return IconButton(
      icon: Icon(icon, size: 32, color: borderColor),
      onPressed: onTap,
    );
  }
}

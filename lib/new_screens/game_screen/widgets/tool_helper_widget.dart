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
              text: '+20s',
              onTap: () {
                context.read<GameBloc>().add(AddTime());
              },
              color: borderColor,
              icon: Icons.more_time),
          SizedBox(
            width: 30,
          ),
          IconCustom(
              text: 'Hint',
              onTap: () {
                context.read<GameBloc>().add(HintUsed());
              },
              color: borderColor,
              icon: Icons.lightbulb_outline),
          SizedBox(
            width: 30,
          ),
          IconCustom(
              text: 'Next',
              onTap: () {
                context.read<GameBloc>().add(NextTurn());
              },
              color: borderColor,
              icon: Icons.skip_next),
        ],
      ),
    );
  }

  Widget IconCustom(
      {IconData? icon,
      required Function() onTap,
      required String text,
      Color? color}) {
    return Column(
      children: [
        InkWell(onTap: onTap, child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4, left: 8, right: 8),
          child: Icon(icon, size: 32, color: borderColor),
        )),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        )
      ],
    );
  }
}

part of '../game_screen.dart';

class _NumberBlocks extends StatelessWidget {
  final List<BlockSchemaNew> blocks;
  final Color textColor, borderColor;

  const _NumberBlocks(
      {required this.blocks,
      required this.textColor,
      required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(16)),
      padding: EdgeInsets.all(30),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: List.generate(blocks.length, (i) {
          final block = blocks[i];
          return numberBlock(
            bgColor: block.color,
            index: i,
            value: block.value,
            isHint: block.isHint,
            isSelected: block.isSelected,
            triggerHint: block.triggerHint,
            onTap: () {
              if (!block.isSelected) {
                context
                    .read<GameBloc>()
                    .add(BlockSelected(index: i, value: block.value));
              }
            },
          );
        }),
      ),
    );
  }

  Widget numberBlock({
    Color? bgColor = const Color(0xFFeff2e9),
    required int index,
    required int value,
    bool isHint = false,
    bool isSelected = false,
    bool triggerHint = false,
    required VoidCallback onTap,
  }) {
    return Animate(
      key: ValueKey('${index}_${isHint}_${triggerHint}'),
      effects: isHint
          ? [
              ShakeEffect(duration: 700.ms, hz: 10),
            ]
          : [],
      child: Material(
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 90,
            height: 90,
            alignment: Alignment(0.0, 0.0),
            decoration: BoxDecoration(
                color: Color(0xFFeff2e9),
                border: Border.all(
                  color: isSelected ? bgColor! : borderColor,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(10)),
            child: Text(
              value.toString(),
              style: TextStyle(
                  color: textColor, fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

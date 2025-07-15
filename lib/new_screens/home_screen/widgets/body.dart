part of '../home_screen_new.dart';

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _BottomNavigationBar(),
      body: PageView(
        onPageChanged: (pageChange) {
          context
              .read<HomeBloc>()
              .add(UpdatePageChangeEvent(pageChange: pageChange));
        },
        controller: context.read<HomeBloc>().pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          RankScreen(),
          _BodyHome(),
          GameScreen(),
          // HomeScreen(),
        ],
      ),
    );
  }
}

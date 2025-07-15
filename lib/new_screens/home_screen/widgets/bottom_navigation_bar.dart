part of '../home_screen_new.dart';

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeBloc, HomeState, int>(
      selector: (state) => state.selectedIndex,
      builder: (context, selectedIndex) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 1,
          ),
          unselectedFontSize: 1,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: renderIcon(
                  selectedIndex: selectedIndex,
                  context: context,
                  index: 0,
                  imagePath: 'assets/icon/home-agreement.png'),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: renderIcon(
                  selectedIndex: selectedIndex,
                  context: context,
                  index: 1,
                  imagePath: 'assets/icon/ranking.png'),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: renderIcon(
                  selectedIndex: selectedIndex,
                  context: context,
                  index: 2,
                  imagePath: 'assets/icon/setting.png'),
              label: '',
            ),
          ],
          currentIndex: selectedIndex,
          onTap: (index) async {
            if (selectedIndex == index) return;
            if (!context.mounted) {
              return;
            }
            context
                .read<HomeBloc>()
                .add(UpdateSelectedIndex(selectedIndex: index));
          },
        );
      },
    );
  }

  Widget renderIcon(
      {required int selectedIndex,
      required int index,
      required String imagePath,
      required BuildContext context}) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
            color: selectedIndex == index ? Color(0xFFc5e6f4) : null,
            borderRadius: BorderRadius.circular(30)),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(top: 8),
        child: Image.asset(
          imagePath,
          color: selectedIndex == index ? Colors.blue : Color(0xFFb1b1b1),
          width: 24,
        ),
      ),
    );
  }
}

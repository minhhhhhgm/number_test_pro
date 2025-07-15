import 'package:flutter/material.dart';

class ScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ScreenAppBar(
      {super.key,
      required this.title,
      this.onTap,
      this.actionWidget,
      this.isCenterTitle = false});
  final Function()? onTap;
  final String title;
  final Widget? actionWidget;
  final bool isCenterTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: isCenterTitle,
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      leading: Navigator.of(context).canPop()
          ? Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            )
          : null,
      actions: [
        if (actionWidget != null) InkWell(onTap: onTap, child: actionWidget),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

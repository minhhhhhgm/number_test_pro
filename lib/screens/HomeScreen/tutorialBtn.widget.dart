import 'package:flutter/material.dart';
import 'package:numbers/utils/constants.dart';

class TutorialWidget extends StatelessWidget {
  const TutorialWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: primaryColor,
        onPressed: () {
          Navigator.of(context).pushNamed('/tutorial');
        },
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 10,
            ),
            Icon(
              Icons.help,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              ' HOW TO PLAY',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

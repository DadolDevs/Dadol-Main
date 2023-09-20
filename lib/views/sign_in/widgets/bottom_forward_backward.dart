import 'package:feelingapp/resources/dadol_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:icon_shadow/icon_shadow.dart';

class AdvanceLoginRegisterBar extends StatelessWidget {
  final forwardEnabled;
  final backEnabled;
  final buttonPressedCallback;
  final bool addShadows;

  AdvanceLoginRegisterBar({
    this.backEnabled = true,
    this.forwardEnabled = false,
    this.buttonPressedCallback,
    this.addShadows = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(width: 20),
            backEnabled
                ? Container(
                    child: GestureDetector(
                      child: IconShadowWidget(
                        Icon(
                          DadolIcons.x_back_arrow,
                          color: Colors.white,
                          size: 45,
                        ),
                        showShadow: addShadows,
                        shadowColor: Colors.black,
                      ),
                      onTap: () {
                        buttonPressedCallback(0);
                      },
                    ),
                  )
                : Container(),
            Spacer(),
            forwardEnabled
                ? Container(
                    child: GestureDetector(
                      child: IconShadowWidget(
                        Icon(
                          DadolIcons.x_next_arrow,
                          color: Colors.white,
                          size: 45,
                        ),
                        shadowColor: Colors.black,
                        showShadow: addShadows,
                      ),
                      onTap: () {
                        buttonPressedCallback(1);
                      },
                    ),
                  )
                : Container(),
                SizedBox(width: 20),
          ],
        ));
  }
}

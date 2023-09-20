import 'package:feelingapp/resources/style_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BottomNavBar extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Gradient gradient = new LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.orangeAccent, Colors.yellow],
      tileMode: TileMode.clamp,
    );

    final Rect colorBounds = Rect.fromLTRB(0, 0, size.width, size.height);
    final Paint paint = new Paint()
      ..shader = gradient.createShader(colorBounds);

    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.9);
    path.lineTo(size.width * 0.5, size.height * 0.93);
    path.lineTo(size.width * 0.5, size.height * 0.93);
    path.lineTo(0, size.height * 0.9);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final x = size.width;
    final y = size.height;

    path.lineTo(0, 0);
    path.lineTo(0, y);
    path.lineTo(x, y);
    path.lineTo(x, 0);
    path.quadraticBezierTo(
        x, y * 0.5, x * 0.9, y * 0.5); //path.lineTo(x * 0.95, y * 0.5);
    path.lineTo(x * 0.1, y * 0.5);
    //path.lineTo(0, 0);
    path.quadraticBezierTo(0, y * 0.5, 0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CustomBottomNavigationBar extends StatefulWidget {
  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 0,
              child: ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: 0.12 * MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: Style().dazzlePrimaryColor,
                ),
              ),
            ),
            /*Positioned(
              bottom: 10,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(Icons.arrow_back),
                  Container(),
                  Icon(Icons.arrow_back),
                  Container(),
                  Icon(Icons.arrow_back),
                ],
              ),
            )*/
          ],
        ),
      ),
    );
  }
}

class CustomNavItem extends StatelessWidget {
  final IconData icon;
  final int id;
  final Function setPage;

  const CustomNavItem({this.setPage, this.icon, this.id});

  @override
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setPage();
      },
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: CircleAvatar(
          radius: 25,
          backgroundColor:
              1 == 1 ? Colors.white.withOpacity(0.9) : Colors.transparent,
          child: Icon(
            icon,
            color: 1 == 1 ? Colors.black : Colors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }
}

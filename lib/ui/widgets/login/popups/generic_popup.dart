import 'package:flutter/material.dart';

/// Represents the popup that is shown to the user when the account has
/// been generated and he can go to the first page of the application.
class LoginPopup extends StatelessWidget {
  final Widget content;

  const LoginPopup({
    Key key,
    @required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          constraints: BoxConstraints.expand(),
          child: CustomPaint(
            painter: _BackgroundPainter(color: Colors.white),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Color(0xFF40318972), blurRadius: 15),
                ],
              ),
              child: Wrap(
                children: [
                  content,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Represents the painter that is used to paint the oblique lines
/// on the popup background.
class _BackgroundPainter extends CustomPainter {
  final Color color;

  _BackgroundPainter({@required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();
    path.moveTo(0, size.height * 0.40);
    path.lineTo(size.width * 0.50, size.height * 0.60);
    path.lineTo(size.width, size.height * 0.40);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

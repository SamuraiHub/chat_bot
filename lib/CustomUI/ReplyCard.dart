import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReplyCard extends StatelessWidget {
  const ReplyCard(
      {Key? key, required this.message, required this.img, required this.time})
      : super(key: key);
  final String message;
  final bool img;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Image.asset(
                'assets/bot_image.jpg',
                scale: 2.25,
              ),
            ),
            Expanded(
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                color: Color(0x6353d7),
                margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 50,
                        top: 5,
                        bottom: 20,
                      ),
                      child: img
                          ? kIsWeb
                              ? Image.network('assets/' + message)
                              : Image.asset(message)
                          : Text(
                              message,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 3,
                      right: 10,
                      child: Text(
                        time.substring(time.length - 7, time.length),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

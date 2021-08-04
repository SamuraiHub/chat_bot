import 'package:flutter/material.dart';

class InputWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSentMessage;
  final focusNode = FocusNode();

  InputWidget({
    required this.controller,
    required this.onSentMessage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        height: 50,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(width: 0.5)),
          color: Colors.white,
        ),
        child: Row(
          children: <Widget>[
            Expanded(child: buildTextField()),
            buildSend(),
          ],
        ),
      );

  Widget buildTextField() => TextField(
      focusNode: focusNode,
      controller: controller,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Type your message...',
        hintStyle: TextStyle(color: Colors.grey),
      ),
      onSubmitted: (value) {
        if (controller.text.trim().isEmpty) {
          return;
        }

        onSentMessage(controller.text);
        controller.clear();
      });

  Widget buildSend() => Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Color.fromRGBO(99, 83, 215, 1.0),
            shape: CircleBorder(),
          ),
          child: Icon(Icons.send, color: Colors.white),
          onPressed: () {
            if (controller.text.trim().isEmpty) {
              return;
            }

            onSentMessage(controller.text);
            controller.clear();
          },
        ),
      );
}

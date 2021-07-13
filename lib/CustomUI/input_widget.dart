import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSentMessage;
  final VoidCallback onAttachFiles;
  final bool attachFiles;
  final focusNode = FocusNode();

  InputWidget({
    required this.controller,
    required this.onSentMessage,
    required this.attachFiles,
    required this.onAttachFiles,
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
        suffixIcon: attachFiles
            ? IconButton(
                icon: Icon(
                  Icons.attach_file,
                  color: Colors.grey,
                ),
                onPressed: () {
                  onAttachFiles();
                },
              )
            : Container(
                width: 0,
                height: 0,
              ),
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
        child: IconButton(
          icon: Icon(Icons.send),
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

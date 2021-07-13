import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

class ReplyCard extends StatelessWidget {
  const ReplyCard(
      {Key? key, required this.message, required this.pdf, required this.time})
      : super(key: key);
  final String message;
  final bool pdf;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Color(0x6353d7),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 50,
                  top: 5,
                  bottom: 20,
                ),
                child: pdf
                    ? PdfDocumentLoader.openAsset(message,
                        pageNumber: 1,
                        pageBuilder: (context, textureBuilder, pageSize) =>
                            textureBuilder())
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
    );
  }
}

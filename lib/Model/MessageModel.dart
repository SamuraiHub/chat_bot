//model for messages and images
class MessageModel {
  String type; // whether it is source or destination.
  String message; // the message itself
  bool img; // if the message is an img invoice
  String time; // time of the post message
  MessageModel(
      {required this.message,
      required this.img,
      required this.type,
      required this.time});
}

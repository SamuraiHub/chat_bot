//model for messages and images
class MessageModel {
  String type; // whether it is source or destination.
  String message; // the message itself
  String time; // time of the post message
  MessageModel({
    required this.message,
    required this.type,
    required this.time,
  });
}

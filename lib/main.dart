import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import 'package:chat_bot/Model/MessageModel.dart';
import 'package:flutter/material.dart';
import 'package:ibm_watson_assistant/ibm_watson_assistant.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
//import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'CustomUI/LoadingIndicator.dart';
import 'CustomUI/OwnMessgaeCard.dart';
import 'CustomUI/ReplyCard.dart';
import 'CustomUI/input_widget.dart';
//import 'package:dotenv/dotenv.dart';

Future<void> main() async {
  final keyApplicationId = 'D6dptmQgK5Gc8597jkAXM43npMN9EoGKID00udv3';
  final keyClientKey = '3ED2cEggwkyMxircMJhGi8xmWh49P8I0oSVBuOMi';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  /*MaterialColor myColor = MaterialColor(
    0x6353d7,
    <int, Color>{
      50: Color.fromRGBO(99, 83, 215, 0.05),
      100: Color.fromRGBO(99, 83, 215, 0.1),
      200: Color.fromRGBO(99, 83, 215, 0.2),
      300: Color.fromRGBO(99, 83, 215, 0.3),
      400: Color.fromRGBO(99, 83, 215, 0.4),
      500: Color.fromRGBO(99, 83, 215, 0.5),
      600: Color.fromRGBO(99, 83, 215, 0.6),
      700: Color.fromRGBO(99, 83, 215, 0.7),
      800: Color.fromRGBO(99, 83, 215, 0.8),
      900: Color.fromRGBO(99, 83, 215, 0.9)
    },
  );*/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepPurple,
      ),
      home: MyHomePage(title: 'ChatBot'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final List<MessageModel> messages = List.filled(
      0, MessageModel(type: 'Destination', message: '', pdf: false, time: ''),
      growable: true);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool attachFiles = false;
  bool load = false;

  late final IbmWatsonAssistant bot;
  late final String sessionId;

  Widget Messages() {
    return ListView.builder(
      shrinkWrap: true,
      controller: _scrollController,
      itemCount: widget.messages.length + 1,
      itemBuilder: (context, index) {
        if (index == widget.messages.length) {
          return Container(
            height: 50,
          );
        }
        if (widget.messages[index].type == "Source") {
          return OwnMessageCard(
            message: widget.messages[index].message,
            time: widget.messages[index].time,
          );
        } else {
          return ReplyCard(
            message: widget.messages[index].message,
            pdf: widget.messages[index].pdf,
            time: widget.messages[index].time,
          );
        }
      },
    );
  }

  Future<String> sendMessage(String message) async {
    final botRes = await bot.sendInput(message, sessionId: sessionId);
    return botRes.responseText!;
  }

  void setMessage(String message) {
    MessageModel messageModel = MessageModel(
        type: 'Source',
        pdf: false,
        message: message,
        time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()));
    //print(messages);

    setState(() {
      widget.messages.add(messageModel);
    });
  }

  Future<bool> initializeBot() async {
    final auth = IbmWatsonAssistantAuth(
      assistantId: '253399a1-7e39-4821-aa10-a9d02bfcce0b',
      url:
          'https://api.eu-gb.assistant.watson.cloud.ibm.com/instances/5b2cd507-95e5-454a-93e3-abd16c34cde3',
      apikey: 'ahWLu_giqzAhznTGX6PwKivS5HK6D65FyY8e27mI3KX_',
    );

    bot = IbmWatsonAssistant(auth);

    sessionId = (await bot.createSession())!;

    return true;
  }

  Future<String> botFirstMessage() async {
    final botRes = await bot.sendInput('hello', sessionId: sessionId);

    return botRes.responseText!;
  }

  void initState() {
    initializeBot().then((value) {
      if (value) {
        botFirstMessage().then((value) {
          MessageModel messageModel = MessageModel(
            type: 'Destination',
            message: value,
            pdf: false,
            time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()),
          );

          setState(() {
            load = true;
            widget.messages.add(messageModel);
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
            backgroundColor: Color.fromRGBO(99, 83, 215, 1.0),
            leadingWidth: 70,
            titleSpacing: 0,
            leading: InkWell(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/bot_image_PB.jpg",
                    height: 36,
                    width: 36,
                  ),
                ],
              ),
            ),
            title: InkWell(
              onTap: () {},
              child: Container(
                margin: EdgeInsets.all(6),
                child: Text('Chat Bot'),
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                onPressed: () {
                  // do something
                  setState(() {
                    if (widget.messages.length > 1) {
                      widget.messages.removeRange(1, widget.messages.length);
                    }
                  });
                },
              ),
            ]),
      ),
      body: load
          ? Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                      //height: MediaQuery.of(context).size.height - 250,
                      child: Messages()),
                  InputWidget(
                    controller: _controller,
                    attachFiles: attachFiles,
                    onAttachFiles: () {
                      pickFiles().then((value) {
                        if (value != null) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return WillPopScope(
                                  onWillPop: () async => false,
                                  child: AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0))),
                                    backgroundColor: Colors.white,
                                    content: LoadingIndicator(),
                                  ));
                            },
                          );

                          uploadFiles(value).then((value) {
                            if (value) {
                              sendMessage('Documents Uploaded').then((value) {
                                MessageModel messageModel = MessageModel(
                                  type: 'Destination',
                                  message: value,
                                  pdf: false,
                                  time: DateFormat('dd-MMMM-yyyy – hh:mm a')
                                      .format(DateTime.now()),
                                );

                                widget.messages.add(messageModel);

                                if (value.startsWith(
                                    'Documents have been uploaded.')) {
                                  int sr = value.indexOf('your', 51) + 5;
                                  String sv = value.substring(sr);

                                  if (sv == 'trade license:') {
                                    MessageModel messageModel = MessageModel(
                                      type: 'Destination',
                                      message: kIsWeb
                                          ? 'assets/TL_Invoice.jpg'
                                          : 'assets/TL_Invoice.jpg',
                                      pdf: true,
                                      time: DateFormat('dd-MMMM-yyyy – hh:mm a')
                                          .format(DateTime.now()),
                                    );
                                    widget.messages.add(messageModel);
                                  } else if (sv == 'driver license:') {
                                    MessageModel messageModel = MessageModel(
                                      type: 'Destination',
                                      message: kIsWeb
                                          ? 'assets/DL_Invoice.jpg'
                                          : 'assets/DL_Invoice.jpg',
                                      pdf: true,
                                      time: DateFormat('dd-MMMM-yyyy – hh:mm a')
                                          .format(DateTime.now()),
                                    );
                                    widget.messages.add(messageModel);
                                  } else {
                                    MessageModel messageModel = MessageModel(
                                      type: 'Destination',
                                      message: kIsWeb
                                          ? 'assets/WP_Invoice.jpg'
                                          : 'assets/WP_Invoice.jpg',
                                      pdf: true,
                                      time: DateFormat('dd-MMMM-yyyy – hh:mm a')
                                          .format(DateTime.now()),
                                    );
                                    widget.messages.add(messageModel);
                                  }

                                  sendMessage('Another Service').then((value) {
                                    MessageModel messageModel = MessageModel(
                                      type: 'Destination',
                                      message: value,
                                      pdf: false,
                                      time: DateFormat('dd-MMMM-yyyy – hh:mm a')
                                          .format(DateTime.now()),
                                    );
                                    setState(() {
                                      widget.messages.add(messageModel);
                                      attachFiles = false;
                                      Navigator.of(context).pop();
                                    });
                                  });
                                }

                                _moveScroll();
                              });
                            }
                          });
                        }
                      });
                    },
                    onSentMessage: (message) {
                      setMessage(message);
                      sendMessage(message).then((value) {
                        MessageModel messageModel = MessageModel(
                          type: 'Destination',
                          message: value,
                          pdf: false,
                          time: DateFormat('dd-MMMM-yyyy – hh:mm a')
                              .format(DateTime.now()),
                        );

                        setState(() {
                          widget.messages.add(messageModel);

                          if (value.startsWith('Please upload')) {
                            attachFiles = true;
                          }
                        });

                        _moveScroll();
                      });
                    },
                  ),
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Future<FilePickerResult?> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'docx'],
    );

    if (result != null) {
      if (result.count != 3) {
        showError('Please select 3 files only');
        return null;
      } else {
        return result;
      }
    }

    return null;
  }

  Future<bool> uploadFiles(FilePickerResult result) async {
    ParseFileBase parseFile;
    ParseFileBase parseFile1;
    ParseFileBase parseFile2;

    if (kIsWeb) {
      parseFile =
          ParseWebFile(result.files[0].bytes!, name: result.files[0].name);
      parseFile1 =
          ParseWebFile(result.files[1].bytes!, name: result.files[1].name);
      parseFile2 =
          ParseWebFile(result.files[2].bytes!, name: result.files[2].name);
    } else {
      parseFile = ParseFile(File(result.paths[0]!));
      parseFile1 = ParseFile(File(result.paths[1]!));
      parseFile2 = ParseFile(File(result.paths[2]!));
    }
    var putFiles = ParseObject('Documents')
      ..set('File1', parseFile)
      ..set('File2', parseFile1)
      ..set('File3', parseFile2);
    var response = await putFiles.save();
    if (response.success) {
      parseFile.upload(
          progressCallback: (int count, int total) =>
              print("$count of $total"));
      parseFile1.upload(
          progressCallback: (int count, int total) =>
              print("$count of $total"));
      parseFile2.upload(
          progressCallback: (int count, int total) =>
              print("$count of $total"));
      return true;
    } else {
      Navigator.of(context).pop();
      showError('Upload failed. Please try again');
      return false;
    }
  }

  void showError(String errorMessage) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error!"),
          content: Text(
            errorMessage,
            maxLines: 3,
          ),
          actions: <Widget>[
            new TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _moveScroll() {
    Timer(Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }
}

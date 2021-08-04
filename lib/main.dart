import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:chat_bot/Model/MessageModel.dart';
import 'package:flutter/material.dart';
import 'package:ibm_watson_assistant/ibm_watson_assistant.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
//import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

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
      0, MessageModel(type: 'Destination', message: '', img: false, time: ''),
      growable: true);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool load = false;
  bool attach =
      false; // attach is true when the user needs to upload name address or phone number.

  late final IbmWatsonAssistant bot;
  late final String sessionId;

  int f = 0; // number of selected files;
  String objectId = ''; // id of the row which contain the selected files;

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
            img: widget.messages[index].img,
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

  void getResponse(String message) {
    sendMessage(message).then((value) {
      if (value.startsWith('Please')) {
        int i = value.indexOf('Please', 5);

        String value1 = value.substring(0, i - 1);
        String value2 = value.substring(i);

        MessageModel messageModel1 = MessageModel(
          type: 'Destination',
          message: value1,
          img: false,
          time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()),
        );
        MessageModel messageModel2 = MessageModel(
          type: 'Destination',
          img: false,
          message: value2,
          time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()),
        );

        setState(() {
          widget.messages.add(messageModel1);
          widget.messages.add(messageModel2);
          attach = true;
        });
      } else if (value.startsWith('Your')) {
        int i = value.indexOf('Here', 4);
        String value1 = value.substring(0, i - 1);
        String value2 = value.substring(i);

        MessageModel messageModel1 = MessageModel(
          type: 'Destination',
          message: value1,
          img: false,
          time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()),
        );
        MessageModel messageModel2 = MessageModel(
          type: 'Destination',
          message: value2,
          img: false,
          time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()),
        );

        String sv = value2.substring(38);

        MessageModel messageModel3;

        if (sv == 'trade license:') {
          messageModel3 = MessageModel(
            type: 'Destination',
            message: kIsWeb ? 'assets/TL_Invoice.jpg' : 'assets/TL_Invoice.jpg',
            img: true,
            time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()),
          );
        } else if (sv == 'market license:') {
          messageModel3 = MessageModel(
            type: 'Destination',
            message: kIsWeb ? 'assets/ML_Invoice.jpg' : 'assets/ML_Invoice.jpg',
            img: true,
            time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()),
          );
        } else {
          messageModel3 = MessageModel(
            type: 'Destination',
            message: kIsWeb ? 'assets/BL_Invoice.jpg' : 'assets/BL_Invoice.jpg',
            img: true,
            time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()),
          );
        }

        setState(() {
          widget.messages.add(messageModel1);
          widget.messages.add(messageModel2);
          widget.messages.add(messageModel3);
          attach = false;
        });
      } else {
        MessageModel messageModel = MessageModel(
          type: 'Destination',
          message: value,
          img: false,
          time: DateFormat('dd-MMMM-yyyy – hh:mm a').format(DateTime.now()),
        );
        setState(() {
          widget.messages.add(messageModel);
        });
      }
      _moveScroll();
    });
  }

  void setMessage(String message) {
    MessageModel messageModel = MessageModel(
        type: 'Source',
        message: message,
        img: false,
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

  @override
  void initState() {
    super.initState();
    initializeBot().then((value) {
      if (value) {
        botFirstMessage().then((value) {
          MessageModel messageModel = MessageModel(
            type: 'Destination',
            message: value,
            img: false,
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
                      f = 0;
                      objectId = '';
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
                    attachFile: attach,
                    onAttachFile: () {
                      pickFile().then((value) {
                        if (value != null) {
                          f++;
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
                          uploadFile(value, f).then((value) {
                            if (value) {
                              Navigator.of(context).pop();
                              getResponse('OK');
                            } else {
                              f--;
                            }
                            if (f == 3) {
                              f = 0;
                              objectId = '';
                            }
                          });
                        }
                      });
                    },
                    onSentMessage: (message) {
                      setMessage(message);
                      getResponse(message);
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

  Future<FilePickerResult?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'docx', 'doc'],
    );

    return result;
  }

  Future<bool> uploadFile(FilePickerResult result, int f) async {
    ParseFileBase parseFile;

    if (kIsWeb) {
      parseFile = ParseWebFile(result.files.single.bytes!,
          name: result.files.single.name);
    } else {
      parseFile = ParseFile(File(result.files.single.path!));
    }
    var putFile = ParseObject('Documents');

    var response;

    if (f == 1 && objectId == "") {
      putFile..set('File' + f.toString(), parseFile);
      response = await putFile.save();
    } else {
      putFile
        ..objectId = objectId
        ..set('File' + f.toString(), parseFile);
      response = await putFile.save();
    }

    if (response.success) {
      objectId = putFile.objectId!;
      return true;
    } else {
      Navigator.of(context).pop();
      showError(
          'Upload failed. ' + response.error!.message + ' Please try again');
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

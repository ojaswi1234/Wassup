import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:logger/logger.dart';

String roomId = "UserA-UserB";
// Theme colors
const kPrimaryColor = Color(0xFFA67B00); // Dark Yellow
const kSecondaryColor = Color(0xFFFFC107); // Amber
const kBackgroundColor = Color(0xFF1E1E1E); // Dark Gray-Black
const kAccentColor = Color(0xFFFFCA28); // Light Amber
const kTextColor = Color(0xFFFFD54F); // Warm Yellow

bool isBlocked = false;

class ChatArea extends StatefulWidget {
  const ChatArea({super.key});

  @override
  State<ChatArea> createState() => _ChatAreaState();
}
class _ChatAreaState extends State<ChatArea> {
  io.Socket? socket;
  
  TextEditingController controller = TextEditingController();
  List<Chat> sendmessages = [];

  String statusColor = "red";
  String userStatus = "Offline";
  String userName = "";

  
  @override
  void initState() {
    super.initState();
    _initializeSocketChat();
  }

  void _initializeSocketChat() {
    socket = io.io('https://wassup-backend-5isl.onrender.com',
      io.OptionBuilder()
        .setTransports(['websocket']) // for Flutter or Dart VM
        .enableAutoConnect()
        .build(),
    );
    socket?.emit('join_room', roomId);
    setupListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setupListeners() {
    socket?.on('connect', (_) {
      Logger().i('socket connected');
      checkStatus();
    });
    socket?.on('disconnect', (_) {
      Logger().e('socket disconnected');
      checkStatus();
    });
    socket?.on('message', (data) {
      setState(() {
        sendmessages.add(Chat.fromJSON(data));
      });
    });
  }

  void getDetails() {
    socket?.emit('get_user_details', {});
    socket?.on('user_details', (data) {
      setState(() {
        userName = data['name'];
      });
    });
  }

  
  bool isSender(){
    return sendmessages.last.senderId == socket?.id;
  }

  void sendChat() {
    if (controller.text.isNotEmpty) {
      
      
      final chat = Chat(
        message: controller.text,
        timestamp: DateTime.now(),
        senderId: socket?.id ?? 'unknown',
      );


      socket?.emit('message', {
        'room': roomId,
        'message': chat.toJSON()
        
      });
      
      controller.clear();
    }
  }

  void checkStatus() {
    if (socket?.connected ?? false) {
      setState(() {
        statusColor = "green";
        userStatus = "Online";
      });
    } else {
      setState(() {
        statusColor = "red";
        userStatus = "Offline";
      });
    }
  }

  


  void refreshChat() async {
    socket?.emit('get_messages', {'room': roomId});
    socket?.once('messages', (data) {
      setState(() {
        sendmessages = (data as List).map((e) => Chat.fromJSON(e)).toList();
      });
    });
  }

  final List<String> actionList = [
    "Img",
    "Voice",
    "Doc",
    "Locate",
    "Contact",
  ];

  final Map<String, IconData> iconMap = {
    "Img": Icons.image,
    "Voice": Icons.mic,
    "Doc": Icons.document_scanner,
    "Locate": Icons.location_on,
    "Contact": Icons.person,
  };

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Number',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              userStatus,
              style: TextStyle(
                color: (userStatus == "Online" ? Colors.green : Colors.black),
                fontSize: 14,
              ),
            )
          ],
        ),
        leadingWidth: 72,
        elevation: 7,
        shadowColor: kAccentColor,
        actions: [
          IconButton(
            icon: Icon(Icons.call, color: Colors.white),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'profile_settings',
                child: Text('Profile Settings'),
              ),
              PopupMenuItem<String>(
                value: 'block',
                child: Text(isBlocked ? 'Unblock User' : 'Block User', style: TextStyle(color: isBlocked ? Colors.green : Colors.red)),
              ),
              PopupMenuItem<String>(
                value: 'clear_chat',
                child: Text('Clear Chat'),
              ),
              PopupMenuItem<String>(
                value: 'back',
                child: Text('Back to Chats'),
              ),
            ],
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              // Handle menu selection
              if (value == 'profile_settings') {
                Navigator.pushNamed(context, '/profile');
              }
              if (value == 'block') {
                setState(() {
                  isBlocked = !isBlocked;
                  if (isBlocked) {
                    socket?.disconnect();
                    userStatus = "Blocked";
                    statusColor = "cyan";
                  } else {
                    socket?.connect();
                    checkStatus();
                  }
                });
              }
              if (value == 'back') {
                Navigator.pushNamed(context, '/home');
              }
              if (value == 'clear_chat') {
                setState(() {
                  sendmessages.clear();
                });
              }
            },
          ),
        ],
        leading: Padding(
          padding: EdgeInsets.all(8),
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(''),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 72,
                          backgroundImage: AssetImage('assets/images/profile.png'),
                        ),
                        SizedBox(height: 16),
                        Text('My Number', style: TextStyle(fontSize: 18)),
                        Text('user@example.com', style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(onPressed: () {}, icon: Icon(Icons.message)),
                            IconButton(onPressed: () {}, icon: Icon(Icons.call)),
                          ],
                        )
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            shape: CircleBorder(
              side: BorderSide(
                color: userStatus == "Online" ? kTextColor : Colors.red,
                width: 2.0,
              ),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
          ),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.only(bottom: (width < 600 ? 32 : 0)),
        color: kBackgroundColor,
        child: Column(
          children: [
            // Messages display area
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  refreshChat();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: sendmessages.length,
                  itemBuilder: (context, index) {
                    final message = sendmessages[index];
                    return ConstrainedBox(constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.4,
                    ),
                    child: Container(
                      alignment: (isSender() ? Alignment.centerRight : Alignment.centerLeft),
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            
                            
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: (!isSender() ? kPrimaryColor : Colors.grey[800]),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.message,
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                Align(
                                  widthFactor: 4.0,
                                  alignment: Alignment.bottomRight,
                                  child: Icon(Icons.check, color: Colors.white, size: 14),
                                  
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0') } am',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    );
                  },
                ),
              ),
            ),
            // Input area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Form(
                      child: TextFormField(
                        controller: controller,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: kAccentColor),
                          filled: false,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(color: kTextColor, width: 1.0),
                          ),
                          suffixIcon: PopupMenuButton<String>(
                            icon: Transform.rotate(
                              angle: 3.14 / 2,
                              child: Icon(Icons.attachment, color: kPrimaryColor),
                            ),
                            color: const Color.fromARGB(255, 0, 0, 0),
                            itemBuilder: (context) => actionList.map((e) {
                              return PopupMenuItem<String>(
                                value: e,
                                child: Row(
                                  children: [
                                    Icon(iconMap[e], color: kTextColor),
                                    const SizedBox(width: 8),
                                    Text(e, style: TextStyle(color: kTextColor)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onSelected: (value) {
                              debugPrint(value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      sendChat();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                      foregroundColor: kPrimaryColor,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12.0),
                      elevation: 2.0,
                      minimumSize: const Size(44.0, 44.0),
                    ),
                    child: Icon(
                      Icons.send,
                      color: Color(0xFF1E1E1E),
                      size: 24.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Chat {
  final String message;
  final DateTime timestamp;
  final String senderId;

  Chat({
    required this.message,
    required this.timestamp,
    required this.senderId,
  });

  factory Chat.fromJSON(Map<String, dynamic> json) => Chat(
    message: json['message'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    senderId: json['senderId'] as String,
  );

  Map<String, dynamic> toJSON() => {
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'senderId': senderId,
  };
}


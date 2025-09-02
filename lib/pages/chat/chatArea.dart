import 'package:file_picker/file_picker.dart';
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

class ChatArea extends StatefulWidget {
  const ChatArea({super.key});

  @override
  State<ChatArea> createState() => _ChatAreaState();
}

class _ChatAreaState extends State<ChatArea> with AutomaticKeepAliveClientMixin {
  io.Socket? socket;
  
  TextEditingController controller = TextEditingController();
  List<Chat> sendmessages = [];
  ScrollController _scrollController = ScrollController();

  String statusColor = "red";
  String userStatus = "Offline";
  String userName = "";
  bool isBlocked = false;
  
  @override
  bool get wantKeepAlive => true;

  
  @override
  void initState() {
    super.initState();
    _initializeSocketChat();
    getDetails(); // Get user details
  }

  void _initializeSocketChat() {
    try {
      socket = io.io('https://wassup-backend-5isl.onrender.com',
        io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .build(),
      );
      
      socket?.emit('join_room', roomId);
      setupListeners();
      
      Logger().i('Socket initialized for room: $roomId');
    } catch (e) {
      Logger().e('Socket initialization error: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    controller.dispose();
    socket?.dispose();
    super.dispose();
  }

  void setupListeners() {
    socket?.on('connect', (_) {
      Logger().i('socket connected');
      checkStatus();
      // Request existing messages when connected
      refreshChat();
    });
    socket?.on('disconnect', (_) {
      Logger().e('socket disconnected');
      checkStatus();
    });
    socket?.on('message', (data) {
      Logger().i('Received message: $data');
      try {
        final newMessage = Chat.fromJSON(data);
        // Check if message is not from current user (to avoid duplicates)
        if (newMessage.senderId != socket?.id) {
          setState(() {
            sendmessages.add(newMessage);
          });
          
          // Auto-scroll to bottom when receiving
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      } catch (e) {
        Logger().e('Error parsing message: $e');
      }
    });
    socket?.on('messages', (data) {
      Logger().i('Received messages history: $data');
      try {
        setState(() {
          sendmessages = (data as List).map((e) => Chat.fromJSON(e)).toList();
        });
      } catch (e) {
        Logger().e('Error parsing messages history: $e');
      }
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
      final messageText = controller.text.trim();
      
      final chat = Chat(
        message: messageText,
        timestamp: DateTime.now(),
        senderId: socket?.id ?? 'unknown',
      );

      // Add message to local list immediately for better UX
      setState(() {
        sendmessages.add(chat);
      });

      // Send message to server
      socket?.emit('message', {
        'room': roomId,
        'message': chat.toJSON()
      });
      
      controller.clear();
      
      // Auto-scroll to bottom when sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
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
    if (socket?.connected == true) {
      Logger().i('Requesting messages for room: $roomId');
      socket?.emit('get_messages', {'room': roomId});
    } else {
      Logger().w('Socket not connected, cannot refresh chat');
    }
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
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

              PopupMenuButton<String>(
                icon: Icon(Icons.voice_chat, color: Colors.white),
                onSelected: (value) {
                  if (value == 'video_call') {
                    Logger().i('Video call not implemented yet.');
                  }
                  if (value == 'voice_call') {
                    Logger().i('Voice call not implemented yet.');
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'video_call',
                    child: Row(children:[
                      Icon(Icons.video_call),
                      const SizedBox(width: 4),
                       Text('Video (in developemnt)')]),
                     
                  ),
                  PopupMenuItem<String>(
                    value: 'voice_call',
                  child: Row(children:[
                      Icon(Icons.call),
                      const SizedBox(width: 4),
                       Text('Voice (in development)')]),
                     
                  ),
                  
                ],
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
                    statusColor = "red";
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
            // Connection status indicator (only show when offline)
            if (userStatus != "Online")
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: statusColor == "red" ? Colors.red.withOpacity(0.8) : Colors.orange.withOpacity(0.8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      statusColor == "red" ? Icons.cloud_off : Icons.hourglass_empty,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      userStatus == "Offline" ? "Connecting..." : userStatus,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            // Messages display area
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  refreshChat();
                },
                child: sendmessages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: kAccentColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              userStatus == "Online" 
                                ? "No messages yet. Start the conversation!"
                                : "Connecting to server...",
                              style: TextStyle(
                                color: kAccentColor.withOpacity(0.7),
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: sendmessages.length,
                        reverse: true, // Show newest messages at bottom
                  itemBuilder: (context, index) {
                    // Reverse index for correct message order
                    final message = sendmessages[sendmessages.length - 1 - index];
                    final bool isMe = message.senderId == (socket?.id ?? 'unknown');
                    
                    return Container(
                      alignment: (isMe ? Alignment.centerRight : Alignment.centerLeft),
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: (isMe ? Colors.grey[800] : kPrimaryColor),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.message,
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Colors.white70, 
                                          fontSize: 12
                                        ),
                                      ),
                                      if (isMe) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.check, 
                                          color: userStatus == "Online" ? Colors.blue : Colors.white70, 
                                          size: 14
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: kBackgroundColor,
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(color: kTextColor, width: 1.0),
                      ),
                      child: TextFormField(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        maxLines: null, // Allow multiple lines
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: kAccentColor.withOpacity(0.7)),
                          filled: false,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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

                                onTap: () async {
                                  // Handle action selection
                                  try {
                                    switch (e) {

                                      case "Img":
                                        final result = await FilePicker.platform.pickFiles(
                                          type: FileType.image,
                                        );
                                      if (result != null && result.files.isNotEmpty) {
                                        final file = result.files.first;
                                        Logger().i('Selected image: ${file.name}, size: ${file.size} bytes');
                                      } else {
                                        Logger().w('No image selected');
                                      }
                                      break;
                                    case "Voice":
                                      final result = await FilePicker.platform.pickFiles(
                                        type: FileType.audio,
                                      );
                                      if (result != null && result.files.isNotEmpty) {
                                        final file = result.files.first;
                                        Logger().i('Selected audio: ${file.name}, size: ${file.size} bytes');
                                      } else {
                                        Logger().w('No audio selected');
                                      }
                                      break;
                                    case "Doc":
                                      final result = await FilePicker.platform.pickFiles(
                                        type: FileType.any,
                                      );
                                      if (result != null && result.files.isNotEmpty) {
                                        final file = result.files.first;
                                        Logger().i('Selected document: ${file.name}, size: ${file.size} bytes');
                                      } else {
                                        Logger().w('No document selected');
                                      }
                                      break;
                                    case "Locate":
                                      Logger().i('Location sharing not implemented yet.');
                                      break;
                                    case "Contact":
                                      Logger().i('Contact sharing not implemented yet.');
                                      break;
                                  }
                                  }catch(error){
                                    Logger().e('Error selecting file: $error');
                                  }
                                },

                              );
                            }).toList(),
                            onSelected: (value) {
                              debugPrint(value);
                            },
                          ),
                        ),
                        onFieldSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            sendChat();
                          }
                        },
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


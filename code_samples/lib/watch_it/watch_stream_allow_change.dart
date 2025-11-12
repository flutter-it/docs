import 'dart:async';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

// Service with dynamic stream based on selected room
class ChatRoomService {
  final Map<String, StreamController<String>> _rooms = {};

  Stream<String> getRoomStream(String roomId) {
    if (!_rooms.containsKey(roomId)) {
      _rooms[roomId] = StreamController<String>.broadcast();
    }
    return _rooms[roomId]!.stream;
  }

  void sendMessage(String roomId, String message) {
    _rooms[roomId]?.add(message);
  }
}

// #region example
class ChatRoomWidget extends WatchingWidget {
  const ChatRoomWidget({super.key, required this.selectedRoomId});

  final String selectedRoomId;

  @override
  Widget build(BuildContext context) {
    final chatService = createOnce(() => ChatRoomService());

    // Stream changes when selectedRoomId changes
    final snapshot = watchStream(
      null,
      target: chatService.getRoomStream(selectedRoomId),
      initialValue: 'No messages yet',
      allowStreamChange: true, // Allow switching between room streams
    );

    return Column(
      children: [
        Text('Room: $selectedRoomId'),
        Text('Last message: ${snapshot.data}'),
      ],
    );
  }
}
// #endregion example

void main() {
  runApp(MaterialApp(home: ChatRoomWidget(selectedRoomId: 'general')));
}

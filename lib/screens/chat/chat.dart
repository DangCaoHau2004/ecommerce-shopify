import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shopify/providers/user_data.dart';
import 'package:shopify/widgets/status_page.dart';
import 'package:shopify/models/status_page.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<FormState> _keyCommentForm = GlobalKey<FormState>();
  String _enterMessage = "";

  // Giả sử `userData` là thông tin người dùng hiện tại

  void _addMessage() {
    if (_keyCommentForm.currentState!.validate()) {
      _keyCommentForm.currentState!.save();
      FirebaseFirestore.instance
          .collection("chats")
          .doc(ref.watch(userData)["uid"])
          .collection("chat")
          .add(
        {
          "create_at": DateTime.now(),
          "content": _enterMessage,
          "uid": ref.watch(userData)["uid"],
        },
      );
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("chats")
            .doc(ref.watch(userData)["uid"])
            .collection("chat")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const StatusPageWithOutAppBar(
                type: StatusPageEnum.loading, err: "");
          } else if (snapshot.hasError) {
            return StatusPageWithOutAppBar(
              type: StatusPageEnum.error,
              err: snapshot.error.toString(),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const StatusPageWithOutAppBar(
              type: StatusPageEnum.noData,
              err: "",
            );
          }
          final messages = snapshot.data!.docs;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final isMe =
                        ref.watch(userData)["uid"] == messages[index]["uid"];

                    return ListTile(
                      leading: isMe
                          ? null
                          : const CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  AssetImage("assets/images/user.png"),
                            ),
                      trailing: isMe
                          ? const CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.transparent,
                              backgroundImage:
                                  AssetImage("assets/images/user.png"),
                            )
                          : null,
                      title: Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          messages[index]["content"] ?? "",
                          textAlign: isMe ? TextAlign.end : TextAlign.start,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm')
                            .format(messages[index]["create_at"].toDate()),
                        textAlign: isMe ? TextAlign.end : TextAlign.start,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Form(
        key: _keyCommentForm,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _commentController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: "Message...",
              suffixIcon: IconButton(
                onPressed: _addMessage,
                icon: const Icon(Icons.send),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "You haven't entered anything!";
              }
              return null;
            },
            onSaved: (value) => _enterMessage = value!.trim(),
          ),
        ),
      ),
    );
  }
}

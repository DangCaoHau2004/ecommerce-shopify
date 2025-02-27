import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/models/status_page.dart';
import 'package:shopify/providers/user_data.dart';
import 'package:shopify/widgets/status_page.dart';
import 'package:shopify/utils/formart_date_time.dart';
import 'package:shopify/models/list_chat.dart';

class DetailChat extends ConsumerStatefulWidget {
  const DetailChat(
      {super.key, required this.uidOrtherUser, required this.name});
  final String uidOrtherUser;
  final String name;
  @override
  ConsumerState<DetailChat> createState() => _DetailChatState();
}

class _DetailChatState extends ConsumerState<DetailChat> {
  final _keyCommentForm = GlobalKey<FormState>();
  String _enterMessage = "";
  void _addMessage() async {
    if (_keyCommentForm.currentState!.validate()) {
      _keyCommentForm.currentState!.save();
      await FirebaseFirestore.instance
          .collection("chats")
          .doc(widget.uidOrtherUser)
          .set(
            ListChatData(
              createAt: DateTime.now(),
              email: ref.read(userData)["email"],
              isRead: false,
              uid: ref.read(userData)["uid"],
              username: ref.read(userData)["username"],
            ).getListChatData(),
            SetOptions(merge: true),
          );
      FirebaseFirestore.instance
          .collection("chats")
          .doc(widget.uidOrtherUser)
          .collection("chat")
          .add(
        {
          "create_at": DateTime.now(),
          "content": _enterMessage,
          "uid": ref.read(userData)["uid"],
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chats")
          .doc(widget.uidOrtherUser)
          .collection("chat")
          .orderBy("create_at", descending: true)
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
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final isMe =
                        ref.read(userData)["uid"] == messages[index]["uid"];

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
                        formartDate(messages[index]["create_at"].toDate()),
                        textAlign: isMe ? TextAlign.end : TextAlign.start,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Form(
                key: _keyCommentForm,
                child: Padding(
                  padding:
                      EdgeInsets.only(bottom: 8, left: 8, right: 8, top: 8),
                  child: TextFormField(
                    style: Theme.of(context).textTheme.bodySmall,
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
            ],
          ),
        );
      },
    );
  }
}

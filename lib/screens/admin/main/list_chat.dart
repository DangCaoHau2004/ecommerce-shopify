import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopify/models/list_chat.dart';
import 'package:shopify/models/status_page.dart';
import 'package:shopify/utils/formart_date_time.dart';
import 'package:shopify/widgets/status_page.dart';

class ListChatScreen extends StatefulWidget {
  const ListChatScreen({super.key});
  @override
  State<ListChatScreen> createState() => _ListChatScreenState();
}

class _ListChatScreenState extends State<ListChatScreen> {
  String _enterSearch = "";
  final _formKey = GlobalKey<FormState>();
  void _search() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
  }

  Stream<int> getUnreadMessageCount() {
    return FirebaseFirestore.instance
        .collection("chats")
        .where("is_read", isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size); // Lấy số lượng tài liệu
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("chats")
          .orderBy("create_at", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const StatusPageWithOutScaffold(
            type: StatusPageEnum.loading,
            err: "",
          );
        } else if (snapshot.hasError) {
          return StatusPageWithOutScaffold(
            type: StatusPageEnum.error,
            err: snapshot.error.toString(),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const StatusPageWithOutScaffold(
            type: StatusPageEnum.noData,
            err: "",
          );
        }
        List<ListChatData> listChat = [];
        if (_enterSearch.isNotEmpty) {
        } else {
          for (var i = 0; i < snapshot.data!.docs.length; i++) {
            listChat.add(
              ListChatData(
                uid: snapshot.data!.docs[i].id,
                username: snapshot.data!.docs[i]["username"],
                email: snapshot.data!.docs[i]["email"],
                createAt: snapshot.data!.docs[i]["create_at"].toDate(),
                isRead: snapshot.data!.docs[i]["is_read"],
              ),
            );
          }
        }
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  "You received",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                StreamBuilder<int>(
                    stream: getUnreadMessageCount(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(
                          color: Colors.orange,
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          "${snapshot.error}",
                          style: Theme.of(context).textTheme.bodyLarge,
                        );
                      } else if (!snapshot.hasData || snapshot.data! == 0) {
                        return Text(
                          "0 Message",
                          style: Theme.of(context).textTheme.bodyLarge,
                        );
                      }
                      return Text(
                        "${snapshot.data} Messages",
                        style: Theme.of(context).textTheme.bodyLarge,
                      );
                    }),
                const SizedBox(
                  height: 50,
                ),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    decoration: InputDecoration(
                      label: Text(
                        "Type name or email",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      suffixIcon: IconButton(
                        onPressed: _search,
                        icon: const Icon(Icons.search),
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "You must enter here.";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _enterSearch = value.toLowerCase();
                    },
                    onSaved: (value) {
                      _enterSearch = value!.toLowerCase();
                    },
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  "Message:",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(
                  height: 30,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listChat.length,
                  itemBuilder: (context, idx) {
                    return TextButton(
                      onPressed: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 30),
                        child: Row(
                          children: [
                            CircleAvatar(
                              child: Image.asset("assets/images/user.png"),
                              backgroundColor: Colors.transparent,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  listChat[idx].username,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  listChat[0].email,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  formartDateTime(listChat[0].createAt),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

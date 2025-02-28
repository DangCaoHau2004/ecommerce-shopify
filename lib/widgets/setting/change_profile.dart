import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/providers/user_data.dart';

class ChangeProfile extends ConsumerStatefulWidget {
  const ChangeProfile({super.key});
  @override
  ConsumerState<ChangeProfile> createState() => _ChangeProfileState();
}

class _ChangeProfileState extends ConsumerState<ChangeProfile> {
  final _keyForm = GlobalKey<FormState>();
  void _changeProfile() {
    FocusScope.of(context).unfocus();

    if (_keyForm.currentState!.validate()) {
      try {
        _keyForm.currentState!.save();
        ref.read(userData.notifier).state["username"] = _enterUserName;
        FirebaseFirestore.instance
            .collection("users")
            .doc(ref.read(userData)["uid"])
            .update(
          {
            "username": _enterUserName,
          },
        );
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Success"),
            action: SnackBarAction(label: "Ok", onPressed: () {}),
          ),
        );
      } catch (e) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$e"),
            action: SnackBarAction(label: "Ok", onPressed: () {}),
          ),
        );
      }
    }
  }

  String _enterUserName = "";
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        color: Theme.of(context).colorScheme.onTertiary,
      ),
      height: height * 0.75,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Change Profile",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 48),
          Form(
            key: _keyForm,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  style: Theme.of(context).textTheme.bodySmall,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: "Name",
                    label: Text(
                      "Your Name",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.toString().trim().isEmpty) {
                      return "Please fill in here.";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enterUserName = value.toString();
                  },
                ),
                const SizedBox(
                  height: 48,
                ),
                OutlinedButton(
                  onPressed: _changeProfile,
                  child: Text(
                    "Change Profile",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

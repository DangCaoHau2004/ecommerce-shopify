import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});
  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _enterEmail = "";
  void resetPassword() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final emailUser = await FirebaseFirestore.instance
            .collection("users")
            .where(
              "email",
              isEqualTo: _enterEmail,
            )
            .get();
        // nếu ko có email thì yêu cầu đăng kí
        if (emailUser.docs.isEmpty) {
          throw Exception("The email does not exist, please sign up.");
        }
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _enterEmail.trim(),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Success, check your email"),
            action: SnackBarAction(label: "Ok", onPressed: () {}),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            action: SnackBarAction(label: "Ok", onPressed: () {}),
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Forget Password",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  "Your email:",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(
                  height: 12,
                ),
                TextFormField(
                  style: Theme.of(context).textTheme.bodySmall,
                  decoration: InputDecoration(
                    hintText: "Email ...",
                    prefixIcon: Icon(
                      Icons.email,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ).applyDefaults(Theme.of(context).inputDecorationTheme),
                  onSaved: (value) {
                    _enterEmail = value.toString().trim();
                  },
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        !value.contains("@")) {
                      return "Please enter a valid email format.";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 12,
                ),
                ElevatedButton(
                  style: Theme.of(context).elevatedButtonTheme.style,
                  onPressed: _isLoading ? null : resetPassword,
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.scrim,
                        )
                      : Text(
                          "Reset Password",
                          style: Theme.of(context)
                              .elevatedButtonTheme
                              .style!
                              .textStyle!
                              .resolve({}),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopify/utils/navigation_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/providers/setting.dart';

class LoginSignUp extends ConsumerStatefulWidget {
  const LoginSignUp({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _LoginSignUpState();
  }
}

class _LoginSignUpState extends ConsumerState<LoginSignUp> {
  final _formKey = GlobalKey<FormState>();
  String _enterEmail = "";
  String _enterPassword = "";
  String _enterConfirmPassword = "";
  String _enterUserName = "";
  bool _isChecked = false;
  bool _isLoading = false;
  bool _isLogin = true;
  bool _hidePassword = true;
  void loginSignUpWithGoogleAccount() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final googleAccount = await GoogleSignIn().signIn();
      print(googleAccount);
      final googleAuth = await googleAccount!.authentication;
      print(googleAuth);

      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("Email: ${googleAccount.email}");
      // kiểm tra đã có dữ liệu user trên db?
      final checkUser = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: googleAccount.email)
          .get();
      // nếu có thì đăng nhập
      if (checkUser.docs.isNotEmpty) {
        await FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set(
          {
            "username": googleAccount.displayName,
            "role": "user",
            "email": googleAccount.email,
            "avatar": googleAccount.photoUrl,
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearMaterialBanners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          action: SnackBarAction(label: "Ok", onPressed: () {}),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void loginSignUp() async {
    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      UserCredential userCredential;
      try {
        if (_isLogin) {
          userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                  email: _enterEmail, password: _enterPassword);
        } else {
          userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: _enterEmail, password: _enterPassword);
          await FirebaseFirestore.instance
              .collection("users")
              .doc(userCredential.user!.uid)
              .set(
            {
              "username": _enterUserName,
              "role": "user",
              "email": _enterEmail,
              "avatar": "assets/images/user.png",
            },
          );
        }
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(
              height: 30,
            ),
            Text(
              _isLogin ? "Welcome Back!" : "Create Your Account",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.left,
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              _isLogin
                  ? "Hello again, you've been missed"
                  : "Let's get you started with a new experience",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(
              height: 48,
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_isLogin)
                    Text(
                      "Name:",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  if (!_isLogin)
                    const SizedBox(
                      height: 12,
                    ),
                  if (!_isLogin)
                    TextFormField(
                      style: Theme.of(context).textTheme.bodySmall,
                      decoration: InputDecoration(
                        hintText: "Name ...",
                        prefixIcon: Icon(
                          Icons.person,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ).applyDefaults(Theme.of(context).inputDecorationTheme),
                      onSaved: (value) {
                        _enterUserName = value.toString().trim();
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter a valid email format.";
                        }
                        return null;
                      },
                    ),
                  if (!_isLogin)
                    const SizedBox(
                      height: 8,
                    ),
                  Text(
                    "Email Adress:",
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
                    height: 8,
                  ),
                  Text(
                    "Password:",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    style: Theme.of(context).textTheme.bodySmall,
                    decoration: InputDecoration(
                      hintText: "Password ...",
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                        icon: _hidePassword
                            ? Icon(
                                Icons.visibility_off,
                                color: Theme.of(context).iconTheme.color,
                              )
                            : Icon(
                                Icons.visibility,
                                color: Theme.of(context).iconTheme.color,
                              ),
                      ),
                    ).applyDefaults(Theme.of(context).inputDecorationTheme),
                    onSaved: (value) {
                      _enterPassword = value.toString();
                    },
                    validator: (value) {
                      if (value == null || value.toString().trim().isEmpty) {
                        return "You must complete this field.";
                      }
                      _enterPassword = value.toString();
                      return null;
                    },
                    obscureText: _hidePassword,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  if (!_isLogin)
                    Text(
                      "Confirm Password:",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  if (!_isLogin)
                    const SizedBox(
                      height: 12,
                    ),
                  if (!_isLogin)
                    TextFormField(
                      style: Theme.of(context).textTheme.bodySmall,
                      decoration: InputDecoration(
                        hintText: "Confirm Password ...",
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: _hidePassword
                              ? Icon(
                                  Icons.visibility_off,
                                  color: Theme.of(context).iconTheme.color,
                                )
                              : Icon(
                                  Icons.visibility,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                        ),
                      ).applyDefaults(Theme.of(context).inputDecorationTheme),
                      onSaved: (value) {
                        _enterConfirmPassword = value.toString();
                      },
                      validator: (value) {
                        if (value == null || value.toString().trim().isEmpty) {
                          return "You must complete this field.";
                        }
                        if (value.toString() != _enterPassword) {
                          return "Password does not match!";
                        }
                        return null;
                      },
                      obscureText: _hidePassword,
                    ),
                  if (!_isLogin)
                    const SizedBox(
                      height: 12,
                    ),
                  if (_isLogin)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // SizedBox(
                        //   child: Row(
                        //     children: [
                        //       Checkbox(
                        //         value: _isChecked,
                        //         onChanged: _isLoading
                        //             ? null
                        //             : (bool? value) {
                        //                 setState(() {
                        //                   _isChecked = value!;
                        //                 });
                        //               },
                        //       ),
                        //       Text(
                        //         "Remember Me",
                        //         style: Theme.of(context).textTheme.bodySmall,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        if (!_isLoading)
                          TextButton(
                            onPressed: () {
                              navigatorToForgetPassword(context);
                            },
                            child: Text(
                              "Forgot password?",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(
                    height: 12,
                  ),
                  ElevatedButton(
                    style: Theme.of(context).elevatedButtonTheme.style,
                    onPressed: loginSignUp,
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.scrim,
                          )
                        : Text(
                            _isLogin ? "Login" : "Sign up",
                            style: Theme.of(context)
                                .elevatedButtonTheme
                                .style!
                                .textStyle!
                                .resolve({}),
                          ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          _isLogin ? "Or Login With" : "Or Sign Up With",
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  OutlinedButton(
                    onPressed: loginSignUpWithGoogleAccount,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          ref.watch(darkMode)
                              ? "assets/images/google_dark.jpg"
                              : "assets/images/google_light.png",
                          width: 50,
                          height: 50,
                          fit: BoxFit.fitHeight,
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Text(
                          _isLogin
                              ? "Sign in with Google"
                              : "Sign up with Google",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 48,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? "Or you don't have account?"
                            : "Already have an account?",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      TextButton(
                        onPressed: () {
                          if (_isLoading) {
                            return;
                          }
                          // reset lại các kí tự đã điền
                          _formKey.currentState!.reset();
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin ? "Sign up" : "Log in",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

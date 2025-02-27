import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingAdminScreen extends StatefulWidget {
  const SettingAdminScreen({super.key});
  @override
  State<SettingAdminScreen> createState() => _SettingAdminScreenState();
}

class _SettingAdminScreenState extends State<SettingAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
          child: Text(
            "Log Out",
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Theme.of(context).colorScheme.onTertiary),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChangeProfile extends StatefulWidget {
  const ChangeProfile({super.key});
  @override
  State<ChangeProfile> createState() => _ChangeProfileState();
}

class _ChangeProfileState extends State<ChangeProfile> {
  final _keyForm = GlobalKey<FormState>();
  void _changeProfile() {
    if (_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();
    }
  }

  String _enterUserName = "";
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Container(
      color: Theme.of(context).colorScheme.onTertiary,
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

import 'package:flutter/material.dart';

class AddNewAddress extends StatefulWidget {
  const AddNewAddress({super.key});
  @override
  State<AddNewAddress> createState() => _AddNewAddressState();
}

class _AddNewAddressState extends State<AddNewAddress> {
  final _keyForm = GlobalKey<FormState>();
  String _name = "";
  String _address = "";
  String _detailAdress = "";
  String _phoneNumber = "";
  bool _isDefault = false;
  final TextEditingController textEditingController = TextEditingController();
  void _addAddress() {
    if (_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();
      print("address:" + _address);
    }
  }

  List<String> address = [
    "Xã Phùng Xá Huyện Thạch Thất",
    "Xã Hữu Bằng Huyện Thạch Thất",
    "Xã Bình Phú Huyện Thạch Thất",
    "Xã Canh Nậu Huyện Thạch Thất",
    "Xã Dị Nậu Huyện Thạch Thất",
    "Xã Lại Thượng Huyện Thạch Thất",
    "Xã Tiến Xuân Huyện Thạch Thất",
    "Xã Yên Bình Huyện Thạch Thất",
    "Xã Yên Trung Huyện Thạch Thất",
    "Xã Chàng Sơn Huyện Thạch Thất"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add New Adress",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Form(
        key: _keyForm,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
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
                  _name = value.toString();
                },
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                style: Theme.of(context).textTheme.bodySmall,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone),
                  hintText: "Phone Number",
                  label: Text(
                    "Your Phone Number",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.toString().trim().isEmpty) {
                    return "Please fill in here.";
                  }
                  if (!value.startsWith("0") ||
                      !value.startsWith("+84") ||
                      !value.startsWith("84") ||
                      value.length != 10) {
                    return "You need to enter the correct phone number.";
                  }
                  return null;
                },
                onSaved: (value) {
                  _phoneNumber = value.toString();
                },
              ),
              const SizedBox(
                height: 48,
              ),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue value) async {
                  if (value.text.isEmpty) {
                    return const Iterable.empty();
                  }
                  return address.where((temp) {
                    return temp
                        .toLowerCase()
                        .contains(value.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  textEditingController.text = selection;
                },
                fieldViewBuilder: (context, textEditingController, focusNode,
                    onFieldSubmitted) {
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    style: Theme.of(context).textTheme.bodySmall,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      hintText: "Commune, District And City",
                      label: Text(
                        "Your Address",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please fill in here.";
                      }

                      bool hasCommune = value.toLowerCase().contains("xã");
                      bool hasDistrict = value.toLowerCase().contains("quận") ||
                          value.toLowerCase().contains("huyện");
                      bool hasCityOrProvince =
                          value.toLowerCase().contains("thành phố") ||
                              value.toLowerCase().contains("tỉnh");

                      if (!(hasCommune || hasDistrict) || !hasCityOrProvince) {
                        return "Invalid address.";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _address = value.toString();
                    },
                  );
                },
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                style: Theme.of(context).textTheme.bodySmall,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_searching_rounded),
                  hintText: "Street, Building, House Number",
                  label: Text(
                    "Additional Address",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                validator: (value) {
                  return null;
                },
                onSaved: (value) {
                  _detailAdress = value.toString();
                },
              ),
              const SizedBox(
                height: 48,
              ),
              Row(
                children: [
                  Text(
                    "Set Address Is Default?",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Switch(
                    value: _isDefault,
                    activeColor: Colors.orange,
                    onChanged: (bool value) {
                      setState(() {
                        _isDefault = value;
                      });
                    },
                  )
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              ElevatedButton(
                onPressed: _addAddress,
                child: Text(
                  "Add New Address",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.white,
                      ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

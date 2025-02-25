import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shopify/models/user_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/providers/user_data.dart';

class AddNewAddress extends ConsumerStatefulWidget {
  const AddNewAddress({super.key});
  @override
  ConsumerState<AddNewAddress> createState() => _AddNewAddressState();
}

class _AddNewAddressState extends ConsumerState<AddNewAddress> {
  String HERE_API_KEY = dotenv.env['HERE_API_KEY'].toString();
  final _keyForm = GlobalKey<FormState>();
  String _name = "";
  String _address = "";
  String _detailAdress = "";
  String _phoneNumber = "";
  String _province = "";
  String _district = "";
  String _ward = "";
  bool _isLoading = false;
  bool _isDefault = false;
  final TextEditingController textEditingController = TextEditingController();
  void _addAddress() async {
    setState(() {
      _isLoading = true;
    });

    if (_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();

      try {
        final userRef = FirebaseFirestore.instance
            .collection("users")
            .doc(ref.watch(userData)["uid"])
            .collection("address");

        // Lấy danh sách địa chỉ hiện có
        final check = await userRef.get();

        // Nếu chưa có địa chỉ nào, đặt địa chỉ đầu tiên làm mặc định
        if (check.docs.isEmpty) {
          await userRef.add({
            "create_at": DateTime.now(),
            "phone_number": _phoneNumber,
            "name": _name,
            "default": true,
            "address": "$_detailAdress $_address",
            "province": _province,
            "district": _district,
            "ward": _ward,
          });
        } else {
          if (_isDefault) {
            final currentDefaultAddress =
                await userRef.where("default", isEqualTo: true).limit(1).get();

            if (currentDefaultAddress.docs.isNotEmpty) {
              await userRef.doc(currentDefaultAddress.docs.first.id).update({
                "default": false,
              });
            }
          }

          // Thêm địa chỉ mới
          await userRef.add({
            "create_at": DateTime.now(),
            "phone_number": _phoneNumber,
            "name": _name,
            "default": _isDefault,
            "address": "$_detailAdress $_address",
            "province": _province,
            "district": _district,
            "ward": _ward,
          });
        }

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: $e"),
            action: SnackBarAction(label: "Ok", onPressed: () {}),
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void splitProvinceDistrictWard(String address) {
    int xaIndex = address.toLowerCase().indexOf("xã");
    int huyenIndex = address.toLowerCase().indexOf("huyện");
    int thanhPhoIndex = address.toLowerCase().indexOf("thành phố");
    int phuongIndex = address.toLowerCase().indexOf("phường");
    int quanIndex = address.toLowerCase().indexOf("quận");
    int tinhIndex = address.toLowerCase().indexOf("tỉnh");

    if (xaIndex != -1 && huyenIndex != -1) {
      _ward = address.substring(xaIndex + 2, huyenIndex).trim();
    } else if (phuongIndex != -1 && huyenIndex != -1) {
      _ward = address.substring(phuongIndex + 6, huyenIndex).trim();
    }

    if (huyenIndex != -1 && thanhPhoIndex != -1) {
      _district = address.substring(huyenIndex + 5, thanhPhoIndex).trim();
    } else if (quanIndex != -1 && thanhPhoIndex != -1) {
      _district = address.substring(quanIndex + 4, thanhPhoIndex).trim();
    }

    if (thanhPhoIndex != -1) {
      _province = address.substring(thanhPhoIndex + 10).trim();
    } else if (tinhIndex != -1) {
      _province = address.substring(tinhIndex + 4).trim();
    }
  }

  bool isValidOrder(String value) {
    value = value.toLowerCase();

    int xaIndex = value.indexOf("xã");
    int phuongIndex = value.indexOf("phường");

    int quanIndex = value.indexOf("quận");
    int huyenIndex = value.indexOf("huyện");

    int tinhIndex = value.indexOf("tỉnh");
    int thanhPhoIndex = value.indexOf("thành phố");

    // Xác định chỉ mục nhỏ nhất (từ đầu tiên xuất hiện)
    int firstLevel = _minPositive(xaIndex, phuongIndex);
    int secondLevel = _minPositive(quanIndex, huyenIndex);
    int thirdLevel = _minPositive(tinhIndex, thanhPhoIndex);

    // Đảm bảo thứ tự: xã/phường -> quận/huyện -> tỉnh/thành phố
    return (firstLevel != -1 &&
        secondLevel != -1 &&
        thirdLevel != -1 &&
        firstLevel < secondLevel &&
        secondLevel < thirdLevel);
  }

  int _minPositive(int a, int b) {
    if (a == -1) return b;
    if (b == -1) return a;
    return a < b ? a : b;
  }

  // void recommentAdress(String addressSearch) async {
  //   final uriAdress = Uri.https(
  //     "geocode.search.hereapi.com",
  //     "/v1/geocode",
  //     {
  //       "limit": "20",
  //       "q": addressSearch,
  //       "apiKey": HERE_API_KEY,
  //     },
  //   );

  //   try {
  //     final response = await http.get(uriAdress);
  //     if (response.statusCode == 200) {
  //       final resultAddress = json.decode(response.body);
  //       setState(() {
  //         address = (resultAddress["items"] as List<dynamic>)
  //             .map((item) => item["title"].toString())
  //             .toList();
  //       });
  //     } else {
  //       print("Error fetching address: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Exception: $e");
  //   }
  // }

  List<String> address = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add New Adress",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : Form(
              key: _keyForm,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
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
                        _name = value.toString().trim();
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

                        String phone = value.trim();

                        // kiểm tra nếu bắt đầu bằng 0 và có 10 chữ số
                        if (RegExp(r'^0\d{9}$').hasMatch(phone)) {
                          return null;
                        }

                        // Kiểm tra nếu bắt đầu bằng +84 và có 11 chữ số
                        if (RegExp(r'^\+84\d{9,10}$').hasMatch(phone)) {
                          return null;
                        }

                        // Kiểm tra nếu bắt đầu bằng 84 nhưng không có +, phải có 11 chữ số
                        if (RegExp(r'^84\d{9,10}$').hasMatch(phone)) {
                          return null;
                        }

                        return "You need to enter the correct phone number.";
                      },
                      onSaved: (value) {
                        _phoneNumber = value.toString().trim();
                      },
                    ),
                    const SizedBox(
                      height: 48,
                    ),
                    Text(
                      "Address",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue value) {
                        if (value.text.isEmpty) {
                          return const Iterable.empty();
                        }
                        return address.where(
                          (temp) {
                            return temp
                                .toLowerCase()
                                .contains(value.text.toLowerCase());
                          },
                        );
                      },
                      onSelected: (String selection) {
                        textEditingController.text = selection;
                      },
                      fieldViewBuilder: (context, textEditingController,
                          focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          style: Theme.of(context).textTheme.bodySmall,
                          // onChanged: (value) {
                          //   recommentAdress(value.trim());
                          // },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            hintText: "Commune, District And City",
                            label: Text(
                              "Commune, District And City",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please fill in here.";
                            }

                            bool hasCommune =
                                (value.toLowerCase().contains("xã") ||
                                    value.toLowerCase().contains("phường"));
                            bool hasDistrict =
                                value.toLowerCase().contains("quận") ||
                                    value.toLowerCase().contains("huyện");
                            bool hasCityOrProvince =
                                value.toLowerCase().contains("thành phố") ||
                                    value.toLowerCase().contains("tỉnh");

                            if (!(hasCommune || hasDistrict) ||
                                !hasCityOrProvince) {
                              return "Invalid address.";
                            }
                            if (!isValidOrder(value)) {
                              return "Must follow the order: ward → district → province/city.";
                            }

                            return null;
                          },
                          onSaved: (value) {
                            splitProvinceDistrictWard(value!);
                            _address = value.toString().trim();
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
                        prefixIcon:
                            const Icon(Icons.location_searching_rounded),
                        hintText: "Street, Building, House Number",
                        label: Text(
                          "Street, Building, House Number",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      validator: (value) {
                        return null;
                      },
                      onSaved: (value) {
                        _detailAdress = value.toString().trim();
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

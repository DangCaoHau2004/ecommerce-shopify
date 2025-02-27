import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopify/models/coupon.dart';
import 'package:shopify/utils/formart_date_time.dart';

class EditCoupon extends StatefulWidget {
  const EditCoupon({super.key, required this.coupon});
  final Coupon coupon;
  @override
  State<EditCoupon> createState() => _EditCouponState();
}

class _EditCouponState extends State<EditCoupon> {
  final _formKey = GlobalKey<FormState>();
  List<String> type = ["delivery", "product"];
  List<String> discountType = ["percent", "fixed"];
  List<String> typeProc = [
    "All",
    "Living Room",
    "Bedroom",
    "Home Accents",
    "Lighting",
    "Dining Room",
  ];
  bool _isLoading = false;
  String? _enterCode;
  String? _enterContent;
  String? _enterType;
  String? _enterDiscountType;
  int? _enterDiscountValue;
  int? _enterMinOrderAmount;
  int? _enterUsageLimit;
  int? _enterUsedCount;
  DateTime? _enterStartDate;
  DateTime? _enterEndDate;
  TimeOfDay? _enterStartTime;
  TimeOfDay? _enterEndTime;
  String? _enterApplicableProductType;
  bool? _enterActive;

  @override
  void initState() {
    _enterCode = widget.coupon.code;
    _enterContent = widget.coupon.content;
    _enterType = widget.coupon.type;
    _enterDiscountType = widget.coupon.discountType;
    _enterDiscountValue = widget.coupon.discountValue;
    _enterMinOrderAmount = widget.coupon.minOrderAmount;
    _enterUsageLimit = widget.coupon.usageLimit;
    _enterUsedCount = widget.coupon.usedCount;
    _enterStartDate = widget.coupon.startDate;
    _enterEndDate = widget.coupon.endDate;
    _enterStartTime = TimeOfDay.fromDateTime(widget.coupon.startDate);
    _enterEndTime = TimeOfDay.fromDateTime(widget.coupon.endDate);
    _enterApplicableProductType = widget.coupon.applicableProductType;
    _enterActive = widget.coupon.active;
    super.initState();
  }

  void showDate(Function(DateTime?) asign, {DateTime? init}) async {
    DateTime now = DateTime.now();
    final pickerDate = await showDatePicker(
      context: context,
      initialDate: init ?? now,
      firstDate: now,
      lastDate: DateTime(
        now.year + 30,
      ),
    );
    asign(pickerDate);
  }

  void showTime(Function(TimeOfDay) asign) async {
    final nowTime = TimeOfDay.now();
    final now = DateTime.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: nowTime,
    );
    asign(pickedTime!);
  }

  Widget buildDropdownField(String label, String initValue,
      {required List<String> listDropDown,
      required Function(dynamic) onchanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField(
          value: initValue,
          items: [
            ...listDropDown.map(
              (item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            )
          ],
          onChanged: onchanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildTextField(
      String label, Function(String?) onSaved, String initValue,
      {TextInputType? inputType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initValue,
          style: Theme.of(context).textTheme.bodySmall,
          keyboardType: inputType,
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            hintText: "$label...",
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? "Please enter correctly!"
              : null,
          onSaved: onSaved,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void save() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      try {
        _formKey.currentState!.save();
        final checkCouponExist = await FirebaseFirestore.instance
            .collection("discount_codes")
            .where(FieldPath.documentId, isNotEqualTo: widget.coupon.id)
            .where("code", isEqualTo: _enterCode)
            .get();
        if (checkCouponExist.docs.isNotEmpty) {
          throw Exception("Code was exist");
        }
        final tempStart = DateTime(
            _enterStartDate!.year,
            _enterStartDate!.month,
            _enterStartDate!.day,
            _enterStartTime!.hour,
            _enterStartTime!.minute);
        final tempEnd = DateTime(_enterEndDate!.year, _enterEndDate!.month,
            _enterEndDate!.day, _enterEndTime!.hour, _enterEndTime!.minute);
        if (tempStart.isAfter(tempEnd)) {
          throw Exception("Start date is after end date.");
        }
        final newCoupon = await FirebaseFirestore.instance
            .collection("discount_codes")
            .doc(widget.coupon.id)
            .update({
          "code": _enterCode,
          "content": _enterContent,
          "type": _enterType,
          "discount_type": _enterDiscountType,
          "discount_value": _enterDiscountValue,
          "min_order_amount": _enterMinOrderAmount,
          "usage_limit": _enterUsageLimit,
          "used_count": 0,
          "start_date": DateTime(
              _enterStartDate!.year,
              _enterStartDate!.month,
              _enterStartDate!.day,
              _enterStartTime!.hour,
              _enterStartTime!.minute),
          "end_date": DateTime(_enterEndDate!.year, _enterEndDate!.month,
              _enterEndDate!.day, _enterEndTime!.hour, _enterEndTime!.minute),
          "active": _enterActive,
          "applicable_product_type": _enterApplicableProductType,
        });
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Success"),
            action: SnackBarAction(
              label: "Ok",
              onPressed: () {},
            ),
          ),
        );
      } catch (e) {
        Navigator.of(context).pop("");
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$e"),
            action: SnackBarAction(
              label: "Ok",
              onPressed: () {},
            ),
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.orange,
        ),
      );
    }
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      color: Theme.of(context).colorScheme.onTertiary,
      padding: EdgeInsets.only(
          bottom: 16 + keyboardSpace, top: 16, left: 16, right: 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Edit coupon",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: widget.coupon.type == "product"
                              ? Colors.orange
                              : Colors.green[300],
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop("");
                    },
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              buildTextField("Code", (value) {
                _enterCode = value!.trim();
              }, _enterCode!),
              buildTextField("Content", (value) {
                _enterContent = value!.trim();
              }, _enterContent!),
              buildDropdownField(
                "Type",
                _enterType!,
                listDropDown: type,
                onchanged: (value) {
                  setState(() {
                    _enterType = value!;
                  });
                },
              ),
              buildDropdownField(
                "Discount Type",
                _enterDiscountType!,
                listDropDown: discountType,
                onchanged: (value) {
                  setState(() {
                    _enterDiscountType = value!;
                  });
                },
              ),
              buildTextField("Discount Value", (value) {
                _enterDiscountValue = int.parse(value!.trim());
              }, _enterDiscountValue!.toString(),
                  inputType: TextInputType.number),
              buildTextField("Min Order Amout", (value) {
                _enterMinOrderAmount = int.parse(value!.trim());
              }, _enterMinOrderAmount.toString(),
                  inputType: TextInputType.number),
              buildTextField("Usage Limit", (value) {
                _enterUsageLimit = int.parse(value!.trim());
              }, _enterUsageLimit.toString(), inputType: TextInputType.number),
              Text(
                "Start",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      showDate((value) {
                        setState(
                          () {
                            _enterStartDate = value!;
                          },
                        );
                      });
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.date_range),
                        const SizedBox(width: 8),
                        Text(
                          formartDate(_enterStartDate!),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () {
                      showTime((value) {
                        setState(() {
                          _enterStartTime = value;
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.timelapse),
                        const SizedBox(width: 8),
                        Text(
                          formatTime(_enterStartTime!),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                "End",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      showDate((value) {
                        setState(
                          () {
                            _enterEndDate = value!;
                          },
                        );
                      });
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.date_range),
                        const SizedBox(width: 8),
                        Text(
                          formartDate(_enterEndDate!),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () {
                      showTime((value) {
                        setState(() {
                          _enterEndTime = value;
                        });
                      });
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.timelapse),
                        const SizedBox(width: 8),
                        Text(
                          formatTime(_enterEndTime!),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              buildDropdownField(
                "Applicable Product Type",
                _enterApplicableProductType!,
                listDropDown: typeProc,
                onchanged: (value) {
                  setState(() {
                    _enterApplicableProductType = value!;
                  });
                },
              ),
              Row(
                children: [
                  Text(
                    "Active",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Switch(
                      value: _enterActive!,
                      onChanged: (value) {
                        setState(() {
                          _enterActive = value;
                        });
                      })
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: save,
                child: Text(
                  "Save",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

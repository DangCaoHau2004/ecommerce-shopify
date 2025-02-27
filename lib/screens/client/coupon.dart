import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shopify/models/status_page.dart';
import 'package:shopify/providers/user_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/models/coupon.dart';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/widgets/status_page.dart';

class CouponScreen extends ConsumerStatefulWidget {
  const CouponScreen({super.key});
  @override
  ConsumerState<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends ConsumerState<CouponScreen> {
  final _formKey = GlobalKey<FormState>();
  String _enterCouponCode = "";
  int? _deliverySelect;
  int? _productSelect;
  bool _isLoading = false;
  void _addCoupon() async {
    setState(() {
      _isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final checkCode = await FirebaseFirestore.instance
          .collection("discount_codes")
          .where("code", isEqualTo: _enterCouponCode)
          .get();
      if (checkCode.docs.isEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("This code does not exist."),
            action: SnackBarAction(
              label: "Ok",
              onPressed: () {},
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (DateTime.now().isBefore(checkCode.docs[0]["start_date"].toDate()) ||
          DateTime.now().isAfter(checkCode.docs[0]["end_date"].toDate()) ||
          !checkCode.docs[0]["active"]) {
        // nếu đã quá hạn thì xóa
        if (DateTime.now().isAfter(checkCode.docs[0]["end_date"].toDate())) {
          FirebaseFirestore.instance
              .collection("discount_codes")
              .doc(checkCode.docs[0].id)
              .delete();
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Code is not valid."),
            action: SnackBarAction(
              label: "Ok",
              onPressed: () {},
            ),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      await FirebaseFirestore.instance
          .collection("users")
          .doc(ref.watch(userData)["uid"])
          .collection("discount_codes")
          .doc(checkCode.docs[0].id)
          .set({
        "create_at": DateTime.now(),
        "used": false,
      });
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Coupon",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(ref.read(userData)["uid"])
                  .collection("discount_codes")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const StatusPageWithOutScaffold(
                      type: StatusPageEnum.loading, err: "");
                } else if (snapshot.hasError) {
                  return StatusPageWithOutScaffold(
                      type: StatusPageEnum.error,
                      err: snapshot.error.toString());
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  label: Text(
                                    "Type Coupon Code",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: _addCoupon,
                                    icon: const Icon(
                                        Icons.subdirectory_arrow_left),
                                  ),
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "You must enter here.";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enterCouponCode = value!.toLowerCase();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const StatusPageWithOutScaffold(
                            type: StatusPageEnum.noData, err: ""),
                      ],
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const StatusPageWithOutScaffold(
                      type: StatusPageEnum.loading, err: "");
                } else if (snapshot.hasError) {
                  return StatusPageWithOutScaffold(
                      type: StatusPageEnum.error,
                      err: snapshot.error.toString());
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  label: Text(
                                    "Type Coupon Code",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: _addCoupon,
                                    icon: const Icon(
                                        Icons.subdirectory_arrow_left),
                                  ),
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "You must enter here.";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enterCouponCode = value!.toLowerCase();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const StatusPageWithOutScaffold(
                            type: StatusPageEnum.noData, err: ""),
                      ],
                    ),
                  );
                }
                final allIdCoupon = snapshot.data!.docs
                    .where((value) => value["used"] != true)
                    .map((value) => value.id)
                    .toList();

                if (allIdCoupon.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  label: Text(
                                    "Type Coupon Code",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: _addCoupon,
                                    icon: const Icon(
                                        Icons.subdirectory_arrow_left),
                                  ),
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "You must enter here.";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enterCouponCode = value!.toLowerCase();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const StatusPageWithOutScaffold(
                            type: StatusPageEnum.noData, err: ""),
                      ],
                    ),
                  );
                }

                return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("discount_codes")
                        .where(FieldPath.documentId, whereIn: allIdCoupon)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const StatusPageWithOutScaffold(
                            type: StatusPageEnum.loading, err: "");
                      } else if (snapshot.hasError) {
                        return StatusPageWithOutScaffold(
                            type: StatusPageEnum.error,
                            err: snapshot.error.toString());
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      decoration: InputDecoration(
                                        label: Text(
                                          "Type Coupon Code",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: _addCoupon,
                                          icon: const Icon(
                                              Icons.subdirectory_arrow_left),
                                        ),
                                      ),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return "You must enter here.";
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _enterCouponCode = value!.toLowerCase();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              const StatusPageWithOutScaffold(
                                  type: StatusPageEnum.noData, err: ""),
                            ],
                          ),
                        );
                      }
                      List<Coupon> _deliveryCoupon = [];
                      List<Coupon> _productCoupon = [];
                      for (var i = 0; i < snapshot.data!.docs.length; i++) {
                        final tempCoupon = snapshot.data!.docs[i];
                        // khi chưa sử dụng
                        if (tempCoupon["type"] == "delivery") {
                          _deliveryCoupon.add(
                            Coupon(
                                code: tempCoupon["code"],
                                content: tempCoupon["content"],
                                type: tempCoupon["type"],
                                discountType: tempCoupon["discount_type"],
                                discountValue: tempCoupon["discount_value"],
                                minOrderAmount: tempCoupon["min_order_amount"],
                                usageLimit: tempCoupon["usage_limit"],
                                usedCount: tempCoupon["used_count"],
                                startDate: tempCoupon["start_date"].toDate(),
                                endDate: tempCoupon["end_date"].toDate(),
                                active: tempCoupon["active"],
                                applicableProductType:
                                    tempCoupon["applicable_product_type"],
                                id: tempCoupon.id),
                          );
                        } else if (tempCoupon["type"] == "product") {
                          _productCoupon.add(
                            Coupon(
                                code: tempCoupon["code"],
                                content: tempCoupon["content"],
                                type: tempCoupon["type"],
                                discountType: tempCoupon["discount_type"],
                                discountValue: tempCoupon["discount_value"],
                                minOrderAmount: tempCoupon["min_order_amount"],
                                usageLimit: tempCoupon["usage_limit"],
                                usedCount: tempCoupon["used_count"],
                                startDate: tempCoupon["start_date"].toDate(),
                                endDate: tempCoupon["end_date"].toDate(),
                                active: tempCoupon["active"],
                                applicableProductType:
                                    tempCoupon["applicable_product_type"],
                                id: tempCoupon.id),
                          );
                        }
                        if (DateTime.now()
                            .isAfter(tempCoupon["end_date"].toDate())) {
                          FirebaseFirestore.instance
                              .collection("discount_codes")
                              .doc(tempCoupon.id)
                              .delete();
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(ref.read(userData)["uid"])
                              .collection("discount_codes")
                              .doc(tempCoupon.id)
                              .delete();
                        }
                      }
                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: ListView(
                          children: [
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    decoration: InputDecoration(
                                      label: Text(
                                        "Type Coupon Code",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: _addCoupon,
                                        icon: const Icon(
                                            Icons.subdirectory_arrow_left),
                                      ),
                                    ),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return "You must enter here.";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      _enterCouponCode = value!.toLowerCase();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            Text(
                              "Shipping discount",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            if (_deliveryCoupon.isEmpty)
                              Center(
                                child: Text(
                                  "None",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            for (int i = 0; i < _deliveryCoupon.length; i++)
                              Container(
                                height: height / 6,
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                          ),
                                          color: Colors.green[300],
                                        ),
                                        height: double.infinity,
                                        child: const Icon(
                                          Icons.fire_truck_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 5),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 0.1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _deliveryCoupon[i].content,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Minimum value:",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                                const Spacer(),
                                                Text(
                                                  _deliveryCoupon[i]
                                                              .minOrderAmount ==
                                                          0
                                                      ? "0 đ"
                                                      : "${formatCurrency(_deliveryCoupon[i].minOrderAmount)} đ",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            if (_deliveryCoupon[i]
                                                    .applicableProductType !=
                                                "All")
                                              Text(
                                                "Only applicable to ${_deliveryCoupon[i].applicableProductType}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error,
                                                    ),
                                                overflow: TextOverflow.clip,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(
                              height: 50,
                            ),
                            Text(
                              "Product discount",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            if (_productCoupon.isEmpty)
                              Center(
                                child: Text(
                                  "None",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            for (int i = 0; i < _productCoupon.length; i++)
                              Container(
                                height: height / 6,
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                          ),
                                          color: Colors.orange[300],
                                        ),
                                        height: double.infinity,
                                        child: const Icon(
                                          Icons.shopping_cart,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 5),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 0.1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _productCoupon[i].content,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Minimum value:",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                                const Spacer(),
                                                Text(
                                                  _productCoupon[i]
                                                              .minOrderAmount ==
                                                          0
                                                      ? "0 đ"
                                                      : "${formatCurrency(_productCoupon[i].minOrderAmount)} đ",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            if (_productCoupon[i]
                                                    .applicableProductType !=
                                                "All")
                                              Text(
                                                "Only applicable to ${_productCoupon[i].applicableProductType}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall!
                                                    .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error,
                                                    ),
                                                overflow: TextOverflow.clip,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    });
              }),
    );
  }
}

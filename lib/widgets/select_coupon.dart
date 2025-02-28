import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopify/models/coupon.dart';
import 'package:shopify/models/status_page.dart';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/providers/user_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/widgets/status_page.dart';

class SelectCoupon extends ConsumerStatefulWidget {
  const SelectCoupon({super.key});
  @override
  ConsumerState<SelectCoupon> createState() => _SelectCouponState();
}

class _SelectCouponState extends ConsumerState<SelectCoupon> {
  int? _deliverySelect;
  int? _productSelect;
  String? _idDeliverySelect;
  String? _idProductSelect;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop({
              "id_delivery": _idDeliverySelect ?? "",
              "id_product": _idProductSelect ?? "",
            });
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          "Select Coupon",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        shape: Border(
          bottom: BorderSide(
              color: Theme.of(context).colorScheme.secondary, width: 0.2),
        ),
      ),
      body: StreamBuilder(
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
                  type: StatusPageEnum.error, err: snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const StatusPageWithOutScaffold(
                  type: StatusPageEnum.noData, err: "");
            }
            final allIdCoupon = snapshot.data!.docs
                .where((value) => value["used"] != true)
                .map((value) => value.id)
                .toList();

            if (allIdCoupon.isEmpty) {
              return const StatusPageWithOutScaffold(
                  type: StatusPageEnum.noData, err: "");
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
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const StatusPageWithOutScaffold(
                        type: StatusPageEnum.noData, err: "");
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
                        Text(
                          "Shipping discount",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        if (_deliveryCoupon.isEmpty)
                          Text(
                            "None",
                            style: Theme.of(context).textTheme.bodyMedium,
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
                                      border: Border(
                                        top: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            width: 0.1),
                                        bottom: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            width: 0.1),
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
                                                  fontWeight: FontWeight.bold),
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
                                            "all")
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
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 5),
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            width: 0.1),
                                        bottom: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            width: 0.1),
                                        right: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            width: 0.1),
                                      ),
                                    ),
                                    child: IconButton(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onPressed: () {
                                        setState(() {
                                          if (_deliverySelect == i) {
                                            _deliverySelect = null;
                                            _idDeliverySelect == null;
                                          } else {
                                            _deliverySelect = i;
                                            _idDeliverySelect =
                                                _deliveryCoupon[i].id;
                                          }
                                        });
                                      },
                                      icon: _deliverySelect == null
                                          ? const Icon(
                                              Icons.circle_outlined,
                                            )
                                          : _deliverySelect == i
                                              ? const Icon(
                                                  Icons.check_circle_outline,
                                                )
                                              : const Icon(
                                                  Icons.circle_outlined,
                                                ),
                                    ),
                                  ),
                                )
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
                          Text(
                            "None",
                            style: Theme.of(context).textTheme.bodyMedium,
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
                                      border: Border(
                                        top: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            width: 0.1),
                                        bottom: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            width: 0.1),
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
                                                  fontWeight: FontWeight.bold),
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
                                            "all")
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
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: const EdgeInsets.only(right: 5),
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            width: 0.1),
                                        bottom: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            width: 0.1),
                                        right: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            width: 0.1),
                                      ),
                                    ),
                                    child: IconButton(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onPressed: () {
                                        setState(() {
                                          if (_productSelect == i) {
                                            _productSelect = null;
                                            _idProductSelect = null;
                                          } else {
                                            _productSelect = i;
                                            _idProductSelect =
                                                _productCoupon[i].id;
                                          }
                                        });
                                      },
                                      icon: _productSelect == null
                                          ? const Icon(
                                              Icons.circle_outlined,
                                            )
                                          : _productSelect == i
                                              ? const Icon(
                                                  Icons.check_circle_outline,
                                                )
                                              : const Icon(
                                                  Icons.circle_outlined,
                                                ),
                                    ),
                                  ),
                                )
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

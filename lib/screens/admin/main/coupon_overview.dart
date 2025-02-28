import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/models/coupon.dart';
import 'package:shopify/models/status_page.dart';
import 'package:shopify/screens/admin/widget/coupon/edit_coupon.dart';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/widgets/status_page.dart';

class CouponOverviewScreen extends ConsumerStatefulWidget {
  const CouponOverviewScreen({super.key});
  @override
  ConsumerState<CouponOverviewScreen> createState() =>
      _CouponOverviewScreenState();
}

class _CouponOverviewScreenState extends ConsumerState<CouponOverviewScreen> {
  void removeCoupon(String idProc) {
    FirebaseFirestore.instance
        .collection("discount_codes")
        .doc(idProc)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection("discount_codes").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const StatusPageWithOutScaffold(
            type: StatusPageEnum.loading,
            err: "",
          );
        } else if (snapshot.hasError) {
          return StatusPageWithOutScaffold(
            type: StatusPageEnum.error,
            err: snapshot.error.toString(),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const StatusPageWithOutScaffold(
            type: StatusPageEnum.noData,
            err: "",
          );
        }
        final coupon = snapshot.data!.docs;
        List<Coupon> _deliveryCoupon = [];
        List<Coupon> _productCoupon = [];
        for (var i = 0; i < coupon.length; i++) {
          if (coupon[i]["type"] == "delivery") {
            _deliveryCoupon.add(
              Coupon(
                  code: coupon[i]["code"],
                  content: coupon[i]["content"],
                  type: coupon[i]["type"],
                  discountType: coupon[i]["discount_type"],
                  discountValue: coupon[i]["discount_value"],
                  minOrderAmount: coupon[i]["min_order_amount"],
                  usageLimit: coupon[i]["usage_limit"],
                  usedCount: coupon[i]["used_count"],
                  startDate: coupon[i]["start_date"].toDate(),
                  endDate: coupon[i]["end_date"].toDate(),
                  active: coupon[i]["active"],
                  applicableProductType: coupon[i]["applicable_product_type"],
                  id: coupon[i].id),
            );
          } else if (coupon[i]["type"] == "product") {
            _productCoupon.add(
              Coupon(
                  code: coupon[i]["code"],
                  content: coupon[i]["content"],
                  type: coupon[i]["type"],
                  discountType: coupon[i]["discount_type"],
                  discountValue: coupon[i]["discount_value"],
                  minOrderAmount: coupon[i]["min_order_amount"],
                  usageLimit: coupon[i]["usage_limit"],
                  usedCount: coupon[i]["used_count"],
                  startDate: coupon[i]["start_date"].toDate(),
                  endDate: coupon[i]["end_date"].toDate(),
                  active: coupon[i]["active"],
                  applicableProductType: coupon[i]["applicable_product_type"],
                  id: coupon[i].id),
            );
          }
        }
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text(
                  "All Coupon",
                  style: Theme.of(context).textTheme.bodyLarge,
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
                  Text(
                    "None",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                for (int i = 0; i < _deliveryCoupon.length; i++)
                  Dismissible(
                    key: ValueKey(_deliveryCoupon[i].id),
                    onDismissed: (direction) {
                      removeCoupon(_deliveryCoupon[i].id);
                    },
                    child: Container(
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
                            child: TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    useSafeArea: true,
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) {
                                      return EditCoupon(
                                          coupon: _deliveryCoupon[i]);
                                    });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 0.1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                          _deliveryCoupon[i].minOrderAmount == 0
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
                          ),
                        ],
                      ),
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
                  Dismissible(
                    key: ValueKey(
                      _productCoupon[i].id,
                    ),
                    onDismissed: (direction) {
                      removeCoupon(_productCoupon[i].id);
                    },
                    child: Container(
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
                            child: TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                    useSafeArea: true,
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) {
                                      return EditCoupon(
                                          coupon: _productCoupon[i]);
                                    });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 0.1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                          _productCoupon[i].minOrderAmount == 0
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
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

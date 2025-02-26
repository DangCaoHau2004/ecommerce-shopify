import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shopify/providers/user_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/models/coupon.dart';
import 'package:shopify/utils/formart_currency.dart';

class CouponScreen extends ConsumerStatefulWidget {
  const CouponScreen({super.key});
  @override
  ConsumerState<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends ConsumerState<CouponScreen> {
  int? _deliverySelect;
  int? _productSelect;
  void _addCoupon() {}
  List<Coupon> _deliveryCoupon = [];
  List<Coupon> _productCoupon = [];
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String _enterCouponCode = "";
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Coupon",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Container(
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
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      suffixIcon: IconButton(
                        onPressed: _addCoupon,
                        icon: const Icon(Icons.subdirectory_arrow_left),
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
                                color: Theme.of(context).colorScheme.secondary,
                                width: 0.1),
                            bottom: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 0.1),
                          ),
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
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Minimum value:",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const Spacer(),
                                Text(
                                  _deliveryCoupon[i].minOrderAmount == 0
                                      ? "0 đ"
                                      : "${formatCurrency(_deliveryCoupon[i].minOrderAmount)} đ",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            if (_deliveryCoupon[i].applicableProductType !=
                                "all")
                              Text(
                                "Only applicable to ${_deliveryCoupon[i].applicableProductType}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.error,
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
                                color: Theme.of(context).colorScheme.secondary,
                                width: 0.1),
                            bottom: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 0.1),
                            right: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
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
                              } else {
                                _deliverySelect = i;
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
                                color: Theme.of(context).colorScheme.secondary,
                                width: 0.1),
                            bottom: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 0.1),
                          ),
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
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Minimum value:",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const Spacer(),
                                Text(
                                  _productCoupon[i].minOrderAmount == 0
                                      ? "0 đ"
                                      : "${formatCurrency(_productCoupon[i].minOrderAmount)} đ",
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            if (_productCoupon[i].applicableProductType !=
                                "all")
                              Text(
                                "Only applicable to ${_productCoupon[i].applicableProductType}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.error,
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
                                color: Theme.of(context).colorScheme.secondary,
                                width: 0.1),
                            bottom: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 0.1),
                            right: BorderSide(
                                color: Theme.of(context).colorScheme.secondary,
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
                              } else {
                                _productSelect = i;
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
      ),
    );
  }
}

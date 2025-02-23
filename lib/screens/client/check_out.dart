import 'package:flutter/material.dart';
import 'package:shopify/data/data_test.dart';
import 'package:shopify/models/coupon.dart';
import 'package:shopify/models/product.dart';
import 'package:shopify/utils/formart_currency.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});
  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  List<Product> product = productTest.sublist(0, 4);
  bool _isSelectCash = true;

  // khi ko có địa chỉ thì ko cho phép thanh toán và ko hiển thị phần giá ship

  // ý tưởng để làm các sản phẩm được áp dụng chia nhỏ tổng của từng sản phẩm ra
  //thành từng loại rồi nếu có mã thì áp dụng cho giá tổng ở sản phẩm đó thôi rồi cộng tổng tất cả lại

  // Khi chuyển hướng sang màn hình voucher thì phải truyền đi danh sách các loại sản phẩm đang có rồi từ đó truy xuất
  Coupon _productCoupon = Coupon(
      code: "",
      content: "50k discount on all items",
      type: "product",
      discountType: "fixed",
      discountValue: 50000,
      minOrderAmount: 0,
      usageLimit: 1000,
      usedCount: 0,
      startDate: "",
      endDate: "",
      active: true,
      applicableProductType: "Living Room");
  Coupon _deliveryCoupon = Coupon(
      code: "",
      content: "50% discount on all items",
      type: "delivery",
      discountType: "percent",
      discountValue: 50,
      minOrderAmount: 0,
      usageLimit: 1000,
      usedCount: 0,
      startDate: "",
      endDate: "",
      active: true,
      applicableProductType: "all");

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Check Out",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextButton(
              onPressed: () {},
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width / 10),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 0.2,
                  ),
                ),
                height: height / 5,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // khi ko có địa chỉ
                    // const Icon(
                    //   Icons.add,
                    //   color: Colors.orange,
                    // ),
                    // const SizedBox(
                    //   width: 16,
                    // ),
                    // Text(
                    //   "Add New Delivery",
                    //   style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    //         color: Colors.orange,
                    //       ),
                    // ),

                    const Icon(
                      Icons.location_on,
                      color: Colors.orange,
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Shipping Address",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Xã Phùng Xá Huyện Thạch Thất Thành Phố Hà Nội",
                            style: Theme.of(context).textTheme.bodySmall!,
                            overflow: TextOverflow.clip,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: [
                              Text(
                                "Đặng Cao Hậu",
                                style: Theme.of(context).textTheme.bodySmall!,
                                overflow: TextOverflow.clip,
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Text(
                                "0966232303",
                                style: Theme.of(context).textTheme.bodySmall!,
                                overflow: TextOverflow.clip,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            for (int i = 0; i < product.length; i++)
              Column(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            product[i].linkImg[0],
                            height: height / 10,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product[i].name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.clip,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                "Color: red, blue",
                                style: Theme.of(context).textTheme.bodySmall!,
                                overflow: TextOverflow.clip,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "300.000",
                                    style:
                                        Theme.of(context).textTheme.bodySmall!,
                                  ),
                                  const Spacer(),
                                  Text(
                                    "x1",
                                    style:
                                        Theme.of(context).textTheme.bodySmall!,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            const SizedBox(
              height: 30,
            ),
            Text(
              "Voucher:",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.clip,
            ),
            const SizedBox(
              height: 16,
            ),
            TextButton(
              onPressed: () {},
              child: Row(
                children: [
                  Text(
                    "All Voucher",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).iconTheme.color,
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green[300],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Text(
                        _deliveryCoupon.content,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const Spacer(),
                      if (_deliveryCoupon.discountType == "percent")
                        Text(
                          "${_deliveryCoupon.discountValue}%",
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      if (_deliveryCoupon.discountType == "fixed")
                        Text(
                          "${formatCurrency(_deliveryCoupon.discountValue)} đ",
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.orange[300],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Text(
                        _productCoupon.content,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const Spacer(),
                      if (_productCoupon.discountType == "percent")
                        Text(
                          "${_productCoupon.discountType}%",
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      if (_productCoupon.discountType == "fixed")
                        Text(
                          "${formatCurrency(_productCoupon.discountValue)} đ",
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            Text(
              "Delivery:",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.clip,
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Text(
                  "Giao Hang Tiet Kiem",
                  style: Theme.of(context).textTheme.bodySmall!,
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      "199.000",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            decoration: TextDecoration.lineThrough,
                            decorationColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                    Text(
                      "199.000",
                      style: Theme.of(context).textTheme.bodySmall!,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            const Divider(),
            const SizedBox(
              height: 24,
            ),
            Text(
              "Payment Method:",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              height: height / 7,
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSelectCash = true;
                      });
                    },
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width / 12),
                        border: Border.all(
                          color: _isSelectCash
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.money,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text("Cash",
                                  style:
                                      Theme.of(context).textTheme.bodySmall!),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Pay cash when the medicine arrives at the destination",
                            style: Theme.of(context).textTheme.bodySmall!,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSelectCash = false;
                      });
                    },
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width / 12),
                        border: Border.all(
                          color: _isSelectCash
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.primary,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.qr_code,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                "Qr Code",
                                style: Theme.of(context).textTheme.bodySmall!,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Pay cash when the medicine arrives at the destination",
                            style: Theme.of(context).textTheme.bodySmall!,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              "Payment details",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.clip,
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Text("Total merchandise amount",
                    style: Theme.of(context).textTheme.bodySmall!),
                const Spacer(),
                Text("700.000 đ",
                    style: Theme.of(context).textTheme.bodySmall!),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Text("Total shipping fee",
                    style: Theme.of(context).textTheme.bodySmall!),
                const Spacer(),
                Text("700.000 đ",
                    style: Theme.of(context).textTheme.bodySmall!),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Text("Total shipping discount",
                    style: Theme.of(context).textTheme.bodySmall!),
                const Spacer(),
                Text(
                  "-700.000 đ",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Text(
                  "Total product voucher discount",
                  style: Theme.of(context).textTheme.bodySmall!,
                ),
                const Spacer(),
                Text(
                  "-700.000 đ",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              children: [
                Text(
                  "Total payment",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text("700.000 đ",
                    style: Theme.of(context).textTheme.bodySmall!),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        height: height / 10,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total payment",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  "700.000 đ",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                "Payment",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

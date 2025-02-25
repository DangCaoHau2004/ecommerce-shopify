import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopify/models/address.dart';
import 'package:shopify/models/cart.dart';
import 'package:shopify/models/coupon.dart';
import 'package:shopify/models/product.dart';
import 'package:shopify/models/status_page.dart';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/utils/navigation_helper.dart';
import 'package:shopify/providers/user_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/widgets/status_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckOutScreen extends ConsumerStatefulWidget {
  const CheckOutScreen({
    super.key,
    required this.productSelect,
    required this.cartProductSelect,
    required this.count,
  });
  final List<Product> productSelect;
  final List<CartModel> cartProductSelect;
  final List<int> count;
  @override
  ConsumerState<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends ConsumerState<CheckOutScreen> {
  List<Product> product = [];
  List<CartModel> cartProductSelect = [];
  String GHTK_API = dotenv.env['GHTK_API'].toString();

  List<int> count = [];
  bool _isSelectCash = true;
  final String urlCheckFeeDeli = "services.giaohangtietkiem.vn";
  final String endPointCheckDeli = "/services/shipment/fee";
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
  String idAddressSelect = "";
  Future<String> getFeeDeli(Address address, String weight) async {
    Map<String, dynamic> queryParam = {
      "pick_province": "Hà Nội",
      "pick_district": "Quận Bắc Từ Liêm",
      "province": address.province,
      "district": address.district,
      "ward": address.ward,
      "weight": weight,
      "deliver_option": "none",
    };
    try {
      Uri uri = Uri.https(urlCheckFeeDeli, endPointCheckDeli, queryParam);
      var response = await http.get(
        uri,
        headers: {"Token": GHTK_API},
      );
      if (response.statusCode == 200) {
        final String fee =
            jsonDecode(response.body)["fee"]["ship_fee_only"].toString();
        return fee;
      } else {
        print("ERR: ${jsonDecode(response.body)}");
        return "";
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ERR: $e"),
          action: SnackBarAction(label: "Ok", onPressed: () {}),
        ),
      );
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    product = widget.productSelect;

    cartProductSelect = widget.cartProductSelect;
    count = widget.count;
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    double _totalWeightProduct = 0;
    for (var i = 0; i < product.length; i++) {
      _totalWeightProduct +=
          (product[i].weight * cartProductSelect[i].purchaseQuantity);
    }
    Widget titleAddress(Address addressSelect) {
      return TextButton(
        onPressed: () async {
          final idAddress = await navigatorToAllAdress(context);
          setState(() {
            idAddressSelect = idAddress;
          });
        },
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
                      addressSelect.address,
                      style: Theme.of(context).textTheme.bodySmall!,
                      overflow: TextOverflow.clip,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Text(
                          addressSelect.name,
                          style: Theme.of(context).textTheme.bodySmall!,
                          overflow: TextOverflow.clip,
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Text(
                          addressSelect.phoneNumber,
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
      );
    }

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
            idAddressSelect.isEmpty
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(ref.watch(userData)["uid"])
                        .collection("address")
                        .where("default", isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      print("id: $idAddressSelect");
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
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return TextButton(
                          onPressed: () async {
                            await navigatorToAllAdress(context);
                          },
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
                                const Icon(
                                  Icons.add,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Text(
                                  "Add New Delivery",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Colors.orange,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return titleAddress(
                        Address(
                          createAt:
                              snapshot.data!.docs[0]["create_at"].toDate(),
                          phoneNumber: snapshot.data!.docs[0]["phone_number"],
                          name: snapshot.data!.docs[0]["name"],
                          id: snapshot.data!.docs[0].id,
                          defaultAddress: snapshot.data!.docs[0]["default"],
                          address: snapshot.data!.docs[0]["address"],
                          province: snapshot.data!.docs[0]["province"],
                          district: snapshot.data!.docs[0]["district"],
                          ward: snapshot.data!.docs[0]["ward"],
                        ),
                      );
                    },
                  )
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(ref.watch(userData)["uid"])
                        .collection("address")
                        .doc(idAddressSelect)
                        .snapshots(),
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
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return TextButton(
                          onPressed: () async {
                            await navigatorToAllAdress(context);
                          },
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
                                const Icon(
                                  Icons.add,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Text(
                                  "Add New Delivery",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Colors.orange,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return titleAddress(
                        Address(
                          createAt: snapshot.data!["create_at"].toDate(),
                          phoneNumber: snapshot.data!["phone_number"],
                          name: snapshot.data!["name"],
                          id: snapshot.data!.id,
                          defaultAddress: snapshot.data!["default"],
                          address: snapshot.data!["address"],
                          province: snapshot.data!["province"],
                          district: snapshot.data!["district"],
                          ward: snapshot.data!["ward"],
                        ),
                      );
                    },
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
                                "Color: ${product[i].color[cartProductSelect[i].colorSelectIndex]}",
                                style: Theme.of(context).textTheme.bodySmall!,
                                overflow: TextOverflow.clip,
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  Text(
                                    product[i].sale == 0
                                        ? "${formatCurrency(product[i].price)} đ"
                                        : "${formatCurrency(
                                            product[i].price -
                                                ((product[i].price *
                                                            product[i].sale) /
                                                        100)
                                                    .floor(),
                                          )} đ",
                                    style:
                                        Theme.of(context).textTheme.bodySmall!,
                                  ),
                                  const Spacer(),
                                  Text(
                                    "x${count[i]}",
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
              onPressed: () {
                navigatorToSelectCoupon(context);
              },
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
            idAddressSelect.isEmpty
                ? StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(ref.watch(userData)["uid"])
                        .collection("address")
                        .where("default", isEqualTo: true)
                        .snapshots(),
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
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return const StatusPageWithOutScaffold(
                          type: StatusPageEnum.noData,
                          err: "",
                        );
                      }
                      final Address addressDeli = Address(
                        createAt: snapshot.data!.docs[0]["create_at"].toDate(),
                        phoneNumber: snapshot.data!.docs[0]["phone_number"],
                        name: snapshot.data!.docs[0]["name"],
                        id: snapshot.data!.docs[0].id,
                        defaultAddress: snapshot.data!.docs[0]["default"],
                        address: snapshot.data!.docs[0]["address"],
                        province: snapshot.data!.docs[0]["province"],
                        district: snapshot.data!.docs[0]["district"],
                        ward: snapshot.data!.docs[0]["ward"],
                      );
                      return FutureBuilder<String>(
                          future: getFeeDeli(
                              addressDeli, _totalWeightProduct.toString()),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const StatusPageWithOutScaffold(
                                type: StatusPageEnum.loading,
                                err: "",
                              );
                            } else if (snapshot.hasError) {
                              return StatusPageWithOutScaffold(
                                type: StatusPageEnum.error,
                                err: snapshot.error.toString(),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const StatusPageWithOutScaffold(
                                type: StatusPageEnum.noData,
                                err: "",
                              );
                            }
                            final fee = snapshot.data;
                            return Row(
                              children: [
                                Text(
                                  "Giao Hang Tiet Kiem",
                                  style: Theme.of(context).textTheme.bodySmall!,
                                ),
                                const Spacer(),
                                Column(
                                  children: [
                                    // Text(
                                    //   "199.000",
                                    //   style: Theme.of(context)
                                    //       .textTheme
                                    //       .bodySmall!
                                    //       .copyWith(
                                    //         decoration:
                                    //             TextDecoration.lineThrough,
                                    //         decorationColor: Theme.of(context)
                                    //             .colorScheme
                                    //             .secondary,
                                    //       ),
                                    // ),
                                    Text(
                                      formatCurrency(int.parse(fee!)),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          });
                    },
                  )
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("users")
                        .doc(ref.watch(userData)["uid"])
                        .collection("address")
                        .doc(idAddressSelect)
                        .snapshots(),
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
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const StatusPageWithOutScaffold(
                          type: StatusPageEnum.noData,
                          err: "",
                        );
                      }
                      final Address addressDeli = Address(
                        createAt: snapshot.data!["create_at"].toDate(),
                        phoneNumber: snapshot.data!["phone_number"],
                        name: snapshot.data!["name"],
                        id: snapshot.data!.id,
                        defaultAddress: snapshot.data!["default"],
                        address: snapshot.data!["address"],
                        province: snapshot.data!["province"],
                        district: snapshot.data!["district"],
                        ward: snapshot.data!["ward"],
                      );
                      return FutureBuilder<String>(
                          future: getFeeDeli(
                              addressDeli, _totalWeightProduct.toString()),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const StatusPageWithOutScaffold(
                                type: StatusPageEnum.loading,
                                err: "",
                              );
                            } else if (snapshot.hasError) {
                              return StatusPageWithOutScaffold(
                                type: StatusPageEnum.error,
                                err: snapshot.error.toString(),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const StatusPageWithOutScaffold(
                                type: StatusPageEnum.noData,
                                err: "",
                              );
                            }
                            final fee = snapshot.data;
                            return Row(
                              children: [
                                Text(
                                  "Giao Hang Tiet Kiem",
                                  style: Theme.of(context).textTheme.bodySmall!,
                                ),
                                const Spacer(),
                                Column(
                                  children: [
                                    // Text(
                                    //   "199.000",
                                    //   style: Theme.of(context)
                                    //       .textTheme
                                    //       .bodySmall!
                                    //       .copyWith(
                                    //         decoration:
                                    //             TextDecoration.lineThrough,
                                    //         decorationColor: Theme.of(context)
                                    //             .colorScheme
                                    //             .secondary,
                                    //       ),
                                    // ),
                                    Text(
                                      formatCurrency(int.parse(fee!)),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          });
                    },
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
              height: height / 6,
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

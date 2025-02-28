import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopify/models/product.dart';
import 'package:flutter/services.dart';
import 'package:shopify/models/status_page.dart';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/utils/navigation_helper.dart';
import 'package:shopify/widgets/status_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailTrackingScreen extends StatefulWidget {
  const DetailTrackingScreen({super.key, required this.idOrder});
  final String idOrder;

  @override
  State<DetailTrackingScreen> createState() => _DetailTrackingScreenState();
}

class _DetailTrackingScreenState extends State<DetailTrackingScreen> {
  String GHTK_API = dotenv.env['GHTK_API'].toString();
  String pick_address = dotenv.env['pick_address'].toString();
  String pick_province = dotenv.env['pick_province'].toString();
  String pick_district = dotenv.env['pick_district'].toString();
  final String urlCheckFeeDeli = "services.giaohangtietkiem.vn";

  bool _isLoading = false;

  void _cancleTracking(String orderStatus) async {
    setState(() {
      _isLoading = true;
    });
    // nếu như đơn hàng ko ở trong trạng thái xác nhận thì cần phải xóa đơn ở trên giao hang tiet kiem
    if (orderStatus != "waiting") {
      try {
        String endPointCheckDeli =
            "/services/shipment/cancel/partner_id:${widget.idOrder}";
        Uri uri = Uri.https(urlCheckFeeDeli, endPointCheckDeli);
        var response = await http.post(
          uri,
          headers: {
            "Token": GHTK_API,
            "X-Client-Source": widget.idOrder,
            "Content-Type": "application/json"
          },
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> result = jsonDecode(response.body);
          if (result["success"]) {
            await FirebaseFirestore.instance
                .collection("orders")
                .doc(widget.idOrder)
                .update({
              "shipping_status": "cancel",
            });

            setState(() {
              _isLoading = false;
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Success"),
                action: SnackBarAction(label: "Ok", onPressed: () {}),
              ),
            );
            return;
          }
          throw Exception(result["message"]);
        } else {
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Err: from api"),
              action: SnackBarAction(label: "Ok", onPressed: () {}),
            ),
          );
          print("ERR: ${jsonDecode(response.body)}");
          return;
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("ERR: $e"),
            action: SnackBarAction(label: "Ok", onPressed: () {}),
          ),
        );
        return;
      }
    }
    await FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.idOrder)
        .update({
      "shipping_status": "cancel",
    });

    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Success"),
        action: SnackBarAction(label: "Ok", onPressed: () {}),
      ),
    );
  }

  Future<void> getStatusProduct(
      String status, Map<String, dynamic> order) async {
    if (status == "waiting") return;

    setState(() => _isLoading = true);
    try {
      if (order["label"] == null) {
        throw Exception("Don't have label");
      }
      String label = order["label"];
      String endPointCheckDeli = "/services/shipment/v2/$label";
      Uri uri = Uri.https(urlCheckFeeDeli, endPointCheckDeli);

      var response = await http.get(
        uri,
        headers: {
          "Token": GHTK_API,
          "X-Client-Source": label,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);

        if (result["success"] == true) {
          final statusNow = int.parse(result["order"]["status"]);
          await FirebaseFirestore.instance
              .collection("orders")
              .doc(widget.idOrder)
              .update({
            "shipping_status": statusNow <= 2
                ? "prepare"
                : statusNow == 3 || statusNow == 4
                    ? "delivery"
                    : statusNow == 5 || statusNow == 6 || statusNow == 45
                        ? "success"
                        : "cancel",
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Success"),
                action: SnackBarAction(label: "Ok", onPressed: () {})),
          );
        } else {
          throw Exception(result["message"]);
        }
      } else {
        print("API Error: ${response.body}");
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("ERR: $e"),
            action: SnackBarAction(label: "Ok", onPressed: () {})),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tracking Details",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("orders")
                .doc(widget.idOrder)
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
              } else if (!snapshot.hasData || snapshot.data!.data() == null) {
                return const StatusPageWithOutScaffold(
                  type: StatusPageEnum.noData,
                  err: "",
                );
              }
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final orderInfor = {
                "id": snapshot.data!.id,
                "total_weight": data!["total_weight"],
                "total_price": data["total_price"],
                "shipping_status": data["shipping_status"]
              };
              return FutureBuilder(
                future: getStatusProduct(orderInfor["shipping_status"], data),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const StatusPageWithOutScaffold(
                      type: StatusPageEnum.loading,
                      err: "",
                    );
                  }
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("orders")
                        .doc(widget.idOrder)
                        .collection("product")
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
                      final procResult = snapshot.data!.docs;
                      final List<ProductInOrder> product = [];
                      for (var proc in procResult) {
                        product.add(ProductInOrder(
                          name: proc["name"],
                          color: proc["color"],
                          purchaseQuantity: proc["purchase_quantity"],
                          colorCode: proc["color_code"] is int
                              ? proc["color_code"]
                              : int.tryParse(proc["color_code"].toString()) ??
                                  0,
                          id: proc.id,
                          idProduct: proc["id_product"],
                          linkImageMatch: proc["link_img_match"],
                        ));
                      }
                      return ListView(
                        children: [
                          for (int i = 0; i < product.length; i++)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        navigatorToDetailProduct(
                                            context, product[i].idProduct);
                                      },
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(height / 80),
                                        child: Image.network(
                                          product[i].linkImageMatch,
                                          height: height / 8,
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product[i].name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            product[i].color,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "x${product[i].purchaseQuantity}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                              ],
                            ),
                          const SizedBox(
                            height: 24,
                          ),
                          if (orderInfor["shipping_status"] != "waiting")
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Id Order",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      Text(
                                        orderInfor["id"],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!,
                                        overflow: TextOverflow.clip,
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          await Clipboard.setData(
                                            const ClipboardData(
                                                text: "your text"),
                                          );
                                        },
                                        icon: const Icon(Icons.copy),
                                      ),
                                    ],
                                  ),
                                ),

                                // copy
                              ],
                            ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "Total",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "${formatCurrency(orderInfor["total_price"])} đ",
                                  style: Theme.of(context).textTheme.bodySmall!,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 24,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.orange,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "From to:",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      pick_address,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!,
                                      overflow: TextOverflow.clip,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.local_shipping,
                                color: Colors.orange,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Send to:",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection("orders")
                                            .doc(widget.idOrder)
                                            .collection("address")
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator(
                                              color: Colors.orange,
                                            );
                                          } else if (snapshot.hasError) {
                                            return Text(
                                              "${snapshot.error}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!,
                                              overflow: TextOverflow.clip,
                                            );
                                          } else if (!snapshot.hasData ||
                                              snapshot.data!.docs.isEmpty) {
                                            return Text(
                                              "No data",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!,
                                              overflow: TextOverflow.clip,
                                            );
                                          }
                                          return Text(
                                            snapshot.data!.docs[0]["address"],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!,
                                            overflow: TextOverflow.clip,
                                          );
                                        }),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.scale,
                                color: Colors.orange,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Total Weight:",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      "${orderInfor["total_weight"]} kg",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!,
                                      overflow: TextOverflow.clip,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 24,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.circle,
                                color: Colors.orange,
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Waiting for Confirmation",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.clip,
                                    ),
                                    Text(
                                      "Order Pending Confirmation",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!,
                                      overflow: TextOverflow.clip,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (orderInfor["shipping_status"] != "waiting" &&
                              orderInfor["shipping_status"] != "cancel")
                            const SizedBox(
                              height: 24,
                            ),
                          if (orderInfor["shipping_status"] != "waiting" &&
                              orderInfor["shipping_status"] != "cancel")
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.circle,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Preparing The Order",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.clip,
                                      ),
                                      Text(
                                        "Order is being prepared for delivery",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!,
                                        overflow: TextOverflow.clip,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          if (orderInfor["shipping_status"] != "waiting" &&
                              orderInfor["shipping_status"] != "prepare" &&
                              orderInfor["shipping_status"] != "cancel")
                            const SizedBox(
                              height: 24,
                            ),
                          if (orderInfor["shipping_status"] != "waiting" &&
                              orderInfor["shipping_status"] != "prepare" &&
                              orderInfor["shipping_status"] != "cancel")
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.circle,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Orders In Delivery",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.clip,
                                      ),
                                      Text(
                                        "Order are being shipped to transit location",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!,
                                        overflow: TextOverflow.clip,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          if (orderInfor["shipping_status"] != "waiting" &&
                              orderInfor["shipping_status"] != "prepare" &&
                              orderInfor["shipping_status"] != "send" &&
                              orderInfor["shipping_status"] != "cancel")
                            const SizedBox(
                              height: 24,
                            ),
                          if (orderInfor["shipping_status"] != "waiting" &&
                              orderInfor["shipping_status"] != "prepare" &&
                              orderInfor["shipping_status"] != "send" &&
                              orderInfor["shipping_status"] != "cancel")
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.circle,
                                  color: Colors.orange,
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Towarts Destination",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.clip,
                                      ),
                                      Text(
                                        "Order to destination address",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!,
                                        overflow: TextOverflow.clip,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(
                            height: 24,
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 12,
                          ),
                          if (orderInfor["shipping_status"] != "waiting")
                            Text(
                              "Order ID Can Be Used To Track On The Homepage Of Giao Hang Tiet Kiem",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                      color:
                                          Theme.of(context).colorScheme.error),
                            ),
                          const SizedBox(
                            height: 24,
                          ),
                          if (orderInfor["shipping_status"] == "waiting" ||
                              orderInfor["shipping_status"] == "prepare")
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: ElevatedButton(
                                onPressed: () {
                                  _cancleTracking(
                                      orderInfor["shipping_status"]);
                                },
                                child: Text(
                                  "Cancel Order",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              );
            }),
      ),
    );
  }
}

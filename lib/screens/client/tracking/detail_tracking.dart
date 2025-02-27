import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopify/data/data_test.dart';
import 'package:shopify/models/product.dart';
import 'package:flutter/services.dart';
import 'package:shopify/models/status_page.dart';
import 'package:shopify/utils/formart_currency.dart';
import 'package:shopify/widgets/status_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DetailTrackingScreen extends StatefulWidget {
  const DetailTrackingScreen({super.key, required this.idOrder});
  final String idOrder;

  @override
  State<DetailTrackingScreen> createState() => _DetailTrackingScreenState();
}

class _DetailTrackingScreenState extends State<DetailTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    String GHTK_API = dotenv.env['GHTK_API'].toString();
    String pick_address = dotenv.env['pick_address'].toString();
    String pick_province = dotenv.env['pick_province'].toString();
    String pick_district = dotenv.env['pick_district'].toString();
    print(pick_address);
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
                            : int.tryParse(proc["color_code"].toString()) ?? 0,
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
                                    onPressed: () {},
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
                                flex: 2,
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
                              flex: 2,
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
                                    style:
                                        Theme.of(context).textTheme.bodySmall!,
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
                                    style:
                                        Theme.of(context).textTheme.bodySmall!,
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
                                        .copyWith(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.clip,
                                  ),
                                  Text(
                                    "Order Pending Confirmation",
                                    style:
                                        Theme.of(context).textTheme.bodySmall!,
                                    overflow: TextOverflow.clip,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (orderInfor["shipping_status"] != "waiting")
                          const SizedBox(
                            height: 24,
                          ),
                        if (orderInfor["shipping_status"] != "waiting")
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (orderInfor["shipping_status"] != "waiting")
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
                            orderInfor["shipping_status"] != "prepare")
                          const SizedBox(
                            height: 24,
                          ),
                        if (orderInfor["shipping_status"] != "waiting" &&
                            orderInfor["shipping_status"] != "prepare")
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
                            orderInfor["shipping_status"] != "send")
                          const SizedBox(
                            height: 24,
                          ),
                        if (orderInfor["shipping_status"] != "waiting" &&
                            orderInfor["shipping_status"] != "prepare" &&
                            orderInfor["shipping_status"] != "send")
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
                                    color: Theme.of(context).colorScheme.error),
                          ),
                        const SizedBox(
                          height: 24,
                        ),
                        if (orderInfor["shipping_status"] == "waiting" ||
                            orderInfor["shipping_status"] != "prepare")
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: ElevatedButton(
                              onPressed: () {},
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
                  });
            }),
      ),
    );
  }
}

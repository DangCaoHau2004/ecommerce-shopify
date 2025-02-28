import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shopify/models/address.dart';
import 'package:shopify/models/status_page.dart';
import 'package:shopify/providers/user_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/utils/navigation_helper.dart';
import 'package:shopify/widgets/status_page.dart';

class AllAddressScreen extends ConsumerStatefulWidget {
  const AllAddressScreen({super.key});
  @override
  ConsumerState<AllAddressScreen> createState() => _AllAddressScreenState();
}

class _AllAddressScreenState extends ConsumerState<AllAddressScreen> {
  // idx address selected
  String idSelect = "";
  int indexAddressSelect = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ), // Thay đổi icon
          onPressed: () {
            Navigator.pop(context, idSelect);
          },
        ),
        title: Text(
          "Select address",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(
              height: 30,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(ref.watch(userData)["uid"])
                  .collection("address")
                  .orderBy("default", descending: true)
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
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const StatusPageWithOutScaffold(
                    type: StatusPageEnum.noData,
                    err: "",
                  );
                }
                List<Address> allAdress = snapshot.data!.docs.map((data) {
                  return Address(
                    id: data.id,
                    createAt: data["create_at"].toDate(),
                    phoneNumber: data["phone_number"],
                    name: data["name"],
                    defaultAddress: data["default"],
                    address: data["address"],
                    province: data["province"],
                    district: data["district"],
                    ward: data["ward"],
                  );
                }).toList();

                return Column(
                  children: [
                    for (int i = 0; i < allAdress.length; i++)
                      Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.2,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          borderRadius: BorderRadius.circular(width / 20),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                i == indexAddressSelect
                                    ? Icons.circle
                                    : Icons.circle_outlined,
                                color: Colors.orange,
                              ),
                              onPressed: () {
                                setState(() {
                                  idSelect = allAdress[i].id;
                                  indexAddressSelect = i;
                                });
                              },
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    allAdress[i].name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.clip,
                                        ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    allAdress[i].phoneNumber,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          overflow: TextOverflow.clip,
                                        ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    allAdress[i].address,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          overflow: TextOverflow.clip,
                                        ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  if (allAdress[i].defaultAddress)
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.orange,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      child: Text(
                                        "Default",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(color: Colors.orange),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                "Edit",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: Colors.orange),
                              ),
                            )
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              child: TextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      "Add New Address",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.orange),
                    )
                  ],
                ),
                onPressed: () {
                  navigatorToAddNewAdress(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

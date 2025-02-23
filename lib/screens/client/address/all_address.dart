import 'package:flutter/material.dart';
import 'package:shopify/models/address.dart';

class AllAddressScreen extends StatefulWidget {
  const AllAddressScreen({super.key});
  @override
  State<AllAddressScreen> createState() => _AllAddressScreenState();
}

class _AllAddressScreenState extends State<AllAddressScreen> {
  List<Address> allAdress = [
    Address(
      createAt: DateTime.now(),
      phoneNumber: "0966232303",
      name: "Hậu",
      defaultAddress: true,
      address: "Xã Phùng Xá Huyện Thạch Thất TP Hà Nội",
      provine: "Xã Phùng Xá",
      district: "Huyện Thạch Thất",
      ward: "TP Hà Nội",
    ),
    Address(
      createAt: DateTime.now(),
      phoneNumber: "0966232303",
      name: "Hậu",
      defaultAddress: false,
      address: "Xã Phùng Xá Huyện Thạch Thất TP Hà Nội",
      provine: "Xã Phùng Xá",
      district: "Huyện Thạch Thất",
      ward: "TP Hà Nội",
    ),
    Address(
      createAt: DateTime.now(),
      phoneNumber: "0966232303",
      name: "Hậu",
      defaultAddress: false,
      address: "Xã Phùng Xá Huyện Thạch Thất TP Hà Nội",
      provine: "Xã Phùng Xá",
      district: "Huyện Thạch Thất",
      ward: "TP Hà Nội",
    ),
  ];
  // idx address selected
  int _idxSelect = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
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
                      icon: const Icon(Icons.circle_outlined),
                      onPressed: () {},
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
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.clip,
                                    ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            allAdress[i].phoneNumber,
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      overflow: TextOverflow.clip,
                                    ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            allAdress[i].address,
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
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
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

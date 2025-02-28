import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/providers/user_data.dart';
import 'package:shopify/utils/navigation_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    return CustomScrollView(
      slivers: [
        // AppBar dạng Sliver
        SliverAppBar(
          backgroundColor: Colors.orange,
          floating: true,
          pinned: false,
          actions: [
            IconButton(
              onPressed: () {
                navigatorToSetting(context);
              },
              icon: const Icon(Icons.settings, color: Colors.white),
            ),
            IconButton(
              onPressed: () {
                navigatorToCoupon(context);
              },
              icon: const Icon(
                Icons.confirmation_number,
                color: Colors.white,
              ),
            ),
          ],
        ),

        // Nội dung danh sách
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Stack(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.only(bottom: 12, right: 12),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(50.0)),
                                border: Border.all(
                                  color: Colors.orange,
                                  width: 4.0,
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.transparent,
                                backgroundImage:
                                    AssetImage("assets/images/user.png"),
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 5,
                            right: 0,
                            child: Icon(Icons.edit),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.watch(userData)["username"],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ref.watch(userData)["email"],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 48,
                ),
                Text(
                  "Orders",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed: () {
                          navigatorToTabviewTrackingScreen(context, 0);
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              size: width / 10,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              "Waiting",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Colors.orange,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed: () {
                          navigatorToTabviewTrackingScreen(context, 1);
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.inventory,
                              size: width / 10,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              "Prepare",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Colors.orange,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed: () {
                          navigatorToTabviewTrackingScreen(context, 2);
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.local_shipping,
                              size: width / 10,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              "Delivery",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Colors.orange,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed: () {
                          navigatorToRate(context);
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.stars_outlined,
                              size: width / 10,
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              "Rate",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Colors.orange,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 80,
                ),
                ElevatedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Log Out",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.onTertiary),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Icon(
                        Icons.start_outlined,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

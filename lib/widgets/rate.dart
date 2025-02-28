import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopify/providers/user_data.dart';

class Rate extends ConsumerStatefulWidget {
  const Rate({super.key, required this.idOrder});
  final String idOrder;
  @override
  ConsumerState<Rate> createState() => _RateState();
}

class _RateState extends ConsumerState<Rate> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _star = 5;
  String _enterComment = "";
  void _saveForm() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        // lưu dữ liệu is_rate
        await FirebaseFirestore.instance
            .collection("orders")
            .doc(widget.idOrder)
            .set(
          {
            "is_rate": true,
          },
          SetOptions(
            merge: true,
          ),
        );
        final allProc = await FirebaseFirestore.instance
            .collection("orders")
            .doc(widget.idOrder)
            .collection("product")
            .get();
        final List<String> allIdProc = allProc.docs.map((proc) {
          return proc["id_product"].toString();
        }).toList();
        // đẩy dữ liệu comment và cập nhật lại rate
        for (var idProc in allIdProc) {
          await FirebaseFirestore.instance
              .collection("products")
              .doc(idProc)
              .collection("reviews")
              .add({
            "uid": ref.watch(userData)["uid"],
            "username": ref.watch(userData)["username"],
            "content": _enterComment,
            "rate": _star,
          });
          final reviews = await FirebaseFirestore.instance
              .collection("products")
              .doc(idProc)
              .collection("reviews")
              .get();
          List<int> allRate = reviews.docs.map((item) {
            return item["rate"] as int;
          }).toList();
          final count = await FirebaseFirestore.instance
              .collection("products")
              .doc(idProc)
              .collection("reviews")
              .count()
              .get();
          FirebaseFirestore.instance.collection("products").doc(idProc).update({
            "rate": (allRate.reduce((a, b) => a + b)) / count.count!,
          });
        }
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).clearMaterialBanners();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Success"),
            action: SnackBarAction(label: "Ok", onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).clearMaterialBanners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          action: SnackBarAction(label: "Ok", onPressed: () {}),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Widget> starWidget() {
    return List.generate(
      5,
      (i) => Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _star = i;
              });
            },
            icon: Icon(i <= _star ? Icons.star : Icons.star_border),
          ),
          if (i != 5)
            const SizedBox(
              width: 2,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return _isLoading
        ? Container(
            height: height * 0.75,
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.onTertiary),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            ),
          )
        : Container(
            height: height * 0.75,
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.onTertiary),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rating",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: starWidget(),
                ),
                const SizedBox(
                  height: 24,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text(
                            "Content",
                            style: Theme.of(context).textTheme.bodyMedium,
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
                          _enterComment = value!.trim();
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      ElevatedButton(
                        onPressed: _saveForm,
                        child: Text(
                          "Submit",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
  }
}

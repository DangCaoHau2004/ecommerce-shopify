import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({
    super.key,
  });

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _keyForm = GlobalKey<FormState>();
  List<String> type = [
    "Living Room",
    "Bedroom",
    "Home Accents",
    "Lighting",
    "Dining Room",
  ];
  bool _isLoading = false;
  String? _name;
  int? _stock;
  int? _sale;
  String? _description;
  List _enterLinkImg = [""];
  List _enterColor = [""];
  List<int> _enterColorCode = [4294967295];
  List _enterLinkImageMatch = [""];
  int? _enterprice;
  double? _enterWeight;
  String _enterType = "Living Room";
  @override
  void initState() {
    super.initState();
  }

  Color pickerColor = Colors.blue;
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void showColorPickerDialog(Color pickerColorNow, int index) {
    setState(() {
      pickerColor = pickerColorNow;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text(
              'Got it',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onPressed: () {
              setState(
                () => _enterColorCode[index] =
                    int.parse(pickerColor.toHexString(), radix: 16),
              );
              Navigator.of(context).pop("");
            },
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, Function(String?) onSaved,
      {TextInputType? inputType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          style: Theme.of(context).textTheme.bodySmall,
          keyboardType: inputType,
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            hintText: "$label...",
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? "Please enter correctly!"
              : null,
          onSaved: onSaved,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildImageField(int index) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                style: Theme.of(context).textTheme.bodySmall,
                initialValue: _enterLinkImg[index],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  hintText: "Image Link...",
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? "Please enter correctly!"
                    : null,
                onSaved: (value) => _enterLinkImg[index] = value!.trim(),
              ),
            ),
            if (_enterLinkImg.length > 1)
              IconButton(
                icon: Icon(Icons.delete,
                    color: Theme.of(context).colorScheme.error),
                onPressed: () => setState(() => _enterLinkImg.removeAt(index)),
              )
          ],
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }

  Widget buildColorField(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 24,
        ),
        Row(
          children: [
            Text(
              "Number ${index + 1}",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            if (_enterColor.length > 1)
              IconButton(
                icon: Icon(Icons.delete,
                    color: Theme.of(context).colorScheme.error),
                onPressed: () {
                  setState(() {
                    _enterColor.removeAt(index);
                    _enterColorCode.removeAt(index);
                    _enterLinkImageMatch.removeAt(index);
                  });
                },
              ),
          ],
        ),
        TextFormField(
          style: Theme.of(context).textTheme.bodySmall,
          initialValue: _enterColor[index],
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            hintText: "Color Name...",
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? "Please enter correctly!"
              : null,
          onSaved: (value) => _enterColor[index] = value!.trim(),
        ),
        const SizedBox(
          height: 12,
        ),
        TextButton(
          onPressed: () {
            showColorPickerDialog(
              Color(_enterColorCode[index]),
              index,
            );
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color(_enterColorCode[index]),
              border:
                  Border.all(color: Theme.of(context).colorScheme.secondary),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        TextFormField(
          style: Theme.of(context).textTheme.bodySmall,
          initialValue: _enterLinkImageMatch[index],
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            hintText: "Link Image Match...",
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? "Please enter correctly!"
              : null,
          onSaved: (value) => _enterLinkImageMatch[index] = value!.trim(),
        ),
      ],
    );
  }

  void saveForm() async {
    setState(() {
      _isLoading = true;
    });
    if (_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();

      try {
        final idProc =
            await FirebaseFirestore.instance.collection("products").add(
          {
            "create_at": DateTime.now(),
            "stock_quantity": _stock,
            "description": _description,
            "name": _name,
            "color": _enterColor,
            "link_img": _enterLinkImg,
            "price": _enterprice,
            "weight": _enterWeight,
            "type": _enterType,
            "link_image_match": _enterLinkImageMatch,
            "color_code": _enterColorCode,
            "sale": _sale,
            "rate": 5.0
          },
        );
        Navigator.of(context).pop(idProc.id);

        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        Navigator.of(context).pop("");
        ScaffoldMessenger.of(context).clearMaterialBanners();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$e"),
            action: SnackBarAction(label: "Ok", onPressed: () {}),
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    if (_isLoading) {
      return Container(
        color: Theme.of(context).colorScheme.onTertiary,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.orange,
          ),
        ),
      );
    }
    return Container(
      color: Theme.of(context).colorScheme.onTertiary,
      padding: EdgeInsets.only(
          bottom: 16 + keyboardSpace, top: 16, left: 16, right: 16),
      child: Form(
        key: _keyForm,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Edit Product",
                      style: Theme.of(context).textTheme.bodyLarge),
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop("");
                      },
                      icon: const Icon(Icons.close))
                ],
              ),
              const SizedBox(height: 20),
              buildTextField("Name", (value) => _name = value),
              buildTextField("Stock Quantity",
                  (value) => _stock = int.parse(value!.trim()),
                  inputType: TextInputType.number),
              buildTextField(
                  "Sale(%)", (value) => _sale = int.parse(value!.trim()),
                  inputType: TextInputType.number),
              const SizedBox(
                height: 4,
              ),
              buildTextField("Description", (value) => _description = value),
              const SizedBox(height: 16),
              Text("Images",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold)),
              ...List.generate(
                _enterLinkImg.length,
                (index) => buildImageField(index),
              ),
              ElevatedButton(
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
                onPressed: () => setState(() {
                  _enterLinkImg.add("");
                }),
              ),
              const SizedBox(height: 16),
              Text("Colors",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold)),
              ...List.generate(
                  _enterColor.length, (index) => buildColorField(index)),
              ElevatedButton(
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
                onPressed: () => setState(() {
                  _enterColor.add("");
                  _enterColorCode.add(4294967295);
                  _enterLinkImageMatch.add("");
                }),
              ),
              const SizedBox(height: 16),
              buildTextField(
                  "Price", (value) => _enterprice = int.parse(value!.trim()),
                  inputType: TextInputType.number),
              buildTextField("Weight(kg)",
                  (value) => _enterWeight = double.parse(value!.trim()),
                  inputType: TextInputType.number),
              Text(
                "Type",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField(
                  value: _enterType,
                  items: [
                    ...type.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(
                          t,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    })
                  ],
                  onChanged: (value) {
                    setState(() {
                      _enterType = value!;
                    });
                  }),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: saveForm,
                child: Text(
                  "Save",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

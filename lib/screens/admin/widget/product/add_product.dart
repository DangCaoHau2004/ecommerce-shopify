import 'package:flutter/material.dart';
import 'package:shopify/models/product.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EditProduct extends StatefulWidget {
  const EditProduct(
      {super.key, required this.idProduct, required this.product});
  final String idProduct;
  final Product product;

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _keyForm = GlobalKey<FormState>();
  List<String> type = [
    "Living Room",
    "Bedroom",
    "Home Accents",
    "Lighting",
    "Dining Room",
  ];
  String? _name;
  int? _stock;
  int? _sale;
  String? _description;
  List _enterLinkImg = [];
  List _enterColor = [];
  List<int> _enterColorCode = [];
  List _enterLinkImageMatch = [];
  int? _enterprice;
  double? _enterWeight; // kg
  String? _enterType;
  @override
  void initState() {
    super.initState();
    _name = widget.product.name;
    _stock = widget.product.stockQuantity;
    _sale = widget.product.sale;
    _description = widget.product.description;
    _enterprice = widget.product.price;
    _enterWeight = widget.product.weight;
    _enterType = widget.product.type;
    _enterLinkImg = widget.product.linkImg;
    _enterColor = widget.product.color;
    _enterColorCode = widget.product.colorCode;
    _enterLinkImageMatch = widget.product.linkImageMatch;
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
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
      String label, String initialValue, Function(String?) onSaved,
      {TextInputType? inputType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
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
                onSaved: (value) => _enterLinkImg[index] = value!.trim(),
              ),
            ),
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
          onSaved: (value) => _enterColor[index] = value!.trim(),
        ),
      ],
    );
  }

  void saveForm() {
    if (_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onTertiary,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _keyForm,
        child: ListView(
          children: [
            Text("Edit Product", style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),
            buildTextField("Name", _name!, (value) => _name = value),
            buildTextField("Stock Quantity", _stock.toString(),
                (value) => _stock = int.parse(value!),
                inputType: TextInputType.number),
            buildTextField(
                "Sale", _sale.toString(), (value) => _sale = int.parse(value!),
                inputType: TextInputType.number),
            buildTextField(
                "Description", _description!, (value) => _description = value),
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
            buildTextField("Price", _enterprice.toString(),
                (value) => _enterprice = int.parse(value!)),
            buildTextField("Weight", _enterWeight.toString(),
                (value) => _enterWeight = double.parse(value!)),
            DropdownButton(
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
                    _enterType = value;
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
    );
  }
}

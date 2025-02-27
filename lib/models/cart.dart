class CartModel {
  CartModel(
      {required this.colorSelectIndex,
      required this.purchaseQuantity,
      required this.id,
      required this.idProc});
  int purchaseQuantity;
  int colorSelectIndex;
  final String id;
  final String idProc;
  Map<String, dynamic> getCart() {
    return {
      "purchase_quantity": purchaseQuantity,
      "color_select_index": colorSelectIndex,
      "id": idProc,
    };
  }
}

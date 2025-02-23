String formatCurrency(int number) {
  List<String> formatNumber = [];

  while (number >= 1) {
    // nếu như còn nhiều hơn 3 chữ số
    if (number >= 100) {
      formatNumber.insert(
          0, (number % 1000).toInt().toString().padLeft(3, '0'));
    }
    // nếu như còn ít hơn 2 chữ số có nghĩa là những số đầu tiên
    else {
      formatNumber.insert(0, (number % 1000).toInt().toString());
    }
    number = number ~/ 1000;
  }

  String formattedNumber = formatNumber.join(".");
  return formattedNumber;
}

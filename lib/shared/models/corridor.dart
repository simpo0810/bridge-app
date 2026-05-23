class Corridor {
  final String id;
  final String fromCurrency;
  final String toCurrency;
  final String countryCode;
  final String countryName;
  final String flagEmoji;
  final List<String> deliveryMethods;

  const Corridor({
    required this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.countryCode,
    required this.countryName,
    required this.flagEmoji,
    required this.deliveryMethods,
  });
}

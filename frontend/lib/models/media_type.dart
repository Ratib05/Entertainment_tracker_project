enum MediaType {
  film('film'),
  show('show'),
  game('game');

  final String value;
  const MediaType(this.value);

  static MediaType fromString(String value) {
    return MediaType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Unknown MediaType: $value'),
    );
  }
}

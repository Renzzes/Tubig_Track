enum UpdateChannel {
  stable('stable'),
  beta('beta');

  final String value;
  const UpdateChannel(this.value);

  static UpdateChannel fromString(String? value) {
    return UpdateChannel.values.firstWhere(
      (c) => c.value == value,
      orElse: () => UpdateChannel.stable,
    );
  }
}

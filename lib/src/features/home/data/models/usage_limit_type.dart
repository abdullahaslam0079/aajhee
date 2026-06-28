enum UsageLimitType {
  oneTime('one_time'),
  oncePerWeek('once_per_week'),
  oncePerMonth('once_per_month'),
  nTimesPerWeek('n_times_per_week'),
  nTimesPerMonth('n_times_per_month'),
  nTimesTotal('n_times_total');

  const UsageLimitType(this.apiValue);

  final String apiValue;

  static UsageLimitType fromApi(String value) {
    return UsageLimitType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => UsageLimitType.oneTime,
    );
  }

  bool get isPeriodBased =>
      this == UsageLimitType.oncePerWeek ||
      this == UsageLimitType.oncePerMonth ||
      this == UsageLimitType.nTimesPerWeek ||
      this == UsageLimitType.nTimesPerMonth;
}

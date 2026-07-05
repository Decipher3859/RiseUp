class WeekdayMask {
  static const int monday = 1 << 0; // 1
  static const int tuesday = 1 << 1; // 2
  static const int wednesday = 1 << 2; // 4
  static const int thursday = 1 << 3; // 8
  static const int friday = 1 << 4; // 16
  static const int saturday = 1 << 5; // 32
  static const int sunday = 1 << 6; // 64

  static bool contains(int mask, int day) => (mask & day) != 0;

  static int addDay(int mask, int day) => mask | day;

  static int removeDay(int mask, int day) => mask & ~day;

  static int fromDate(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return monday;
      case DateTime.tuesday:
        return tuesday;
      case DateTime.wednesday:
        return wednesday;
      case DateTime.thursday:
        return thursday;
      case DateTime.friday:
        return friday;
      case DateTime.saturday:
        return saturday;
      case DateTime.sunday:
        return sunday;
      default:
        return 0;
    }
  }

  static int countDays(int mask) {
    int count = 0;
    for (int i = 0; i < 7; i++) {
      if ((mask & (1 << i)) != 0) count++;
    }
    return count;
  }
}

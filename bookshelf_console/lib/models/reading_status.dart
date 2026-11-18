enum ReadingStatus {
  planned('Запланирована', 0),
  reading('Читаю', 1),
  finished('Прочитана', 2),
  abandoned('Брошена', 3);

  final String label;
  final int order;
  const ReadingStatus(this.label, this.order);

  bool get isDone => this == ReadingStatus.finished;

  static ReadingStatus fromName(String name) {
    final String value = name.trim().toLowerCase();
    return values.firstWhere(
      (ReadingStatus s) => s.name == value || s.label.toLowerCase() == value,
      orElse: () => planned,
    );
  }
}

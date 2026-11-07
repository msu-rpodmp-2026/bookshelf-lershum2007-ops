import 'reading_status.dart';
import 'library_item.dart';

abstract interface class Searchable {
  bool matches(String query);
}

abstract interface class RateableInterface {
  void vote(double score);
}

class Book extends LibraryItem
    implements Searchable, RateableInterface, Comparable<Book> {
  @override
  final String title;
  final String author;
  final int year;
  final int pages;
  final Set<String> genres;
  final ReadingStatus status;
  double? _rating;

  double _totalRating = 0;
  int _votesCount = 0;

  Book({
    required this.title,
    required this.author,
    this.year = 2024,
    this.pages = 0,
    Set<String>? genres,
    this.status = ReadingStatus.planned,
    double? rating,
  }) : genres = genres ?? {},
       _rating = rating;

  String get shortTitle =>
      title.length > 25 ? '${title.substring(0, 22)}...' : title;
  double get readingHours => pages / 50.0;
  int get age => DateTime.now().year - year;
  bool get isRated => _rating != null;

  set rating(double? value) {
    if (value != null && (value < 0 || value > 5)) {
      throw ArgumentError('Оценка должна быть от 0 до 5');
    }
    _rating = value;
  }

  double? get rating => _rating;

  @override
  bool matches(String query) {
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) || author.toLowerCase().contains(q);
  }

  @override
  void vote(double score) {
    _totalRating += score;
    _votesCount++;
  }

  double get averageRating => _votesCount == 0 ? 0 : _totalRating / _votesCount;

  @override
  String describe() => '«$title» — $author ($year), $pages стр.';

  @override
  String toString() => 'Book($title, $author, $year)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Book &&
        other.title == title &&
        other.author == author &&
        other.year == year;
  }

  @override
  int get hashCode => Object.hash(title, author, year);

  @override
  int compareTo(Book other) => title.compareTo(other.title);

  Book copyWith({
    String? newTitle,
    String? newAuthor,
    int? newYear,
    int? newPages,
    Set<String>? newGenres,
    ReadingStatus? newStatus,
    double? newRating,
  }) {
    return Book(
      title: newTitle ?? title,
      author: newAuthor ?? author,
      year: newYear ?? year,
      pages: newPages ?? pages,
      genres: newGenres ?? genres,
      status: newStatus ?? status,
      rating: newRating ?? _rating,
    );
  }
}

mixin Loggable {
  void log(String message) {
    print('[${DateTime.now().toIso8601String()}] $message');
  }
}

mixin Borrowable on Book {
  DateTime? _dueDate;

  bool get isBorrowed => _dueDate != null;

  void borrow(int days) {
    _dueDate = DateTime.now().add(Duration(days: days));
    print('Книга «$title» выдана до ${_dueDate.toString().split(' ')[0]}');
  }

  void giveBack() {
    _dueDate = null;
    print('Книга «$title» возвращена');
  }
}

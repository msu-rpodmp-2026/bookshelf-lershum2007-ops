import 'audio_book.dart';
import 'book.dart';
import 'ebook.dart';
import 'paper_book.dart';
import 'reading_status.dart';

/// Фабрика-диспетчер: по полю type собирает нужный подкласс книги.
/// Благодаря ей полиморфизм из ЛР №3 сохраняется после перезагрузки.
Book bookFromJson(Map<String, dynamic> j) {
  final String type = j['type'] as String? ?? 'book';
  final String title = j['title'] as String? ?? 'Без названия';
  final String author = j['author'] as String? ?? 'Автор неизвестен';
  final int year = (j['year'] as num?)?.toInt() ?? 0;
  final int pages = (j['pages'] as num?)?.toInt() ?? 0;
  final Set<String> genres =
      (j['genres'] as List?)?.cast<String>().toSet() ?? <String>{};
  final ReadingStatus status = ReadingStatus.fromName(
    j['status'] as String? ?? '',
  );

  final Book book;
  switch (type) {
    case 'paper':
      book = PaperBook(
        title: title,
        author: author,
        year: year,
        pages: pages,
        genres: genres,
        status: status,
        shelfLocation: j['shelfLocation'] as String? ?? 'A1',
      );
      break;
    case 'ebook':
      book = EBook(
        title: title,
        author: author,
        year: year,
        pages: pages,
        genres: genres,
        status: status,
        format: j['format'] as String? ?? 'PDF',
        sizeMb: (j['sizeMb'] as num?)?.toDouble() ?? 0,
      );
      break;
    case 'audio':
      book = AudioBook(
        title: title,
        author: author,
        year: year,
        genres: genres,
        status: status,
        duration: Duration(
          minutes: (j['durationMinutes'] as num?)?.toInt() ?? 0,
        ),
        narrator: j['narrator'] as String? ?? 'не указан',
      );
      break;
    default:
      book = Book.fromJson(j);
  }

  // Сеттер rating из ЛР №3 сам проверяет диапазон 0..5.
  final double? rating = (j['rating'] as num?)?.toDouble();
  if (rating != null && rating >= 0 && rating <= 5) {
    book.rating = rating;
  }
  return book;
}

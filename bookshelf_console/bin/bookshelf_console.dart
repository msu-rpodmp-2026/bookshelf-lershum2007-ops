import 'dart:io';
import 'dart:convert';
import 'package:bookshelf_console/models/book.dart';
import 'package:bookshelf_console/models/audio_book.dart';
import 'package:bookshelf_console/models/ebook.dart';
import 'package:bookshelf_console/models/paper_book.dart';
import 'package:bookshelf_console/models/library.dart';
import 'package:bookshelf_console/models/reading_status.dart';

void out(Object? s) {
  stdout.add(utf8.encode('$s\n'));
}

void outWrite(String s) {
  stdout.add(utf8.encode(s));
}

void printHeader(String text) {
  out('\n────────────────────────────────────');
  out('  $text');
  out('────────────────────────────────────');
}

void main() {
  final Library<Book> lib = Library<Book>();

  // Заполняем каталог
  lib.add(
    PaperBook(
      title: 'Война и мир',
      author: 'Л. Н. Толстой',
      year: 1869,
      pages: 1225,
      genres: {'роман', 'классика'},
      shelfLocation: 'A2',
      status: ReadingStatus.finished,
    ),
  );
  lib.add(
    EBook(
      title: '1984',
      author: 'Дж. Оруэлл',
      year: 1949,
      format: 'PDF',
      sizeMb: 5.2,
      genres: {'антиутопия'},
    ),
  );
  lib.add(
    AudioBook(
      title: 'Дюна',
      author: 'Ф. Герберт',
      year: 1965,
      duration: Duration(minutes: 120),
      narrator: 'Иван Иванов',
      genres: {'фантастика'},
    ),
  );
  lib.add(
    Book(
      title: 'Основы Dart',
      author: 'С. Чернышев',
      year: 2024,
      pages: 521,
      genres: {'учебник'},
    ),
  );

  var running = true;
  while (running) {
    out('\n=== Каталог BookShelf (ООП) ===');
    out('1. Показать весь каталог');
    out('2. Поиск (название/автор/жанр)');
    out('3. Показать только прочитанные');
    out('4. Сортировка по названию');
    out('5. Статистика по жанрам');
    out('6. Выдать бумажную книгу');
    out('0. Выход');
    outWrite('Выберите действие > ');

    final command = (stdin.readLineSync(encoding: utf8) ?? '').trim();

    switch (command) {
      case '1':
        printHeader('Весь каталог (${lib.count} шт.)');
        for (final b in lib.items) {
          out(' ${b.describe()}');
        }
        break;

      case '2':
        outWrite('\nВведите запрос для поиска: ');
        final q = stdin.readLineSync(encoding: utf8) ?? '';
        final results = lib.search(q).toList();

        if (results.isEmpty) {
          out('\n[!] По запросу «$q» ничего не найдено.');
        } else {
          printHeader('Результаты поиска по «$q» (${results.length} шт.)');
          for (final b in results) {
            out(' ${b.describe()}');
          }
        }
        break;

      case '3':
        final readBooks = lib
            .where((b) => b.status == ReadingStatus.finished)
            .toList();
        printHeader('Прочитанные книги (${readBooks.length} шт.)');
        if (readBooks.isEmpty) {
          out(' Пока нет прочитанных книг.');
        } else {
          for (final b in readBooks) {
            out(' ${b.describe()}');
          }
        }
        break;

      case '4':
        printHeader('Сортировка по названию');
        final sorted = lib.items.toList()..sort();
        for (final b in sorted) {
          out(' ${b.title} — ${b.author}');
        }
        break;

      case '5':
        printHeader('Статистика по жанрам');
        final stats = lib.countByGenre();
        if (stats.isEmpty) {
          out(' Жанры не указаны.');
        } else {
          stats.forEach((genre, count) {
            out(' Жанр «$genre»: $count кн.');
          });
        }
        break;

      case '6':
        printHeader('Выдача бумажной книги');
        var issued = false;
        for (final b in lib.items) {
          if (b is PaperBook && !b.isBorrowed) {
            b.borrow(14);
            issued = true;
            break;
          }
        }
        if (!issued) out(' Нет доступных бумажных книг.');
        break;

      case '0':
        running = false;
        out('\nРабота программы завершена. До свидания!');
        break;

      default:
        out('\n[!] Неизвестная команда. Попробуйте снова.');
    }
  }
}

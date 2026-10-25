import 'dart:io';
import 'dart:convert';

// Вспомогательные функции вывода в UTF-8
void out(Object? s) {
  stdout.add(utf8.encode('$s\n'));
}

void outWrite(String s) {
  stdout.add(utf8.encode(s));
}

// Задание 1. Структура данных каталога
typedef Book = Map<String, Object?>;

final List<Book> library = [
  {
    'title': 'Основы Dart',
    'author': 'С. А. Чернышев',
    'year': 2024,
    'pages': 521,
    'genre': 'учебник',
    'read': true,
  },
  {
    'title': 'Flutter на практике',
    'author': 'Ф. Заметти',
    'year': 2020,
    'pages': 328,
    'genre': 'учебник',
    'read': false,
  },
  {
    'title': 'Война и мир',
    'author': 'Л. Н. Толстой',
    'year': 1869,
    'pages': 1225,
    'genre': 'роман',
    'read': true,
  },
  {
    'title': 'Мастер и Маргарита',
    'author': 'М. А. Булгаков',
    'year': 1967,
    'pages': 480,
    'genre': 'роман',
    'read': true,
  },
  {
    'title': 'Преступление и наказание',
    'author': 'Ф. М. Достоевский',
    'year': 1866,
    'pages': 671,
    'genre': 'роман',
    'read': false,
  },
  {
    'title': '1984',
    'author': 'Дж. Оруэлл',
    'year': 1949,
    'pages': 320,
    'genre': 'антиутопия',
    'read': true,
  },
  {
    'title': 'Гарри Поттер и философский камень',
    'author': 'Дж. Роулинг',
    'year': 1997,
    'pages': 400,
    'genre': 'фэнтези',
    'read': false,
  },
  {
    'title': 'Дюна',
    'author': 'Ф. Герберт',
    'year': 1965,
    'pages': 688,
    'genre': 'фантастика',
    'read': false,
  },
];

// Задание 3. Функции вывода и поиска
void printAll(List<Book> books, {String emptyMessage = 'Ничего не найдено.'}) {
  if (books.isEmpty) {
    out(emptyMessage);
    return;
  }
  for (int i = 0; i < books.length; i++) {
    final b = books[i];
    final mark = b['read'] == true ? '[✓]' : '[ ]';
    out(
      '${i + 1}. $mark «${b['title']}» — ${b['author']}, ${b['year']}, '
      '${b['pages']} стр., ${b['genre']}',
    );
  }
}

List<Book> searchByField(List<Book> books, String field, String query) {
  final q = query.toLowerCase();
  return books.where((b) {
    final value = b[field];
    if (value == null) return false;
    return value.toString().toLowerCase().contains(q);
  }).toList();
}

List<Book> filterByRead(List<Book> books, bool isRead) {
  return books.where((b) => b['read'] == isRead).toList();
}

List<Book> sortBy(List<Book> books, String field, {bool descending = false}) {
  final copy = [...books]; // Копия — не изменяем исходный список
  copy.sort((a, b) {
    final av = a[field];
    final bv = b[field];
    int cmp;
    if (av is num && bv is num) {
      cmp = av.compareTo(bv);
    } else {
      cmp = av.toString().compareTo(bv.toString());
    }
    return descending ? -cmp : cmp;
  });
  return copy;
}

// Задание 4. Статистика
void printStatistics(List<Book> books) {
  if (books.isEmpty) {
    out('Каталог пуст.');
    return;
  }

  final total = books.length;
  final readCount = books.where((b) => b['read'] == true).length;

  final totalPages = books.fold<int>(0, (sum, b) => sum + (b['pages'] as int));
  final avgPages = totalPages / total;

  final oldest = books.reduce(
    (a, b) => (a['year'] as int) < (b['year'] as int) ? a : b,
  );
  final newest = books.reduce(
    (a, b) => (a['year'] as int) > (b['year'] as int) ? a : b,
  );

  final thickest = books.reduce(
    (a, b) => (a['pages'] as int) > (b['pages'] as int) ? a : b,
  );

  final genres = books.map((b) => b['genre']).toSet();

  final byGenre = <String, int>{};
  for (final g in genres) {
    byGenre[g as String] = books.where((b) => b['genre'] == g).length;
  }

  final percent = (readCount / total * 100).toStringAsFixed(1);

  out(' Статистика ');
  out('Всего книг: $total (прочитано: $readCount)');
  out('Суммарно страниц: $totalPages');
  out('В среднем на книгу: ${avgPages.toStringAsFixed(1)} стр.');
  out('Самая старая: «${oldest['title']}» (${oldest['year']})');
  out('Самая новая: «${newest['title']}» (${newest['year']})');
  out('Самая объёмная: «${thickest['title']}» (${thickest['pages']} стр.)');
  out('Жанры: ${genres.join(', ')}');
  out('По жанрам: $byGenre');
  out('Прочитано: $percent%');
}

// Задание 5. Надёжный ввод числа и добавление/удаление
int askInt(String prompt, {int min = 0, int? max}) {
  int? value;
  do {
    outWrite('$prompt: ');
    value = int.tryParse(stdin.readLineSync(encoding: utf8) ?? '');
    if (value == null || value < min || (max != null && value > max)) {
      out(
        'Некорректное значение. Ожидается целое число'
        '${max == null ? ' не меньше $min' : ' от $min до $max'}.',
      );
      value = null;
    }
  } while (value == null);
  return value;
}

void addBook(List<Book> books) {
  outWrite('Название: ');
  final title = stdin.readLineSync(encoding: utf8) ?? '';
  if (title.trim().isEmpty) {
    out('Ошибка: название не может быть пустым.');
    return;
  }

  outWrite('Автор: ');
  final author = stdin.readLineSync(encoding: utf8) ?? 'неизвестен';

  final year = askInt('Год издания', min: 1000, max: 2100);
  final pages = askInt('Количество страниц', min: 1);

  outWrite('Жанр: ');
  final genre = stdin.readLineSync(encoding: utf8) ?? 'неизвестен';

  outWrite('Прочитана (да/нет): ');
  final readAnswer = (stdin.readLineSync(encoding: utf8) ?? '').toLowerCase();
  final read = readAnswer == 'да';

  books.add({
    'title': title,
    'author': author,
    'year': year,
    'pages': pages,
    'genre': genre,
    'read': read,
  });
  out('Книга добавлена.');
}

void removeBook(List<Book> books) {
  if (books.isEmpty) {
    out('Каталог пуст.');
    return;
  }
  printAll(books);
  final index = askInt('Номер книги для удаления', min: 1, max: books.length);
  outWrite('Подтвердить удаление «${books[index - 1]['title']}» (да/нет): ');
  final confirm = (stdin.readLineSync(encoding: utf8) ?? '').toLowerCase();
  if (confirm == 'да') {
    out('Удалена: «${books[index - 1]['title']}»');
    books.removeAt(index - 1);
  } else {
    out('Удаление отменено.');
  }
}

// Задание 6. Функции высшего порядка
typedef BookPredicate = bool Function(Book book);

List<Book> filter(List<Book> books, BookPredicate test) {
  return books.where(test).toList();
}

Function makeCounter() {
  int count = 0;
  return () {
    count++;
    return count;
  };
}

// Главное меню для 2 задания
void printMenu() {
  out('');
  out('=== Каталог BookShelf ===');
  out('1 — Показать весь каталог');
  out('2 — Поиск по автору');
  out('3 — Поиск по названию');
  out('4 — Фильтр по жанру');
  out('5 — Фильтр по признаку «прочитана»');
  out('6 — Сортировка');
  out('7 — Статистика');
  out('8 — Добавить книгу');
  out('9 — Удалить книгу по номеру');
  out('0 — Выход');
}

void main() {
  final commandCounter = makeCounter();
  var running = true;

  while (running) {
    printMenu();
    outWrite('> ');
    final command = (stdin.readLineSync(encoding: utf8) ?? '').trim();
    commandCounter();
    out('');

    switch (command) {
      case '1':
        printAll(library);
        break;

      case '2':
        outWrite('Автор (подстрока): ');
        final q = stdin.readLineSync(encoding: utf8) ?? '';
        printAll(searchByField(library, 'author', q));
        break;

      case '3':
        outWrite('Название (подстрока): ');
        final q = stdin.readLineSync(encoding: utf8) ?? '';
        printAll(searchByField(library, 'title', q));
        break;

      case '4':
        outWrite('Жанр: ');
        final g = stdin.readLineSync(encoding: utf8) ?? '';
        printAll(searchByField(library, 'genre', g));
        break;

      case '5':
        outWrite('Показать прочитанные (да/нет): ');
        final ans = (stdin.readLineSync(encoding: utf8) ?? '').toLowerCase();
        printAll(filterByRead(library, ans == 'да'));
        break;

      case '6':
        out('По какому полю сортировать? title/author/year/pages');
        outWrite('> ');
        final field = (stdin.readLineSync(encoding: utf8) ?? '').trim();
        outWrite('По убыванию (да/нет): ');
        final dir = (stdin.readLineSync(encoding: utf8) ?? '').toLowerCase();
        printAll(sortBy(library, field, descending: dir == 'да'));
        break;

      case '7':
        printStatistics(library);
        break;

      case '8':
        addBook(library);
        break;

      case '9':
        removeBook(library);
        break;

      case '0':
        running = false;
        out('Работа завершена. Команд выполнено: ${commandCounter()}');
        break;

      default:
        out('Неизвестная команда. Повторите ввод.');
    }
  }
}

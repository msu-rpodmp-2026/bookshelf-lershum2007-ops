import 'dart:io';
import 'dart:convert';

void out(String s) {
  stdout.add(utf8.encode('$s\n'));
}

// Пишем строку без перевода строки (для приглашений).
void outWrite(String s) {
  stdout.add(utf8.encode(s));
}

void main() {
  // 2.2 Привествие и сведения среды
  out('проект: BookShelf');
  out('Версия Dart: ${Platform.version}');
  out('ОС: ${Platform.operatingSystem}');
  out('');

  // 2.3 Ввод данных о книге
  outWrite('название: ');
  final String title = stdin.readLineSync(encoding: utf8) ?? ' ';
  outWrite('автор: ');
  final String author = stdin.readLineSync(encoding: utf8) ?? 'неизвестен';
  outWrite('год издания: ');
  final int year = int.tryParse(stdin.readLineSync(encoding: utf8) ?? '') ?? 0;
  outWrite('количество страниц: ');
  final int pages = int.tryParse(stdin.readLineSync(encoding: utf8) ?? '') ?? 0;
  outWrite('Оценка (0-5): ');
  final double rating =
      double.tryParse(stdin.readLineSync(encoding: utf8) ?? '') ?? 0.0;

  outWrite('Прочитана (да/нет): ');
  final String readInput = stdin.readLineSync(encoding: utf8) ?? 'нет';
  final bool isRead = readInput.toLowerCase() == 'да';
  // Карточка книги
  out('');
  out('=' * 44);
  out(' «$title»');
  out(' Автор: $author');
  out(' Год: $year');
  out(' Страниц: $pages');
  out(' Оценка: $rating');
  out(' Прочитана: ${isRead ? "да" : "нет"}');
  out('=' * 44);

  //задание 2.3 вычисляемые характеристики
  // Категория по объёму (тернарный оператор)
  final String category = pages < 150
      ? 'брошюра'
      : pages < 400
      ? 'книга'
      : 'том';

  // Время чтения при 50 стр/час
  final double hours = pages / 50;

  // Возраст издания
  final int currentYear = DateTime.now().year;
  final int age = currentYear - year;

  // Инициалы автора
  final List<String> authorParts = author.split(' ');
  final String initials = authorParts
      .where((String p) => p.isNotEmpty)
      .map((String p) => '${p[0].toUpperCase()}.')
      .join(' ');

  out('');
  out('Категория: $category');
  out('Время чтения: ${hours.toStringAsFixed(1)} ч');
  out('Возраст издания: $age лет');
  out('Инициалы автора: $initials');

  //задание 2.4 коллекции
  //2.4.1 List<String>
  final List<String> shelf = <String>[
    'Война и мир',
    'Преступление и наказание',
    'Мастер и Маргарита',
    '1984',
    'Гарри Поттер',
  ];
  out('');
  out('Полка: $shelf');
  out('Длина: ${shelf.length}');
  out('Первый: ${shelf.first}');
  out('Последний: ${shelf.last}');

  shelf.insert(0, 'Анна Каренина'); // в начало
  shelf.add('Три товарища'); // в конец
  shelf.remove('1984'); // удалить по значению
  out('После изменений: $shelf');

  //2.4.2 Set<String>
  outWrite('Жанры через запятую: ');
  final String genreInput = stdin.readLineSync(encoding: utf8) ?? '';
  final Set<String> genres = genreInput
      .split(',')
      .map((String g) => g.trim())
      .where((String g) => g.isNotEmpty)
      .toSet();

  out('Жанры: $genres');
  // Демонстрация отбрасывания дубликатов:
  genres.add('фантастика');
  genres.add('фантастика'); // второй раз не добавится
  out('После повторного добавления: $genres');

  //2.4.3 Map<String, int>
  final Map<String, int> pagesByBook = <String, int>{
    'Война и мир': 1225,
    'Преступление и наказание': 671,
    'Мастер и Маргарита': 480,
    '1984': 320,
    'Гарри Поттер': 400,
  };

  pagesByBook.forEach((String t, int p) {
    out('$t — $p стр.');
  });

  // Книга с максимумом страниц
  String maxBook = '';
  int maxPages = 0;
  pagesByBook.forEach((String t, int p) {
    if (p > maxPages) {
      maxPages = p;
      maxBook = t;
    }
  });
  out('Самая толстая: $maxBook ($maxPages стр.)');

  // Сумма и среднее
  int total = 0;
  pagesByBook.forEach((String _, int p) => total += p);
  final double average = total / pagesByBook.length;
  out('Всего страниц: $total');
  out('В среднем: ${average.toStringAsFixed(1)}');

  //2.4.4 Список с раскрытием, if и for
  final List<String> all = <String>[
    'Базовый элемент',
    ...shelf, // раскрытие
    if (genres.isNotEmpty) 'Есть жанры', // условный элемент
    for (int i = 0; i < 3; i++) 'Книга #$i', // цикл
  ];
  out('all: $all');

  // Задание 5. Операторы
  out('');
  out(' Задание 5. Операторы ');

  // 1) Различие /, ~/ и %
  out('');
  out('1) Операторы деления:');
  out('   7 / 2  = ${7 / 2}    // вещественное деление (double)');
  out('   7 ~/ 2 = ${7 ~/ 2}    // целочисленное деление (int)');
  out('   7 % 2  = ${7 % 2}    // остаток от деления');

  // 2) Ленивое вычисление && и ||
  out('');
  out('2) Ленивое вычисление && и ||:');
  bool sideEffect() {
    out('   -> sideEffect() ВЫЗВАН');
    return true;
  }

  // Возвращаем значения через функции — компилятор не может их предсказать
  bool getFalse() => false;
  bool getTrue() => true;

  out('   getFalse() && sideEffect():');
  out('     результат = ${getFalse() && sideEffect()}');
  out('     (sideEffect не вызвался — правая часть пропущена)');
  out('');
  out('   getTrue() || sideEffect():');
  out('     результат = ${getTrue() || sideEffect()}');
  out('     (sideEffect не вызвался — правая часть пропущена)');

  // 3) Операторы ?., ??, ??=
  out('');
  out('3) Операторы null-safety:');

  String? getNull() => null;
  String? maybeNull = getNull();

  out('   Переменная maybeNull = null');
  final int? maybeLength = maybeNull?.length;
  out('   maybeNull?.length  = $maybeLength      // ?. вернул null, не упал');

  out(
    '   maybeNull ?? "по умолчанию" = ${maybeNull ?? "по умолчанию"}   // ?? подставил значение',
  );

  maybeNull ??= 'присвоено';
  out(
    '   maybeNull ??= "присвоено" -> $maybeNull  // ??= присвоил, т.к. было null',
  );

  // 4) final и const
  out('');
  out('4) Различие final и const:');
  final List<int> listFinal = <int>[1, 2, 3];
  listFinal.add(4);
  out('   final listFinal = [1, 2, 3]; listFinal.add(4);');
  out('   -> $listFinal   // final: содержимое менять МОЖНО');
  out('   // listFinal = [9]; -> ОШИБКА (нельзя переприсвоить)');

  const List<int> listConst = <int>[1, 2, 3];
  out('   const listConst = [1, 2, 3];');
  out('   -> $listConst   // const: содержимое менять НЕЛЬЗЯ');
  out('   // listConst.add(4); -> ОШИБКА (const неизменяем)');

  // 5) Каскадный оператор
  out('');
  out('5) Каскадный оператор .. на StringBuffer:');
  final StringBuffer buffer = StringBuffer()
    ..write('Book')
    ..write('Shelf')
    ..write('!');
  out('   StringBuffer()..write("Book")..write("Shelf")..write("!")');
  out('   результат = ${buffer.toString()}');
}

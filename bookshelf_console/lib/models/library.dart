import 'library_item.dart';
import 'book.dart';

class Library<T extends LibraryItem> {
  final List<T> _items = [];

  // Защита от внешнего изменения (нельзя добавить в обход add)
  List<T> get items => List.unmodifiable(_items);

  int get count => _items.length;

  // Добавление с защитой от дубликатов
  void add(T item) {
    if (!_items.contains(item)) {
      _items.add(item);
    }
  }

  bool remove(T item) => _items.remove(item);

  T? findByTitle(String title) {
    try {
      return _items.firstWhere(
        (i) => i.title.toLowerCase() == title.toLowerCase(),
      );
    } on StateError {
      return null;
    }
  }

  Iterable<T> search(String query) {
    final q = query.toLowerCase();
    return _items.where((item) {
      if (item.title.toLowerCase().contains(q)) return true;
      if (item is Book) {
        if (item.author.toLowerCase().contains(q)) return true;
        if (item.genres.any((g) => g.toLowerCase().contains(q))) return true;
      }
      return false;
    });
  }

  Iterable<T> where(bool Function(T) test) => _items.where(test);

  Map<String, int> countByGenre() {
    final Map<String, int> map = {};
    for (final item in _items) {
      if (item is Book) {
        for (final genre in item.genres) {
          map[genre] = (map[genre] ?? 0) + 1;
        }
      }
    }
    return map;
  }
}

part of ws_server;

final RegExp tableNameRegexp = new RegExp(r'^\w+$');
final Database db = new Database();

class Database {
  Map<String, Table> _tables = new Map();

  void init(String dbRoot) {
    // TODO Read table data from disk
  }

  void writeToDisk() {
    // TODO Write table data to disk
  }

  bool tableExists(String name) => _tables.containsKey(name);

  operator [](String name) => _tables[name];

  Iterable<Table> get tables => _tables.values;

  Table createTable(String name) {
    Table created = _tables[name] = new Table(name);
    writeToDisk();
    return created;
  }
}

class Table {
  String _name;

  Table(this._name);

  String get name => _name;
}

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

  Table operator [](String name) => _tables[name];

  Iterable<Table> get tables => _tables.values;

  Table createTable(String name, List<HeaderCell> header) {
    Table created = _tables[name] = new Table(name, header);
    writeToDisk();
    return created;
  }
}

class Table extends Iterable<Row> {
  String _name;
  List<HeaderCell> _header;
  List<Row> _rows;

  Table(this._name, this._header) {
    this._rows = [];
  }

  String get name => _name;

  List<HeaderCell> get header => _header;

  Row operator [](int row) => _rows[row];

  Row addRow() {
    Row row = new Row(this);
    _rows.add(row);
    return row;
  }

  Row removeRow(int row) => _rows.removeAt(row);

  @override
  Iterator<Row> get iterator => _rows.iterator;
}

class HeaderCell<T> {
  String _name;
  DataType<T> _type;
  Domain _domain;

  HeaderCell(this._name, this._type, this._domain);

  String get name => _name;

  DataType<T> get type => _type;

  Domain get domain => _domain;
}

class Row extends Iterable<Wrapper> {
  Table _parent;
  List<Wrapper> _data;

  Row(this._parent) {
    this._data = []..length = _parent.header.length;
  }

  int get rowIndex => _parent._rows.indexOf(this);

  List<HeaderCell> get header => _parent.header;

  Wrapper operator [](int column) => _data[column];

  @override
  Iterator<Wrapper> get iterator => _data.iterator;
}
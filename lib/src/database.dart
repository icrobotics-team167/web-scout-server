part of ws_server;

final RegExp tableNameRegexp = new RegExp(r'^\w+$');
final Database db = new Database();

class Database {
  Map<String, Table> _tables = new Map();
  Directory _dbRoot = null;

  void init(String dbRoot) {
    _dbRoot = new Directory(dbRoot);
    if (!_dbRoot.existsSync()) {
      _dbRoot.createSync();
    } else {
      List<File> files = _dbRoot
          .listSync()
          .where((fse) => fse is File)
          .where((f) => f.path.endsWith('.json'));
      Map<String, Map<String, dynamic>> serTables = new Map.fromIterable(files,
          key: (f) => f.path, value: (f) => JSON.decode(f.readAsStringSync()));
      serTables.forEach((name, data) {
        int sepIndex = name.lastIndexOf(Platform.pathSeparator) + 1;
        int extIndex = name.lastIndexOf(".json");
        String tableName = name.substring(sepIndex, extIndex);
        List<HeaderCell> header = new List();
        data['header'].forEach((h) => header.add(new HeaderCell(h['name'],
            typeByName(h['type']), new DeserializedDomain.from(h['domain']))));
        Table table = new Table(tableName, header);
        data['rows'].forEach((rowData) {
          Row row = table.addRow();
          for (int i = 0; i < row.length; i++) {
            row[i] = new Wrapper(
                header[i]._type, header[i]._type.deserialize(rowData[i]));
          }
        });
        _tables[tableName] = table;
      });
    }
  }

  void writeToDisk() {
    _tables.forEach((name, table) {
      String data = JSON.encode(table.serialized);
      File tableFile = new File("${_dbRoot.path}/$name.json");
      tableFile.writeAsStringSync(data);
    });
  }

  bool tableExists(String name) => _tables.containsKey(name);

  Table operator [](String name) => _tables[name];

  Iterable<Table> get tables => _tables.values;

  Table createTable(String name, List<HeaderCell> header) {
    Table created = _tables[name] = new Table(name, header);
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

  Row removeRowAt(int row) => _rows.removeAt(row);

  bool removeRow(Row row) => _rows.remove(row);

  @override
  Iterator<Row> get iterator => _rows.iterator;

  Map<String, dynamic> get serialized {
    Map<String, dynamic> ser = new Map();
    ser['header'] = _header.map((c) => c.serialized).toList();
    ser['rows'] = _rows.map((r) => r.serialized).toList();
    return ser;
  }
}

class HeaderCell<T> {
  String _name;
  DataType<T> _type;
  Domain _domain;

  HeaderCell(this._name, this._type, this._domain);

  String get name => _name;

  DataType<T> get type => _type;

  Domain get domain => _domain;

  Map<String, dynamic> get serialized {
    Map<String, dynamic> ser = new Map();
    ser['name'] = _name;
    ser['type'] = _type.name;
    ser['domain'] = _domain.toString();
    return ser;
  }
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

  void operator []=(int column, Wrapper data) {
    _data[column] = data;
  }

  bool remove() => _parent.removeRow(this);

  @override
  Iterator<Wrapper> get iterator => _data.iterator;

  List<dynamic> get serialized => _data.map((d) => d.toString()).toList();
}

part of ws_server;

final RegExp tableNameRegexp = new RegExp(r'^\w+$');
final Database db = new Database();

class Database {
    Map<String, Table> _tables = new Map();
    
    void init(String dbRoot) {
        // TODO Read table data from disk
    }
    
    void onShutdown() {
        // TODO Write table data to disk
    }
    
    bool tableExists(String name) => _tables.containsKey(name);
    
    operator [](String name) => _tables[name];
    
    List<Table> get tables => _tables.values;
    
    Table createTable(String name) => _tables[name] = new Table(name);
}

class Table {
    String name;
    
    Table(this.name);
}
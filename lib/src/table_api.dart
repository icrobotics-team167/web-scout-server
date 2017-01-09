part of ws_server;

class TableApi {
  @ApiMethod(path: 'tables')
  List<TableMetaResponse> methodTables({String query: ''}) =>
      new List.from(// TODO Implement queries
          db.tables.map((table) => new TableMetaResponse.describing(table)));

  @ApiMethod(path: 'tables/create', method: 'POST')
  TableMetaResponse methodTablesCreate(TableCreationRequest req) {
    if (!tableNameRegexp.hasMatch(req.name))
      throw new BadRequestError('Invalid table name "${req.name}".');
    if (db.tableExists(req.name))
      throw new ConflictError('Table "${req.name}" already exists.');
    Table newTable = db.createTable(
        req.name, req.header.map((h) => h.toHeaderCell()).toList());
    db.writeToDisk();
    return new TableMetaResponse.describing(newTable);
  }

  @ApiMethod(path: 'table/{name}')
  TableMetaResponse methodTable(String name) {
    if (!db.tableExists(name))
      throw new NotFoundError('No such table "$name".');
    return new TableMetaResponse.describing(db[name]);
  }

  @ApiMethod(path: 'table/{name}/rows')
  List<List<String>> methodTableRows(String name, {String query: ''}) {
    // TODO Implement queries
    if (!db.tableExists(name))
      throw new NotFoundError('No such table "$name".');
    return db[name].map((r) => r.map((w) => w.toString()).toList()).toList();
  }

  @ApiMethod(path: 'table/{name}/rows/create', method: 'POST')
  List<String> methodTableRowsCreate(String name, RowCreationRequest req) {
    if (!db.tableExists(name))
      throw new NotFoundError('No such table "$name".');
    Row newRow = db[name].addRow();
    try {
      for (int i = 0; i < req.data.length; i++) {
        newRow[i] = new Wrapper(newRow.header[i].type,
            newRow.header[i].type.deserialize(req.data[i]));
      }
    } catch (e) {
      newRow.remove();
    }
    db.writeToDisk();
    return newRow.map((w) => w.toString()).toList();
  }

  @ApiMethod(path: 'table/{name}/row/{row}')
  List<String> methodTableRow(String name, int row) {
    if (!db.tableExists(name))
      throw new NotFoundError('No such table "$name".');
    if (db[name].length <= row)
      throw new NotFoundError('Table "$name" does not have $row row(s).');
    return db[name][row].map((w) => w.toString()).toList();
  }

  @ApiMethod(path: 'table/{name}/row/{row}/mutate', method: 'POST')
  List<String> methodTableRowMutate(
      String name, String row, RowMutationRequest req) {
    // TODO Implement
    throw new NoImplError();
  }

  @ApiMethod(path: 'table/{name}/row/{row}/delete', method: 'POST')
  List<String> methodTableRowDelete(
      String name, int row, RowRemovalRequest req) {
    if (!db.tableExists(name))
      throw new NotFoundError('No such table "$name".');
    if (db[name].length <= row)
      throw new NotFoundError('Table "$name" does not have $row row(s).');
    db[name].removeRowAt(row);
    db.writeToDisk();
    return db[name].map((r) => r.map((w) => w.toString()).toList()).toList();
  }
}

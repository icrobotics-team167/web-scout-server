part of ws_server;

class TableApi {
  @ApiMethod(path: 'tables')
  List<TableMetaResponse> methodTables({String query: ''}) =>
      new List.from(// TODO Implement queries
          db.tables.map((table) => new TableMetaResponse.describing(table)));

  @ApiMethod(path: 'tables', method: 'PUT')
  TableMetaResponse methodTablesPut(TableCreationRequest req) {
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

  @ApiMethod(path: 'table/{name}', method: 'DELETE')
  List<TableMetaResponse> methodTableDelete(String name) {
    if (!db.tableExists(name))
      throw new NotFoundError('No such table "$name".');
    db.dropTable(name);
    db.writeToDisk();
    return new List.from(
        db.tables.map((table) => new TableMetaResponse.describing(table)));
  }

  @ApiMethod(path: 'table/{name}/rows')
  List<List<String>> methodTableRows(
      String name, {String query: "", int limit = -1}) {
    // TODO Implement queries
    if (!db.tableExists(name))
      throw new NotFoundError('No such table "$name".');
    List<dynamic> results =
      db[name].map((r) => r.map((w) => w.toString()).toList()).toList();
    return limit < 0 ? results : results.sublist(0, min(results.length, limit));
  }

  @ApiMethod(path: 'table/{name}/rows', method: 'PUT')
  List<String> methodTableRowsPut(String name, RowCreationRequest req) {
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
      throw new BadRequestError(e.toString());
    }
    db.writeToDisk();
    return newRow.map((w) => w.toString()).toList();
  }

  @ApiMethod(path: 'table/{name}/row/{row}')
  List<String> methodTableRow(String name, int row) {
    if (!db.tableExists(name))
      throw new NotFoundError('No such table "$name".');
    if (db[name].length <= row)
      throw new NotFoundError('Table "$name" does not have ${row + 1} row(s).');
    return db[name][row].map((w) => w.toString()).toList();
  }

  @ApiMethod(path: 'table/{name}/row/{row}', method: 'POST')
  List<String> methodTableRowPost(
      String name, int row, RowMutationRequest req) {
    if (!db.tableExists(name))
      throw new NotFoundError('No such table "$name".');
    if (db[name].length <= row)
      throw new NotFoundError('Table "$name" does not have ${row + 1} row(s).');
    Row theRow = db[name][row];
    List<Wrapper> rowSim = new List(theRow.length);
    try {
      for (int i = 0; i < theRow.length; i++) {
        rowSim[i] = new Wrapper(theRow.header[i].type,
            theRow.header[i].type.deserialize(req.data[i]));
      }
    } catch (e) {
      throw new BadRequestError(e.toString());
    }
    for (int i = 0; i < theRow.length; i++) theRow[i] = rowSim[i];
    db.writeToDisk();
    return theRow.map((w) => w.toString()).toList();
  }

  @ApiMethod(path: 'table/{name}/row/{row}', method: 'DELETE')
  List<String> methodTableRowDelete(String name, int row) {
    if (!db.tableExists(name))
      throw new NotFoundError('No such table "$name".');
    if (db[name].length <= row)
      throw new NotFoundError('Table "$name" does not have ${row + 1} row(s).');
    db[name].removeRowAt(row);
    db.writeToDisk();
    return db[name].map((r) => r.map((w) => w.toString()).toList()).toList();
  }
}

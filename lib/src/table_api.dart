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
    return new TableMetaResponse.describing(db.createTable(
        req.name, req.header.map((h) => h.toHeaderCell()).toList()));
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
    // TODO Implement
    throw new NoImplError();
  }

  @ApiMethod(path: 'table/{name}/row/{row}')
  List<String> methodTableRow(String name, String row) {
    // TODO Implement
    throw new NoImplError();
  }

  @ApiMethod(path: 'table/{name}/row/{row}/mutate', method: 'POST')
  List<String> methodTableRowMutate(
      String name, String row, RowMutationRequest req) {
    // TODO Implement
    throw new NoImplError();
  }

  @ApiMethod(path: 'table/{name}/row/{row}/delete', method: 'POST')
  List<String> methodTableRowDelete(String name, String row) {
    // TODO Implement
    throw new NoImplError();
  }
}

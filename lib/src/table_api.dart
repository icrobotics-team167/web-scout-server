part of ws_server;

class TableApi {
  @ApiMethod(path: 'tables')
  List<TableMetaResponse> methodTables() => new List.from(
      db.tables.map((table) => new TableMetaResponse.describing(table)));

  @ApiMethod(path: 'tables/create', method: 'POST')
  TableMetaResponse methodTablesCreate(TableCreationRequest req) {
    if (!tableNameRegexp.hasMatch(req.name))
      throw new BadRequestError('Invalid table name "${req.name}".');
    if (db.tableExists(req.name))
      throw new ConflictError('Table "${req.name}" already exists.');
    return new TableMetaResponse.describing(db.createTable(req.name));
  }

  @ApiMethod(path: 'table/{name}')
  Table methodTable(String name) {
    if (!db.tableExists(name))
      throw new NotFoundError('No such table "$name".');
    return db[name];
  }

  @ApiMethod(path: 'table/{name}/meta')
  TableMetaResponse methodTableMeta(String name) {
    if (!db.tableExists(name))
      throw new NotFoundError('No such table "$name".');
    return new TableMetaResponse.describing(db[name]);
  }
}

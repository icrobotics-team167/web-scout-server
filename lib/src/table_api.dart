part of ws_server;

class TableApi {
  @ApiMethod(path: 'tables')
  List<TableMetaResponse> methodTables({String query: ''}) => new List.from(
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

  @ApiMethod(path: 'tables/interpolate', method: 'POST')
  TableInterpResponse methodTablesInterpolate(TableInterpRequest req) {
    if (req.tables.isEmpty)
      throw new BadRequestError("No table specified!");
    else if (req.column.isEmpty)
      throw new BadRequestError("No interpolation column specified!");
    req.tables.forEach((name) {
      if (!db.tableExists(name))
        throw new NotFoundError('No such table "$name".');
      if (!db[name].header.any((h) => h.name == req.column)) {
        throw new NotFoundError(
            'Table "$name" does not have column "${req.column}".');
      }
    });
    List<Table> tables = req.tables.map((name) => db[name]).toList();
    List<HeaderCell> interpHeader = new List();
    Map<String, Table> fieldMap = new Map();
    tables.forEach((tbl) => tbl.header.forEach((hc) {
          fieldMap[hc.name] = tbl;
          if (!interpHeader.any((hc2) => hc2.name == hc.name))
            interpHeader.add(hc);
        }));
    Table interp =
        new Table('${req.column} -> ${req.tables.join(', ')}', interpHeader);
    tables.first.forEach((r) {
      dynamic value = r.forName(req.column).value;
      if (tables.every(
          (tbl) => tbl.any((r) => r.forName(req.column).value == value))) {
        Row row = interp.addRow();
        fieldMap.forEach((col, tbl) {
          Row src = tbl.firstWhere((r) => r.forName(req.column).value == value);
          row.setForName(col, src.forName(col));
        });
      }
    });
    return new TableInterpResponse(interp, req.query, req.limit);
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
  List<List<String>> methodTableRows(String name,
      {String query: "", int limit = -1}) {
    if (!db.tableExists(name))
      throw new NotFoundError('No such table "$name".');
    List<dynamic> results;
    if (query.isEmpty) {
      results = db[name].toList();
    } else {
      Query qTest = new Query.parse(query);
      results = db[name].where(qTest.matches).toList();
    }
    results = results.map((r) => r.map((w) => w.toString()).toList()).toList();
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

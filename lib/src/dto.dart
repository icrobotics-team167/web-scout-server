part of ws_server;

/**
 * Generic stuff
 */

class UptimeResponse {
  int uptime;

  UptimeResponse(this.uptime);
}

/**
 * Table data types
 */

class TableMetaResponse {
  String name;
  List<HeaderCellResponse> header;

  TableMetaResponse(this.name, this.header);

  TableMetaResponse.describing(Table table)
      : this(
            table.name,
            table.header
                .map((h) => new HeaderCellResponse.describing(h))
                .toList());
}

class TableCreationRequest {
  @ApiProperty(required: true)
  String name;
  @ApiProperty(required: true)
  List<HeaderCellRequest> header;
}

/**
 * Row data types
 */

class RowCreationRequest {
  @ApiProperty(required: true)
  List<String> data;
}

class RowMutationRequest {
  @ApiProperty(required: true)
  int row;
  @ApiProperty(required: true)
  List<String> data;
}

class RowRemovalRequest {
  @ApiProperty(required: true)
  int row;
}

/**
 * Cell data types
 */

class HeaderCellRequest {
  @ApiProperty(required: true)
  String name;
  @ApiProperty(required: true)
  String dataType;
  String domain;

  HeaderCell toHeaderCell() => new HeaderCell(name, typeByName(dataType),
      domain == null ? domainAcceptAll : new DeserializedDomain.from(domain));
}

class HeaderCellResponse {
  String name;
  String dataType;
  String domain;

  HeaderCellResponse(this.name, this.dataType, this.domain);

  HeaderCellResponse.describing(HeaderCell cell)
      : this(cell.name, cell.type.name, cell.domain.toString());
}

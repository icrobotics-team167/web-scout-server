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
    
    TableMetaResponse(this.name);
    
    TableMetaResponse.describing(Table table) : this(table.name);
}

class TableCreationRequest {
    @ApiProperty(required: true)
    String name;
}
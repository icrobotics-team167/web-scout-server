part of ws_server;

class ConflictError extends RpcError {
  ConflictError([String message = 'Key Conflict.'])
      : super(409, 'Key Conflict', message);
}

class NoImplError extends RpcError {
  NoImplError([String message = 'No Implementation.'])
      : super(501, 'No Implementation', message);
}

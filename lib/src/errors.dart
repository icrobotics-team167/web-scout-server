part of ws_server;

class ConflictError extends RpcError {
  ConflictError([String message = 'Key Conflict.'])
      : super(409, 'Key Conflict', message);
}

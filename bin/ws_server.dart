import 'dart:io';

import 'package:logging/logging.dart';
import 'package:rpc/rpc.dart';

import 'package:ws_server/ws_server.dart';

int _startTime;

final Logger _log = new Logger('wss');
final ApiServer _api = new ApiServer();

void main(List<String> args) async {
    _startTime = new DateTime.now().millisecondsSinceEpoch;
    
    Logger.root.level = Level.FINEST;
    Logger.root.onRecord.listen((rec) {
        print('${rec.time} [${rec.level.name}] ${rec.loggerName} -- ${rec.message}');
        if (rec.error != null)
            print(rec.error);
        if (rec.stackTrace != null)
            print(rec.stackTrace);
    });
    _log.info('Logging initialized.');
    
    _log.info('Initializing database...');
    try {
        db.init("~/.ws_server");
    } catch (e, trace) {
        _log.severe('Database init failed!', e, trace);
        exit(1);
    }
    _log.info('Database initialized.');
    
    _log.info('Registring shutdown hook...');
    try {
        ProcessSignal.SIGTERM.watch().listen(() {
            _log.info('Shutting down server...');
            db.onShutdown();
            _log.info('Shutdown complete.');
        });
    } catch (e, trace) {
        _log.severe('Shutdown hook could not be registered!', e, trace);
        exit(1);
    }
    _log.info('Shutdown hook registered.');
    
    _log.info('Initializing HTTP server...');
    try {
        _api.addApi(new WebScoutServer());
        HttpServer server = await HttpServer.bind(InternetAddress.ANY_IP_V4, 8080);
        server.listen(_api.httpRequestHandler);
    } catch (e, trace) {
        _log.severe('Server init failed!', e, trace);
        exit(1);
    }
    _log.info('Server initialized.');
}

@ApiClass(name: 'ws-server', version: 'v1')
class WebScoutServer {
    @ApiResource(name: 'table')
    TableApi tableApi = new TableApi();
    
    @ApiMethod(path: 'uptime')
    UptimeResponse methodUptime() => new UptimeResponse(new DateTime.now().millisecondsSinceEpoch - _startTime);
}
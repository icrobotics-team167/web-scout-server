part of ws_server;

final Domain domainAcceptAll = new AcceptAllDomain();

abstract class Domain {
  List<Pattern> get list;

  bool get isBlacklist;

  bool allowed(String input) =>
      isBlacklist != list.any((p) => p.matchAsPrefix(input) != null);

  @override
  String toString() => '${isBlacklist ? '!' : '-'}${list.join(r'\|')}';
}

class AcceptAllDomain extends Domain {
  @override
  List<Pattern> get list => [];

  @override
  bool get isBlacklist => true;
}

class DeserializedDomain extends Domain {
  List<Pattern> list;
  bool isBlacklist;

  DeserializedDomain() : this.of([], false);

  DeserializedDomain.of(this.list, this.isBlacklist);

  DeserializedDomain.from(String domain) : this.of(
      domain.substring(1).split(r'\|').map((p) => new RegExp(p)),
      domain.startsWith('!'));
}

part of ws_server;

final Domain domainAcceptAll = new AcceptAllDomain();
final RegExp spaceRegexp = new RegExp(r'\s+');

abstract class Domain {
  List<String> get list;

  bool get isBlacklist;

  bool allowed(String input) =>
      isBlacklist != list.contains(input.trim().toLowerCase());

  @override
  String toString() => '${isBlacklist ? '!' : '-'}${list.join(' ')}';
}

class AcceptAllDomain extends Domain {
  @override
  List<String> get list => [];

  @override
  bool get isBlacklist => true;
}

class DeserializedDomain extends Domain {
  List<String> list;
  bool isBlacklist;

  DeserializedDomain() : this.of([], false);

  DeserializedDomain.of(this.list, this.isBlacklist);

  DeserializedDomain.from(String domain)
      : this.of(domain.substring(1).split(spaceRegexp), domain.startsWith('!'));
}

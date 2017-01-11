part of ws_server;

RegExp _PRED_REGEXP = new RegExp(r'(\w+)\s*([<>=~%]+)\s*(.+)');

class Query {
  Set<QueryPredicate> _predicates;

  Query(this._predicates);

  factory Query.parse(String query) =>
      new Query(query.split(';').map((predSer) {
        Match match = _PRED_REGEXP.matchAsPrefix(predSer);
        return _qTypes[match.group(2)](match.group(1), match.group(3));
      }));

  bool matches(Row row) =>
      _predicates.every((pred) => pred.matches(row.forName(pred._name)));
}

abstract class QueryPredicate<T> {
  String _name;

  QueryPredicate(this._name);

  bool matches(Wrapper<T> value);
}

Map<String, Function> _qTypes = {
  '=': (name, test) => new EqualityPredicate(name, test),
  '~=': (name, test) => new RegExpPredicate(name, test),
  '<': (name, test) => new ComparisonPredicate(name, 1, num.parse(test)),
  '>': (name, test) => new ComparisonPredicate(name, 0, num.parse(test)),
  '<=': (name, test) => new ComparisonPredicate(name, 3, num.parse(test)),
  '>=': (name, test) => new ComparisonPredicate(name, 2, num.parse(test)),
  '%': (name, test) => new DivisibilityPredicate(name, int.parse(test))
};

class EqualityPredicate<T> extends QueryPredicate<T> {
  String _testValue;

  EqualityPredicate(String name, this._testValue) : super(name);

  @override
  bool matches(Wrapper<T> value) => value.value.toString() == _testValue;
}

class RegExpPredicate extends QueryPredicate<String> {
  RegExp _pattern;

  RegExpPredicate(String name, String regexp) : super(name) {
    _pattern = new RegExp(regexp);
  }

  @override
  bool matches(Wrapper<String> value) =>
      _pattern.matchAsPrefix(value.value) != null;
}

class ComparisonPredicate extends QueryPredicate<num> {
  bool _isLessThan;
  bool _eqFlag;
  num _num;

  ComparisonPredicate(String name, int comparison, this._num) : super(name) {
    _isLessThan = (comparison & 1) != 0;
    _eqFlag = (comparison & 2) != 0;
  }

  @override
  bool matches(Wrapper<num> value) {
    num result = value.value - _num;
    if (_isLessThan)
      return _eqFlag ? result <= 0 : result < 0;
    else
      return _eqFlag ? result >= 0 : result > 0;
  }
}

class DivisibilityPredicate extends QueryPredicate<int> {
  int _divisor;

  DivisibilityPredicate(String name, this._divisor) : super(name);

  @override
  bool matches(Wrapper<int> value) => (value.value % _divisor) == 0;
}

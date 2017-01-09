part of ws_server;

final Map<Symbol, DataType> typeMap = {
  reflectClass(String).qualifiedName: new _StringDataType(),
  reflectClass(int).qualifiedName: new _IntegerDataType(),
  reflectClass(double).qualifiedName: new _FPDataType(),
  reflectClass(bool).qualifiedName: new _BooleanDataType()
};

DataType typeByName(String name) =>
    typeMap.values.firstWhere((e) => e.name == name);

class Wrapper<T> {
  DataType<T> _type;
  T _value;

  Wrapper(this._type, this._value);

  factory Wrapper.wrap(dynamic object) {
    Symbol typeName = reflect(object).type.qualifiedName;
    if (typeMap.containsKey(typeName))
      return new Wrapper(typeMap[typeName], object);
    throw new UnsupportedError(
        '${typeName.toString()} is not a wrappable data type!');
  }

  factory Wrapper.deserialize(String typeName, String data) {
    DataType<T> type = typeByName(typeName);
    if (type == null)
      throw new UnsupportedError(
          '$typeName is not a deserializable data type!');
    return new Wrapper(type, type.deserialize(data));
  }

  DataType<T> get type => _type;

  T get value => _value;

  @override
  String toString() {
    return _type.serialize(_value);
  }
}

abstract class DataType<T> {
  String get name;

  T deserialize(String ser);

  String serialize(T object);
}

class _StringDataType implements DataType<String> {
  @override
  String get name => 'str';

  @override
  String deserialize(String ser) {
    return ser;
  }

  @override
  String serialize(String object) {
    return object;
  }
}

class _IntegerDataType implements DataType<int> {
  @override
  String get name => 'int';

  @override
  int deserialize(String ser) {
    return int.parse(ser, radix: 10);
  }

  @override
  String serialize(int object) {
    return object.toRadixString(10);
  }
}

class _FPDataType implements DataType<double> {
  @override
  String get name => 'fpn';

  @override
  double deserialize(String ser) {
    return double.parse(ser);
  }

  @override
  String serialize(double object) {
    return object.toString();
  }
}

class _BooleanDataType implements DataType<bool> {
  @override
  String get name => 'bln';

  @override
  bool deserialize(String ser) {
    return ser.trim().toLowerCase() == 'true';
  }

  @override
  String serialize(bool object) {
    return object.toString();
  }
}

part of ws_server;

class Wrapper<T> {
  DataType<T> _type;
  T _value;

  Wrapper(this._type, this._value);

  Wrapper.wrap(dynamic object) {

  }
}

abstract class DataType<T> {
  String serialize(T object);

  T deserialize(String ser);
}
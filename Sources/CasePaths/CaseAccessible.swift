public protocol CaseAccessible {
  associatedtype Root = Self
  static func _get(_ self: Self) -> Root
  static func _set(into self: inout Self, _ root: Root)
}

extension CaseAccessible where Root == Self {
  public static func _get(_ self: Self) -> Root { self }
  public static func _set(into self: inout Self, _ root: Root) { self = root }
}

@dynamicMemberLookup
public struct _OptionallyChained<Value> {
  var value: Value

  public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Value, Subject>) -> Subject {
    _read { yield self.value[keyPath: keyPath] }
    _modify { yield &self.value[keyPath: keyPath] }
  }
}

extension _OptionallyChained: CaseAccessible where Value: CaseAccessible {
  public typealias Root = Value
  public static func _get(_ self: Self) -> Root { self.value }
  public static func _set(into self: inout Self, _ root: Root) { self.value = root }
}

extension CaseAccessible {
  public subscript<Value>(casePath: CasePath<Root, Value>) -> Value? {
    casePath.extract(from: Self._get(self))
  }

  @_disfavoredOverload
  public subscript<Value>(casePath: CasePath<Root, Value>?) -> Value {
    @available(*, unavailable, message: "only available as optional getter")
    get { fatalError() }
    set {
      guard let casePath else { return }
      Self._set(into: &self, casePath.embed(newValue))
    }
  }

  @_disfavoredOverload
  public subscript(casePath: CasePath<Root, some Any>) -> Never? {
    @available(*, unavailable, message: "only available as optional getter")
    get { fatalError() }
    @available(*, unavailable, message: "only available as non-optional setter")
    set { fatalError() }
  }

  @_disfavoredOverload
 
  public subscript<Value>(casePath: CasePath<Root, Value>?) -> _OptionallyChained<Value>? {
    // Note: using an optional case path removes ambiguity between -> Never?
    get { casePath?.extract(from: Self._get(self)).map { _OptionallyChained(value: $0) } }
    set {
      guard let newValue, let casePath else { return }
      Self._set(into: &self, casePath.embed(newValue.value))
    }
  }
}

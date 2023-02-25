public protocol CaseAccessible {
  associatedtype Root = Self
  static func _get(_ self: Self) -> Root
  static func _set(into self: inout Self, _ root: Root)
}

@dynamicMemberLookup
public struct _CaseComponent<Root>: CaseAccessible {
  var root: Root

  public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Root, Value>) -> Value {
    _read { yield self.root[keyPath: keyPath] }
    _modify { yield &self.root[keyPath: keyPath] }
  }

  public static func _get(_ self: Self) -> Root { self.root }
  public static func _set(into self: inout Self, _ root: Root) { self.root = root }
}

extension CaseAccessible where Root == Self {
  public static func _get(_ self: Self) -> Root { self }
  public static func _set(into self: inout Self, _ root: Root) { self = root }
}

extension CaseAccessible {
  public subscript<Value>(casePath: CasePath<Root, Value>) -> Value? {
    casePath.extract(from: Self._get(self))
  }

  @_disfavoredOverload
  public subscript(casePath: CasePath<Root, some Any>) -> Never? {
    @available(*, unavailable, message: "only available as optional getter")
    get { fatalError() }
    @available(*, unavailable, message: "only available as non-optional setter")
    set { fatalError() }
  }

  @_disfavoredOverload
  public subscript<Value>(casePath: CasePath<Root, Value>?) -> _CaseComponent<Value>? {
    get { casePath?.extract(from: Self._get(self)).map { _CaseComponent(root: $0) } }
    _modify {
      var component = casePath?.extract(from: Self._get(self)).map { _CaseComponent(root: $0) }
      yield &component
      guard let component, let casePath else { return }
      Self._set(into: &self, casePath.embed(component.root))
    }
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
}

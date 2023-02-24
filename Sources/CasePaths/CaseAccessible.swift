

public protocol CaseAccessible {
  associatedtype Root = Self
  var root: Root { get set }
}

@dynamicMemberLookup
public struct CaseComponent<Root>: CaseAccessible {
  public var root: Root

  public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Root, Value>) -> Value {
    _read { yield self.root[keyPath: keyPath] }
    _modify { yield &self.root[keyPath: keyPath] }
  }
}

extension CaseAccessible where Root == Self {
  public var root: Root {
    _read { yield self }
    _modify { yield &self }
  }
}

extension CaseAccessible {
  public subscript<Value>(casePath: CasePath<Root, Value>) -> Value? {
    casePath.extract(from: self.root)
  }

  @_disfavoredOverload
  public subscript(casePath: CasePath<Root, some Any>) -> Never? {
    @available(*, unavailable, message: "only available as optional getter")
    get { fatalError() }
    @available(*, unavailable, message: "only available as non-optional setter")
    set { fatalError() }
  }

  @_disfavoredOverload
  public subscript<Value>(casePath: CasePath<Root, Value>?) -> CaseComponent<Value>? {
    get { casePath?.extract(from: self.root).map { CaseComponent(root: $0) } }
    set {
      guard let newValue, let casePath else { return }
      self.root = casePath.embed(newValue.root)
    }
  }

  public subscript<Value>(casePath: CasePath<Root, Value>) -> Value {
    @available(*, unavailable, message: "only available as optional getter")
    get { fatalError() }
    set { self.root = casePath.embed(newValue) }
  }
}

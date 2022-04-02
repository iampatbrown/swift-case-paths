@dynamicMemberLookup
public protocol CaseAccessible {
  associatedtype Cases
  subscript<Value>(dynamicMember keyPath: KeyPath<Cases, Value>) -> Value? { get }
  subscript<Value>(dynamicMember keyPath: WritableKeyPath<Cases, Value>) -> Value? { get set }
  subscript<Value>(dynamicMember keyPath: WritableKeyPath<Cases, Value>) -> Value { get set }
  static func casePath<Value>(for keyPath: KeyPath<Cases, Value>) -> CasePath<Self, Value>?
}

extension CaseAccessible {
  public subscript<Value>(dynamicMember keyPath: KeyPath<Cases, Value>) -> Value? {
    Self.casePath(for: keyPath)?.extract(from: self)
  }

  @_disfavoredOverload
  public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Cases, Value>) -> Value? {
    get { Self.casePath(for: keyPath)?.extract(from: self) }
    _modify {
      let casePath = Self.casePath(for: keyPath)
      let value = casePath?.extract(from: self)
      var newValue = value
      yield &newValue
      guard let newValue = newValue, let casePath = casePath else { return }
      self = casePath.embed(newValue)
    }
    @available(*, unavailable, message: "only available as non-optional setter")
    set {}
  }

  @_disfavoredOverload
  public subscript<Value>(dynamicMember keyPath: WritableKeyPath<Cases, Value>) -> Value {
    @available(*, unavailable, message: "only available as optional getter")
    get { fatalError() }
    set { try? Self.casePath(for: keyPath)?.modify(&self) { $0 = newValue } }
  }

  public static func casePath<Value>(for keyPath: KeyPath<Cases, Value>) -> CasePath<Self, Value>? {
    guard
      let caseName = keyPath.fieldName,
      let embed = embedHelp(type: Value.self, into: Self.self, caseName: caseName)
    else { return nil }
    return /embed
  }
}

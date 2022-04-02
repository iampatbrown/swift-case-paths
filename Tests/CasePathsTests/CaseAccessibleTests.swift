import CasePaths
import XCTest

final class CaseAccessibleTests: XCTestCase {
  enum Foo: CaseAccessible {
    case bar(Int), baz(String)
    struct Cases { var bar: Int; var baz: String }
  }

  struct State { var foo: Foo; var route: Route? }
  enum Route: CaseAccessible { case a(A), b(B); struct Cases { var a: A; var b: B } }
  struct A { var route: ARoute?; var value: Bool }
  enum ARoute: CaseAccessible { case x(X), y(Y); struct Cases { var x: X; var y: Y } }
  struct X { var value: Int }
  struct Y { var value: String }
  struct B { var values: [Int] }

  func testBasic() {
    var foo = Foo.bar(42)

    XCTAssertEqual(foo.bar, 42)
    XCTAssertNil(foo.baz)
    foo.baz = "Blob"
    XCTAssertNil(foo.baz)
    foo.bar = 43
    XCTAssertEqual(foo.bar, 43)
  }

  func testNested() {
    var state = State(foo: .bar(42))
    XCTAssertEqual(state.foo.bar, 42)
    XCTAssertNil(state.foo.baz)
    XCTAssertNil(state.route?.a?.value)
    XCTAssertNil(state.route?.a?.route?.x)
    XCTAssertNil(state.route?.b)
    XCTAssertNil(state.route?.b?.values)

    state.route = .a(A(value: true))

    XCTAssertEqual(state.route?.a?.value, true)
    state.route?.a?.value = false
    XCTAssertEqual(state.route?.a?.value, false)

    // state.route?.a = nil // 🛑 only available as non-optional setter
    // state.route?.a?.value = nil // 🛑 'nil' cannot be assigned to type 'Bool'


    state.route?.b = B(values: [1, 2, 3])
    XCTAssertEqual(state.route?.a?.value, false)
    XCTAssertNil(state.route?.b?.values)
    state.route = .b(B(values: [1, 2, 3]))
    XCTAssertEqual(state.route?.b?.values, [1, 2, 3])
    XCTAssertNil(state.route?.a)
  }

  func testKeyPath() {
    var state = State(foo: .bar(42))

    let barKeyPath = \State.foo.bar
    let bazKeyPath = \State.foo.baz
    XCTAssertEqual(state[keyPath: barKeyPath], 42)
    XCTAssertNil(state[keyPath: bazKeyPath])

    state.route = .a(A(route: .y(Y(value: "Blob")), value: true))
    let yValueKeyPath = \State.route?.a?.route?.y?.value
    XCTAssertEqual(state[keyPath: yValueKeyPath], "Blob")
  }
}

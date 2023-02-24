import CasePaths
import XCTest

final class CaseAccessibleTests: XCTestCase {
  func testBasics() {
    struct Baz: Equatable { var array: [Int] = [1, 2, 3], string: String = "Blob" }
    indirect enum Foo: CaseAccessible {
      case foo(Foo)
      case bar(Int)
      case baz(Baz)
    }

    var foo = Foo.bar(42)
    foo[/Foo.foo] = .baz(Baz()) // foo == Foo.foo(.baz(Baz())
    foo[/Foo.baz]?.string = "Blobby" // no-op
    foo[/Foo.foo .. /Foo.bar] = 42 // foo == Foo.foo(.bar(42))
    foo[/Foo.baz] = Baz()  // foo == Foo.baz(Baz())
    XCTAssertEqual(foo[/Foo.baz]?.array, [1,2,3])
    foo[/Foo.foo]?[/Foo.baz] = Baz() // no-op
    foo[/Foo.foo .. /Foo.baz] = Baz() // foo == Foo.foo(.baz(Baz())
    let x = foo[/Foo.foo]?[/Foo.baz]
    XCTAssertEqual(foo[/Foo.foo]?[/Foo.baz]?.array, [1,2,3])
    
    foo[/Foo.foo]?[/Foo.baz]?.array = [3, 2, 1] // foo == Foo.foo(.baz(Baz(array: [3, 2, 1]))

    foo[/Foo.foo] = nil // 🛑 forbidden by the compiler
    foo[/Foo.foo]?[/Foo.baz] = nil // 🛑 forbidden by the compiler
    foo[/Foo.foo .. /Foo.baz] = nil // 🛑 forbidden by the compiler
    foo[/Foo.foo] = .none // 🛑 forbidden by the compiler
    foo[/Foo.foo] = Optional<Foo>.none  //❗️ work around no-op
  }
}

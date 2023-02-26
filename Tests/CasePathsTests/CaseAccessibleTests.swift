import CasePaths
import XCTest

final class CaseAccessibleTests: XCTestCase {
  func testBasics() {
    struct Baz: Equatable { var array: [Int] = [1, 2, 3], string: String = "Blob" }
    indirect enum Foo: Equatable, CaseAccessible {
      case foo(Foo)
      case bar(Int)
      case baz(Baz)
    }

    var foo = Foo.bar(42)
    
    foo[/Foo.foo] = .baz(Baz())
    XCTAssertEqual(foo, Foo.foo(.baz(Baz())))
    
    foo[/Foo.baz]?.string = "Blobby" // no-op
    XCTAssertEqual(foo, Foo.foo(.baz(Baz())))
    
    foo[/Foo.foo .. /Foo.bar] = 42
    XCTAssertEqual(foo, Foo.foo(.bar(42)))
    
    foo[/Foo.baz] = Baz()
    XCTAssertEqual(foo, Foo.baz(Baz()))
    
    foo[/Foo.foo]?[/Foo.baz] = Baz() // no-op
    XCTAssertEqual(foo, Foo.baz(Baz()))
    
    foo[/Foo.foo .. /Foo.baz] = Baz()
    XCTAssertEqual(foo, Foo.foo(.baz(Baz())))
    
    foo[/Foo.foo]?[/Foo.baz]?.array = [3,2,1] 
    XCTAssertEqual(foo[/Foo.foo]?[/Foo.baz]?.array, [3,2,1])
    
    let fooCase = foo[/Foo.foo]
    XCTAssertEqual(fooCase, Foo.baz(Baz(array: [3, 2, 1])))
    
    let fooBaz = foo[/Foo.foo]?[/Foo.baz]
    XCTAssertEqual(fooBaz, Baz(array: [3, 2, 1]))
    
    let fooBazArray = foo[/Foo.foo]?[/Foo.baz]?.array
    XCTAssertEqual(fooBazArray,  [3, 2, 1])
    
    let barCase = foo[/Foo.bar]
    XCTAssertNil(barCase)
    
    let bazCase = foo[/Foo.baz]
    XCTAssertNil(bazCase)
    

    foo[/Foo.foo] = nil as _OptionallyChained<Foo>? // 🙃 no-op
    foo[/Foo.bar] = nil as _OptionallyChained<Int>? // 🙃 no-op
    
    XCTAssertEqual(foo[/Foo.foo]?[/Foo.baz]?.array, [3,2,1])
    
//    foo[/Foo.foo] = nil // 🛑 forbidden by the compiler
//    foo[/Foo.foo]?[/Foo.baz] = nil // 🛑 forbidden by the compiler
//    foo[/Foo.foo .. /Foo.baz] = nil // 🛑 forbidden by the compiler
//    foo[/Foo.foo] = .none // 🛑 forbidden by the compiler
//    foo[/Foo.foo] = nil as Foo? // 🛑 forbidden by the compiler
  }
  
  func testOptionalPath() {
    enum Foo: Equatable, CaseAccessible {
      case bar(Bar)
      case baz(Baz)
    }
    
    enum Bar: Equatable, CaseAccessible {
      case baz(Baz)
    }
    
    enum FizzBuzz: Equatable, CaseAccessible {
      case fizz(Int)
      case buzz(Int)
    }
    
    struct Baz: Equatable { var array: [FizzBuzz] = [.fizz(42), .buzz(1729)] }
    
    struct State { var foo: Foo? }
    
    var state = State(foo: .bar(.baz(Baz())))
    
    XCTAssertEqual(state.foo?[/Foo.bar]?[/Bar.baz]?.array[0][/FizzBuzz.fizz], 42)
    XCTAssertNil(state.foo?[/Foo.bar]?[/Bar.baz]?.array[0][/FizzBuzz.buzz])
    XCTAssertEqual(state.foo?[/Foo.bar]?[/Bar.baz]?.array[1][/FizzBuzz.buzz], 1729)
    XCTAssertNil(state.foo?[/Foo.bar]?[/Bar.baz]?.array[1][/FizzBuzz.fizz])
    
    state.foo?[/Foo.bar]?[/Bar.baz]?.array[0][/FizzBuzz.fizz] = 4104
    XCTAssertEqual(state.foo?[/Foo.bar]?[/Bar.baz]?.array[0][/FizzBuzz.fizz], 4104)
    
    state.foo = nil
    XCTAssertNil(state.foo?[/Foo.bar]?[/Bar.baz]?.array[1][/FizzBuzz.fizz])
    XCTAssertNil(state.foo?[/Foo.bar]?[/Bar.baz]?.array[0][/FizzBuzz.buzz])
    
    state.foo?[/Foo.bar]?[/Bar.baz]?.array[0][/FizzBuzz.fizz] = 4104
    XCTAssertNil(state.foo)
   }
}

#if swift(>=5.9)
import Benchmark
import CasePaths

@CasePathable
enum One { case two(Two), value(Int), anotherValue(String) }
@CasePathable
enum Two { case three(Three), value(Int), anotherValue(String) }
@CasePathable
enum Three { case four(Four), value(Int), anotherValue(String) }
@CasePathable
enum Four { case five(Five), value(Int), anotherValue(String) }
@CasePathable
enum Five { case six(Six), value(Int), anotherValue(String) }
@CasePathable
enum Six { case seven(Seven), value(Int), anotherValue(String) }
@CasePathable
enum Seven { case value(Int), anotherValue(String) }

let one = One.value(1)
let two = One.two(.value(2))
let six = One.two(.three(.four(.five(.six(.value(6))))))
let seven = One.two(.three(.four(.five(.six(.seven(.value(7)))))))

struct Scope<Root, Value> {
  let toValue: AnyCasePath<Root, Value>
  init(_ toValue: CaseKeyPath<Root, Value>) {
    self.toValue = AnyCasePath(toValue)
  }

  func extract(from root: Root) -> Value? {
    toValue.extract(from: root)
  }
}

let scope = BenchmarkSuite(name: "Scope") {
  $0.benchmark("1 Level") {
    precondition(Scope<One, Int>(\.value).extract(from: one) == 1)
  }
  $0.benchmark("2 Levels") {
    precondition(Scope<One, Int>(\.two.value).extract(from: two) == 2)
  }
  $0.benchmark("6 Levels") {
    precondition(Scope<One, Int>(\.two.three.four.five.six.value).extract(from: six) == 6)
  }
  $0.benchmark("7 Levels") {
    precondition(Scope<One, Int>(\.two.three.four.five.six.seven.value).extract(from: seven) == 7)
  }
}

let cachedScope = BenchmarkSuite(name: "Cached Scope") {
  let scope1 = Scope<One, Int>(\.value)
  $0.benchmark("1 Level") {
    precondition(scope1.extract(from: one) == 1)
  }
  let scope2 = Scope<One, Int>(\.two.value)
  $0.benchmark("2 Levels") {
    precondition(scope2.extract(from: two) == 2)
  }
  let scope6 = Scope<One, Int>(\.two.three.four.five.six.value)
  $0.benchmark("6 Levels") {
    precondition(scope6.extract(from: six) == 6)
  }
  let scope7 = Scope<One, Int>(\.two.three.four.five.six.seven.value)
  $0.benchmark("7 Levels") {
    precondition(scope7.extract(from: seven) == 7)
  }
}

// Initial Results
// name                  time        std        iterations
// -------------------------------------------------------
// Scope.1 Level         1667.000 ns ±  31.14 %     785038
// Scope.2 Levels        2667.000 ns ±  24.20 %     496770
// Scope.6 Levels        7209.000 ns ±   6.44 %     192067
// Scope.7 Levels        8333.000 ns ±   5.75 %     166795
// Cached Scope.1 Level   416.000 ns ±  26.03 %    1000000
// Cached Scope.2 Levels  750.000 ns ±  16.37 %    1000000
// Cached Scope.6 Levels 2333.000 ns ±   9.26 %     597589
// Cached Scope.7 Levels 2708.000 ns ±   6.36 %     513418

// Hoist case initializer
// Scope.1 Level         1667.000 ns ±  13.60 %     818973
// Scope.2 Levels        2708.000 ns ±  13.19 %     515329
// Scope.6 Levels        7375.000 ns ±   4.61 %     188746
// Scope.7 Levels        8541.000 ns ±   3.98 %     163764
// Cached Scope.1 Level   209.000 ns ±  33.45 %    1000000
// Cached Scope.2 Levels  375.000 ns ±  14.51 %    1000000
// Cached Scope.6 Levels 1000.000 ns ±  10.41 %    1000000
// Cached Scope.7 Levels 1208.000 ns ±   9.89 %    1000000

// Inline some things
// name                  time        std        iterations
// -------------------------------------------------------
// Scope.1 Level         1417.000 ns ±  24.47 %     966372
// Scope.2 Levels        2375.000 ns ±  11.04 %     588133
// Scope.6 Levels        6333.000 ns ±   5.79 %     219332
// Scope.7 Levels        7500.000 ns ±   4.13 %     185685
// Cached Scope.1 Level    83.000 ns ±  27.65 %    1000000
// Cached Scope.2 Levels  125.000 ns ±  30.29 %    1000000
// Cached Scope.6 Levels  333.000 ns ±  18.99 %    1000000
// Cached Scope.7 Levels  625.000 ns ±  11.84 %    1000000

Benchmark.main([
  scope,
  cachedScope,
])
#endif

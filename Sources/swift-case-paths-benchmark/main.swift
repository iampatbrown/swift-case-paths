#if swift(>=5.9)
import Benchmark
import CasePaths

@CasePathable
enum Enum {
  case associatedValue(Int)
  case anotherAssociatedValue(String)
}

let enumCase = Enum.associatedValue(42)
let anotherCase = Enum.anotherAssociatedValue("Blob")

let success = BenchmarkSuite(name: "Success") {
  $0.benchmark("CasePathable") {
    precondition(enumCase[case: \.associatedValue] == 42)
  }

  $0.benchmark("Specialized CasePathable") {
    precondition(enumCase[_case: \.associatedValue] == 42)
  }
}

let failure = BenchmarkSuite(name: "Failure") {
  $0.benchmark("CasePathable") {
    precondition(anotherCase[case: \.associatedValue] == nil)
  }

  $0.benchmark("Specialized CasePathable") {
    precondition(anotherCase[_case: \.associatedValue] == nil)
  }
}

Benchmark.main([
  success,
  failure,
])
#endif

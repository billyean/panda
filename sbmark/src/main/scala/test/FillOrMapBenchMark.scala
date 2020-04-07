package test

import org.openjdk.jmh.annotations.{Benchmark, Scope, State}

object FillOrMapBenchMark {
  @State(Scope.Benchmark)
  class Data {
    val dimension : Int = 5

    val default_value : Double = 0.4
  }
}

class FillOrMapBenchMark {
  import FillOrMapBenchMark._
  @Benchmark
  def arrayFill(d: Data): Unit = {
    Array.fill(d.dimension)(d.default_value)
  }

  @Benchmark
  def map(d: Data): Unit = {
    (0 to d.dimension).map(_ => d.default_value).toArray
  }
}

package test

import org.openjdk.jmh.annotations.{Benchmark, Scope, State}

import scala.util.Try

object TryBenchMark {
  @State(Scope.Benchmark)
  class Data {
    val s: String = "10"
  }
}
class TryBenchMark {
  import TryBenchMark._

  @Benchmark
  def tryParse(d: Data): Int = Try(d.s.toInt).toOption.getOrElse(0)

  @Benchmark
  def parse(d: Data): Int = d.s.toInt
}

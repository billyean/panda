package test

import org.openjdk.jmh.annotations.{Benchmark, Scope, State}

object Enum1 extends Enumeration {
  val A1, A2, A3, A4, A5, A6 = Value;
}

object EnumBenchmark {
  val m = Enum1.values.map(e => e.toString -> e).toMap

  @State(Scope.Benchmark)
  class C1 {
    val c = "A1"
    val m = Enum1.values.map(e => e.toString -> e).toMap
  }
}

class EnumBenchmark {
  import EnumBenchmark._

  @Benchmark
  def testWithName(s: C1) = Enum1.withName(s.c)


  @Benchmark
  def testWithNameOnMap(s: C1) = s.m.get(s.c).getOrElse(Enum1.A1)
}

package test

import org.openjdk.jmh.annotations.{Benchmark, Scope, State}

import scala.collection.mutable


object ImmutableBenchMark{
  @State(Scope.Benchmark)
  class Data {
    val v1 : Int = 1

    val v2 : Int = 1
  }
}
class ImmutableBenchMark {
  import ImmutableBenchMark._

  @Benchmark
  def createMutableList(d: Data): mutable.MutableList[Int] = {
    var l = mutable.MutableList[Int]()
    l += d.v1
    l += d.v2
    l
  }

  @Benchmark
  def createImmutableList(d: Data): List[Int] = List(d.v1, d.v2)

}

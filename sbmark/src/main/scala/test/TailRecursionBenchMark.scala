package test

import org.openjdk.jmh.annotations.{Benchmark, Scope, State}

class TailRecursionBenchMark {
  import TailRecursionBenchMark._

  def sum(n: Int): Long =
    n match {
      case 0 => 0
      case x => x + sum(x-1)
    }


  def sumTail(n: Int): Long = {
    def inner(sum: Int, n: Int): Long =
      n match {
        case 0 => sum
        case x => inner(sum + n, n - 1)
      }

    inner(0, n)
  }

  @Benchmark
  def testSumTail(d: Data) = sumTail(d.c)

  @Benchmark
  def testSum(d: Data) = sum(d.c)
}

object TailRecursionBenchMark {
  @State(Scope.Benchmark)
  class Data {
    val c = 1000
  }
}

package test

import org.openjdk.jmh.annotations.{Benchmark, Scope, State}

case class CpcKey1(targeting: String, pageType: String, platform: String, moduleLocation: String) {
  override def toString: String = {
    s"$targeting:$pageType:$platform:$moduleLocation"
  }
}

object PatternMatchBenchMark {
  @State(Scope.Benchmark)
  class Zero {
    val c = ""
  }

  @State(Scope.Benchmark)
  class One {
    val c = "hello"
  }

  @State(Scope.Benchmark)
  class Two {
    val c = "hello:world"
  }

  @State(Scope.Benchmark)
  class Three {
    val c = "hello:world:how"
  }

  @State(Scope.Benchmark)
  class Four {
    val c = "hello:world:how:are"
  }

  @State(Scope.Benchmark)
  class Five {
    val c = "hello:world:how:are:you"
  }
}

class PatternMatchBenchMark {
  import PatternMatchBenchMark._

  def create1(key: String): CpcKey1 = {
    val keys = if (key != null) key.split(":") else Array.empty

    if (keys.length == 4) {
      CpcKey1(keys(0), keys(1), keys(2), keys(3))
    } else if (keys.length == 3) {
      CpcKey1(keys(0), keys(1), keys(2),moduleLocation = null)
    } else {
      CpcKey1(null, null, null, null)
    }
  }

  def create2(key: String): CpcKey1 = {
    val keys = key.split(":").toList

    keys match {
      case t :: p :: others =>
        others match {
          case List(x) => CpcKey1(t.toString, p.toString, x.toString, null)
          case x :: List(m) => CpcKey1(t.toString, p.toString, x.toString, m)
          case _ => CpcKey1(null, null, null, null)
        }

      case _ => CpcKey1(null, null, null, null)
    }
  }

  @Benchmark
  def testCreate1WithThree(t: Three) = create1(t.c)

  @Benchmark
  def testCreate2WithThree(t: Three) = create2(t.c)

  @Benchmark
  def testCreate1WithFour(f: Four) = create1(f.c)

  @Benchmark
  def testCreate2WithFour(f: Four) = create2(f.c)
}

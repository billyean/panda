package test

import org.openjdk.jmh.annotations.{Benchmark, Scope, State}

case class I1(o: Option[String])

case class I2(i: Option[I1])

case class I3(i: Option[I2])

case class I4(i: Option[I3])

object OptionBenchMark{
  @State(Scope.Benchmark)
  class Data {
    val d: Option[I4] = Some(I4(Some(I3(Some(I2(Some(I1(Some("hello")))))))))
  }
}

class OptionBenchMark {
  import OptionBenchMark._

  @Benchmark
  def extractStringByMap(x: Data): String = x.d.flatMap(_.i).flatMap(_.i).flatMap(_.i).flatMap(_.o).get

  @Benchmark
  def extractStringByIf(x: Data): String = {
    if (x.d.isDefined) {
      val i4: I4 = x.d.get
      if (i4.i.isDefined) {
        val i3: I3 = i4.i.get
        if (i3.i.isDefined) {
          val i2: I2 = i3.i.get
          if (i2.i.isDefined) {
            val i1: I1 = i2.i.get
            if (i1.o.isDefined) {
              return i1.o.get
            }
          }
        }
      }
    }

    return null
  }
}

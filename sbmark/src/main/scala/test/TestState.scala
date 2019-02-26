package test

import org.openjdk.jmh.annotations.{Benchmark, Scope, State}

object TestState {
  @State(Scope.Benchmark)
  class BenchmarkState {
    var x = Math.PI
  }

  @State(Scope.Thread)
  class ThreadState {
    var x = Math.PI
  }
}

class TestState {
  import TestState._
  /*
   * Benchmark methods can reference the states, and JMH will inject
   * the appropriate states while calling these methods. You can have
   * no states at all, or have only one state, or have multiple states
   * referenced. This makes building multi-threaded benchmark a breeze.
   *
   * For this exercise, we have two methods.
   */

  @Benchmark
  def measureUnshared(state: ThreadState) = {
    // All benchmark threads will call in this method.
    //
    // However, since ThreadState is the Scope.Thread, each thread
    // will have it's own copy of the state, and this benchmark
    // will measure unshared case.
    state.x += 1
  }

  @Benchmark
  def measureShared(state: BenchmarkState) = {
    // All benchmark threads will call in this method.
    //
    // Since BenchmarkState is the Scope.Benchmark, all threads
    // will share the state instance, and we will end up measuring
    // shared case.
    state.x += 1
  }
}

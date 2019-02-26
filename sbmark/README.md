# sbmark
This is a JMH test repo for scala benchmark

# Tests include
- [X] [Enum](src/main/scala/test/EnumBenchMark.scala)

|Benchmark                       |  Mode  | Cnt     |     Score     |     Error    | Units|
|--------------------------------|--------|---------|---------------|--------------|------|
|EnumBenchmark.testWithName      |   thrpt|  2      | 17926822.565  |              | ops/s|
|EnumBenchmark.testWithNameOnMap |   thrpt|  2      | 82804467.782  |              | ops/s|

- [X] [Option](src/main/scala/test/OptionBenchMark.scala)

|Benchmark                             |  Mode  | Cnt     |     Score     |     Error    | Units|
|--------------------------------------|--------|---------|---------------|--------------|------|
|OptionBenchMark.extractStringByIf     |  thrpt |  2      | 125626879.797 |              | ops/s|
|OptionBenchMark.extractStringByMap    |  thrpt |  2      | 117938676.872 |              | ops/s|


- [X] [Try](src/main/scala/test/TryBenchMark.scala)

|Benchmark             |  Mode  | Cnt     |     Score     |     Error    | Units|
|----------------------|--------|---------|---------------|--------------|------|
|TryBenchMark.parse    |   thrpt|  25     | 125542115.169 | ± 668863.698 | ops/s|
|TryBenchMark.tryParse |   thrpt|  25     |  65263903.887 | ± 255795.871 | ops/s|

- [X] [TailRecursion](src/main/scala/test/TailRecursionBenchMark.scala)

|Benchmark                          |  Mode  | Cnt     |     Score     |     Error    | Units|
|-----------------------------------|--------|---------|---------------|--------------|------|
|TailRecursionBenchMark.testSum     |   thrpt|  25     | 473430.113    |              | ops/s|
|TailRecursionBenchMark.testSumTail |   thrpt|  25     | 3770819.505   |              | ops/s|

- [X] [ImmutableBenchMark](src/main/scala/test/ImmutableBenchMark.scala)


|Benchmark                                |  Mode  | Cnt     |     Score     |     Error    | Units|
|-----------------------------------------|--------|---------|---------------|--------------|------|
|ImmutableBenchMark.createImmutableList   |  thrpt |  2      | 12854111.289  |              | ops/s|
|ImmutableBenchMark.createMutableList     |  thrpt |  2      | 22969947.009  |              | ops/s|
object Micro {
  val MEM_SIZE = 128
  val REGISTER_SIZE = 1024
}

case class Micro(a: Int, b: Int, mem: List[Int] = List.fill(Micro.MEM_SIZE)(0)){
  require(a < Micro.REGISTER_SIZE && a > -Micro.REGISTER_SIZE)
  require(b < Micro.REGISTER_SIZE && b > -Micro.REGISTER_SIZE)
  require(mem.size == Micro.MEM_SIZE)
}
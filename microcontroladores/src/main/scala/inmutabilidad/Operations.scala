package object Operations{

  type Program = List[Operation]
  class ExecutionHaltException extends RuntimeException

  def run(program: Program, initialMicro: Micro) : Micro = {  
    var micro = initialMicro

    for(instruction <- program){
      instruction match {
        case Add => micro = micro.copy(a = micro.a + micro.b)
        case Mul => micro = micro.copy(a = micro.a * micro.b)
        case Swap => micro = micro.copy(a = micro.b, b = micro.a)
        case Load(address) => micro = micro.copy(a = micro.mem(address))
        case Store(address) => micro = micro.copy(mem = micro.mem.updated(address, micro.a))
        case If(subInstructions) => if(micro.a != 0) run(subInstructions, micro) else micro
        case Halt => throw new ExecutionHaltException
      }
    }

    micro
  }

}

package object Operations2{

  type Program = List[Operation]
  class ExecutionHaltException extends RuntimeException

  def run(program: Program, initialMicro: Micro) : Micro = 
    program.foldLeft(initialMicro) { (micro, instruction) => 
      instruction match {
        case Add => micro.copy(a = micro.a + micro.b)
        case Mul => micro.copy(a = micro.a * micro.b)
        case Swap => micro.copy(a = micro.b, b = micro.a)
        case Load(address) => micro.copy(a = micro.mem(address))
        case Store(address) => micro.copy(mem = micro.mem.updated(address, micro.a))
        case If(subInstructions) => if(micro.a != 0) run(subInstructions, micro) else micro
        case Halt => throw new ExecutionHaltException
      }
    }
}
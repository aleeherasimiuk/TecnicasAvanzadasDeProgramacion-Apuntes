package object Operations{

  type Program = List[Operation]
  class ExecutionHaltException extends RuntimeException

  def run(program: Program, initialMicro: Micro): Try[Micro] = {
    program.foldLeft(Try(initialMicro)){
      instruction match {
        case ADD => for(micro <- previousResult) yield micro.copy(a = micro.a + micro.b)
        case MUL => for(micro <- previousResult) yield micro.copy(a = micro.a * micro.b)
        case SWAP => for(micro <- previousResult) yield micro.copy(a = micro.b, b = micro.a)
        case LOAD(address) => for(micro <- previousResult) yield micro.copy(a = micro.mem(address))
        case STORE(address) => for(micro <- previousResult) yield micro.copy(mem = micro.mem.updated(address, micro.a))
        
        case IF(subInstructions) => 
          for {
            micro <- previousResult
            nextMicro <- run(subInstructions, micro)
          } yield if(micro.a == 0) nextMicro else micro

        case HALT => for {
          micro <- previousResult
          haltedMicro <- Try(throw new ExecutionHaltException(micro))
        } yield haltedMicro
      }

    }
  }
}
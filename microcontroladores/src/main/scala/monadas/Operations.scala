package object Operations{

  type Program = List[Operation]
  class ExecutionHaltException extends RuntimeException

  object Result {
    def apply(micro: => Micro): Result = try{
      Success(micro)
    } catch {
      case error: Exception => Failure(micro, error)
    }
  }

  sealed trait Result {
    def micro: Micro
    def map(f: Micro => Micro): Result
    def flatMap(f: Micro => Result): Result
  }

  case class Sucess(micro: Micro) extends Result {
    def map(f: Micro => Micro): Result = Sucess(f(micro))
    def flatMap(f: Micro => Result): Result = f(micro)
  }

  case class Halted(micro: Micro) extends Result {
    def map(f: Micro => Micro): Halted = this
    def flatMap(f: Micro => Result): Halted = this
  }

  case class Failure(micro: Micro, error: Exception) extends Result {
    def map(f: Micro => Micro): Failure = this
    def flatMap(f: Micro => Result): Failure = this
  }

  def run(program: Program, initialMicro: Micro) : Result = {
    program.foldLeft(Result(initialMicro)){ (previousResult, instructions) => 
      instruction match{
        case ADD => previousResult.map(micro => micro.copy(a = micro.a + micro.b))
        case MUL => previousResult.map(micro => micro.copy(a = micro.a * micro.b))
        case SWAP => previousResult.map(micro => micro.copy(a = micro.b, b = micro.a))
        case LOAD(address) => previousResult.map(micro => micro.copy(a = micro.mem(address)))
        case STORE(address) => previousResult.map(micro => micro.copy(mem = micro.mem.updated(address, micro.a)))
        case IF(subInstructions) => previousResult.flatMap(micro => if(micro.a == 0) run(subInstructions, micro) else micro)
        case HALT => previousResult.flatMap(micro => Halted(micro))
      }
    }
  }

  def run2(program: Program, initialMicro: Micro): Result = {
    program.foldLeft(Result(initialMicro)){
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
          haltedMicro <- Halted(micro)
        } yield haltedMicro
      }

    }
  }
}
#!/usr/bin/env julia
module tetris_jl

import Dates

include("./utils.jl")
include("./data.jl")
include("./engine.jl")

function main()
   descent_interval = Dates.Millisecond(1000)
   update_interval = Dates.Millisecond(35)
   tetris = Data.Tetris()
   keys = Utils.key_events()
   put!(keys, 's')
   last_update = last_descent = Dates.now()
   while !Engine.is_game_over(tetris)
      if isready(keys)
         key = take!(keys)
         if key == 'q'
            break
         end
         if key == 's'
            last_descent = Dates.now()
         end
         tetris = Engine.update(tetris, key)
      else
         can_descend = (Dates.now() - last_descent) >= descent_interval
         if can_descend
            tetris = Engine.update(tetris, 's')
            last_descent = Dates.now()
         end
      end
      can_update = (Dates.now() - last_update) >= update_interval
      if can_update
         Engine.print_frame(tetris)
         last_update = Dates.now()
      end 
   end
   close(keys)
   println("Game Over!")
end

end

if abspath(PROGRAM_FILE) == @__FILE__
   tetris_jl.main()
end
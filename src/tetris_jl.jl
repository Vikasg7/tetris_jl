module tetris_jl

using Rocket

include("./take_while.jl")
include("./utils.jl")
include("./data.jl")
include("./engine.jl")

function main()
   ss = timer(0, 1500) |> map_to('s') |> async()
   ks = Utils.key_events() |> filter(∈(['w', 'a', 's', 'd'])) |> async()
   tetris =
      merged((ks, ss)) |>
      scan(Data.Tetris, Engine.update, Data.Tetris()) |>
      take_while(!Engine.game_over; is_inclusive=true)

   ch = Channel(1)
   subscribe!(tetris, lambda(
      on_next     = tetris -> Engine.print_frame(tetris),
      on_error    = err    -> put!(ch, err),
      on_complete = ()     -> put!(ch, "Game Over!")
   ))
   result = fetch(ch)
   println(result)
end

end

if abspath(PROGRAM_FILE) == @__FILE__
   tetris_jl.main()
end
module tetris_jl

using Rocket

include("./take_while.jl")
include("./repeat_latest_on_interval.jl")
include("./utils.jl")
include("./data.jl")
include("./engine.jl")

function main()
   ks = Utils.key_events() |> start_with('s') |> async() |> share()
   ss = ks |> filter(∈(['s'])) |> repeat_latest_on_interval(1.5)
   os = ks |> filter(∈(['w', 'a', 'd']))
   tetris =
      merged((ss, os)) |>
      scan(Data.Tetris, Engine.update, Data.Tetris()) |>
      take_while(!Engine.game_over; is_inclusive=true)

   Utils.blocking_subscribe!(tetris, lambda(
      on_next     = tetris -> Engine.print_frame(tetris),
      on_error    = err    -> showerror(stderr, err),
      on_complete = ()     -> println("Game Over!")
   ))
end

end

if abspath(PROGRAM_FILE) == @__FILE__
   tetris_jl.main()
end
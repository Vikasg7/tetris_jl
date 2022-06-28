module tetris_jl

include("./data.jl")
include("./engine.jl")

function main()
   println("hello world!")
end

end

if abspath(PROGRAM_FILE) == @__FILE__
   tetris_jl.main()
end
module Data

const STACK_COLS = 10
const STACK_ROWS = 20

const Grid = Vector{Vector{Int}}

const Tetrominos = [
   # ____
   [[1,1,1,1]],
   # square
   [[1,1],
    [1,1]],
   # Z
   [[1,1,0],
    [0,1,1]],
   # Reverse Z
   [[0,1,1],
    [1,1,0]],
   # _|_
   [[0,1,0],
    [1,1,1]],
   # |__
   [[1,0,0],
    [1,1,1]],
   # __|
   [[0,0,1],
    [1,1,1]]
]

struct Shape
   grid::Grid
   rows::Int
   cols::Int
   function Shape(grid::Grid)
      new(grid, length(grid), length(first(grid)))
   end
   function Shape(grid::Grid, rows::Int, cols::Int)
      new(grid, rows, cols)
   end
end

mutable struct Tetromino
   shape::Shape
   cordX::Int
   cordY::Int
   function Tetromino()
      new(Shape(rand(Tetrominos)), STACK_COLS/2-2, 1)
   end
   function Tetromino(other::Tetromino, shape::Shape)
      new(shape, other.cordX, other.cordY)
   end
end

mutable struct Tetris
   stack::Grid
   tetro::Tetromino
   function Tetris()
      grid = fill(zeros(Int, 10), 15)
      new(grid, Tetromino())
   end
end

function Base.show(io::Core.IO, grid::Grid)
   for r in grid
      println(io, replace(join(r, " "), "1" => "#", "0" => " "))
   end
end

Base.show(io::Core.IO, shape::Shape)     = show(io, shape.grid)
Base.show(io::Core.IO, tetro::Tetromino) = show(io, tetro.shape.grid)

end
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

mutable struct Shape
   grid::Grid
   rows::Int
   cols::Int
   Shape(grid::Grid) = new(grid, length(grid), length(first(grid)))
   Shape(grid::Grid, rows::Int, cols::Int) = new(grid, rows, cols)
end

mutable struct Tetromino
   shape::Shape
   cordX::Int
   cordY::Int
   Tetromino() = new(Shape(rand(Tetrominos)), 4, 1)
   Tetromino(shape::Shape, cordX::Int, cordY::Int) = new(shape, cordX, cordY)
end

Base.copy(t::Tetromino) = Tetromino(t.shape, t.cordX, t.cordY)

mutable struct Tetris
   stack::Grid
   tetro::Tetromino
   function Tetris()
      grid = [zeros(Int, STACK_COLS) for _ in 1:STACK_ROWS]
      new(grid, Tetromino())
   end
   Tetris(stack::Grid, tetro::Tetromino) = new(stack, tetro)
end

function Base.show(io::Core.IO, grid::Grid)
   rows = map(grid) do row
      replace(join(row, " "), "1" => "#", "0" => "-")
   end
   print(io, join(rows, "\n"))
end

Base.show(io::Core.IO, shape::Shape)     = show(io, shape.grid)
Base.show(io::Core.IO, tetro::Tetromino) = show(io, tetro.shape.grid)

function Base.show(io::Core.IO, tetris::Tetris)
   stack::Grid = deepcopy(tetris.stack)
   tetro = tetris.tetro
   for r = 1:tetro.shape.rows,
       c = 1:tetro.shape.cols
      dy = r + tetro.cordY - 1
      dx = c + tetro.cordX - 1
      if stack[dy][dx] == 0
         stack[dy][dx] = tetro.shape.grid[r][c]
      end
   end
   show(io, stack)
end

end
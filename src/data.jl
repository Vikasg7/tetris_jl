module Data

const STACK_COLS = 10
const STACK_ROWS = 20

const Grid = Vector{Vector{Int}}
const Direction = Tuple{Int, Int}
const Cords = Tuple{Int, Int}

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
end

Shape(grid::Grid) = Shape(grid, length(grid), length(first(grid)))

mutable struct Tetromino
   shape::Shape
   cords::Tuple{Int, Int}
end

Tetromino() = Tetromino(Shape(rand(Tetrominos)), (4, 1))

Base.copy(t::Tetromino) = Tetromino(t.shape, t.cords)

mutable struct Tetris
   stack::Grid
   tetro::Tetromino
end

function Tetris()
   grid = [zeros(Int, STACK_COLS) for _ in 1:STACK_ROWS]
   Tetris(grid, Tetromino())
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
      dy = r + tetro.cords[2] - 1
      dx = c + tetro.cords[1] - 1
      if stack[dy][dx] == 0
         stack[dy][dx] = tetro.shape.grid[r][c]
      end
   end
   show(io, stack)
end

end
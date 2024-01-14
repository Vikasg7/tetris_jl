module Engine

import ..Data
using  ..Utils: inc, dec, over, with

function wall_collision(tetro::Data.Tetromino)::Bool
   # Left Wall
   tetro.cordX < 1 && return true
   # Right Wall
   (tetro.cordX + tetro.shape.cols - 1) > Data.STACK_COLS && return true
   # Bottom Wall
   (tetro.cordY + tetro.shape.rows - 1) > Data.STACK_ROWS && return true
   return false
end

function stack_collision(stack::Data.Grid, tetro::Data.Tetromino)::Bool
   for r = 1:tetro.shape.rows,
       c = 1:tetro.shape.cols
      if tetro.shape.grid[r][c] == 1
         x = c + tetro.cordX - 1
         y = r + tetro.cordY - 1
         (stack[y][x] == 1) &&
            return true
      end
   end
   return false
end

stack_collision(tetris::Data.Tetris)::Bool = stack_collision(tetris.stack, tetris.tetro)

function can_rotate(tetris::Data.Tetris)::Bool
   rotated = rotate(tetris.tetro)
   wall_collision(rotated) && return false
   stack_collision(tetris.stack, rotated) && return false
   return true
end

function rotate(shape::Data.Shape)::Data.Shape
   grid::Data.Grid = [zeros(Int, shape.rows) for _ in 1:shape.cols]
   for r = 1:shape.rows,
       c = 1:shape.cols
      grid[c][shape.rows-r+1] = shape.grid[r][c]
   end
   return Data.Shape(grid, shape.cols, shape.rows)
end

function rotate(tetro::Data.Tetromino)::Data.Tetromino
   over(tetro, :shape => rotate)
end

function move(tetro::Data.Tetromino, direction::Pair)::Data.Tetromino
   over(tetro, direction)
end

function can_move(tetris::Data.Tetris, direction::Pair)::Bool
   moved = move(tetris.tetro, direction)
   wall_collision(moved) &&
      return false
   stack_collision(tetris.stack, moved) &&
      return false
   return true
end

function remove_lines!(stack::Data.Grid)::Data.Grid
   filter!(stack) do row
      !all(x -> x == 1, row)
   end
   for _ = 1:Data.STACK_ROWS-length(stack)
      pushfirst!(stack, zeros(Int, Data.STACK_COLS))
   end
   return stack
end

function fill!(tetris::Data.Tetris)::Data.Grid
   for r = 1:tetris.tetro.shape.rows,
       c = 1:tetris.tetro.shape.cols
      dy = r + tetris.tetro.cordY - 1
      dx = c + tetris.tetro.cordX - 1
      if tetris.stack[dy][dx] == 0
         tetris.stack[dy][dx] = tetris.tetro.shape.grid[r][c]
      end
   end
   return tetris.stack
end

function is_game_over(tetris::Data.Tetris)::Bool
   stack_collision(tetris) & (tetris.tetro.cordY == 1)
end

function update(tetris::Data.Tetris, k::Char)
   if (k == 's')
      if can_move(tetris, :cordY => inc)
         return with(tetris, :tetro => move(tetris.tetro, :cordY => inc))
      else
         stack = tetris |> fill! |> remove_lines!
         return Data.Tetris(stack, Data.Tetromino())
      end
   end
   if (k == 'w') & can_rotate(tetris)
      return with(tetris, :tetro => rotate(tetris.tetro))
   end
   if (k == 'a') & can_move(tetris, :cordX => dec)
      return with(tetris, :tetro => move(tetris.tetro, :cordX => dec))
   end
   if (k == 'd') & can_move(tetris, :cordX => inc)
      return with(tetris, :tetro => move(tetris.tetro, :cordX => inc))
   end
   return tetris
end

const clear_terminal_cmd =
   "\033[$(Data.STACK_ROWS)A" *
   "\033[$(Data.STACK_COLS)D"

function print_frame(tetris::Data.Tetris)
   print(clear_terminal_cmd)
   println(tetris)
end

end
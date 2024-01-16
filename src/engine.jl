module Engine

import ..Data

function wall_collision(tetro::Data.Tetromino)::Bool
   # Left Wall
   tetro.cords[1] < 1 && 
      return true
   # Right Wall
   (tetro.cords[1] + tetro.shape.cols - 1) > Data.STACK_COLS && 
      return true
   # Bottom Wall
   (tetro.cords[2] + tetro.shape.rows - 1) > Data.STACK_ROWS && 
      return true
   return false
end

function stack_collision(stack::Data.Grid, tetro::Data.Tetromino)::Bool
   for r = 1:tetro.shape.rows,
       c = 1:tetro.shape.cols
      if tetro.shape.grid[r][c] == 1
         x = c + tetro.cords[1] - 1
         y = r + tetro.cords[2] - 1
         (stack[y][x] == 1) &&
            return true
      end
   end
   return false
end

stack_collision(tetris::Data.Tetris)::Bool = stack_collision(tetris.stack, tetris.tetro)

function rotate(shape::Data.Shape)::Data.Shape
   grid::Data.Grid = [zeros(Int, shape.rows) for _ in 1:shape.cols]
   for r = 1:shape.rows,
       c = 1:shape.cols
      grid[c][shape.rows-r+1] = shape.grid[r][c]
   end
   return Data.Shape(grid, shape.cols, shape.rows)
end

function rotate!(tetro::Data.Tetromino)
   tetro.shape = rotate(tetro.shape)
   return nothing
end

function move!(tetro::Data.Tetromino, direction::Data.Direction)
   tetro.cords = tetro.cords .+ direction
   return nothing
end

function can_rotate(tetris::Data.Tetris)::Bool
   rotated = copy(tetris.tetro)
   rotate!(rotated)
   wall_collision(rotated) &&
      return false
   stack_collision(tetris.stack, rotated) &&
      return false
   return true
end

function can_move(tetris::Data.Tetris, direction::Data.Direction)::Bool
   moved = copy(tetris.tetro)
   move!(moved, direction)
   wall_collision(moved) &&
      return false
   stack_collision(tetris.stack, moved) &&
      return false
   return true
end

function remove_lines!(stack::Data.Grid)
   filter!(stack) do row
      !all(x -> x == 1, row)
   end
   for _ = 1:Data.STACK_ROWS-length(stack)
      pushfirst!(stack, zeros(Int, Data.STACK_COLS))
   end
end

function fill!(tetris::Data.Tetris)
   for r = 1:tetris.tetro.shape.rows,
       c = 1:tetris.tetro.shape.cols
      dy = r + tetris.tetro.cords[2] - 1
      dx = c + tetris.tetro.cords[1] - 1
      if tetris.stack[dy][dx] == 0
         tetris.stack[dy][dx] = tetris.tetro.shape.grid[r][c]
      end
   end
end

function is_game_over(tetris::Data.Tetris)::Bool
   stack_collision(tetris) & (tetris.tetro.cords[2] == 1)
end

function update!(tetris::Data.Tetris, k::Char)
   if (k == 's')
      if can_move(tetris, (0,1))
         move!(tetris.tetro, (0,1))
      else
         fill!(tetris)
         remove_lines!(tetris.stack)
         tetris.tetro = Data.Tetromino()
      end
   end
   if (k == 'w') & can_rotate(tetris)
      rotate!(tetris.tetro)
   end
   if (k == 'a') & can_move(tetris, (-1,0))
      move!(tetris.tetro, (-1,0))
   end
   if (k == 'd') & can_move(tetris, (1,0))
      move!(tetris.tetro, (1,0))
   end
end

const clear_terminal_cmd =
   "\033[$(Data.STACK_ROWS)A" *
   "\033[$(Data.STACK_COLS)D"

function print_frame(tetris::Data.Tetris)
   print(clear_terminal_cmd)
   println(tetris)
end

end
module Engine

using ..Data

function wall_collision(tetro::Data.Tetromino)::Bool
   # Left Wall
   tetro.cordX < 1 & 
   # Right Wall
   tetro.cordX + tetro.shape.cols > Data.STACK_COLS &
   # Bottom Wall
   tetro.cordY + tetro.shape.rows > Data.STACK_ROWS
end

function stack_collision(stack::Data.Grid, tetro::Data.Tetromino)::Bool
   for r = 1:tetro.shape.rows,
       c = 1:tetro.shape.cols
      if tetro.shape.grid[y][x] == 1
         x = c + tetro.cordX
         y = r + tetro.cordY
         stack[y][x] == 1 &&
            return true
      end
   end
   return false
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
   Data.Tetromino(tetro, rotate(tetro.shape))
end

function move_left!(stack::Data.Grid, tetro::Data.Tetromino)::Nothing
   tetro.cordX -= 1
   if wall_collision(tetro) ||
      stack_collision(stack, tetro) 
         tetro.cordX += 1
   end
end

function move_right!(stack::Data.Grid, tetro::Data.Tetromino)::Nothing
   tetro.cordX -= 1
   if wall_collision(tetro) ||
      stack_collision(stack, tetro) 
         tetro.cordX += 1
   end
end

function move_down!(stack::Data.Grid, tetro::Data.Tetromino)::Bool
   tetro.cordY += 1
   if wall_collision(tetro) ||
      stack_collision(stack, tetro) 
         tetro.cordX -= 1
         return false
   end
   return true
end

function rotate!(stack::Data.Grid, tetro::Data.Tetromino)::Nothing
   rotated = rotate(tetro)
   if !wall_collision(rotated) &&
      !stack_collision(stack, rotated)
         tetro.shape = rotated.shape
   end
end

function remove_lines!(stack::Data.Grid)
   filter!(stack) do row
      all(x -> x == 1, row)
   end
end

end
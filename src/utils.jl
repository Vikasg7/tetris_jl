module Utils

import REPL
import Dates

function key_events()::Channel{Char}
   t = REPL.TerminalMenus.terminal
   REPL.Terminals.raw!(t, true)
   Channel{Char}(1, spawn=true) do ch
      while isopen(ch)
         put!(ch, read(t, Char))
      end
   end
end

function with(old, pairs::Pair...)
   T = typeof(old)
   field_values = [getfield(old, field) for field in fieldnames(T)]
   for pair in pairs
      index = findfirst(fieldnames(T) .== pair.first)
      @assert index !== nothing "$(pair.first) is not a field of $(T)"
      field_values[index] = pair.second
   end
   return T(field_values...)
end

function over(old, pairs::Pair...)
   T = typeof(old)
   field_values = [getfield(old, field) for field in fieldnames(T)]
   for pair in pairs
      index = findfirst(fieldnames(T) .== pair.first)
      @assert index !== nothing "$(pair.first) is not a field of $(T)"
      field_values[index] = pair.second(field_values[index])
   end
   return T(field_values...)
end

inc(x::Int)::Int = x + 1
dec(x::Int)::Int = x - 1

end
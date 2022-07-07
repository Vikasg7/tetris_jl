module Utils

export key_events, blocking_subscribe!, with, over, inc, dec

using Rocket
using REPL

function key_events()
   make(Char) do actor
      t = REPL.TerminalMenus.terminal
      REPL.Terminals.raw!(t, true)
      while !actor.is_unsubscribed
         c = Char(REPL.TerminalMenus.readkey(t.in_stream))
         if Int(c) == 3
            showerror(stderr, InterruptException())
            exit(1)
         end
         next!(actor, c)
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
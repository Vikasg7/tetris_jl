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

end
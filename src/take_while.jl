using Rocket

take_while(pred::Function; is_inclusive::Bool=false) = TakeWhile(pred, is_inclusive)

struct TakeWhile <: InferableOperator
   pred::Function
   is_inclusive::Bool
end

function Rocket.on_call!(::Type{L}, ::Type{L}, op::TakeWhile, source) where {L}
   return proxy(L, source, TakeWhileProxy(op.pred, op.is_inclusive))
end

struct TakeWhileProxy <: ActorProxy
   pred::Function
   is_inclusive::Bool
end

Rocket.operator_right(::TakeWhile, ::Type{L}) where {L} = L

Rocket.actor_proxy!(::Type{L}, proxy::TakeWhileProxy, actor::A) where {L,A} = TakeWhileActor{L,A}(actor, proxy.pred, proxy.is_inclusive)

# actor is downstream actor
struct TakeWhileActor{L,A} <: Actor{L}
   actor::A
   pred::Function
   is_inclusive::Bool
end

function Rocket.on_next!(actor::TakeWhileActor{L}, data::L) where {L}
   result = actor.pred(data)
   (result | actor.is_inclusive) &&
      next!(actor.actor, data)
   !result && complete!(actor.actor)
end

Rocket.on_error!(actor::TakeWhileActor, err) = error!(actor.actor, err)
Rocket.on_complete!(actor::TakeWhileActor) = complete!(actor.actor)

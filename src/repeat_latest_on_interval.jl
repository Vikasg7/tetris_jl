using Rocket

repeat_latest_on_interval(delay::Real) = RepeatLatestOnInterval(delay)

struct RepeatLatestOnInterval <: InferableOperator
   delay::Real
end

Rocket.on_call!(::Type{L}, ::Type{L}, op::RepeatLatestOnInterval, source) where {L} = begin
   proxy(L, source, RepeatLatestOnIntervalProxy(op.delay))
end

Rocket.operator_right(::RepeatLatestOnInterval, ::Type{L}) where {L} = L

struct RepeatLatestOnIntervalProxy <: ActorSourceProxy
   delay::Real
end

# actor::A is a downstream actor
Rocket.actor_proxy!(::Type{L}, proxy::RepeatLatestOnIntervalProxy, actor::A) where {L,A} = RepeatLatestOnIntervalActor{L,A}(actor, proxy.delay)
Rocket.source_proxy!(::Type{L}, proxy::RepeatLatestOnIntervalProxy, source::S) where {L,S} = RepeatLatestOnIntervalSource{L,S}(source)

mutable struct RepeatLatestOnIntervalActor{L,A} <: Actor{L}
   actor::A
   delay::Real
   timer::Timer
   prev::Union{Nothing,L}

   is_disposed::Bool
   RepeatLatestOnIntervalActor{L,A}(actor::A, delay::Real) where {L,A} = new(actor, delay, Timer(1), nothing, false)
end

function on_interval(actor::RepeatLatestOnIntervalActor{L}) where {L}
   timer -> isopen(timer) && next!(actor.actor, actor.prev)
end

Rocket.on_next!(actor::RepeatLatestOnIntervalActor{L}, data::L) where {L} = begin
   if !actor.is_disposed
      close(actor.timer)
      actor.prev = data
      actor.timer = Timer(on_interval(actor), 0; interval=actor.delay)
   end
end

Rocket.on_error!(actor::RepeatLatestOnIntervalActor, err) = begin
   close(actor.timer)
   error!(actor.actor, err)
end

# on_complete! will be called when the source subscription completes
Rocket.on_complete!(actor::RepeatLatestOnIntervalActor) = begin
   close(actor.timer)
   complete!(actor.actor)
end

struct RepeatLatestOnIntervalSource{L,S} <: Subscribable{L}
   source::S
end

Rocket.on_subscribe!(observable::RepeatLatestOnIntervalSource, actor::RepeatLatestOnIntervalActor) = begin
   RepeatLatestOnIntervalSubscription(actor, subscribe!(observable.source, actor))
end

struct RepeatLatestOnIntervalSubscription <: Teardown
   actor
   subscription
end

Rocket.as_teardown(::Type{<:RepeatLatestOnIntervalSubscription}) = UnsubscribableTeardownLogic()

# on_unsubscribe! will be called when downstream unsubscribes
Rocket.on_unsubscribe!(subscription::RepeatLatestOnIntervalSubscription) = begin
   subscription.actor.is_disposed = true
   close(subscription.actor.timer)
   unsubscribe!(subscription.subscription)
   return nothing
end

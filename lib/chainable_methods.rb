require "chainable_methods/version"

module ChainableMethods
  module Nil
    # TODO placeholder for shortcut initializer. not the best option but works for now
  end

  def chain_from(initial_state)
    ChainableMethods::Link.new(initial_state, self)
  end

  def self.wrap(context, initial_state)
    ChainableMethods::Link.new(initial_state, context)
  end

  class Link
    attr_reader :state, :context

    def initialize(object, context)
      @state   = object
      @context = context
    end

    def chain(&block)
      new_state = block.call(state)
      ChainableMethods::Link.new( new_state, context )
    end

    def method_missing(name, *args, &block)
      local_response   = state.respond_to?(name)
      context_response = context.respond_to?(name)

      # if the state itself has the means to respond, delegate to it
      # but if the context has the behavior, it has priority over the delegation
      if local_response && !context_response
        ChainableMethods::Link.new( state.send(name, *args, &block), context)
      else
        ChainableMethods::Link.new( context.send(name, *([state] + args), &block), context )
      end
    end

    def unwrap
      @state
    end
  end
end

# easier shortcut
def CM(initial_state, context = ChainableMethods::Nil)
  ChainableMethods.wrap(context, initial_state)
end

require "chainable_methods/version"

module ChainableMethods
  def chain_from(initial_state)
    ChainableMethods::Link.new(initial_state, self)
  end

  class Link
    attr_reader :state, :context

    def initialize(object, context)
      @state   = object
      @context = context
    end

		def apply(&block)
			@state = block.call @state
			ChainableMethods::Link.new(@state, @context)
		end

    def method_missing(name, *args, &block)
      if state.respond_to?(name)
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

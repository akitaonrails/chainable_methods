require "chainable_methods/version"

# easier shortcut
def CM(initial_state, context = ChainableMethods::Nil)
  ChainableMethods::Link.new(initial_state, context)
end

module ChainableMethods
  # TODO placeholder context to always delegate method missing to the state object
  module Nil; end

  def self.included(base)
    base.extend(self)
    begin
      # this way the module doesn't have to declare all methods as class methods
      base.extend(base) if base.kind_of?(Module)
    rescue TypeError
      # wrong argument type Class (expected Module)
    end
  end

  def chain_from(initial_state, context = self)
    ChainableMethods::Link.new(initial_state, context)
  end

  class Link
    def initialize(object, context = ChainableMethods::Nil)
      @state, @context = object, context
    end

    def chain(&block)
      new_state = block.call(@state)
      ChainableMethods::Link.new( new_state, @context )
    end

    def method_missing(method_name, *args, &block)
      if is_constant?(method_name)
        return ChainableMethods::Link.new( @state, constant_name(method_name) )
      end

      ChainableMethods::Link.new( new_state(method_name, args, block), @context )
    end

    def unwrap
      @state
    end

    private

    def run_on_state?(method_name)
      @state.respond_to?(method_name) && !@context.respond_to?(method_name)
    end

    def new_state(method_name, args, block)
      # if the state itself has the means to respond, delegate to it
      # but if the context has the behavior, it has priority over the delegation
      if run_on_state?(method_name)
        @state.send(method_name, *args, &block)
      else
        @context.send(method_name, *args.unshift(@state), &block)
      end
    end

    def is_constant?(method_name)
      method_name_start = method_name.to_s.chars.first
      if method_name_start =~ /\A[[:alpha:]]+\z/i
        return ( method_name_start.upcase == method_name_start )
      end
      false
    end

    def constant_name(method_name)
      ::Kernel.const_get(method_name)
    end
  end
end

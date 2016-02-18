require 'test_helper'

module FooModule
  extend ChainableMethods

  def self.do_upcase(state)
    state.upcase
  end

  def self.append_message(state, message)
    [state, message].join(" ")
  end

  def self.split_words(state)
    state.split(" ")
  end
end

class ChainableMethodsTest < Minitest::Test
  def test_that_it_unwraps_the_state
    initial_state = "Hello World"
    last_result = FooModule.chain_from(initial_state).unwrap
    assert_equal last_result, initial_state
  end

  def test_that_it_chains_correctly
    initial_state = "Hello"

    result = FooModule.chain_from(initial_state).
               do_upcase.
               append_message("World").
               split_words.
               unwrap

    assert_equal result, %w{HELLO World}
  end

  def test_that_it_chains_through_the_state_object_own_methods
    initial_state = "Hello"

    result = FooModule.chain_from(initial_state).
               upcase.
               append_message("World").
               split(" ").
               unwrap

    assert_equal result, %w(HELLO World)
  end

  def test_that_it_has_a_version_number
    refute_nil ::ChainableMethods::VERSION
  end
end

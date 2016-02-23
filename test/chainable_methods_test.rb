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

  def self.filter(state)
    yield(state)
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

  def test_that_it_allows_methods_with_blocks
    initial_state = "Hello"

    result = FooModule.chain_from(initial_state).
               append_message("World").
               filter { |state| state.gsub("o", "0") }.
               unwrap

    assert_equal result, "Hell0 W0rld"
  end

  def test_more_enumerable_methods
    initial_state = "a b c d e f"

    result = FooModule.chain_from(initial_state).
      split_words.
      map { |character| "(#{character})" }.
      join(", ").
      unwrap

    assert_equal result, "(a), (b), (c), (d), (e), (f)"
  end

  def test_extend_into_array_object
    initial_state = %w(a b c d)
    initial_state.extend ChainableMethods

    # the 1 object responds to [] but it defers to the [] in the array as priority
    result = initial_state.chain_from(1).
      [].
      upcase.
      unwrap

    assert_equal result, "B"
  end

  def test_same_as_extending_into_object_but_with_leaner_wrapper
    initial_state = %w(a b c d)

    result = CM.wrap(initial_state, 2).
      [].
      upcase.
      unwrap

    assert_equal result, "C"
  end

  def test_that_it_has_a_version_number
    refute_nil ::ChainableMethods::VERSION
  end
end

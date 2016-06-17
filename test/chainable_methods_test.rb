require 'test_helper'

# a module has no state, in this case all methods are 'static'
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

# useful for classes that also hold no internal state and
# each instance method receives state from the outside
class FooClass
  def do_upcase(state)
    state.upcase
  end

  def split_words(state)
    state.split(" ")
  end
end

class BarClass
  include ChainableMethods

  attr_reader :some_state

  def composed_workflow(value)
    @some_state = chain_from(value)
      .convert_to_dollar
      .subtract_interest
      .add_bonus
      .unwrap
  end

  private

  def convert_to_dollar(real_value)
    real_value * dollar_rate
  end

  def dollar_rate
    3.6
  end

  def subtract_interest(dollar_value)
    dollar_value - (dollar_value * interest_rate)
  end

  def interest_rate
    0.35
  end

  def add_bonus(dollar_value)
    if dollar_value > 10.0
      dollar_value + bonus_value
    else
      dollar_value
    end
  end

  def bonus_value
    10.0
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

    result = CM(2, initial_state).
      [].
      upcase.
      unwrap

    assert_equal result, "C"
  end

  def test_allow_for_a_class_instance_that_does_not_hold_state_to_have_chainable_methods
    initial_state = "a b c d e f"

    result = CM(initial_state, FooClass.new).
      split_words.
      map { |character| "(#{character})" }.
      join(", ").
      upcase.
      unwrap

    assert_equal result, "(A), (B), (C), (D), (E), (F)"
  end

  def test_that_it_has_a_version_number
    refute_nil ::ChainableMethods::VERSION
  end

  def test_composable_methods_in_a_class_instead_of_module
    b = BarClass.new
    b.composed_workflow(10.0)
    assert_equal b.some_state, 33.4
  end

  def test_compose_methods_from_anywhere_through_blocks
    sample = "this is a random string with a url https://www.github.com/akitaonrails/chainable_methods/ embedded"
    # url = URI.extract(s).first
    # uri = URI.parse(url)
    # response = open(uri).read
    # doc = Nokogiri::HTML(response)
    # node = doc.css(".readme article h1").first.text.strip

    require "uri"
    require "open-uri"
    require "nokogiri"
    title = CM(sample)
      .chain { |text| URI.extract(text) }
      .first
      .chain { |url| URI.parse(url) }
      .chain { |uri| open(uri) }
      .read
      .chain { |body| Nokogiri::HTML(body) }
      .css(".readme article h1")
      .first
      .text
      .strip
      .unwrap
    assert_equal title, "Chainable Methods"
  end
end

# Chainable Methods

The Elixir language is doing great and within its many incredible features is the famour "Pipe Operator".

It allows you to do constructs such as this:

```
1..100_000
  |> Stream.map(&(&1 * 3))
  |> Stream.filter(odd?)
  |> Enum.sum
```

In a nutshell, this is taking the previous returning value and automatically passing as the first argument of the following function call, so it's equivalent to do this:

```
Enum.sum(Enum.filter(Enum.map(1..100_000, &(&1 * 3)), odd?))
```

This is how we would usually do it, but with the Pipe Operator it becomes incredibly more enjoyable and readable to work with and shifts our way of thinking into making small functions in linked chains. (By the way, this example comes straight from [Elixir's Documentation](http://elixir-lang.org/getting-started/enumerables-and-streams.html))

Now, in the Ruby world, we would prefer to do it in a more Object Oriented fashion, with chained methods like this:

```
object.method_1.method_2(argument).method_3 { |x| do_something(x) }.method_4
```

This is how we do things in Rails, for example, Arel coming into mind:

```
User.first.comments.where(created_at: 2.days.ago..Time.current).limit(5)
```

This pattern involves the methods returning "self" and further methods changing the internal state of the object.

On the other hand, sometimes we would want to just be able to take adhoc returning objects and passing them ahead and isolating on the methods level instead of the objects level. There is a lot of existing discussions so the idea is not to vouch for one option or the other.

In case you want to do the "semi-functional" way, we can do it like this:

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chainable_methods'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chainable_methods

## Usage

```
# create your Module with composable 'functions'
module MyModule
  extend ChainableMethods

  def self.method_a(current_state)
    # transform the state
    do_something(current_state)
  end

  def self.method_b(current_state, other_argument)
    do_something2(current_state, other_argument)
  end

  def self.method_c(current_state)
    yield(current_state)
  end
end
```

And now we can build something like this:

```
MyModule.
  chain_from(some_text).
  upcase. # this calls a method from the string in 'some_text'
  method_a.
  method_b("something").
  method_c { |current_state| do_something3(current_state) }.
  unwrap
```

And that's it. This would be the equivalent of doing something more verbose like this:

```
a = some_text.upcase
b = MyModule.method_a(a)
c = MyModule.method_b(b, "something")
d = MyModule.method_c(c) { |c| do_something3(c) }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/akitaonrails/chainable_methods. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


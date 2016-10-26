# Chainable Methods

<a href="https://codeclimate.com/repos/57659a6019dc0b459200205b/feed"><img src="https://codeclimate.com/repos/57659a6019dc0b459200205b/badges/fbf8f254fa716b481c40/gpa.svg" /></a>

<a href="https://travis-ci.org/akitaonrails/chainable_methods"><img src="https://travis-ci.org/akitaonrails/chainable_methods.svg?branch=master" /></a>

<a href="https://codeclimate.com/repos/57659a6019dc0b459200205b/coverage"><img src="https://codeclimate.com/repos/57659a6019dc0b459200205b/badges/fbf8f254fa716b481c40/coverage.svg" /></a>

<a href="https://codeclimate.com/repos/57659a6019dc0b459200205b/feed"><img src="https://codeclimate.com/repos/57659a6019dc0b459200205b/badges/fbf8f254fa716b481c40/issue_count.svg" /></a>

The Elixir language is great and within its many incredible features is the famous "Pipe Operator". Other popular functional languages like Haskell and F# sport a similar feature to chain method calls in a non-OO language.

It allows you to do constructs such as this:

```elixir
require Integer
1..100_000
  |> Stream.map(&(&1 * 3))
  |> Stream.filter(&(Integer.is_odd(&1)))
  |> Enum.sum
```

In a nutshell, this is taking the previous returning value and automatically passing it as the first argument of the following function call, so it's sort of equivalent to do this:

```elixir
require Integer
Enum.sum(Enum.filter(Enum.map(1..100_000, &(&1 * 3)), &(Integer.is_odd(&1))))
```

This is how we would usually do it, but with the Pipe Operator it becomes incredibly more enjoyable and readable to work with and shifts our way of thinking into making small functions in linked chains. (By the way, this example comes straight from [Elixir's Documentation](http://elixir-lang.org/getting-started/enumerables-and-streams.html))

(In F# it's even more important to make proper left-to-right type inference.)

Now, in the Ruby world, we would prefer to do it in a more Object Oriented fashion, with chained methods like this:

```ruby
object.method_1.method_2(argument).method_3 { |x| do_something(x) }.method_4
```

This is how we do things with collections (Enumerables in general), and in Rails. For example, Arel coming into mind:

```ruby
User.first.comments.where(created_at: 2.days.ago..Time.current).limit(5)
```

This pattern involves the methods returning a chainable Relation object and further methods changing the internal state of that object.

On the other hand, sometimes we would just want to be able to take adhoc returning objects and passing them ahead and isolating on the methods level instead of the objects level. There is a lot of existing discussions so the idea is not to vouch for one option or another.

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

The easiest way and one of the most important purposes of this implementation in Ruby is to allow quick prototyping and better interface discovery. The gist of it is to think of _"given an input data, what transformation steps should I follow to get to a certain output data?"_

For example, given a text with links in it, how do I extract the links, parse them, fetch thee content of a link, parse the HTML, and finally get the title?

This is one such example:

```ruby
include Nokogiri
CM("foo bar http://github.com/akitaonrails/chainable_methods foo bar")
  .URI.extract
  .first
  .URI.parse
  .HTTParty.get
  .HTML.parse
  .css("H1")
  .text
  .unwrap
```

And that's it!

Now, an important point is that I am **NOT** saying that this is a good state to leave your code, but it makes it easy to quickly prototype, test and reason about which parts should be encapsulated in a different method or even a different class.

The only other way to quickly prototype the same thing without Chainable Methods would be to use _temporary variables_ which litter your code with dangerous variables that can be misused and make refactorings more difficult, for example:

```ruby
sample_text = "foo bar http://github.com/akitaonrails/chainable_methods foo bar"
sample_link = URI.extract(sample_text).first
uri = URI.parse(sample_link)
response = HTTParty.get(uri)
doc = Nokogiri::HTML.parse(response)
title = doc.css("H1").text
```

Chaining feels way more natural. And in a pseudo-Elixir version it would be something like this:

```ruby
"foo bar http://github.com/akitaonrails/chainable_methods foo bar"
  |> URI.extract
  |> List.first
  |> URI.parse
  |> HTTParty.get
  |> HTML.parse
  |> css("H1")
```

So we got similar levels of functionality without compromising the dot-notation and the Ruby style.

And we can advance further in other ways to use this chaining methods scheme to better organize functional-style coding:

```ruby
# create your Module with composable 'functions'
module MyModule
  include ChainableMethods

  def method_a(current_state)
    # transform the state
    do_something(current_state)
  end

  def method_b(current_state, other_argument)
    do_something2(current_state, other_argument)
  end

  def method_c(current_state)
    yield(current_state)
  end
end
```

And now we can build something like this:

```ruby
MyModule.
  chain_from(some_text).
  upcase. # this calls a method from the string in 'some_text'
  method_a.
  method_b("something").
  method_c { |current_state| do_something3(current_state) }.
  unwrap
```

And that's it. Again, this would be the equivalent of doing something more verbose like this:

```ruby
a = some_text.upcase
b = MyModule.method_a(a)
c = MyModule.method_b(b, "something")
d = MyModule.method_c(c) { |c| do_something3(c) }
```

So we have this approach to create modules to serve as "namespaces" for collections of isolated and stateless functions, each being a step of some transformation workflow. A module will not hold any internal state and the methods will rely only on what the previous methods return.

Sometimes we have adhoc transformations. We usually have to store intermediate states as temporary variables like this:

```ruby
text  = "hello http:///www.google.com world"
url   = URI.extract(text).first }
uri   = URI.parse(url)
body  = open(uri).read
title = Nokogiri::HTML(body).css("h1").first.text.strip
```

Or now, we can just chain them together like this:

```ruby
include Nokogiri
CM("hello http:///www.google.com world")
  .URI.extract.first
  .URI.parse
  .chain { |uri| open(uri).read }
  .HTML.parse
  .css("h1")
  .first.text.strip
  .unwrap
```

I think this is way neater :-) And as a bonus it's also easier to refactor and change the order of the steps or add new steps in-between.

If you don't have a neat "Module.method" format to chain, you can use the `#chain` call to add transformations from anywhere and keep chaining methods from the returning objects as well, in the same mix, and without those ugly dangling variables.

The shortcut `CM(state, context)` will wrap the initial state and optionally provide a module as a context upon which to call the chained methods. Without you declaring this context, the chained methods will run the initial state object's methods.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/akitaonrails/chainable_methods. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## CHANGELOG

v0.1.0
- initial version

v0.1.1
- introduces the ability to wrap any plain ruby object, without the need for a special module to extend the ChainableMethods module first.
- fixes the priority of methods to call if both state and context has the same method, context always has precedence

v0.1.2
- introduces a shortcut global method 'CM' to be used like this:

```ruby
CM(2, ['a', 'b', 'c'])
  .[]
  .upcase
  .unwrap
# => "C"
```

v0.1.3
- introduces the #chain method do link blocks of code together, the results are wrapped in the Link object and chained again

v0.1.4
- makes the ChainableMethods module "includable" and it automatically makes all instance methods of the parent Module as class methods that can be easily chainable without having to declare all of them as `def self.method` first. So you can do it like this:

v0.2.1
- use a const_get trick to allow to chain Module or Class names directly in the dot notation. Inspired by [this gist](https://gist.github.com/bkerley/754df43c98e116e82003). Kudos to @bkerley for the idea and letting me know.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

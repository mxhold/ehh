# Ehh

Ehh is an experimental web microframework.

## Example

```ruby
# config.ru
require "ehh"

module MyApp
  class Root
    def call(env)
      [200, {}, ["Hello!\n"]]
    end
  end

  module Users
    class Show
      def call(env)
        [200, {}, ["Hello, #{env["router.params"]["username"]}!\n"]]
      end
    end
  end
end

router = Ehh::Router.new

router.register("GET", %r(/$), MyApp::Root.new)
router.register("GET", %r(/users/(?<username>\w+)), MyApp::Users::Show.new)

app = Ehh::Application.new(router: router)
run app
```

## Components

Ehh is made up of a few bits:

- `Ehh::Router`: a very basic router

That's it! (for now...)

## Design principles

- Prioritize ease of reading/understanding over ease of writing: no DSLs
- Leave no trace: no monkey-patching
- Composition over inheritance: no subclassing for code reuse

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ehh'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ehh

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ehh. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


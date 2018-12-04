# OmniAuth Samedi

Samedi&reg; authentication strategy for OmniAuth.

The strategy implements the OAuth 2.0 flow for authentication with samedi&reg;, as described in [samedi&reg; Booking API docs](https://wiki.samedi.de/display/doc/Booking+API#BookingAPI-AuthenticationandAuthorization) and also fetches basic [user information](https://wiki.samedi.de/display/doc/Booking+API#BookingAPI-UserInformation).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-samedi'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-samedi

## Usage

Obtain your Client Key and Client Secret by [signing up for samedi&reg; API credentials](https://patient.samedi.de/api/signup).

You can then add the `samedi` provider in the way that is most appropriate for your app. E.g. if you're using Rails with OmniAuth directly, you can add the following to your `conifg/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :samedi, ENV.fetch('CLIENT_ID'), ENV.fetch('CLIENT_SECRET')
end
```

After the authentication is performed, the user data is retrieved automatically.

For an example of using the strategy within a Rails application, consult the [rails-booking-api](https://github.com/samedi/rails-booking-api) repo.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/samedi/omniauth-samedi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OmniAuth Samedi project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/omniauth-samedi/blob/master/CODE_OF_CONDUCT.md).

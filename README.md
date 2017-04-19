# Kdbx Ruby

[![Code Climate](https://codeclimate.com/github/rumtid/kdbx.rb/badges/gpa.svg)](https://codeclimate.com/github/rumtid/kdbx.rb)

Yet another library for kdbx file.

## Installation

    $ gem install kdbx

## Usage

```ruby
# Open existing kdbx file
kdbx = Kdbx.new("demo.kdbx", password: "password", keyfile: "demo.key")

# Change password
kdbx.password = "new pass"

# Change filename
kdbx.filename = "new.kdbx"

# Save as new.kdbx
kdbx.save
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

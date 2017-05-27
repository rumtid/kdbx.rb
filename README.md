# Kdbx.rb

[![Code Climate](https://codeclimate.com/github/rumtid/kdbx.rb/badges/gpa.svg)](https://codeclimate.com/github/rumtid/kdbx.rb)
[![Gem Version](https://badge.fury.io/rb/kdbx.svg)](https://badge.fury.io/rb/kdbx)

A library for accessing [KeePass](http://keepass.info/) database (v2+), aka kdbx format file.

## Capability

- [x] Read/Write kdbx (v2) file.
- [x] Change keys and headers.
- [ ] Support kdbx (v4) file.

## Installation

    $ gem install kdbx

## Examples

```ruby
# Open existing kdbx file
kdbx = Kdbx.new("demo.kdbx", password: "password", keyfile: "demo.key")

# Read contents
puts kdbx.content

# Change password
kdbx.password = "foobar"

# Save
kdbx.save
```

## Development

First, install dependencies: `bundle install`

Then run tests: `rspec`

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

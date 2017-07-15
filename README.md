# Kdbx.rb

[![Build Status](https://travis-ci.org/rumtid/kdbx.rb.svg?branch=master)](https://travis-ci.org/rumtid/kdbx.rb)
[![Code Climate](https://codeclimate.com/github/rumtid/kdbx.rb/badges/gpa.svg)](https://codeclimate.com/github/rumtid/kdbx.rb)
[![Gem Version](https://badge.fury.io/rb/kdbx.svg)](https://badge.fury.io/rb/kdbx)

A library to access [KeePass](http://keepass.info/) database(aka kdbx format file).

## Warning

:construction: Working in progress, not ready for production.

## Installation

    $ gem install kdbx

## Examples

```ruby
# Open existing kdbx file
kdbx = Kdbx.open("demo.kdbx", password: "password", keyfile: "demo.key")

# Read contents
puts kdbx.content

# Change password
kdbx.password = "foobar"

# Save
kdbx.save("demo.kdbx")
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

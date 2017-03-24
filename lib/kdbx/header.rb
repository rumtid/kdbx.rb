require "openssl"
require "forwardable"

class Kdbx::Header
  def self.load(stream)
    fields = {
      :pid => stream.readpartial(4),
      :sid => stream.readpartial(4),
      :ver => stream.readpartial(4)
    }
    loop do
      id = stream.readbyte
      sz = stream.readpartial 2
      sz = sz.unpack("S").first
      fields[id] = stream.readpartial sz
      break if id == 0
    end
    new.merge! fields
  end

  extend Forwardable
  def_delegators :@fields, :[], :[]=, :has_key?

  def initialize
    @fields = {}
  end

  def initialize_copy(other)
    super
    @fields = other.instance_variable_get(:@fields).clone
  end

  def merge(hash)
    clone.merge! hash
  end

  def merge!(hash)
    @fields.merge! hash
    self
  end

  def save(stream)
    set_defaults
    stream.write @fields.fetch :pid
    stream.write @fields.fetch :sid
    stream.write @fields.fetch :ver
    @fields.each do |key, val|
      next if !(key.is_a? Integer) || key == 0
      stream.write [key, val.bytesize].pack("CS") + val
    end
    val = @fields.fetch 0
    stream.write [0, val.bytesize].pack("CS") + val
  end

  private

  def set_defaults
    @fields.merge!({
      :pid => "\x03\xD9\xA2\x9A",
      :sid => "\x67\xFB\x4B\xB5",
      :ver => "\x01\x00\x03\x00",
      0 => "\x00\xD0\xAD\x0A",
      2 => "\x31\xC1\xF2\xE6\xBF\x71\x43\x50\xBE\x58\x05\x21\x6A\xFC\x5A\xFF",
      3 => "\x01\x00\x00\x00",
      4 => OpenSSL::Random.random_bytes(32),
      5 => OpenSSL::Random.random_bytes(32),
      6 => "\x70\x17\x00\x00\x00\x00\x00\x00",
      7 => OpenSSL::Random.random_bytes(16),
      8 => OpenSSL::Random.random_bytes(32),
      9 => OpenSSL::Random.random_bytes(32),
      10 => "\x02\x00\x00\x00"
    }) { |k, v1, v2| v1 }
  end
end

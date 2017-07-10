require "openssl"
require "forwardable"

class Kdbx::Header
  FILEMAGIC = "\x03\xD9\xA2\x9A\x67\xFB\x4B\xB5\x01\x00\x03\x00".b

  def self.load(file)
    if file.readpartial(12) != FILEMAGIC
      fail ParseError, "bad magic number"
    end
    fields = {}
    loop do
      (id, sz) = file.readpartial(3).unpack("CS<")
      fields[id] = file.readpartial sz
      break if id == 0
    end
    new fields
  rescue TypeError, EOFError
    fail ParseError, "truncated header"
  end

  extend Forwardable
  def_delegators :@fields, :[], :[]=

  def initialize(fields = {})
    @fields = fields
    validate
  end

  def dump
    merge_defaults and validate
    StringIO.new.binmode.tap do |io|
      io.write FILEMAGIC
      @fields.each do |k, v|
        io.write [k, v.bytesize].pack("CS<") + v if k != 0
      end
      io.write [0, @fields[0].bytesize].pack("CS<") + @fields[0]
    end.string
  end

  def validate
    @fields.each do |k, v|
      fail FormatError, "header #{k.inspect}: #{v}" unless k.is_a? Integer
      fail FormatError, "header #{k}: #{v.inspect}" unless v.is_a? String
      @fields[k] = v = v.b unless v.encoding == Encoding::ASCII_8BIT
      case k
      when 2
        if v != "\x31\xC1\xF2\xE6\xBF\x71\x43\x50\xBE\x58\x05\x21\x6A\xFC\x5A\xFF".b
          fail FormatError, "header #{k}: #{v.inspect}"
        end
      when 3
        if v.bytesize != 4 || !(0..1).include?(v.unpack("L").first)
          fail FormatError, "header #{k}: #{v.inspect}"
        end
      when 4, 5
        fail FormatError, "header #{k}: #{v.inspect}" if v.bytesize != 32
      when 6
        fail FormatError, "header #{k}: #{v.inspect}" if v.bytesize != 8
      when 7
        fail FormatError, "header #{k}: #{v.inspect}" if v.bytesize != 16
      when 8
        if @fields[10] == "\x02\x00\x00\x00".b && v.bytesize != 32
          fail FormatError, "header #{k}: #{v.inspect}"
        end
      when 10
        fail FormatError, "header #{k}: #{v.inspect}" if v.bytesize != 4
        if (n = v.unpack("L<").first) != 0 && n != 2
          fail FormatError, "header #{k}: #{v.inspect}"
        end
      end
    end
  end

  private

  def merge_defaults
    @fields.merge!({
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
    }) { |_k, v1, _v2| v1 }
    true
  end
end

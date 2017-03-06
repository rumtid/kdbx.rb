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
end

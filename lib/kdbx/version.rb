class Kdbx
  VERSION = "0.0.1"

  class Version
    MAGICNUM = "\x03\xD9\xA2\x9A"

    attr_reader :version, :major, :minor

    def initialize
      @raw = ""
    end

    def load(stream)
      @raw = stream.readpartial 12
      @version, @minor, @major = @raw.unpack "xxxxaxxxSS"
    end

    def save(stream)
      stream.write @raw
    end
  end
end

class Kdbx
  class Payload
    def initialize
      @hash = Hash.new
    end

    def load(stream)
      loop do
        id, size = stream.readpartial(40).unpack("Lx32L")
        data = stream.readpartial(size)
        if data.bytesize != 0
          @hash[id] = data
        else
          break
        end
      end
    end

    def save(stream)
    end

    def [](key)
      @hash[key]
    end

    def []=(key, value)
      @hash[key] = value
    end
  end
end

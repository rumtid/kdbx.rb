class Kdbx
  class Headers
    def initialize
      @hash = Hash.new
    end

    def load(stream)
      loop do
        id   = stream.readbyte
        size = stream.readpartial(2)
        size = size.unpack("S<").first
        data = stream.readpartial(size)
        @hash[id] = data
        break if id == 0
      end
    end

    def save(stream)
      fields = @hash.to_a.reject { |i| i[0] == 0 }
      fields = fields.sort_by(&:first)
      fields.each do |id, data|
        array = [id, data.bytesize, data]
        stream.write array.pack "CSA*"
      end
      array = [0, @hash[0].bytesize, @hash[0]]
      stream.write array.pack "CSA*"
    end

    def [](index)
      @hash[index]
    end

    def []=(index, value)
      @hash[index] = value
    end
  end
end

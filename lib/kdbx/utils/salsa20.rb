class Kdbx::Salsa20
  def initialize(key = nil, iv = nil)
    self.iv = iv unless iv.nil?
    self.key = key unless key.nil?
    reset
  end

  attr_reader :iv
  def iv=(bytes)
    return @iv = bytes.b if bytes.bytesize == 8
    fail ArgumentError, "iv must be 8 bytes"
  end

  attr_reader :key
  def key=(bytes)
    return @key = bytes.b if bytes.bytesize == 16
    return @key = bytes.b if bytes.bytesize == 32
    fail ArgumentError, "key must be 16 or 32 bytes"
  end

  def reset
    @n, @i = 0, 63
    nil
  end

  def update(data)
    setup_keyparts
    data.bytes.map! do |byte|
      if @i == 63 then rehash
      else @i += 1 end
      byte ^ @block[@i]
    end.pack("C*")
  end

  alias :encrypt :update
  alias :decrypt :update

  private

  def setup_keyparts
    if @key.bytesize == 16
      @keypart1 = "expa" + @key + "nd 1" + @iv
      @keypart2 = "6-by" + @key + "te k"
    else
      @keypart1 = "expa" + @key.byteslice(0, 16) + "nd 3" + @iv
      @keypart2 = "2-by" + @key.byteslice(16, 16) + "te k"
    end
  end

  def rehash
    a = (@keypart1 + [@n].pack("Q<") + @keypart2).unpack("L<*")
    z = a.clone
    10.times { colround a; rowround a }
    16.times { |i| z[i] = (a[i] + z[i]) & 0xFFFFFFFF }
    @block = z.pack("L<*").bytes; @i = 0; @n += 1
  end

  def colround(x)
    x[0], x[4], x[8], x[12] = quarterround(x[0], x[4], x[8], x[12])
    x[5], x[9], x[13], x[1] = quarterround(x[5], x[9], x[13], x[1])
    x[10], x[14], x[2], x[6] = quarterround(x[10], x[14], x[2], x[6])
    x[15], x[3], x[7], x[11] = quarterround(x[15], x[3], x[7], x[11])
    return nil
  end

  def rowround(y)
    y[0], y[1], y[2], y[3] = quarterround(y[0], y[1], y[2], y[3])
    y[5], y[6], y[7], y[4] = quarterround(y[5], y[6], y[7], y[4])
    y[10], y[11], y[8], y[9] = quarterround(y[10], y[11], y[8], y[9])
    y[15], y[12], y[13], y[14] = quarterround(y[15], y[12], y[13], y[14])
    return nil
  end

  def quarterround(y0, y1, y2, y3)
    fo = (y0 + y3) & 0xFFFFFFFF
    fo = (fo << 7) | (fo >> 25)
    z1 = fo & 0xFFFFFFFF ^ y1
    fo = (z1 + y0) & 0xFFFFFFFF
    fo = (fo << 9) | (fo >> 23)
    z2 = fo & 0xFFFFFFFF ^ y2
    fo = (z2 + z1) & 0xFFFFFFFF
    fo = (fo << 13) | (fo >> 19)
    z3 = fo & 0xFFFFFFFF ^ y3
    fo = (z3 + z2) & 0xFFFFFFFF
    fo = (fo << 18) | (fo >> 14)
    z0 = fo & 0xFFFFFFFF ^ y0
    return z0, z1, z2, z3
  end
end

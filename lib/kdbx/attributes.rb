require "base64"
require "rexml/document"

class Kdbx # :nodoc:
  attr_reader :password
  def password=(str)
    @password = str == nil ? "" : sha256(str)
  end

  attr_reader :keyfile
  def keyfile=(str)
    @keyfile = str == nil ? nil : File.absolute_path(str)
  end

  def credential
    cred = password || String.new
    return cred if keyfile == nil
    data = IO.read keyfile
    if !data.valid_encoding?
      return cred + sha256(data)
    end
    if data.bytesize == 32
      return cred + data
    end
    if data =~ /\A\h{64}\z/
      data = [data].pack("H*")
      return cred + data
    end
    begin
      xpath = "/KeyFile/Key/Data"
      tnd = REXML::Document.new(data).get_text(xpath)
      cred + Base64.decode64(tnd.to_s)
    rescue REXML::ParseException
      cred + sha256(data)
    end
  end

  attr_accessor :header

  def compressionflags
    @header[3].unpack("L").first
  end

  def compressionflags=(flag)
    @header[3] = [flag].pack("L")
  end

  def masterseed
    @header[4]
  end

  def transformseed
    @header[5]
  end

  def transformrounds
    @header[6].unpack("Q").first
  end

  def transformrounds=(num)
    @header[6] = [num].pack("Q")
  end

  def encryptioniv
    @header[7]
  end

  def protectedstreamkey
    @header[8]
  end

  def streamstartbytes
    @header[9]
  end

  def innerrandomstreamid
    @header[10].unpack("L").first
  end

  def innerrandomstreamid=(id)
    @header[10] = [id].pack("L")
  end

  attr_accessor :content

  def inspect
    super
  end

  private

  def nonce
    "\xE8\x30\x09\x4B\x97\x20\x5D\x2A".b
  end
end

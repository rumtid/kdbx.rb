require "base64"
require "rexml/document"

class Kdbx
  attr_reader :password
  def password=(str)
    @password = str == nil ? "" : sha256(str)
  end

  attr_reader :keyfile
  def keyfile=(str)
    @keyfile = File.absolute_path str
  end

  def credential
    secrets = String.new
    secrets << password if password
    if keyfile
      data = File.read keyfile
      if [32, 64].include? data.bytesize
        secrets << data
      else
        begin
          doc = REXML::Document.new data
          ele = doc.elements["/KeyFile/Key/Data"]
          secrets << Base64.decode64(ele.text)
        rescue REXML::ParseException
          secrets << sha256(data)
        end
      end
    end
    secrets
  end

  attr_accessor :header

  def compressionflags
    @header[3].unpack("L").first
  end

  def compressionflags=(flag)
    @header[3] = [flag].pack("L")
  end

  def zipped?
    compressionflags == 1
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
end

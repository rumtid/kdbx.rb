require "kdbx/attributes"
require "kdbx/encryption"
require "kdbx/headers"
require "kdbx/payload"
require "kdbx/version"

class Kdbx
  include Attributes
  include Encryption

  def initialize(filename)
    @version = Version.new
    @headers = Headers.new
    @payload = Payload.new
    self.filename = filename
  end

  def load
    File.open filename do |kdbxfile|
      @version.load kdbxfile
      @headers.load kdbxfile
      data = StringIO.new decrypt kdbxfile.read
      data.seek streamstartbytes.bytesize
      @payload.load data
      @payload[0] = unwrap @payload[0]
    end
  end

  def save
    File.open filename, "w" do |kdbxfile|
      @version.save kdbxfile
      @headers.save kdbxfile
      @payload[0] = wrap @payload[0]
      data = @payload.save
      data = streamstartbytes + data
      kdbxfile.write encrypt data
    end
  end
end

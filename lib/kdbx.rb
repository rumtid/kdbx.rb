require "kdbx/version"
require "kdbx/attributes"
require "kdbx/encryption"
require "kdbx/wrapper"
require "kdbx/header"

class Kdbx
  include Attributes
  include Encryption

  def initialize(filename = nil, **opts)
    super()
    if filename == nil
      @header   = Header.new
      @carriage = Carriage.new
    else
      self.filename = filename
      self.password = opts[:password] if opts.has_key? :password
      self.keyfile  = opts[:keyfile]  if opts.has_key? :keyfile
      load
    end
  end

  def load
    file = File.open filename, "rb"
    @header = Header.load file
    decode_content file.read
    self
  ensure
    file.close
  end

  def save
    File.open filename, "wb" do |file|
      @header.save file
      encode_content file
    end
    self
  end
end

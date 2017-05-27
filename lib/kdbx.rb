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
      @header  = Header.new
      @content = String.new
    else
      self.filename = filename
      self.password = opts[:password] if opts.has_key? :password
      self.keyfile  = opts[:keyfile]  if opts.has_key? :keyfile
      load
    end
  end

  def load
    File.open filename, "rb" do |file|
      @header = Header.load file
      decode_content file.read
    end
    self
  end

  def save(name = nil)
    filename = name unless name == nil
    File.open filename, "wb" do |file|
      @header.save file
      file.write encode_content
    end
    self
  end
end

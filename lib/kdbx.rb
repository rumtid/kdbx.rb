require "kdbx/attributes"
require "kdbx/errors"
require "kdbx/header"
require "kdbx/crypto"
require "kdbx/version"

class Kdbx
  def self.open(filename, **options)
    new(**options).tap do |kdbx|
      File.open filename, "rb" do |file|
        kdbx.header = Header.load file
        kdbx.decrypt_content file.read
      end
    end
  end

  def initialize(**options)
    @password = @keyfile = nil
    @header, @content = Header.new, String.new
    self.password = options[:password] if options.has_key? :password
    self.keyfile  = options[:keyfile]  if options.has_key? :keyfile
  end

  def save(filename)
    secure_write filename do |file|
      file.write header.dump
      file.write encrypt_content
    end
    true
  end

  private

  def secure_write(name)
    name  = File.absolute_path name
    index = -1 - File.extname(name).length
    temp  = 1.step do |i|
      t = name.dup.insert index, ".#{i}"
      break t unless File.exist? t
    end
    begin
      File.open(temp, "wb") { |file| yield file }
      File.rename temp, name
    ensure
      File.delete temp if File.exist? temp
    end
  end
end

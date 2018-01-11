require "kdbx/attributes"
require "kdbx/errors"
require "kdbx/header"
require "kdbx/crypto"
require "kdbx/version"

class Kdbx
  def initialize(filename, **credentials)
    self.password = credentials[:password]
    self.keyfile  = credentials[:keyfile]

    File.open filename, "rb" do |file|
      @header = Header.load file
      decrypt_content file.read
    end
  end


  def save(filename)
    secure_write filename do |file|
      file.write header.dump
      file.write encrypt_content
    end
    self
  end

  private

  def secure_write(filename)
    origin = File.absolute_path filename
    middle = -1 - File.extname(origin).length
    buffer = 1.step do |i|
      b = origin.dup.insert middle, ".#{i}"
      break b unless File.exist? b
    end

    begin
      File.open(buffer, "wb") { |f| yield f }
      File.rename buffer, origin
    ensure
      File.delete buffer if File.exist? buffer
    end
  end
end

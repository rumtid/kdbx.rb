require "kdbx/attributes"
require "kdbx/errors"
require "kdbx/header"
require "kdbx/crypto"
require "kdbx/version"
require "kdbx/document"

class Kdbx

  ##
  # Open kdbx file from the given +filename+. Optional parameter +credentials+
  # are as follows:
  #
  # * +password+
  # * +keyfile+
  #
  # For example
  #   kdbx = Kdbx.new("example.kdbx", password: "pass", keyfile: "key.jpg")

  def initialize(filename, **credentials)
    self.password = credentials[:password]
    self.keyfile  = credentials[:keyfile]

    File.open filename, "rb" do |file|
      @header = Header.load file
      decrypt_content file.read
    end
  end

  ##
  # Verify itself and write to +filename+

  def save(filename)
    secure_write filename do |file|
      head = header.dump
      file.write head
      @document.send :headerhash=, sha256(head)
      file.write encryption
    end
    self
  end

  private

  ##
  # Stop saving when error occurs, keep the old file.

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

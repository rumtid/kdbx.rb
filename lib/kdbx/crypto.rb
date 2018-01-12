require "zlib"
require "openssl"
require "salsa20"
require "rexml/document"

class Kdbx # :nodoc:
  def encrypt_content
    if innerrandomstreamid == 2
      cipher = Salsa20.new sha256(protectedstreamkey), nonce
      data = @document.to_xml cipher
    else
      data = @document.to_xml
    end
    data = gzip data if compressionflags == 1
    encrypt streamstartbytes + encode(data)
  end

  def decrypt_content(data)
    data = decrypt data.to_s
    if data.start_with? streamstartbytes
      size = streamstartbytes.bytesize
      data = data.byteslice size..-1
    else
      fail KeyError, "wrong password or keyfile"
    end
    data = decode data
    data = gunzip data if compressionflags == 1
    if innerrandomstreamid == 2
      cipher = Salsa20.new sha256(protectedstreamkey), nonce
      @document = Document.new data, cipher
    else
      @document = Document.new data
    end
  end

  private

  def sha256(data)
    OpenSSL::Digest::SHA256.digest data
  end

  def masterkey
    cipher = OpenSSL::Cipher.new("AES-256-ECB").encrypt
    cipher.key, key = transformseed, sha256(credential)
    transformrounds.times { key = cipher.update key }
    sha256(masterseed + sha256(key))
  end

  def encrypt(data)
    cipher = OpenSSL::Cipher.new("AES-256-CBC").encrypt
    cipher.iv, cipher.key = encryptioniv, masterkey
    cipher.update(data) + cipher.final
  end

  def decrypt(data)
    cipher = OpenSSL::Cipher.new("AES-256-CBC").decrypt
    cipher.iv, cipher.key = encryptioniv, masterkey
    cipher.update(data) + cipher.final
  rescue OpenSSL::Cipher::CipherError
    fail KeyError, "wrong password or keyfile"
  end

  def encode(data)
    StringIO.new.binmode.tap do |io|
      io.write "\x00" * 4 + sha256(data)
      io.write [data.bytesize].pack("L<")
      io.write data + "\x01" + "\x00" * 39
    end.string
  end

  def decode(data)
    io = StringIO.new.binmode
    dt = StringIO.new data
    loop do
      t = dt.readpartial 40
      (hash, size) = t.unpack("x4a32L<")
      break io.string if size == 0
      block = dt.readpartial size
      if sha256(block) != hash
        fail "broken file"
      else
        io.write block
      end
    end
  rescue TypeError, EOFError
    fail ParseError, "truncated payload"
  end

  def gzip(data)
    StringIO.open do |io|
      gz = Zlib::GzipWriter.new io.binmode
      gz.write data; gz.close; io.string
    end
  end

  def gunzip(data)
    StringIO.open data do |io|
      gz = Zlib::GzipReader.new io
      [gz.read, gz.close].first
    end
  rescue Zlib::GzipFile::Error => e
    fail ParseError, e.message
  end

  class Salsa20 # :nodoc:
    def initialize(key, iv)
      @cipher = ::Salsa20.new key, iv
      update_block
    end

    def update(data)
      data = data.bytes
      data.map! do |byte|
        if @index == 64
          update_block
        end

        b = @block.getbyte @index
        @index = @index + 1

        byte ^ b
      end
      data.pack("C*")
    end

    private

    def update_block
      @block = @cipher.encrypt "\x00" * 64
      @index = 0
    end
  end
end

require "zlib"
require "base64"
require "openssl"
require "salsa20"
require "rexml/document"

class Kdbx # :nodoc:
  def encrypt_content
    data = @content.to_s
    data = obfuscate data if innerrandomstreamid == 2
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
    data = reverse data if innerrandomstreamid == 2
    @content = data
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

  def sequence
    cipher = Salsa20.new sha256(protectedstreamkey), nonce
    Enumerator.new do |e|
      loop { cipher.encrypt("\x00" * 64).each_byte { |b| e << b } }
    end
  end

  def obfuscate(data)
    xpath = "//Value[@Protected='True']"
    doc, seq = REXML::Document.new(data), sequence
    doc.each_element xpath do |ele|
      t = ele.texts.join.bytes
      t.map! { |b| b ^ seq.next }
      t = Base64.encode64 t.pack("C*")
      ele.text = t.strip
    end
    doc.to_s
  rescue REXML::ParseException => e
    fail FormatError, e.message
  end

  def reverse(data)
    xpath = "//Value[@Protected='True']"
    doc, seq = REXML::Document.new(data), sequence
    doc.each_element xpath do |ele|
      t = Base64.decode64(ele.texts.join).bytes
      ele.text = t.map! { |b| b ^ seq.next }.pack("C*")
    end
    doc.to_s
  rescue REXML::ParseException => e
    fail ParseError, e.message
  end
end

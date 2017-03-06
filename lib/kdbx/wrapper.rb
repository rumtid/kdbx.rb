require "base64"
require "openssl"
require "rexml/document"

module Kdbx::Wrapper
  XPATH = "//Value[@Protected='True']"

  module_function

  def unwrap(data)
    stream  = StringIO.new data
    payload = String.new
    loop do
      head = stream.readpartial 40
      id, hash, size = head.unpack "La32L"
      break if size == 0
      part = stream.readpartial size
      payload << part
    end
    payload
  end

  def wrap(data)
    data = String.new
    data << "\x00\x00\x00\x00"
    data << OpenSSL::Digest::SHA256.digest(data)
    data << [data.bytesize].pack("L") << data
    data << "\x01\x00\x00\x00"
    data << "\x00" * 36
    data
  end

  def pieces(doc)
    doc.elements.to_a(XPATH).map(&:text).compact
  end

  def expose(data)
    doc = REXML::Document.new data
    ciphertext = pieces(doc).map do |t|
      Base64.decode64 t
    end
    plaintext = yield ciphertext.join
    doc.elements.each XPATH do |e|
      next if e.text == nil
      size = ciphertext.shift.bytesize
      e.text = plaintext.byteslice 0, size
      plaintext = plaintext.byteslice size..-1
    end
    doc.to_s
  end

  def protect(data)
    doc = REXML::Document.new data
    plaintext = pieces doc
    ciphertext = yield plaintext.join
    doc.elements.each XPATH do |e|
      next if e.text == nil
      size = plaintext.shift.bytesize
      text = ciphertext.byteslice 0, size
      ciphertext = ciphertext.byteslice size..-1
      e.text = Base64.encode64 text
    end
    doc.to_s
  end
end

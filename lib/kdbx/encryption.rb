require "zlib"
require "base64"
require "openssl"
require "salsa20"
require "rexml/document"

class Kdbx
  module Encryption
    XPATH = "//Value[@Protected='True']"

    private

    def wrap(data)
      if innerrandomstreamid == 2
        doc = REXML::Document.new data
        plain = doc.elements.to_a(XPATH).map(&:text)
        value = salsa20.encrypt plain.join
        doc.elements.each_with_index XPATH do |e, i|
          size   = plain.shift.bytesize
          e.text = value.byteslice 0, size
          value  = value.byteslice size..-1
        end
        data = doc.to_s
      end
      if compressionflags == 1
        data = Zlib.gzip data
      end
      data
    end

    def unwrap(data)
      if compressionflags == 1
        data = Zlib.gunzip data
      end
      if innerrandomstreamid == 2
        doc = REXML::Document.new data
        value = doc.elements.to_a(XPATH).map do |e|
          Base64.decode64 e.text
        end
        plain = salsa20.decrypt value.join
        doc.elements.each_with_index XPATH do |e, i|
          size   = value.shift.bytesize
          e.text = plain.byteslice 0, size
          plain  = plain.byteslice size..-1
        end
        data = doc.to_s
      end
      data
    end

    def sha256(data)
      OpenSSL::Digest::SHA256.digest data
    end

    def salsa20
      iv = ["E830094B97205D2A"].pack "H*"
      Salsa20.new sha256(protectedstreamkey), iv
    end

    def masterkey
      cipher = OpenSSL::Cipher.new("AES-256-ECB").encrypt
      cipher.key, data = transformseed, sha256(password)
      transformrounds.times { data = cipher.update data }
      return sha256(masterseed + sha256(data))
    end

    def encrypt(payload)
      cipher = OpenSSL::Cipher.new("AES-256-CBC").encrypt
      cipher.iv, cipher.key = encryptioniv, masterkey
      cipher.update(payload) + cipher.final
    end

    def decrypt(payload)
      cipher = OpenSSL::Cipher.new("AES-256-CBC").decrypt
      cipher.iv, cipher.key = encryptioniv, masterkey
      cipher.update(payload) + cipher.final
    end
  end
end

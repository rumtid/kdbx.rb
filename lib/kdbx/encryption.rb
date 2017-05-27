require "zlib"
require "openssl"
require "salsa20"

class Kdbx
  module Encryption
    private

    def sha256(data)
      OpenSSL::Digest::SHA256.digest data
    end

    def salsa20
      key = sha256 protectedstreamkey
      Salsa20.new key, "\xE8\x30\x09\x4B\x97\x20\x5D\x2A"
    end

    def masterkey
      cipher = OpenSSL::Cipher.new("AES-256-ECB").encrypt
      cipher.key, data = transformseed, sha256(credential)
      transformrounds.times { data = cipher.update data }
      sha256(masterseed + sha256(data))
    end

    def encrypt(data)
      cipher = OpenSSL::Cipher.new("AES-256-CBC").encrypt
      cipher.iv, cipher.key = encryptioniv, masterkey
      cipher.update(streamstartbytes + data) + cipher.final
    end

    def decrypt(data)
      cipher = OpenSSL::Cipher.new("AES-256-CBC").decrypt
      cipher.iv, cipher.key = encryptioniv, masterkey
      data = cipher.update(data) + cipher.final
      unless data.start_with? streamstartbytes
        fail "InvalidKey"
      end
      size = streamstartbytes.bytesize
      return data.byteslice size..-1
    end

    def encode_content
      data = Wrapper.protect @content do |block|
        salsa20.encrypt block
      end if innerrandomstreamid == 2
      data = Zlib.gzip data if zipped?
      data = Wrapper.wrap data
      data = encrypt data
      return data
    end

    def decode_content(data)
      data = decrypt data
      data = Wrapper.unwrap data
      data = Zlib.gunzip data if zipped?
      data = Wrapper.expose data do |block|
        salsa20.decrypt block
      end if innerrandomstreamid == 2
      @content = data
    end
  end
end

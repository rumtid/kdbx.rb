class Kdbx
  module Attributes
    HEADERS = %w[finalheader comment cipherid compressionflags masterseed transformseed transformrounds encryptioniv protectedstreamkey streamstartbytes innerrandomstreamid]

    attr_reader :filename
    def filename=(name)
      @filename = File.absolute_path name
    end

    def password
      @password ||= sha256 ""
    end

    def password=(str)
      @password = sha256 str
    end

    def compressionflags
      @headers[3].unpack("L").first
    end

    def masterseed
      @headers[4]
    end

    def transformseed
      @headers[5]
    end

    def transformrounds
      @headers[6].unpack("Q").first
    end

    def encryptioniv
      @headers[7]
    end

    def protectedstreamkey
      @headers[8]
    end

    def streamstartbytes
      @headers[9]
    end

    def innerrandomstreamid
      @headers[10].unpack("L").first
    end
  end
end

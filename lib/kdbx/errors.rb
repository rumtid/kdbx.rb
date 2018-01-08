class Kdbx
  class KdbxError < StandardError; end
  class FormatError < KdbxError; end
  class ParseError < KdbxError; end
  class KeyError < KdbxError; end
end

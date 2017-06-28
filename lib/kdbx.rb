require "kdbx/attributes"
require "kdbx/version"
require "kdbx/header"
require "kdbx/crypto"

class Kdbx
  def self.open(filename, **options)
    kdbx = new **options
    File.open filename, "rb" do |file|
      kdbx.header = Header.load file
      kdbx.decrypt_content file.read
    end
    return kdbx
  end

  def initialize(**options)
    @header  = Header.new
    @content = String.new
    self.password = options[:password] if options.has_key? :password
    self.keyfile  = options[:keyfile]  if options.has_key? :keyfile
  end

  def save(filename)
    filename = File.absolute_path filename
    swapname = getswapname filename
    begin
      File.open swapname, "wb" do |file|
        file.write header.dump
        file.write encrypt_content
      end
      File.delete filename if File.exist? filename
      File.rename swapname, filename
      true
    ensure
      File.delete swapname if File.exist?(swapname)
    end
    true
  end

  private

  def getswapname(filename)
    version, name, idx = 1, nil, -1 - File.extname(filename).length
    loop do
      name = filename.dup.insert idx, ".#{version}"
      break unless File.exist? name
      version += 1
    end
    name
  end
end

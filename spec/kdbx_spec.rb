require "spec_helper"

RSpec.describe Kdbx do
  it "has a version number" do
    expect( Kdbx::VERSION ).to be_a( String )
  end

  describe "::open" do
    it "accepts null password" do
      kdbx = Kdbx.new file("null_pass.kdbx")
      expect( kdbx.content ).to include( "secret" )
    end

    it "accepts empty password" do
      kdbx = Kdbx.new file("empty_pass.kdbx"), password: ""
      expect( kdbx.content ).to include( "secret" )
    end

    it "accepts 32-byte keyfile" do
      kdbx = Kdbx.new file("32_byte.kdbx"), keyfile: file("32_byte.key")
      expect( kdbx.content ).to include( "secret" )
    end

    it "accepts 64-byte keyfile" do
      kdbx = Kdbx.new file("64_byte.kdbx"), keyfile: file("64_byte.key")
      expect( kdbx.content ).to include( "secret" )
    end

    it "accepts binary keyfile" do
      kdbx = Kdbx.new file("binary_key.kdbx"), keyfile: file("binary_key.key")
      expect( kdbx.content ).to include( "secret" )
    end

    it "accepts both password and keyfile" do
      kdbx = Kdbx.new file("demo.kdbx"), password: "demo", keyfile: file("demo.key")
      expect( kdbx.content ).to include( "secret" )
    end
  end

  describe "#save" do
    TEMPFILE = File.expand_path("../data/temp.kdbx", __FILE__)

    after(:example) { File.delete TEMPFILE if File.exist? TEMPFILE }

    it "saves kdbx file" do
      kdbx = Kdbx.new file("null_pass.kdbx")
      expect{ kdbx.save TEMPFILE }.not_to raise_error
      expect{ Kdbx.new TEMPFILE }.not_to raise_error
    end

    it "keeps old file when error occurred" do
      IO.write TEMPFILE, "records"
      kdbx = Kdbx.new file("null_pass.kdbx")
      allow( OpenSSL::Cipher ).to receive( :new )
      expect{ kdbx.save TEMPFILE }.to raise_error( NoMethodError )
      expect( File.exist? TEMPFILE ).to be_truthy
      expect( IO.read TEMPFILE ).to eql( "records" )
    end
  end

  def file(filename)
    File.expand_path("../data/#{filename}", __FILE__)
  end
end

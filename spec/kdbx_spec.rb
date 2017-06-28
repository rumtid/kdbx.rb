require "spec_helper"

RSpec.describe Kdbx do
  it "has a version number" do
    expect( Kdbx::VERSION ).to be_a( String )
  end

  describe "::open" do
    it "accepts null password" do
      kdbx = Kdbx.open data("null_pass.kdbx")
      expect( kdbx.content ).to include( "secret" )
    end

    it "accepts empty password" do
      kdbx = Kdbx.open data("empty_pass.kdbx"), password: ""
      expect( kdbx.content ).to include( "secret" )
    end

    it "accepts binary keyfile" do
      kdbx = Kdbx.open data("binary_key.kdbx"), keyfile: data("binary_key.key")
      expect( kdbx.content ).to include( "secret" )
    end

    it "accepts both password and keyfile" do
      kdbx = Kdbx.open data("demo.kdbx"), password: "demo", keyfile: data("demo.key")
      expect( kdbx.content ).to include( "secret" )
    end

    def data(filename)
      File.expand_path("../data/#{filename}", __FILE__)
    end
  end

  describe "::new" do
    it "has empty content" do
      expect( Kdbx.new.content ).to eql( String.new )
    end

    it "accepts password as keyword" do
      kdbx = Kdbx.new password: "pass"
      expect( kdbx.password ).to be_a( String )
    end

    it "accepts keyfile as keyword" do
      kdbx = Kdbx.new keyfile: "file"
      expect( kdbx.keyfile ).to be_a( String )
    end
  end

  describe "#save" do
    FILENAME = File.expand_path("../data/saved.kdbx", __FILE__)

    after(:example) { File.delete FILENAME if File.exist? FILENAME }

    it "saves kdbx file" do
      expect{ Kdbx.new.save FILENAME }.not_to raise_error
      expect{ Kdbx.open FILENAME }.not_to raise_error
    end

    it "keeps old file when error occurred" do
      IO.write FILENAME, "records"
      allow( OpenSSL::Cipher ).to receive( :new )
      expect{ Kdbx.new.save FILENAME }.to raise_error( NoMethodError )
      expect( File.exist? FILENAME ).to be_truthy
      expect( IO.read FILENAME ).to eql( "records" )
    end
  end
end

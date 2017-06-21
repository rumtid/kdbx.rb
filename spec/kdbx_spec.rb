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
      expect( Kdbx.new.content ).to eq( String.new )
    end
  end

  describe "#save" do
  end
end

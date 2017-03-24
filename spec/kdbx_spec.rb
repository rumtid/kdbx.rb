require "spec_helper"

RSpec.describe Kdbx do
  def resource(name)
    File.expand_path("../../resource/#{name}", __FILE__)
  end

  def init_from(filename, **opts)
    if opts.has_key? :keyfile
      opts[:keyfile] = resource opts[:keyfile]
    end
    Kdbx.new resource(filename), **opts
  end

  it "has a version number" do
    expect(Kdbx::VERSION).not_to be_nil
  end

  context "when loading file" do
    it "accepts null password" do
      kdbx = init_from "null_pass.kdbx"
      expect(kdbx.content).to include("secret")
    end

    it "accepts empty password" do
      kdbx = init_from "empty_pass.kdbx", password: ""
      expect(kdbx.content).to include("secret")
    end

    it "accepts binary keyfile" do
      kdbx = init_from "binary_key.kdbx", keyfile: "binary_key.key"
      expect(kdbx.content).to include("secret")
    end

    it "accepts both password and keyfile" do
      kdbx = init_from "demo.kdbx", password: "demo", keyfile: "demo.key"
      expect(kdbx.content).to include("secret")
    end
  end

  context "when saving database" do
    it "saves entire content" do
      result = StringIO.new
      allow(File).to receive(:open).and_call_original
      kdbx = init_from "empty_pass.kdbx", password: ""
      origin = kdbx.content
      expect(File).to receive(:open).and_yield(result)
      kdbx.save
      expect do
        kdbx = init_from "empty_pass.kdbx", password: ""
      end.not_to raise_error
      expect(kdbx.content).to eq(origin)
    end

    it "create empty content"
  end
end

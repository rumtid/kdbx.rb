require "spec_helper"

RSpec.describe Kdbx do
  it "has a version number" do
    expect(Kdbx::VERSION).not_to be_nil
  end

  context "when loading file" do
    def resource(name)
      File.expand_path("../../resource/#{name}", __FILE__)
    end

    def init_from(filename, **opts)
      if opts.has_key? :keyfile
        opts[:keyfile] = resource opts[:keyfile]
      end
      Kdbx.new resource(filename), **opts
    end

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
    it "create empty content" do
      kdbx, file = Kdbx.new, StringIO.new
      allow(File).to receive(:open).and_yield(file)
      expect { kdbx.save }.not_to raise_error
      file.pos = 0
      expect(Kdbx.new("").content).to eq("")
    end
  end
end

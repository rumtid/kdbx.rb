require "spec_helper"

RSpec.describe Kdbx::Salsa20 do
  IV  = Base64.decode64 "Gc/bOqDW+Lk="
  KEY = Base64.decode64 "w2QftWQAQOdt7yxE6XAiacH40FmZcikR9dVg5mM0nuo="

  let(:engine) { Kdbx::Salsa20.new KEY, IV }

  it "produce quarterround" do
    input  = [0x00000000, 0x00000000, 0x00000000, 0x00000000]
    output = [0x00000000, 0x00000000, 0x00000000, 0x00000000]
    expect(engine.send(:quarterround, *input)).to eq(output)
    input  = [0x00000001, 0x00000000, 0x00000000, 0x00000000]
    output = [0x08008145, 0x00000080, 0x00010200, 0x20500000]
    expect(engine.send(:quarterround, *input)).to eq(output)
    input  = [0x00000000, 0x00000001, 0x00000000, 0x00000000]
    output = [0x88000100, 0x00000001, 0x00000200, 0x00402000]
    expect(engine.send(:quarterround, *input)).to eq(output)
    input  = [0x00000000, 0x00000000, 0x00000001, 0x00000000]
    output = [0x80040000, 0x00000000, 0x00000001, 0x00002000]
    expect(engine.send(:quarterround, *input)).to eq(output)
    input  = [0x00000000, 0x00000000, 0x00000000, 0x00000001]
    output = [0x00048044, 0x00000080, 0x00010000, 0x20100001]
    expect(engine.send(:quarterround, *input)).to eq(output)
    input  = [0xe7e8c006, 0xc4f9417d, 0x6479b4b2, 0x68c67137]
    output = [0xe876d72b, 0x9361dfd5, 0xf1460244, 0x948541a3]
    expect(engine.send(:quarterround, *input)).to eq(output)
    input  = [0xd3917c5b, 0x55f1c407, 0x52a58a7a, 0x8f887a3b]
    output = [0x3e2f308c, 0xd90a8f36, 0x6ab2a923, 0x2883524c]
    expect(engine.send(:quarterround, *input)).to eq(output)
  end

  it "produce rowround" do
    input  = [0x08521bd6, 0x1fe88837, 0xbb2aa576, 0x3aa26365,
      0xc54c6a5b, 0x2fc74c2f, 0x6dd39cc3, 0xda0a64f6, 0x90a2f23d,
      0x067f95a6, 0x06b35f61, 0x41e4732e, 0xe859c100, 0xea4d84b7,
      0x0f619bff, 0xbc6e965a]
    output = [0xa890d39d, 0x65d71596, 0xe9487daa, 0xc8ca6a86,
      0x949d2192, 0x764b7754, 0xe408d9b9, 0x7a41b4d1, 0x3402e183,
      0x3c3af432, 0x50669f96, 0xd89ef0a8, 0x0040ede5, 0xb545fbce,
      0xd257ed4f, 0x1818882d]
    engine.send(:rowround, input)
    expect(input).to eq(output)
  end

  it "produce colround" do
    input  = [0x08521bd6, 0x1fe88837, 0xbb2aa576, 0x3aa26365,
      0xc54c6a5b, 0x2fc74c2f, 0x6dd39cc3, 0xda0a64f6, 0x90a2f23d,
      0x067f95a6, 0x06b35f61, 0x41e4732e, 0xe859c100, 0xea4d84b7,
      0x0f619bff, 0xbc6e965a]
    output = [0x8c9d190a, 0xce8e4c90, 0x1ef8e9d3, 0x1326a71a,
      0x90a20123, 0xead3c4f3, 0x63a091a0, 0xf0708d69, 0x789b010c,
      0xd195a681, 0xeb7d5504, 0xa774135c, 0x481c2027, 0x53a8e4b5,
      0x4c1f89c5, 0x3f78c9c8]
    engine.send(:colround, input)
    expect(input).to eq(output)
  end

  it "encrypt blocks" do
    input  = Base64.decode64("7J6xm9Q2kGxIF4pzMOJk5VE0d+m+l3tEBNt2N+d
      py9A/56a+HMnuiINF8MxhlmBtPW9OmipZEcm9eWc7/rDM1g==")
    output = Base64.decode64("0Fy9JG4wAsLjNSxLcwggUKXVVscydnRKKo/c9hQ
      a5OVpD9qKRxvwY6sn4iHpKrCiPV4odTdRaWgr8pl6v0kRig==")
    99.times { input = engine.encrypt input }
    expect(input).to eq(output)
  end

  it "decrypt blocks" do
    input  = Base64.decode64("0Fy9JG4wAsLjNSxLcwggUKXVVscydnRKKo/c9hQ
      a5OVpD9qKRxvwY6sn4iHpKrCiPV4odTdRaWgr8pl6v0kRig==")
    output = Base64.decode64("7J6xm9Q2kGxIF4pzMOJk5VE0d+m+l3tEBNt2N+d
      py9A/56a+HMnuiINF8MxhlmBtPW9OmipZEcm9eWc7/rDM1g==")
    99.times { input = engine.decrypt input }
    expect(input).to eq(output)
  end
end

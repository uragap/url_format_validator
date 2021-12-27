RSpec.describe 'URL format validation using Active Record' do
  before(:all) do
    ActiveRecord::Schema.define(version: 1) do
      create_table :models, force: true do |table|
        table.column :url, :string
      end
    end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table(:models)
  end

  let!(:model) { Model.new }

  [
    'http://example.com',
    'https://example.com',
    'http://d124.example.com',
    'http://333.example.com',
    'http://example345.com',
    'http://example.com/',
    'http://www.example.com/',
    'http://sub.domain.example.com/',
    'http://bbc.co.uk',
    'http://example.com?foo',
    'http://example.com?url=http://example.com',
    'http://example.com:8000',
    'http://www.sub.example.com/page.html?foo=bar&baz=%23#anchor',
    'http://example.com/~user',
    'http://example.xy',
    'http://example.museum',
    'http://1.0.255.249',
    'http://1.2.3.4:80',
    'HttP://example.com',
    'https://example.com',
    'http://xn--rksmrgs-5wao1o.nu', # Punycode
    'http://example.com.',          # Explicit TLD root period
    'http://example.com./foo',
    'http://example.cancerresearch',
    'http://example.solutions',
    'http://_test.example.com',
    'http://test.exa_mple.com',
    'http://кириллица.рф',
    'http://тест.бел',
    'http://test.қаз',
    'http://example.გე',
    'http://foo_bar.com',
    'http://[2001:0db8:85a3:0000:0000:8a2e:0370:7334]',
    'http://[2001:DB8::1]',
    'http://[::ffff:c000:0280]',
    'http://1k.by',
    'http://11.22.com',
    'http://1.1.1.com',
    'http://2.2.2.2.com',
    'http://user:pass@example.com',
    'http://user:@example.com',
    'http://u:u:u@example.com',  # password has : inside
    'http://u@example.com'       # userinfo contains only username
  ].each do |url|
    it "allows url #{url}" do
      model.url = url
      expect(model).to be_valid
    end
  end

  [
    nil, 1, "", " ", "url",
    "www.example.com",                            # without scheme
    'http://',                                    # only a scheme
    'http:/',                                     # without a host
    "http://ex ample.com",                        # space in the hostname
    "http://example.com/foo bar",
    "http://example.com/some/? doodads=ok",       # space in the querystring
    'http://256.0.0.1',                           # wrong number in ip
    'http://r?ksmorgas.com',                      # wrong symbol in the hostname
    'ftp://localhost',                            # wrong scheme
    "http://example",                             # without top level domain
    "http://example.c",                           # too short TLD length
    'http://example.toolongtlddddddddddddddddddddddddddddddddddddddddddddddddddddddd', # A TLD length is 64 characters
    ["https://foo.com", "https://bar.com"],       # an array of urls
    'http://[2001:0db8:85a3:0000:0000:8a2e:7334]' # 7 blocks in ipv6 address
  ].each do |url|
    it "does not allow url #{url}" do
      model.url = url
      expect(model).not_to be_valid
    end
  end

  it 'returns a default error message' do
    model.url = 'http://invalid'
    model.valid?
    expect(model.errors[:url]).to eq(['is not a valid URL'])
  end

  context 'with no_local: true' do
    let!(:model) { ModelNoLocal.new }

    [
      'http://127.1.1.1',
      'http://10.1.1.1',
      'http://172.20.1.1',
      'http://192.168.1.1',
      'http://0.0.0.0',
      'http://255.255.255.255',
      'http://169.254.0.0',
      'http://example.local',
      'http://example.test.localhost',
      'http://example.intranet',
      'http://example.internal',
      'http://example.corp',
      'http://example.home',
      'http://example.lan',
      'http://example.private',
      'http://localhost'
    ].each do |url|
      it "does not allow local url #{url}" do
        model.url = url
        expect(model).not_to be_valid
      end
    end
  end

  context 'with allow_nil: true' do
    let!(:model) { ModelAllowNil.new }

    it 'allows nil url' do
      model.url = nil
      expect(model).to be_valid
    end

    it 'does not allow blank url' do
      model.url = ''
      expect(model).not_to be_valid
    end
  end

  context 'with allow_blank: true' do
    let!(:model) { ModelAllowBlank.new }

    it 'allows blank url' do
      model.url = ''
      expect(model).to be_valid
    end

    it 'allows nil url' do
      model.url = nil
      # require 'pry-byebug'; binding.pry
      expect(model).to be_valid
    end
  end

  context 'with custom schemes' do
    let!(:model) { ModelCustomScheme.new }
    let(:url) { 'ftp://example.com' }

    it 'allows url with custom scheme' do
      model.url = url
      expect(model).to be_valid
    end
  end

  context 'with public_suffix: true' do
    let!(:model) { ModelPublicSuffix.new }

    [
      'http://example.com',
      'http://d124.example.com',
      'http://333.example.com',
      'http://example345.com',
      'http://www.example.com/',
      'http://sub.domain.example.com/',
      'http://bbc.co.uk',
      'http://www.sub.example.com',
      'http://example.museum',
      'http://xn--rksmrgs-5wao1o.nu', # Punycode
      'http://example.com.',          # Explicit TLD root period
      'http://example.cancerresearch',
      'http://example.solutions',
      'http://_test.example.com',
      'http://test.exa_mple.com',
      'http://кириллица.рф',
      'http://тест.бел',
      'http://test.қаз',
      'http://example.გე',
      'http://foo_bar.com',
      'http://1k.by',
      'http://11.22.com',
      'http://1.1.1.com',
      'http://2.2.2.2.com'
    ].each do |url|
      it "allows url #{url}" do
        model.url = url
        expect(model).to be_valid
      end
    end

    context 'when private domain' do
      let(:url) { 'http://blogspot.com' }

      it 'does not allow' do
        model.url = url
        expect(model).not_to be_valid
      end
    end

    context 'when url with not listed TLD' do
      let(:url) { 'http://example.tldnotlisted' }

      it 'does not allow' do
        model.url = url
        expect(model).not_to be_valid
      end
    end
  end
end

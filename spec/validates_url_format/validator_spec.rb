RSpec.describe 'URL format validation' do
  let(:url) { 'http://example.com' }
  let(:options) { {} }

  subject { ValidatesUrlFormat::Validator.new(options).validate(url) }

  it 'returns success is_valid status and valid message' do
    expect(subject).to eq([true, :valid_url])
  end

  context 'when wrong url' do
    let(:url) { 'ftp://example.com' }

    it 'returns failed is_valid status and error message' do
      expect(subject).to eq([false, :invalid_scheme])
    end
  end

  context 'when options passed' do
    let(:url) { 'ftp://example.com' }
    let(:options) { { schemes: ['ftp'] } }

    it 'validates considering options' do
      expect(subject).to eq([true, :valid_url])
    end
  end
end

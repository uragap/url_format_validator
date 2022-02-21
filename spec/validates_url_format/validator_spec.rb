RSpec.describe 'URL format validation' do
  let(:url) { 'http://example.com' }
  let(:options) { {} }

  subject { ValidatesUrlFormat::Validator.new(options).validate(url) }

  it 'returns success valid status and valid message' do
    expect(subject).to eq({ valid: true, message: :valid_url })
  end

  context 'when wrong url' do
    let(:url) { 'ftp://example.com' }

    it 'returns failed valid status and error message' do
      expect(subject).to eq({ valid: false, message: :invalid_scheme })
    end
  end

  context 'when options passed' do
    let(:url) { 'ftp://example.com' }
    let(:options) { { schemes: ['ftp'] } }

    it 'validates considering options' do
      expect(subject).to eq({ valid: true, message: :valid_url })
    end
  end

  context 'nil value' do
    let(:url) { nil }

    it 'returns failed valid status and error message' do
      expect(subject).to eq({ valid: false, message: :nil_or_blank_url })
    end
  end
end

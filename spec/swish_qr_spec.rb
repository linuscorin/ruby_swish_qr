require 'spec_helper'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

describe SwishQr do
  describe '#invalid_empty_request' do
    it 'Should raise an exception' do
      expect{SwishQr.new({})}.to raise_error(ArgumentError, /Invalid format/)
    end
  end

  describe '#invalid_png_request_without_size' do
    it 'Should raise an exception' do
      expect{SwishQr.new({format: 'png'})}.to raise_error(ArgumentError, /Size.*must be specified/)
    end
  end

  describe '#invalid_transparent_JPEG_request' do
    it 'Should raise an exception' do
      expect{SwishQr.new({format: 'jpg', size: 300, transparent: true})}.to raise_error(ArgumentError, /JPEG.*transparent/)
    end
  end

  describe '#border_too_big' do
    it 'Should raise an exception' do
      expect{SwishQr.new({format: 'jpg', size: 300, border: 5})}.to raise_error(ArgumentError, /Max border/)
    end
  end

  describe '#empty_svg', :vcr do
    subject { SwishQr.new(format: 'svg') }
    it 'Should have a 200 response code' do
      expect(subject.http_response_code).to eq 200
    end

    it 'Should be a successful response' do
      expect(subject.success?).to eq true
    end

    it 'Error should be empty' do
      expect(subject.error).to be_nil
    end

    it 'Request hash should be built correctly' do
      expect(subject.request_hash).to eq ({format: 'svg'})
    end
  end

  describe '#request with editable fields', :vcr do
    subject { SwishQr.new(format: 'svg', size: 300, border: 3, transparent: true, amount: 6789, payee: 1234567890, message: "A test QR code for Swish", editable: [ :message, :payee ] ) }
    it 'Should have a 200 response code' do
      expect(subject.http_response_code).to eq 200
    end

    it 'Should be a successful response' do
      expect(subject.success?).to eq true
    end

    it 'Error should be empty' do
      expect(subject.error).to be_nil
    end

    it 'Message should be as set by caller, and editable' do
      expect(subject.request_hash[:message]).to eq ({ value: "A test QR code for Swish", editable: true })
    end

    it 'Request hash should be built correctly' do
      expect(subject.request_hash).to eq ({format: 'svg', size: 300, border: 3, transparent: true, amount: { value: 6789, editable: false }, payee: { value: 1234567890, editable: true }, message: {value: "A test QR code for Swish", editable: true }})
    end
  end
end

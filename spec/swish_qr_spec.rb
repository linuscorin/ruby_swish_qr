require 'spec_helper'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

describe SwishQr do
  describe '#invalid_png_request', :vcr do
    subject { SwishQr.new({format: 'png'}) }

    it 'Request hash should be built correctly (empty)' do
      expect(subject.request_hash).to eq ({format: 'png'})
    end

    it 'Should have a 400 response code' do
      expect(subject.result.code).to eq 400
    end

  end

  describe '#empty_svg', :vcr do
    subject { SwishQr.new(format: 'svg') }
    it 'Should have a 200 response code' do
      expect(subject.result.code).to eq 200
    end
    it 'Request hash should be built correctly' do
      expect(subject.request_hash).to eq ({format: 'svg'})
    end
  end

  describe '#request with editable fields', :vcr do
    subject { SwishQr.new(format: 'svg', size: 300, border: 3, transparent: true, amount: 6789, payee: 1234567890, message: "A test QR code for Swish", editable: [ :message, :payee ] ) }
    it 'Should have a 200 response code' do
      expect(subject.result.code).to eq 200
    end

    it 'Message should be as set by caller, and editable' do
      expect(subject.request_hash[:message]).to eq ({ value: "A test QR code for Swish", editable: true })
    end

    it 'Request hash should be built correctly' do
      expect(subject.request_hash).to eq ({format: 'svg', size: 300, border: 3, transparent: true, amount: { value: 6789, editable: false }, payee: { value: 1234567890, editable: true }, message: {value: "A test QR code for Swish", editable: true }})
    end
  end
end

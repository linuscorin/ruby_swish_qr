# Interface for generating Swish QR codes
# https://developer.getswish.se/qr-api-manual/4-create-qr-codes-using-swish-qr-code-generator-apis/#4-1-1-prefilled
# https://developer.getswish.se/content/uploads/2017/04/Guide-Swish-QR-code-design-specification_v1.5.pdf

class SwishQr
  require 'httparty'

  SWISH_QR_API_ENDPOINT="https://www.swish.bankgirot.se/qrg-swish/api/v1/prefilled"
  @result = {}
  @request_hash = {}
  @image_format
  attr_accessor :request_hash

  SIMPLE_VALUES = [ :format, :size, :border, :transparent ]
  COMPLEX_VALUES = [ :payee, :amount, :message ]
  VALID_FORMATS = [ 'svg', 'png', 'jpg' ]

  def initialize(args)
    check_args(args)
    @result = HTTParty.post(SWISH_QR_API_ENDPOINT,
      :body => build_request_body(args),
      :headers => { 'Content-Type' => 'application/json' } )
  end

  def image
    @result.body
  end

  def success?
    @result.code == 200
  end

  def http_response_code
    @result.code
  end

  def error
    @result.parsed_response['error']
  end

  def check_args(args)
    raise ArgumentError, "Invalid format: '#{args[:format]}', must specify one of: #{VALID_FORMATS}" unless VALID_FORMATS.include?(args[:format])
    raise ArgumentError, "Size (minimum 300) must be specified for #{args[:format]}" unless (args[:format] == 'svg' || args[:size].to_i >= 300)
    raise ArgumentError, "JPEG can't be transparent" if (args[:format] == 'jpg' && args[:transparent])
    raise ArgumentError, "Max border is 4" if (args[:border].to_i > 4)
  end

  def build_request_body(args)
    @image_format = args[:format]
    @request_hash = get_simple_values_from_args(args)
    @request_hash.merge!(get_complex_values_from_args(args))
    sanitise_amount
    @request_hash.to_json
  end

  def sanitise_amount
    return unless @request_hash[:amount]
    # Delete amount if it's blank / 0, to ensure that the request is valid
    if @request_hash[:amount][:value].to_i == 0
      @request_hash.delete(:amount)
      return
    end
    # This is to support BigDecimal, which would otherwise get misrepresented as a string in the JSON
    @request_hash[:amount][:value] = @request_hash[:amount][:value].to_f unless @request_hash[:amount][:value].is_a?(Integer)
  end

  def get_simple_values_from_args(args)
    args.select{|k,v| SIMPLE_VALUES.include?(k)}
  end

  def get_complex_values_from_args(args)
    ret = {}
    COMPLEX_VALUES.each do |k|
      ret[k] = { value: args[k], editable: ((args[:editable]||[]).include?(k)) } if args[k]
    end
    ret
  end
end

class SwishUri < SwishQr
  def initialize(args)
    build_request_body(args)
  end

  def uri
    "swish://payment?data=#{{version: 1}.merge(@request_hash).to_json}"
  end
end


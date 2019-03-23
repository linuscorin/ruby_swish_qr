# Interface for generating Swish QR codes
# https://developer.getswish.se/qr-api-manual/4-create-qr-codes-using-swish-qr-code-generator-apis/#4-1-1-prefilled
# https://developer.getswish.se/content/uploads/2017/04/Guide-Swish-QR-code-design-specification_v1.5.pdf

class SwishQr
  require 'httparty'

  SWISH_QR_API_ENDPOINT="https://mpc.getswish.net/qrg-swish/api/v1/prefilled"
  @result = {}
  @data_hash = {}
  @image_format
  attr_accessor :data_hash

  SIMPLE_VALUES = [ :format, :size, :border, :transparent ]
  COMPLEX_VALUES = [ :payee, :amount, :message ]
  VALID_FORMATS = [ 'svg', 'png', 'jpg' ]

  def initialize(args)
    check_args(args)
    @result = HTTParty.post(SWISH_QR_API_ENDPOINT,
      :body => build_data_hash(args),
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

  private

  def check_args(args)
    check_format(args)
    check_jpeg_transparency(args)
    check_border(args)
    check_size(args)
  end

  def check_jpeg_transparency(args)
    raise ArgumentError, "JPEG can't be transparent" if (args[:format] == 'jpg' && args[:transparent])
  end

  def check_border(args)
    raise ArgumentError, "Max border is 4" if (args[:border].to_i > 4)
  end

  def check_size(args)
    raise ArgumentError, "Size (minimum 300) must be specified for #{args[:format]}" unless (args[:format] == 'svg' || args[:size].to_i >= 300)
  end

  def check_format(args)
    raise ArgumentError, "Invalid format: '#{args[:format]}', must specify one of: #{VALID_FORMATS}" unless VALID_FORMATS.include?(args[:format])
  end

  def build_data_hash(args)
    @image_format = args[:format]
    @data_hash = get_simple_values_from_args(args)
    @data_hash.merge!(get_complex_values_from_args(args))
    sanitise_amount
    @data_hash.to_json
  end

  def sanitise_amount
    return unless @data_hash[:amount]
    # Delete amount if it's blank / 0, to ensure that the request is valid
    if @data_hash[:amount][:value].to_i == 0
      @data_hash.delete(:amount)
      return
    end
    # This is to support BigDecimal, which would otherwise get misrepresented as a string in the JSON
    @data_hash[:amount][:value] = @data_hash[:amount][:value].to_f unless @data_hash[:amount][:value].is_a?(Integer)
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
    build_data_hash(args)
  end

  def uri
    "swish://payment?data=#{{version: 1}.merge(@data_hash).to_json}"
  end
end


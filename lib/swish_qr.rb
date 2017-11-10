# Interface for generating Swish QR codes
# https://developer.getswish.se/qr-api-manual/4-create-qr-codes-using-swish-qr-code-generator-apis/#4-1-1-prefilled
# https://developer.getswish.se/content/uploads/2017/04/Guide-Swish-QR-code-design-specification_v1.5.pdf

# TODO: Throw exceptions for invalid input: Border > 4, , Size < 300, missing size for formats other than SVG, missing format

class SwishQr
  require 'httparty'
  VERSION="0.0.0"
  RELEASE_DATE="2017-11-09"

  SWISH_QR_API_ENDPOINT="https://www.swish.bankgirot.se/qrg-swish/api/v1/prefilled"
  @result = {}
  @request_hash = {}
  @image_format
  attr_accessor :result, :request_hash

  SIMPLE_VALUES = [ :format, :size, :border, :transparent ]
  COMPLEX_VALUES = [ :payee, :amount, :message ]

  def initialize(args)
    @result = HTTParty.post(SWISH_QR_API_ENDPOINT,
      :body => build_request_body(args),
      :headers => { 'Content-Type' => 'application/json' } )
  end

  def image
    # To make it handle different formats in different ways, maybe have a method for each one, which returns something sensible
    # self.send(@image_format)
    @result.body
  end

  private

  #def svg
  #  @result.body
  #end

  def build_request_body(args)
    @image_format = args[:format]
    @request_hash = get_simple_values_from_args(args)
    @request_hash.merge!(get_complex_values_from_args(args))
    #puts @request_hash
    @request_hash.to_json
  end

  def get_simple_values_from_args(args)
    args.select{|k,v| SIMPLE_VALUES.include?(k)}
  end

  def get_complex_values_from_args(args)
    ret = {}
    COMPLEX_VALUES.each do |k|
      ret[k] = { value: args[k], editable: (args[:editable].include?(k)) } if args[k]
    end
    ret
  end

end

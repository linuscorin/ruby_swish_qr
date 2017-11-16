# Ruby SwishQr / SwishUri
A Ruby Gem for generating Swish QR codes and Swish URIs

# What is it?
Swish is a Swedish mobile payment system.

This gem generates a QR code or URI with encoded recipient, amount, message, and other selected properties.

For QR images, it uses the Swish QR API, and gets an officially branded QR code.

The Swish QR API is documented here:  
https://developer.getswish.se/qr-api-manual/4-create-qr-codes-using-swish-qr-code-generator-apis/#4-1-1-prefilled

Swish URIs are just a URI with payment details, which a user can click on their mobile to open up the payment app.

# Installation
The gem contains both classes, SwishQr and SwishUri
```
gem 'swish_qr', '~> 0.0.3'
bundle
```

```
require 'swish_qr'
```


# Example usage
## Inline SVG
This puts the SVG image within your HTML
### Controller
```ruby
@qr = SwishQr.new(
  editable: [ :message, :amount],
  format: "svg",
  payee: 1234567890,
  amount: 6789,
  message: "Invoice X from Company Y",
)
```
### View
```ruby
- if @qr.success?
  =raw @qr.image
- else
  Problem loading QR image
```

## Render a JPG, which can be loaded from an HTML page
### Controller
```ruby
def render_qr
  @qr = SwishQr.new(
    editable: [ :message, :amount],
    format: "png",
    size: "400",
    payee: 1234567890,
    amount: 6789,
    message: "Invoice X from Company Y",
  )
  if @qr.success?
    send_data(@qr.image, type: 'image/png', disposition: 'inline')
  else
    # Handle error - maybe render a placeholder image?
  end
```

### View
```ruby
=image_tag '/path_for_controller/render_qr.png'
```

# URI Scheme
SwishUri takes the same arguments as SwishQr, except for the image related ones - size/transparent/format/border
```ruby
SwishUri.new({payee: 1234567890, amount: 1234, message: 'Hello, World!'}).uri
```
Generates a URL, such as:  
swish://payment?data={"version":1,"payee":{"value":1234567890,"editable":false},"amount":{"value":1234,"editable":false},"message":{"value":"Hello, World!","editable":false}}

# Options
| Option name | Type | Function | Valid options | required |
| format | string | Sets the image format | jpg, svg, png | yes |
| size | number | Horizontal/vertical image dimension (it's square)| Number >= 300 | for jpg and png |
| transparent | bool | Sets if the image is transparent | true, false, blank (not valid for JPEG) | no |
| border | number | Size of border around image. | number <= 4 | no |
| payee | number | The Swish number of the payee | A valid Swish number | no |
| amount | number | Amount in SEK | A valid amount | no |
| message | string | A prefilled message | Any string | no |
| editable | symbol | Sets which fields are editable in the Swish mobile app | :message, :amount, :payee | no |

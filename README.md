# Ruby SwishQR
A Ruby Gem for generating Swish QR codes

Work in progress. Currently only properly supports SVG, other formats just return binary data, which you would have to process yourself.

# What is it?
Swish is a Swedish mobile payment system.

This gem generates a QR code with encoded recipient, amount, message, and other selected properties.

It uses the Swish QR API, and gets an officially branded QR code.
https://developer.getswish.se/qr-api-manual/4-create-qr-codes-using-swish-qr-code-generator-apis/#4-1-1-prefilled


# Example usage
Controller:
@image = SwishQr.new(
  editable: [ :message, :amount],
  format: "svg",
  payee: 1234567890,
  amount: 6789,
  message: "Invoice X from Company Y",
).image


View:
=raw @image

#!/usr/bin/env ruby
# frozen_string_literal: true

# Converts 256-bit hex-encoded private key to WIF (wallet import format)
# See: https://en.bitcoin.it/wiki/Wallet_import_format

# Code from: https://bhelx.simst.im/articles/generating-bitcoin-keys-from-scratch-with-ruby/

require 'digest'
require 'bitcoin'

hex_string = ARGV[0]

if hex_string.nil? || !hex_string.downcase.match?(/[0-9a-f]{64}/)
  warn "Usage: #{$PROGRAM_NAME} <32 byte hex string>"
  exit 1
end

def int_to_base58(int_val, _leading_zero_bytes = 0)
  alpha = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
  base58_val = ''
  base = alpha.size
  while int_val > 0
    int_val, remainder = int_val.divmod(base)
    base58_val = alpha[remainder] + base58_val
  end
  base58_val
end

def encode_base58(hex)
  leading_zero_bytes = (hex =~ /^([0]+)/ ? Regexp.last_match(1) : '').size / 2
  ('1' * leading_zero_bytes) + int_to_base58(hex.to_i(16))
end

def sha256(hex)
  Digest::SHA256.hexdigest([hex].pack('H*'))
end

# checksum is first 4 bytes of sha256-sha256 hexdigest.
def checksum(hex)
  sha256(sha256(hex))[0...8]
end

PRIV_KEY_VERSION = '80'
def wif(hex)
  data = PRIV_KEY_VERSION + hex
  encode_base58(data + checksum(data))
end

wif = wif(hex_string)
puts "WIF:  #{wif}"

key = Bitcoin::Key.from_base58(wif)
puts "Public: #{key.addr}"

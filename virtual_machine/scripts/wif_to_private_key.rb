#!/usr/bin/env ruby
# frozen_string_literal: true

# Converts 256-bit hex-encoded private key to WIF (wallet import format)
# See: https://en.bitcoin.it/wiki/Wallet_import_format

# Code from: https://bhelx.simst.im/articles/generating-bitcoin-keys-from-scratch-with-ruby/

require 'digest'
require 'bitcoin'

wif = ARGV[0]

if wif.nil?
  warn "Usage: #{$PROGRAM_NAME} <WIF key>"
  exit 1
end

puts "WIF:  #{wif}"
key = Bitcoin::Key.from_base58(wif)
puts "Public: #{key.addr}"

hex = key.key.private_key.to_i.to_s(16)
puts "Hex: #{hex}"

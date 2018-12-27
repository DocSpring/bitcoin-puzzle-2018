#!/usr/bin/env ruby
# frozen_string_literal: true

require 'securerandom'
private_key = SecureRandom.hex(32)
puts "Private key: #{private_key}"
system("./scripts/private_key_to_wif.rb #{private_key}")

#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/string_compiler.rb'

instructions = File.read(File.expand_path('../instructions.txt', __dir__))

obfuscated = StringCompiler.new(
  instructions,
  ascii: true,
  encrypt: true,
  compact: true
).compile

puts 'Writing build/instructions.hex...'
File.open(File.expand_path('../build/instructions.hex', __dir__), 'w') do |f|
  f.write obfuscated
end

# Converted from hex to binary
binary_obfuscated = obfuscated.scan(/../).map(&:hex).pack('C*')

puts 'Writing build/instructions.exe...'
File.open(File.expand_path('../build/instructions.exe', __dir__), 'w') do |f|
  f.write binary_obfuscated
end

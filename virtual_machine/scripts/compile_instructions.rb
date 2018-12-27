#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/string_compiler.rb'
require 'fileutils'
FileUtils.mkdir_p(File.expand_path('../build', __dir__))

instructions = File.read(File.expand_path('../instructions.txt', __dir__))

obfuscated_instructions = StringCompiler.new(
  instructions,
  ascii: true,
  encrypt: true,
  compact: true
).compile

# puts 'Writing build/program.hex...'
# File.open(File.expand_path('../build/program.hex', __dir__), 'w') do |f|
#   f.write obfuscated
# end

# Converted from hex to binary
binary_obfuscated_instructions = obfuscated_instructions.scan(/../).map(&:hex).pack('C*')

puts 'Writing build/program.exe...'
File.open(File.expand_path('../build/program.exe', __dir__), 'w') do |f|
  f.write binary_obfuscated_instructions
end

part_three = File.read(File.expand_path('../part-three.txt', __dir__))

obfuscated_part_three = StringCompiler.new(
  part_three,
  ascii: true,
  encrypt: true,
  compact: true
).compile

# Converted from hex to binary
binary_obfuscated_part_three = obfuscated_part_three.scan(/../).map(&:hex).pack('C*')

puts 'Writing build/btc.exe...'
File.open(File.expand_path('../build/btc.exe', __dir__), 'w') do |f|
  f.write binary_obfuscated_part_three
end

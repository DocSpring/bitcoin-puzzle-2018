#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry-byebug'
require 'json'
require 'yaml'
require 'msgpack'

TESTS = JSON.parse(File.read(File.expand_path('../spec/tests.json', __dir__)))

stripped_inputs = TESTS.map do |t|
  input = t[0].gsub(/\s+/, '')
  output = t[1]
  [input, output]
end

binary_inputs = stripped_inputs.map do |t|
  input = t[0].gsub(/\s+/, '').scan(/../).map(&:hex).pack('C*')
  # Can't encode the output - it's either hex strings, or ASCII text.
  # No binary output.
  output = t[1] # .scan(/../).map(&:hex).pack('C*')

  [input, output]
end

# # JSON doesn't support binary data
# puts 'Writing build/tests.json...'
# File.open(File.expand_path('../build/tests.json', __dir__), 'w') do |f|
#   f.write stripped_inputs.to_json
# end

# puts 'Writing build/tests.yml...'
# File.open(File.expand_path('../build/tests.yml', __dir__), 'w') do |f|
#   f.write binary_inputs.to_yaml
# end

puts 'Writing build/tests.bin...'
File.open(File.expand_path('../build/tests.bin', __dir__), 'w') do |f|
  f.write binary_inputs.to_msgpack
end

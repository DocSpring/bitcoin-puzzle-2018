#!/usr/bin/env ruby
# frozen_string_literal: true

# This program compiles a string into a bytecode program
# that will print out that string.

require_relative '../lib/string_compiler.rb'

input =
  if ARGV.last == '-'
    STDIN.read
  else
    ARGV.shift || 'Hello world!'
  end
ascii = ARGV.include?('--ascii')
encrypt = ARGV.include?('--encrypt')
compact = ARGV.include?('--compact')

output = StringCompiler.new(
  input,
  ascii: ascii,
  encrypt: encrypt,
  compact: compact
).compile

if ARGV.include?('-v')
  puts 'Input:'
  puts '---------------------------------------------'
  puts input
  puts '---------------------------------------------'
end

puts output

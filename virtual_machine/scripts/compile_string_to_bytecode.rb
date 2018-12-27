#!/usr/bin/env ruby
# frozen_string_literal: true

# This program compiles a string into a bytecode program
# that will print out that string.

require_relative '../lib/string_compiler.rb'

ascii = !ARGV.delete('--ascii').nil?
encrypt = !ARGV.delete('--encrypt').nil?
compact = !ARGV.delete('--compact').nil?

input =
  if ARGV.last == '-'
    STDIN.read
  else
    ARGV.shift || 'Hello world!'
  end

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

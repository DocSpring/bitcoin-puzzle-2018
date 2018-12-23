#!/usr/bin/env ruby
# frozen_string_literal: true

# This program compiles a string into a bytecode program
# that will print out that string.

require_relative 'lib/string_compiler.rb'

input = ARGV.shift || 'Hello world!'
ascii = ARGV.include?('--ascii')
encrypt = ARGV.include?('--ascii')

output = StringCompiler.new(input, ascii: ascii, encrypt: encrypt).compile

puts "Input:  '#{input}'"
puts "Bytecode: #{output}"

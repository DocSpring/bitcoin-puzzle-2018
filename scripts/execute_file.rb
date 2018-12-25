#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/solver.rb'

filepath = ARGV[0]
unless filepath
  warn "Usage: #{$PROGRAM_NAME} <file>"
  exit 1
end
unless File.exist?(filepath)
  warn "Cannot find file: #{filepath}"
  exit 1
end

File.open(filepath, 'rb') do |file|
  hex_string = +''

  bytes = file.read.unpack('C*')
  bytes.each { |b| hex_string << b.to_s(16).rjust(2, '0') }

  puts Solver.new.solve(hex_string)
end

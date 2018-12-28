#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry-byebug'
require 'awesome_print'
require 'json'
require 'securerandom'
require 'fileutils'
FileUtils.mkdir_p(File.expand_path('../build', __dir__))

$LOAD_PATH << File.expand_path('../lib', __dir__)

require 'puzzle_solver'

filename = ARGV[0]
size = (ARGV[1] || 8).to_i

if filename.nil?
  warn "Usage: #{$PROGRAM_NAME} <puzzle_filename>"
  exit 1
end

pieces = JSON.parse(File.read(filename))

solution = PuzzleSolver.new(
  pieces, seed: 123, width: size, height: size, depth: size
).solve

puts "Solution: #{solution}"

if size == 8
  raise "Something went wrong! private_key was: #{solution.inspect}" unless solution

  system "../virtual_machine/scripts/private_key_to_wif.rb #{solution}"
end

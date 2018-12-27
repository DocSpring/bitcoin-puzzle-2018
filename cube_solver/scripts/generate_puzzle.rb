#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry-byebug'
require 'awesome_print'
require 'json'
require 'fileutils'
FileUtils.mkdir_p(File.expand_path('../build', __dir__))

$LOAD_PATH << File.expand_path('../lib', __dir__)

require 'puzzle_generator'

puzzle_generator = PuzzleGenerator.new(
  seed: 124,
  width: 8,
  height: 8,
  depth: 8,
  min_length: 16,
  max_length: 28
)
puts 'Generating 8x8x8 puzzle...'
pieces = puzzle_generator.generate_pieces

rng = Random.new(123)

puts 'Scrambling pieces...'
scrambled_pieces = pieces.map(&:last).shuffle(random: rng).map do |piece|
  piece
    .rotate_x(rng.rand(3) * 90)
    .rotate_y(rng.rand(3) * 90)
    .rotate_z(rng.rand(3) * 90)
end

puts 'Writing ../build/puzzle.json'
File.open(File.expand_path('../build/puzzle.json', __dir__), 'w') do |f|
  f.puts scrambled_pieces.map(&:array).to_json
end

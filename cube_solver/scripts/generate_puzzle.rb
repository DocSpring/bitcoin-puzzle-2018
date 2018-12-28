#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry-byebug'
require 'awesome_print'
require 'json'
require 'securerandom'
require 'fileutils'
FileUtils.mkdir_p(File.expand_path('../build', __dir__))

PRIVATE_KEY = 'd63c04bfa19fa546a175ca90f5b9a4bc718f6233a574c6058d57e80b5de12cf5'

filename = ARGV[0] || File.expand_path('../build/blocks.json', __dir__)
size = (ARGV[1] || 8).to_i
data = ARGV[2] || PRIVATE_KEY

puts "Filename:    #{filename}"
puts "Puzzle size: #{size}"
puts "Data:        #{data}"
puts

$LOAD_PATH << File.expand_path('../lib', __dir__)

require 'data_puzzle_generator'

data_bytes = data.scan(/../).map(&:hex)

# Create the same name of random bytes
random_bytes = SecureRandom.random_bytes(data_bytes.size).unpack('C*')
data_xor = data_bytes.map.with_index do |b, i|
  b ^ random_bytes[i]
end

puzzle_bits = (
  data_xor + random_bytes
).pack('C*').unpack1('B*').split('').map(&:to_i)

if size == 8
  min_length = 24
  max_length = 48
else
  min_length = (size / 2.0).round
  max_length = size * 2
end

puzzle_generator = DataPuzzleGenerator.new(
  seed: 124,
  width: size,
  height: size,
  depth: size,
  min_length: min_length,
  max_length: max_length
)
puts "Generating #{size}x#{size}x#{size} puzzle with encoded private key..."
piece_matrixes = puzzle_generator.generate_pieces(puzzle_bits)

puts "Pieces: #{piece_matrixes.size}"

# Find the piece that sets the first bit at 0,0,0
first_piece_index = piece_matrixes.find_index { |m| m[1].get(0, 0, 0) != -1 }

# Trim the matrixes down to the minimum size
pieces = []
piece_matrixes.map(&:last).each do |pm|
  trim_result = pm.trim { |v| v != -1 }
  pieces << [trim_result[:offset], trim_result[:matrix]]
end

first_piece = pieces.delete_at(first_piece_index)

rng = Random.new(123)

puts 'Scrambling pieces...'
scrambled_pieces = pieces.map(&:last).shuffle(random: rng).map do |piece|
  piece
    .rotate_x(rng.rand(3) * 90)
    .rotate_y(rng.rand(3) * 90)
    .rotate_z(rng.rand(3) * 90)
end

# Add the unscrambled first piece to the beginning
scrambled_pieces.unshift(first_piece.last)

puts "Writing #{filename}"
File.open(filename, 'w') do |f|
  f.puts scrambled_pieces.map(&:array).to_json
end

unscrambled_filename = filename.sub(/\.json$/, '-unscrambled.json')
puts "Writing #{unscrambled_filename}"
File.open(unscrambled_filename, 'w') do |f|
  f.puts piece_matrixes.map { |m| m[1].array }.to_json
end

visualizer_filename = filename.sub(/\.json$/, '-visualizer.json')
puts "Writing #{visualizer_filename}"
File.open(visualizer_filename, 'w') do |f|
  f.puts piece_matrixes.map { |m| [m[0], m[1].array] }.to_json
end

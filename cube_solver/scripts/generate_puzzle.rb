#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry-byebug'
require 'awesome_print'
require 'json'
require 'securerandom'
require 'fileutils'
FileUtils.mkdir_p(File.expand_path('../build', __dir__))

$LOAD_PATH << File.expand_path('../lib', __dir__)

require 'data_puzzle_generator'

private_key_hex = 'd63c04bfa19fa546a175ca90f5b9a4bc718f6233a574c6058d57e80b5de12cf5'
private_key_bytes = private_key_hex.scan(/../).map(&:hex)

random_bytes = SecureRandom.random_bytes(32).unpack('C*')

private_key_xor = private_key_bytes.map.with_index do |b, i|
  b ^ random_bytes[i]
end

private_key_xor_plus_random_bytes = private_key_xor + random_bytes

private_key_xor_plus_random_bits =
  private_key_xor_plus_random_bytes.pack('C*').unpack1('B*').split('').map(&:to_i)

puzzle_generator = DataPuzzleGenerator.new(
  seed: 124,
  width: 8,
  height: 8,
  depth: 8,
  min_length: 16,
  max_length: 28
)
puts 'Generating 8x8x8 puzzle with encoded private key...'
piece_matrixes = puzzle_generator.generate_pieces(private_key_xor_plus_random_bits)

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

puts 'Writing ../build/blocks.json'
File.open(File.expand_path('../build/blocks.json', __dir__), 'w') do |f|
  f.puts scrambled_pieces.map(&:array).to_json
end

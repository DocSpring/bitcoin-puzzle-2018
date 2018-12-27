# frozen_string_literal: true

require 'puzzle_generator'

RSpec.describe PuzzleGenerator do
  it 'generates a set of puzzle pieces for a 3x3x3 cube' do
    pieces = PuzzleGenerator.new(
      seed: 123, width: 3, height: 3, depth: 3,
      min_length: 2, max_length: 4
    ).generate_pieces

    expect(pieces.size).to eq 7
    piece_matrixes = pieces.map { |p| p[1].array }
    piece_coords = pieces.map { |p| p[0] }
    # puts piece_matrixes.inspect
    # puts piece_coords.inspect

    expect(piece_matrixes).to eq [[[[true], [true], [false]], [[true], [true], [true]]], [[[true, false], [true, true]], [[false, false], [true, true]]], [[[true, true], [false, false]], [[true, true], [false, true]]], [[[true, true, false], [true, true, true]]], [[[true, true], [true, true]]], [[[true], [true]]], [[[true]]]]
    expect(piece_coords).to eq [[2, 0, 1], [0, 1, 1], [0, 0, 0], [0, 1, 0], [0, 0, 2], [2, 0, 0], [2, 2, 1]]
  end
end

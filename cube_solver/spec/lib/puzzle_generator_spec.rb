# frozen_string_literal: true

require 'puzzle_generator'

RSpec.describe PuzzleGenerator do
  it 'generates a set of puzzle pieces for a 3x3x3 cube' do
    pieces = PuzzleGenerator.new(
      seed: 123, width: 3, height: 3, depth: 3, max_length: 3
    ).generate_pieces

    expect(pieces.size).to eq 10
    expect(pieces.map(&:array)).to eq []
  end
end

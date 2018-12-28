# frozen_string_literal: true

require 'data_puzzle_generator'

RSpec.describe DataPuzzleGenerator do
  it 'generates a set of puzzle pieces for a 3x3x3 cube' do
    data = '3345bd49a75235ce2cbfbe0a68c6888cb29a09627b0e17d76aa2d3136f908925' * 2
    bits = data.scan(/../).map(&:hex).pack('C*').unpack1('B*').split('').map(&:to_i)

    pieces = DataPuzzleGenerator.new(
      seed: 123, width: 8, height: 8, depth: 8,
      min_length: 24, max_length: 16
    ).generate_pieces(bits)

    expect(pieces.size).to eq 7
    piece_matrixes = pieces.map { |p| p[1].array }
    piece_coords = pieces.map { |p| p[0] }

    # puts piece_matrixes.first.inspect
    expect(piece_matrixes.first).to eq(
      [[[1, 0, 1, -1, -1, -1, -1, -1], [0, 1, 0, 1, -1, -1, -1, -1], [0, 0, 1, 1, -1, -1, -1, -1], [1, 1, 0, 0, 1, -1, -1, -1]], [[-1, -1, -1, -1, -1, -1, -1, -1], [1, 1, 0, 0, -1, -1, -1, -1], [1, 0, 0, 0, -1, -1, -1, -1], [1, 0, 0, 0, 1, -1, -1, -1]], [[-1, 1, -1, -1, -1, -1, -1, -1], [0, 0, -1, -1, -1, -1, -1, -1], [0, 0, -1, 1, -1, -1, -1, -1], [1, -1, -1, 1, -1, -1, -1, -1]], [[-1, 1, -1, -1, -1, -1, -1, -1], [-1, 0, -1, -1, -1, -1, -1, -1], [1, 0, 0, 0, 1, -1, -1, -1], [0, -1, -1, 0, 0, -1, -1, -1]], [[-1, -1, -1, -1, -1, -1, -1, -1], [-1, -1, -1, -1, -1, -1, -1, -1], [-1, -1, -1, 1, 0, -1, -1, -1], [-1, -1, 0, 0, 1, 1, -1, -1]], [[-1, -1, -1, -1, -1, -1, -1, -1], [-1, -1, -1, -1, -1, -1, -1, -1], [-1, 0, -1, -1, -1, -1, -1, -1], [-1, 0, 0, 0, 1, 1, -1, -1]], [[-1, -1, -1, -1, -1, -1, -1, -1], [-1, -1, -1, -1, -1, -1, -1, -1], [-1, -1, -1, -1, -1, -1, -1, -1], [-1, -1, -1, 1, 0, 1, 1, 1]], [[-1, -1, -1, -1, 1, 1, -1, -1], [-1, -1, -1, -1, -1, 0, 0, -1], [-1, -1, -1, -1, -1, -1, 0, 1], [-1, -1, -1, -1, 0, -1, -1, 1]]]
    )

    expect(piece_coords.first).to eq [0, 4, 0]
  end
end

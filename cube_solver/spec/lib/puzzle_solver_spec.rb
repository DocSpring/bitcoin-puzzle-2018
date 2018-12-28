# frozen_string_literal: true

require 'puzzle_solver'

RSpec.describe PuzzleSolver do
  it 'solves a set of puzzle pieces for a 3x3x3 cube' do
    pieces = JSON.parse(
      File.read(File.expand_path('../fixtures/puzzle-4x4.json', __dir__))
    )
    solution = PuzzleSolver.new(
      pieces, seed: 123, width: 4, height: 4, depth: 4
    ).solve

    expect(solution).to eq '207261c5'
  end
end

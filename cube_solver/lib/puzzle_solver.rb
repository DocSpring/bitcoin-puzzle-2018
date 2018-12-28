# frozen_string_literal: true

require 'matrix_3d'

module PuzzleSolver
  attr_accessor :rng, :width, :height, :depth,
                :pieces, :matrix

  def initialize(pieces, seed: 123, width: 8, height: 8, depth: 8)
    @rng = Random.new(seed)
    @width = width
    @height = height
    @depth = depth

    @matrix = Matrix3D.from_dimensions(width, height, depth, false)
    @pieces = pieces
  end

  def solve!; end
end

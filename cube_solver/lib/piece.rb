# frozen_string_literal: true

require_relative 'piece/converter'

class Piece
  attr_accessor :matrix

  def initialize(matrix)
    @matrix = matrix
  end

  def self.from_matrix(matrix)
    new(matrix)
  end

  def self.from_tree(tree)
    matrix = PieceConverter.from_tree_to_matrix(tree)
    new(matrix)
  end

  def rotate_x(degrees)
    self.matrix = MatrixRotator.rotate_x(matrix, degrees)
  end

  def rotate_y(degrees)
    self.matrix = MatrixRotator.rotate_y(matrix, degrees)
  end

  def rotate_z(degrees)
    self.matrix = MatrixRotator.rotate_z(matrix, degrees)
  end
end

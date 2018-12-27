# frozen_string_literal: true

# Maybe we should encode the pieces as trees, with a sequence
# of movements (e.g. x + 1, z + 1, y - 1)
# (Just start with matrix and come back to this if we have time.)

class Piece
  module Converter
    def self.from_tree_to_matrix(tree, matrix); end

    def self.from_matrix_to_tree(matrix, tree); end
  end
end

# frozen_string_literal: true

require 'matrix_3d'

module Solver
  RSpec.describe Matrix3D do
    it 'should initialize a new instance from an array' do
      array = [
        [[0, 0, 0], [0, 0, 0]]
      ]
      matrix = Matrix3D.from_array(array)
      expect(matrix.dimensions).to eq [3, 2, 1]
      expect(matrix.array).to eq array
    end
  end
end

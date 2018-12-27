# frozen_string_literal: true

require_relative '../../../lib/matrix_3d/dimension_calculator'

module Solver
  RSpec.describe Matrix3D::DimensionCalculator do
    it 'should return the correct result for empty or 1x1x1 arrays' do
      array = []
      dimensions = Matrix3D::DimensionCalculator.array_dimensions(array)
      expect(dimensions).to eq [0, 0, 0]

      array = [[]]
      dimensions = Matrix3D::DimensionCalculator.array_dimensions(array)
      expect(dimensions).to eq [0, 0, 1]

      array = [[[]]]
      dimensions = Matrix3D::DimensionCalculator.array_dimensions(array)
      expect(dimensions).to eq [0, 1, 1]

      array = [[[0]]]
      dimensions = Matrix3D::DimensionCalculator.array_dimensions(array)
      expect(dimensions).to eq [1, 1, 1]
    end

    it 'should calculate the width, height, and depth for a 2x2x1 array' do
      array = [[[0, 0], [0, 0]]]
      dimensions = Matrix3D::DimensionCalculator.array_dimensions(array)
      expect(dimensions).to eq [2, 2, 1]
    end

    it 'should calculate the width, height, and depth for a 2x1x2 array' do
      array = [[[0, 0]], [[0, 0]]]
      dimensions = Matrix3D::DimensionCalculator.array_dimensions(array)
      expect(dimensions).to eq [2, 1, 2]
    end

    it 'should calculate the width, height, and depth for a 3x3x3 array' do
      array = [
        [[0, 0, 0], [0, 0, 0], [0, 0, 0]],
        [[0, 0, 0], [0, 0, 0], [0, 0, 0]],
        [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
      ]

      dimensions = Matrix3D::DimensionCalculator.array_dimensions(array)
      expect(dimensions).to eq [3, 3, 3]
    end

    it 'should calculate the width, height, and depth for a 3x2x3 array' do
      array = [
        [[0, 0, 0], [0, 0, 0]],
        [[0, 0, 0], [0, 0, 0]],
        [[0, 0, 0], [0, 0, 0]]
      ]
      dimensions = Matrix3D::DimensionCalculator.array_dimensions(array)
      expect(dimensions).to eq [3, 2, 3]
    end

    it 'should calculate the width, height, and depth for a 3x2x2 array' do
      array = [
        [[0, 0, 0], [0, 0, 0]],
        [[0, 0, 0], [0, 0, 0]]
      ]
      dimensions = Matrix3D::DimensionCalculator.array_dimensions(array)
      expect(dimensions).to eq [3, 2, 2]
    end

    it 'should calculate the width, height, and depth for a 2x3x2 array' do
      array = [
        [[0, 0], [0, 0], [0, 0]],
        [[0, 0], [0, 0], [0, 0]]
      ]
      dimensions = Matrix3D::DimensionCalculator.array_dimensions(array)
      expect(dimensions).to eq [2, 3, 2]
    end
  end
end

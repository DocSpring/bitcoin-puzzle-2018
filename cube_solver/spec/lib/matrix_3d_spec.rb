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

    it 'should initialize a new instance from dimensions' do
      matrix = Matrix3D.from_dimensions(3, 2, 3, 0)
      expect(matrix.dimensions).to eq [3, 2, 3]
      expect(matrix.array).to eq [[[0, 0, 0], [0, 0, 0]], [[0, 0, 0], [0, 0, 0]], [[0, 0, 0], [0, 0, 0]]]
    end

    it 'should return the correct value for #all?' do
      matrix = Matrix3D.from_dimensions(3, 2, 3, 0)
      expect(matrix.all? { |v| v == 0 }).to eq true
      matrix.array[2][1][2] = 1
      expect(matrix.all? { |v| v == 0 }).to eq false
    end

    it 'should return the correct value for #any?' do
      matrix = Matrix3D.from_dimensions(3, 2, 3, 0)
      expect(matrix.any? { |v| v == 1 }).to eq false
      matrix.array[2][1][2] = 1
      expect(matrix.any? { |v| v == 1 }).to eq true
    end

    it 'should return the correct value for #count' do
      matrix = Matrix3D.from_dimensions(3, 3, 3, 0)
      expect(matrix.count { |v| v == 1 }).to eq 0
      matrix.array[2][1][2] = 1
      expect(matrix.count { |v| v == 1 }).to eq 1
      matrix.array[0][1][2] = 1
      expect(matrix.count { |v| v == 1 }).to eq 2
    end

    it 'should get and set a value from coordinates' do
      matrix = Matrix3D.from_dimensions(3, 3, 3, 0)
      expect(matrix.get(1, 1, 1)).to eq 0
      matrix.set(1, 1, 1, 1)
      expect(matrix.get(1, 1, 1)).to eq 1
      expect(matrix.get(1, 1, 0)).to eq 0
      expect(matrix.get(1, 1, 2)).to eq 0
    end
  end
end

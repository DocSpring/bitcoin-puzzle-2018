# frozen_string_literal: true

require 'matrix_3d'
require 'matrix_3d/rotation'

module Solver
  RSpec.describe Matrix3D::Rotation do
    it 'should raise an error for an invalid rotation' do
      matrix = Matrix3D.new([])

      expect(Matrix3D::Rotation.rotate_x(matrix, 91)).to raise_error(
        Matrix3D::Rotation::InvalidRotationError
      )
    end
  end

  it 'should rotate a 3x3x3 matrix 90 degrees around the Z axis (depth)' do
    array = [
      [
        [1, 0, 0],
        [1, 0, 0],
        [1, 1, 1]
      ],
      [
        [1, 0, 0],
        [1, 0, 0],
        [1, 1, 1]
      ],
      [
        [1, 0, 0],
        [1, 0, 0],
        [1, 1, 1]
      ]
    ]

    expect(solver_class.new.rotate_x(piece, 91)).to raise_error(
      Solver::PieceRotator::InvalidRotationError
    )
  end
end

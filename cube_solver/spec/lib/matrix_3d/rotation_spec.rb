# frozen_string_literal: true

require 'matrix_3d'
require 'matrix_3d/rotation'

RSpec.describe Matrix3D::Rotation do
  it 'should raise an error for an invalid rotation' do
    matrix = Matrix3D.from_array([])

    expect { Matrix3D::Rotation.rotate_x(matrix, 91) }.to raise_error(
      Matrix3D::Rotation::InvalidRotationError
    )
  end

  context 'with L3 matrix' do
    let(:matrix) { Fixtures::MATRIX_3D[:L3] }

    context 'with rotation around the Z axis' do
      it 'should rotate a 3x3x3 matrix 0 degrees' do
        rotated = Matrix3D::Rotation.rotate_z(matrix, 0)
        expect(rotated.array).to eq matrix.array
      end

      it 'should rotate a 3x3x3 matrix 90 degrees' do
        rotated = Matrix3D::Rotation.rotate_z(matrix, 90)
        expect(rotated.array).to eq [[[2, 1, 1], [2, 0, 0], [2, 0, 0]], [[3, 2, 2], [3, 0, 0], [3, 0, 0]], [[4, 3, 3], [4, 0, 0], [4, 0, 0]]]
        rotated2 = Matrix3D::Rotation.rotate_z(matrix, -270)
        expect(rotated.array).to eq rotated2.array
      end

      it 'should rotate a 3x3x3 matrix 180 degrees' do
        rotated = Matrix3D::Rotation.rotate_z(matrix, 180)
        expect(rotated.array).to eq [[[2, 2, 2], [0, 0, 1], [0, 0, 1]], [[3, 3, 3], [0, 0, 2], [0, 0, 2]], [[4, 4, 4], [0, 0, 3], [0, 0, 3]]]

        rotated2 = Matrix3D::Rotation.rotate_z(matrix, -180)
        expect(rotated.array).to eq rotated2.array
      end

      it 'should rotate a 3x3x3 matrix 270 degrees' do
        rotated = Matrix3D::Rotation.rotate_z(matrix, 270)
        expect(rotated.array).to eq [[[0, 0, 2], [0, 0, 2], [1, 1, 2]], [[0, 0, 3], [0, 0, 3], [2, 2, 3]], [[0, 0, 4], [0, 0, 4], [3, 3, 4]]]
        rotated2 = Matrix3D::Rotation.rotate_z(matrix, -90)
        expect(rotated.array).to eq rotated2.array
      end
    end

    context 'with rotation around the X axis' do
      it 'should rotate a 3x3x3 matrix 0 degrees' do
        rotated = Matrix3D::Rotation.rotate_x(matrix, 0)
        expect(rotated.array).to eq matrix.array
      end

      it 'should rotate a 3x3x3 matrix 90 degrees' do
        rotated = Matrix3D::Rotation.rotate_x(matrix, 90)
        expect(rotated.array).to eq [[[3, 0, 0], [2, 0, 0], [1, 0, 0]], [[3, 0, 0], [2, 0, 0], [1, 0, 0]], [[4, 4, 4], [3, 3, 3], [2, 2, 2]]]
        rotated2 = Matrix3D::Rotation.rotate_x(matrix, -270)
        expect(rotated.array).to eq rotated2.array
      end

      it 'should rotate a 3x3x3 matrix 180 degrees' do
        rotated = Matrix3D::Rotation.rotate_x(matrix, 180)
        expect(rotated.array).to eq [[[4, 4, 4], [3, 0, 0], [3, 0, 0]], [[3, 3, 3], [2, 0, 0], [2, 0, 0]], [[2, 2, 2], [1, 0, 0], [1, 0, 0]]]

        rotated2 = Matrix3D::Rotation.rotate_x(matrix, -180)
        expect(rotated.array).to eq rotated2.array
      end

      it 'should rotate a 3x3x3 matrix 270 degrees' do
        rotated = Matrix3D::Rotation.rotate_x(matrix, 270)
        expect(rotated.array).to eq [[[2, 2, 2], [3, 3, 3], [4, 4, 4]], [[1, 0, 0], [2, 0, 0], [3, 0, 0]], [[1, 0, 0], [2, 0, 0], [3, 0, 0]]]
        rotated2 = Matrix3D::Rotation.rotate_x(matrix, -90)
        expect(rotated.array).to eq rotated2.array
      end
    end

    context 'with rotation around the Y axis' do
      it 'should rotate a 3x3x3 matrix 0 degrees' do
        rotated = Matrix3D::Rotation.rotate_y(matrix, 0)
        expect(rotated.array).to eq matrix.array
      end

      it 'should rotate a 3x3x3 matrix 90 degrees' do
        rotated = Matrix3D::Rotation.rotate_y(matrix, 90)
        expect(rotated.array).to eq [[[3, 2, 1], [3, 2, 1], [4, 3, 2]], [[0, 0, 0], [0, 0, 0], [4, 3, 2]], [[0, 0, 0], [0, 0, 0], [4, 3, 2]]]
        rotated2 = Matrix3D::Rotation.rotate_y(matrix, -270)
        expect(rotated.array).to eq rotated2.array
      end

      it 'should rotate a 3x3x3 matrix 180 degrees' do
        rotated = Matrix3D::Rotation.rotate_y(matrix, 180)
        expect(rotated.array).to eq [[[0, 0, 3], [0, 0, 3], [4, 4, 4]], [[0, 0, 2], [0, 0, 2], [3, 3, 3]], [[0, 0, 1], [0, 0, 1], [2, 2, 2]]]

        rotated2 = Matrix3D::Rotation.rotate_y(matrix, -180)
        expect(rotated.array).to eq rotated2.array
      end

      it 'should rotate a 3x3x3 matrix 270 degrees' do
        rotated = Matrix3D::Rotation.rotate_y(matrix, 270)
        expect(rotated.array).to eq [[[0, 0, 0], [0, 0, 0], [2, 3, 4]], [[0, 0, 0], [0, 0, 0], [2, 3, 4]], [[1, 2, 3], [1, 2, 3], [2, 3, 4]]]
        rotated2 = Matrix3D::Rotation.rotate_y(matrix, -90)
        expect(rotated.array).to eq rotated2.array
      end
    end
  end
end

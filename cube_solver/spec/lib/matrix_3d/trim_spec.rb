# frozen_string_literal: true

require 'matrix_3d'
require 'matrix_3d/trim'

# We import this module into the Matrix3D class, so can just
# test the instance method.
RSpec.describe Matrix3D::Trim do
  it 'should trim an empty matrix into a 0x0x0 matrix' do
    matrix = Matrix3D.from_dimensions(3, 3, 3, false)
    trim_result = matrix.trim(true)

    expect(trim_result[:matrix].array).to eq []
    expect(trim_result[:matrix].dimensions).to eq [0, 0, 0]
    expect(trim_result[:offset]).to eq [0, 0, 0]
  end

  it 'should trim a matrix with a single value into a 1x1x1 matrix' do
    matrix = Matrix3D.from_dimensions(3, 3, 3, false)
    matrix.set(1, 1, 1, true)

    trim_result = matrix.trim(true)

    expect(trim_result[:matrix].array).to eq [[[true]]]
    expect(trim_result[:matrix].dimensions).to eq [1, 1, 1]
    expect(trim_result[:offset]).to eq [1, 1, 1]
  end

  it 'should trim a matrix using a block to find boundaries' do
    matrix = Matrix3D.from_dimensions(3, 3, 3, false)
    matrix.set(1, 1, 1, true)

    trim_result = matrix.trim { |v| v == true }

    expect(trim_result[:matrix].array).to eq [[[true]]]
    expect(trim_result[:matrix].dimensions).to eq [1, 1, 1]
    expect(trim_result[:offset]).to eq [1, 1, 1]
  end

  it 'should not trim a matrix if it cannot be trimmed' do
    matrix = Matrix3D.from_dimensions(3, 3, 3, false)
    matrix.set(0, 0, 0, true)
    matrix.set(2, 2, 2, true)

    trim_result = matrix.trim(true)

    expect(trim_result[:matrix].array).to eq matrix.array
    expect(trim_result[:matrix].dimensions).to eq [3, 3, 3]
    expect(trim_result[:offset]).to eq [0, 0, 0]
  end

  it 'should trim a matrix into a 3x1x1 matrix' do
    matrix = Matrix3D.from_dimensions(3, 3, 3, false)
    matrix.set(0, 0, 0, true)
    matrix.set(2, 0, 0, true)

    trim_result = matrix.trim(true)

    expect(trim_result[:matrix].array).to eq [[[true, false, true]]]
    expect(trim_result[:matrix].dimensions).to eq [3, 1, 1]
    expect(trim_result[:offset]).to eq [0, 0, 0]
  end
end

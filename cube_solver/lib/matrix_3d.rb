# frozen_string_literal: true

require_relative 'matrix_3d/rotation'
require_relative 'matrix_3d/dimension_calculator'
require 'facets/kernel/deep_clone'

class Matrix3D
  attr_accessor :width, :height, :depth, :array

  def initialize(width, height, depth, array)
    @width = width
    @height = height
    @depth = depth
    @array = array
  end

  def dimensions
    [width, height, depth]
  end

  def self.from_array(array)
    width, height, depth = DimensionCalculator.array_dimensions(array)
    new(width, height, depth, array)
  end

  def rotate_x(degrees)
    Matrix3D::Rotation.rotate_x(self, degrees)
  end

  def rotate_y(degrees)
    Matrix3D::Rotation.rotate_y(self, degrees)
  end

  def rotate_z(degrees)
    Matrix3D::Rotation.rotate_z(self, degrees)
  end
end

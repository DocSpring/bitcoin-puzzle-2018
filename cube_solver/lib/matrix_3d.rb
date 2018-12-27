# frozen_string_literal: true

require_relative 'matrix_3d/rotation'
require_relative 'matrix_3d/dimension_calculator'
require_relative 'matrix_3d/trim'
require 'facets/kernel/deep_clone'

class Matrix3D
  include Trim

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

  def self.from_dimensions(width, height, depth, initial_value = nil)
    # Don't use the "*" operator here, it uses a copy of the array
    array = Array.new(depth) do
      Array.new(height) do
        Array.new(width) { initial_value }
      end
    end
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

  def all?(&block)
    array.all? { |plane| plane.all? { |row| row.all?(&block) } }
  end

  def any?(&block)
    array.any? { |plane| plane.any? { |row| row.any?(&block) } }
  end

  def find_index
    array.each_with_index do |plane, z|
      plane.each_with_index do |rows, y|
        rows.each_with_index do |value, x|
          return [x, y, z] if yield(value)
        end
      end
    end
  end

  def count
    array.sum do |plane|
      plane.sum do |rows|
        rows.count do |value|
          yield(value)
        end
      end
    end
  end

  def get(x, y, z)
    array[z][y][x]
  end

  def set(x, y, z, value)
    array[z][y][x] = value
  end

  def within_bounds?(x, y, z)
    x >= 0 && y >= 0 && z >= 0 &&
      x < width && y < height && z < depth
  end
end

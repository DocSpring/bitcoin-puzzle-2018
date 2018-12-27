# frozen_string_literal: true

class Matrix3D
  module DimensionCalculator
    # Returns the width, height, and depth
    def self.array_dimensions(array)
      return [0, 0, 0] if !array || array.empty?

      width = 0
      height = 0
      depth = array.size

      array.each do |planes|
        height = planes.size if planes.size > height
        planes.each do |rows|
          width = rows.size if rows.size > width
        end
      end

      [width, height, depth]
    end
  end
end

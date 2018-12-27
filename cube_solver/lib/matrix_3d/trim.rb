# frozen_string_literal: true

class Matrix3D
  module Trim
    def trim(search = nil)
      # Find the minimum and maximum x, y, z
      # (Initialize values to the opposite extremes)
      found = false
      min_x = width - 1
      max_x = 0
      min_y = height - 1
      max_y = 0
      min_z = depth - 1
      max_z = 0
      array.each_with_index do |plane, z|
        plane.each_with_index do |rows, y|
          rows.each_with_index do |value, x|
            next unless block_given? ? (yield value, x, y, z) : value == search

            found = true
            min_x = x if x < min_x
            min_y = y if y < min_y
            min_z = z if z < min_z
            max_x = x if x > max_x
            max_y = y if y > max_y
            max_z = z if z > max_z
          end
        end
      end

      return { offset: [0, 0, 0], matrix: Matrix3D.from_array([]) } unless found

      new_matrix = Matrix3D.from_dimensions(
        max_x - min_x + 1, max_y - min_y + 1, max_z - min_z + 1, nil
      )

      array.each_with_index do |plane, z|
        next unless z >= min_z && z <= max_z

        plane.each_with_index do |rows, y|
          next unless y >= min_y && y <= max_y

          rows.each_with_index do |value, x|
            next unless x >= min_x && x <= max_x

            new_matrix.set(x - min_x, y - min_y, z - min_z, value)
          end
        end
      end

      {
        offset: [min_x, min_y, min_z],
        matrix: new_matrix
      }
    end
  end
end

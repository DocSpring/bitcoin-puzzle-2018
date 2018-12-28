# frozen_string_literal: true

class Matrix3D
  module Rotation
    class InvalidRotationError < StandardError; end

    class << self
      def rotate_x(matrix, degrees)
        return matrix if degrees == 0

        validate_degrees!(degrees)
        rotated_array = matrix.array
        (degrees % 360 / 90).times do
          rotated_array = rotated_array.transpose.map(&:reverse)
        end
        Matrix3D.from_array(rotated_array)
      end

      def rotate_y(matrix, degrees)
        return matrix if degrees == 0

        validate_degrees!(degrees)
        rotated_array = matrix.array
        (degrees % 360 / 90).times do
          # There's probably a better way to do this, but it works!
          rotated_array = rotated_array
                          .map(&:transpose)
                          .reverse
                          .transpose
                          .map(&:transpose)
        end
        Matrix3D.from_array(rotated_array)
      end

      def rotate_z(matrix, degrees)
        return matrix if degrees == 0

        validate_degrees!(degrees)
        rotated_array = matrix.array
        (degrees % 360 / 90).times do
          rotated_array = rotated_array.map do |z_plane|
            z_plane.transpose.map(&:reverse)
          end
        end
        Matrix3D.from_array(rotated_array)
      end

      private

      def validate_degrees!(degrees)
        return if degrees % 90 == 0

        raise InvalidRotationError,
              "Cannot rotate by #{degrees} degrees! Must be a multiple of 90."
      end
    end
  end
end

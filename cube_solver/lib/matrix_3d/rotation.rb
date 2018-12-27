# frozen_string_literal: true

class Matrix3D
  module Rotation
    class InvalidRotationError < StandardError; end

    def self.rotate_x(_matrix_3d, _degrees)
      matrix
    end

    def self.rotate_y(_matrix_3d, _degrees)
      matrix
    end

    def self.rotate_z(_matrix_3d, _degrees)
      matrix
    end
  end
end

# frozen_string_literal: true

require 'matrix_3d'

class Fixtures
  MATRIX_3D_ARRAYS = YAML.load_file(
    File.expand_path('../fixtures/pieces.yml', __dir__)
  )

  MATRIX_3D = begin
    MATRIX_3D_ARRAYS.each_with_object({}) do |(name, array), hash|
      hash[name] = Matrix3D.from_array(array)
    end
  end
end

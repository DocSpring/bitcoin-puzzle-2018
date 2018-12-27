# frozen_string_literal: true

require 'yaml'
require 'matrix_3d'

class Fixtures
  MATRIX_3D = begin
    arrays = YAML.load_file(
      File.expand_path('../fixtures/pieces.yml', __dir__)
    )
    arrays.each_with_object({}) do |(name, array), hash|
      hash[name] = Matrix3D.from_array(array)
    end
  end
end

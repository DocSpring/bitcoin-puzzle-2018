# frozen_string_literal: true

require 'puzzle_generator'

# Adds some data into the puzzle pieces
class DataPuzzleGenerator < PuzzleGenerator
  def generate_pieces(data)
    piece_matrixes = super(trim: false)

    # Fill in the data
    piece_matrixes.each do |piece|
      matrix = piece[1]
      matrix.array.each_with_index do |plane, z|
        plane.each_with_index do |rows, y|
          rows.each_with_index do |value, x|
            if value == false
              matrix.set(x, y, z, -1)
              next
            end
            data_index = x + (y * width) + (z * width * height)
            if data_index >= data.size
              raise 'Data index cannot be greater than the size of the data! ' \
                "Grid size: #{width * height * depth}, Data Size: #{data.size}, " \
                "Data Index: #{data_index}. You must pad the data."
            end

            matrix.set(x, y, z, data[data_index])
          end
        end
      end
    end

    pieces = []
    piece_matrixes.map(&:last).each do |pm|
      # Trim the matrix down to the minimum size.
      trim_result = pm.trim { |v| v != -1 }

      # Use the offset as the piece position
      pieces << [trim_result[:offset], trim_result[:matrix]]
    end
    pieces
  end
end

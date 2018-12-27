# frozen_string_literal: true

require 'matrix_3d'

class PuzzleGenerator
  attr_accessor :rng, :width, :height, :depth, :max_length, :matrix, :piece_matrixes

  def initialize(
    seed: 123, width: 8, height: 8, depth: 8, max_length: width
  )
    @rng = Random.new(seed)
    @width = width
    @height = height
    @depth = depth
    @max_length = max_length

    @matrix = Matrix3D.from_dimensions(width, height, depth, false)
    @piece_matrixes = []
  end

  # Generates a set of puzzle pieces that form a complete 8x8x8 cube
  def generate_pieces
    while matrix.any? { |v| v == false }
      piece_matrix = Matrix3D.from_dimensions(width, height, depth, false)

      # Get initial position
      coords = find_initial_coordinates
      piece_matrix.set(*coords, true)
      matrix.set(*coords, true)
      unblocked_positions = []
      add_new_position(unblocked_positions, coords)

      piece_length = 1

      while piece_length <= max_length && unblocked_positions.any?
        position_index = unblocked_positions.size.times.to_a.sample(random: rng)
        position = unblocked_positions[position_index]
        # Update the available moves
        position[:available_moves] = available_moves(position[:coords], matrix)
        if position[:available_moves].empty?
          # No available moves, so delete this position
          unblocked_positions.delete_at(position_index)
          next
        end

        # Pick a random move
        x, y, z = position[:available_moves].sample(random: rng)
        piece_matrix.set(x, y, z, true)
        matrix.set(x, y, z, true)
        add_new_position(unblocked_positions, [x, y, z])
        piece_length += 1
      end
      piece_matrixes << piece_matrix
    end

    piece_matrixes
  end

  def add_new_position(positions, coords)
    positions << {
      coords: coords,
      available_moves: available_moves(coords, matrix)
    }
  end

  def available_moves(coords, matrix)
    x, y, z = coords
    available_moves = []

    %i[x y z].each do |axis|
      [-1, 1].each do |offset|
        case axis
        when :x
          new_x = x + offset
          next if new_x < 0 || new_x >= width
          next if matrix.get(new_x, y, z)

          available_moves << [new_x, y, z]
        when :y
          new_y = y + offset
          next if new_y < 0 || new_y >= height
          next if matrix.get(x, new_y, z)

          available_moves << [x, new_y, z]
        when :z
          new_z = z + offset
          next if new_z < 0 || new_z >= depth
          next if matrix.get(x, y, new_z)

          available_moves << [x, y, new_z]
        end
      end
    end
    available_moves
  end

  # Finds a random position to start from
  def pick_random_position(positions)
    position = positions.sample(random: rng)

    # Check if the piece can move in any direction

    tree.each do |node|
      unblocked_nodes << node unless node[:blocked]

      node[:leaves]
    end
  end

  def find_initial_coordinates
    iterations = 0
    loop do
      x = rng.rand(width)
      y = rng.rand(height)
      z = rng.rand(depth)
      return [x, y, z] unless matrix.get(x, y, z)

      iterations += 1
      # Switch to sequential lookup once the matrix starts getting full
      break if iterations > width * 2
    end

    position = matrix.find_index { |v| v == false }
    raise 'Could not find a free position in the matrix!' unless position

    position
  end
end

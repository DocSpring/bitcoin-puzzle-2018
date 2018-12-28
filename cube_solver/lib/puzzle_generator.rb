# frozen_string_literal: true

require 'matrix_3d'

class PuzzleGenerator
  attr_accessor :rng, :width, :height, :depth,
                :min_length, :max_length, :matrix, :pieces

  def initialize(
    seed: 123, width: 8, height: 8, depth: 8,
    min_length: 2, max_length: width
  )
    @rng = Random.new(seed)
    @width = width
    @height = height
    @depth = depth
    @min_length = min_length
    @max_length = max_length

    @matrix = Matrix3D.from_dimensions(width, height, depth, false)
    @pieces = []
  end

  # Generates a set of puzzle pieces that form a complete 8x8x8 cube
  def generate_pieces(trim: true)
    piece_matrixes = []

    while matrix.any? { |v| v == false }
      piece_matrix = Matrix3D.from_dimensions(width, height, depth, false)
      next_piece_index = piece_matrixes.size

      # Get initial position
      coords = find_initial_coordinates

      piece_matrix.set(*coords, true)
      # Record the piece index in the matrix. Makes it easier
      # to merge small pieces into adjacent pieces.
      matrix.set(*coords, next_piece_index)
      unblocked_positions = []
      add_new_position(unblocked_positions, coords)

      piece_length = 1

      while piece_length <= max_length && unblocked_positions.any?
        # Use the most recent block 70% of the time
        # Actually it looks much cooler if we do this 100% of the time.
        position_index = unblocked_positions.size - 1
        # if rng.rand(10) < 7
        #   unblocked_positions.size - 1
        # else
        #   unblocked_positions.size.times.to_a.sample(random: rng)
        # end
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
        matrix.set(x, y, z, next_piece_index)
        add_new_position(unblocked_positions, [x, y, z])
        piece_length += 1
      end

      piece_matrixes << piece_matrix
    end

    # Merge small pieces into adjacent pieces
    loop do
      piece_index = piece_matrixes.find_index do |m|
        m && m.count { |v| v == true } < min_length
      end
      break unless piece_index

      piece_matrix = piece_matrixes[piece_index]

      # Choose a random piece with an adjacent block
      directions = [
        [0, 1], [1, 1], [2, 1], [0, -1], [1, -1], [2, -1]
      ]
      loop do
        raise 'Directions should never be empty!' if directions.empty?

        direction = directions.sample(random: rng)
        directions.delete(direction)

        # puts "Direction:  #{direction}"

        coord = piece_matrix.find_index { |v| v == true }.map(&:dup)

        # puts "Coordinate: #{coord}"

        adjacent_piece_index = piece_index
        loop do
          coord[direction[0]] += direction[1]
          # puts "==========> #{coord}"

          # Keep going until we hit the boundary
          break unless matrix.within_bounds?(*coord)

          adjacent_piece_index = matrix.get(*coord)

          # Keep going until we leave this piece
          break if adjacent_piece_index != piece_index
        end

        next if adjacent_piece_index == piece_index

        adjacent_piece = piece_matrixes[adjacent_piece_index]

        # Add this piece's blocks to the adjacent piece
        piece_matrix.array.each_with_index do |plane, z|
          plane.each_with_index do |rows, y|
            rows.each_with_index do |value, x|
              next unless value == true

              adjacent_piece.set(x, y, z, true)

              # Update the index in the main matrix
              matrix.set(x, y, z, adjacent_piece_index)
            end
          end
        end

        break
      end

      # Important - Don't delete the pieces! This screws up the
      # indexes in the matrix. Just set them to nil
      piece_matrixes[piece_index] = nil
    end

    piece_matrixes.each do |pm|
      next if pm.nil?

      unless trim
        pieces << [[0, 0, 0], pm]
        next
      end

      # Trim the matrix down to the minimum size.
      trim_result = pm.trim(true)

      # Use the offset as the piece position
      pieces << [trim_result[:offset], trim_result[:matrix]]
    end

    # binding.pry

    pieces
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

# frozen_string_literal: true

require 'matrix_3d'

class PuzzleSolver
  ROTATION_DEGREES = [0, 90, 180, 270].freeze

  attr_accessor :rng, :width, :height, :depth,
                :pieces, :matrix, :corner_pieces

  def initialize(piece_arrays, seed: 123, width: 8, height: 8, depth: 8)
    @rng = Random.new(seed)
    @width = width
    @height = height
    @depth = depth

    @matrix = Matrix3D.from_dimensions(width, height, depth, false)
    @pieces = piece_arrays.map { |arr| Matrix3D.from_array(arr) }

    move_first_piece_into_matrix!

    # @debug = true
    # @exhaustive = true
  end

  def log(msg)
    puts msg if @debug
  end

  def move_first_piece_into_matrix!
    # Move first piece into the matrix
    piece = pieces.shift
    piece.each do |value, x, y, z|
      next if value == -1

      matrix.set(x, y, z, value)
    end
  end

  def solve
    @solutions = []
    @solution_ints = []

    puts "Placing #{pieces.size} pieces (excluding first piece)..."
    solve_recursively(matrix, pieces)

    if @solutions.any?
      puts "Found #{@solutions.size} solutions!"
      solved_matrix = @solutions.first

      # Sanity check
      raise 'Returned an invalid matrix!!!' if solved_matrix.any? { |v| v == false }

      log 'Found a solution!'
      bits = []
      solved_matrix.each do |v|
        bits << v
      end

      hex_data = bits.join('').to_i(2).to_s(16)

      return hex_data if width != 8

      hex_one = hex_data[0..64]
      hex_two = hex_data[64..-1]

      hex_one_bytes = hex_one.scan(/../).map(&:hex)
      hex_two_bytes = hex_two.scan(/../).map(&:hex)

      private_key_bytes = hex_one_bytes.map.with_index do |b, i|
        b ^ hex_two_bytes[i]
      end

      private_key_hex = private_key_bytes.map { |b| b.to_s(16).rjust(2, '0') }.join
      return private_key_hex
    end

    log 'No Solution!'
  end

  def solve_recursively(current_matrix, current_pieces, previous_indexes = [])
    current_pieces.each_with_index do |piece, piece_index|
      next unless piece

      # rotated_piece = piece

      log "\e[1;37m=> Trying to place piece #{piece_index}\e[0m (" \
        "W: #{piece.width}, H: #{piece.height}, " \
        "D: #{piece.depth}) - #{piece.array.inspect}"

      puts "\e[1;35m=> Current permutation: #{previous_indexes.inspect}\e[0m" if previous_indexes.size == 2

      log current_matrix.array.inspect

      ROTATION_DEGREES.each do |x_rot|
        rotated_piece = piece.rotate_x(x_rot)
        ROTATION_DEGREES.each do |y_rot|
          rotated_piece = rotated_piece.rotate_y(y_rot)
          ROTATION_DEGREES.each do |z_rot|
            rotated_piece = rotated_piece.rotate_z(z_rot)
            width.times do |x_offset|
              break if x_offset + rotated_piece.width > width

              height.times do |y_offset|
                break if y_offset + rotated_piece.height > height

                depth.times do |z_offset|
                  break if z_offset + rotated_piece.depth > depth

                  new_matrix = current_matrix.clone

                  log "x: #{x_offset}, y: #{y_offset}, z: #{z_offset}"

                  collision = false
                  rotated_piece.each do |value, x, y, z|
                    # Skip empty cells
                    next if value == -1

                    xo = x + x_offset
                    yo = y + y_offset
                    zo = z + z_offset

                    if new_matrix.get(xo, yo, zo) != false
                      collision = true
                      break
                    end

                    new_matrix.set(xo, yo, zo, value)
                  end
                  # binding.pry if collision
                  next if collision

                  log "\e[1;32m====> Successfully placed piece #{piece_index}!\e[0m"

                  # binding.pry

                  # Keep searching after we find a solution,
                  # so that we're sure there's only a single solution to this puzzle.
                  if new_matrix.none? { |v| v == false }
                    bits = []
                    new_matrix.each { |v| bits << v }
                    solution_int = bits.join('').to_i(2)

                    unless @solution_ints.include?(solution_int)
                      @solution_ints << solution_int
                      @solutions << new_matrix
                      puts "Found a new unique solution! Current solutions: #{@solutions.size}"
                      return true unless @exhaustive
                    end

                    next
                  end

                  new_pieces = current_pieces.dup
                  new_indexes = previous_indexes.dup
                  new_pieces[piece_index] = nil
                  new_indexes << piece_index

                  result = solve_recursively(new_matrix, new_pieces, new_indexes)
                  # Return the matrix if this path was successful,
                  # otherwise continue trying new positions after this point.
                  return result if result && !@exhaustive

                  log "\e[1;33m========> No result after placing piece #{piece_index}. " \
                    "Trying a new position for #{piece_index}...\e[0m"
                end
              end
            end
          end
        end
      end

      log "\e[1;31m====> Could not place piece #{piece_index}!\e[0m"
    end

    false
  end

  # # Find corner pieces
  # def find_potential_corner_pieces
  #   @corner_pieces = []
  #   pieces.each do |piece|
  #     corner_pieces << piece if is_potential_corner_piece?(piece)
  #   end
  # end

  # def is_potential_corner_piece?(piece)
  #   [0, piece.width - 1].each do |x|
  #     [0, piece.height - 1].each do |y|
  #       [0, piece.depth - 1].each do |z|
  #         return true if piece.get(x, y, z) != -1
  #       end
  #     end
  #   end
  # end
end

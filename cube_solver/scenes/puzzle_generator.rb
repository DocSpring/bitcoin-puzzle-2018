#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'base_scene'
require 'securerandom'
require 'data_puzzle_generator'

class PuzzleGeneratorScene < BaseScene
  COLORS = [
    0xee2222,
    0x22ee22,
    0x2222ee,
    0xdd22ee,
    0x22ddee,
    0xddee22
  ].freeze

  MODES = %i[select_piece all_pieces single_piece].freeze

  attr_accessor :size, :cube_group, :puzzle_generator,
                :puzzle_pieces, :selected_piece_index,
                :mode

  def initialize
    super

    @mode = MODES.first

    @cube_group = Mittsu::Group.new
    @scene.add(@cube_group)

    @size = (ARGV[0] || 8).to_i
    min_length = [(size / 2).ceil, 4].max
    max_length = size * 2

    if size == 8
      min_length = 16
      max_length = 28
    end

    camera.position.z = 14.0
    camera.zoom = size < 5 ? 2.5 : 0.75
    camera.update_projection_matrix

    puts "==> Puzzle size: #{size}"
    @puzzle_generator = DataPuzzleGenerator.new(
      seed: 124,
      width: size,
      height: size,
      depth: size,
      min_length: min_length,
      max_length: max_length
    )

    bytes = (size * size * size / 8.0).ceil
    data = SecureRandom.random_bytes(bytes).unpack1('B*').split('').map(&:to_i)

    @puzzle_pieces = puzzle_generator.generate_pieces(data)

    @selected_piece_index = 0

    puts "==> Generated #{@puzzle_pieces.size} puzzle pieces"

    add_matrix
  end

  def add_matrix
    current_piece = puzzle_pieces[selected_piece_index]
    puts "Showing piece: #{selected_piece_index + 1} / #{puzzle_pieces.size} " \
    "(#{current_piece[0].join(', ')})"

    case mode
    when :select_piece, :all_pieces
      puzzle_pieces.each_with_index do |piece, index|
        x_offset, y_offset, z_offset = piece[0]
        matrix = piece[1]

        # Center the cube in the window
        x_offset -= (puzzle_generator.width - 1) / 2
        y_offset -= (puzzle_generator.height - 1) / 2
        z_offset -= (puzzle_generator.depth - 1) / 2

        add_piece_matrix(matrix, [x_offset, y_offset, z_offset], index)
      end
    when :single_piece
      matrix = current_piece[1]

      x_offset = 0
      y_offset = 0
      z_offset = 0

      # Center the piece in the window
      x_offset -= (matrix.width - 1) / 2
      y_offset -= (matrix.height - 1) / 2
      z_offset -= (matrix.depth - 1) / 2

      add_piece_matrix(matrix, [x_offset, y_offset, z_offset], selected_piece_index)
    end
  end

  def add_piece_matrix(matrix, offset, index)
    matrix.array.each_with_index do |z_plane, z|
      z_plane.each_with_index do |rows, y|
        rows.each_with_index do |value, x|
          next if value == -1

          opacity =
            if mode != :select_piece || index == selected_piece_index
              1
            elsif size < 5
              0.2
            else
              0.08
            end

          color = COLORS[index % COLORS.size]

          if value == 0
            rgb = color.to_s(16).scan(/../).map(&:hex)
            rgb << 0 while rgb.size < 3
            rgb = rgb.map { |v| [v - (0.25 * 255).round, 0].max }
            color = rgb.unshift(0).pack('C*').unpack1('N') || 0
          end

          material = Mittsu::MeshLambertMaterial.new(
            color: color,
            opacity: opacity,
            transparent: true
          )
          cube = Mittsu::Mesh.new(BOX_GEOMETRY, material)
          cube.position.set(
            x + offset[0],
            (y + offset[1]) * -1,
            (z + offset[2]) * -1
          )
          cube_group.add(cube)
        end
      end
    end
  end

  def update_matrix
    # The remove method calls "delete_at", so we have to delete from the end.
    cube_group.children.reverse_each { |c| cube_group.remove(c) }
    add_matrix
  end

  def on_key_typed(key)
    super

    case key
    when GLFW_KEY_UP
      @selected_piece_index += 1
      @selected_piece_index = 0 if @selected_piece_index >= @puzzle_pieces.size
    when GLFW_KEY_DOWN
      @selected_piece_index -= 1
      @selected_piece_index = @puzzle_pieces.size - 1 if @selected_piece_index < 0
    when GLFW_KEY_M
      change_mode
    else
      return
    end

    update_matrix
  end

  def change_mode
    next_index = MODES.index(mode) + 1
    next_index = 0 if next_index >= MODES.size
    self.mode = MODES[next_index]
    puts "Changed mode: #{mode}"

    update_matrix
  end
end

PuzzleGeneratorScene.new.run!

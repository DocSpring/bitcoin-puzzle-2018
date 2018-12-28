#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'base_scene'
require 'puzzle_generator'

class PuzzleGeneratorScene < BaseScene
  COLORS = [
    0xee1111,
    0x11ee11,
    0x1111ee,
    0xdd11ee,
    0x11ddee,
    0xddee11
  ].freeze

  attr_accessor :size, :cube_group, :puzzle_generator, :puzzle_pieces, :piece_index

  def initialize
    super

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
    @puzzle_generator = PuzzleGenerator.new(
      seed: 124,
      width: size,
      height: size,
      depth: size,
      min_length: min_length,
      max_length: max_length
    )
    @puzzle_pieces = puzzle_generator.generate_pieces

    @piece_index = 0

    puts "==> Generated #{@puzzle_pieces.size} puzzle pieces"

    add_matrix
  end

  def add_matrix
    current_piece = puzzle_pieces[piece_index]

    puts "Showing piece: #{piece_index + 1} / #{puzzle_pieces.size} " \
      "(#{current_piece[0].join(', ')})"

    puzzle_pieces.each_with_index do |piece, current_piece_index|
      x_offset, y_offset, z_offset = piece[0]
      matrix = piece[1]

      # Center the pieces in the window
      x_offset -= (puzzle_generator.width - 1) / 2
      y_offset -= (puzzle_generator.height - 1) / 2
      z_offset -= (puzzle_generator.depth - 1) / 2

      matrix.array.each_with_index do |z_plane, z|
        z_plane.each_with_index do |rows, y|
          rows.each_with_index do |value, x|
            next if value == false

            opacity =
              if current_piece_index == piece_index
                1
              elsif size < 5
                0.2
              else
                0.08
              end

            material = Mittsu::MeshLambertMaterial.new(
              color: COLORS[current_piece_index % COLORS.size],
              opacity: opacity,
              transparent: true
            )
            cube = Mittsu::Mesh.new(BOX_GEOMETRY, material)
            cube.position.set(
              x + x_offset,
              (y + y_offset) * -1,
              (z + z_offset) * -1
            )
            cube_group.add(cube)
          end
        end
      end
    end
  end

  def reset_matrix
    # The remove method calls "delete_at", so we have to delete from the end.
    cube_group.children.reverse_each { |c| cube_group.remove(c) }
    add_matrix
  end

  def on_key_typed(key)
    super

    case key
    when GLFW_KEY_UP
      @piece_index += 1
      @piece_index = 0 if @piece_index >= @puzzle_pieces.size
    when GLFW_KEY_DOWN
      @piece_index -= 1
      @piece_index = @puzzle_pieces.size - 1 if @piece_index < 0
    else
      return
    end

    reset_matrix
  end
end

PuzzleGeneratorScene.new.run!

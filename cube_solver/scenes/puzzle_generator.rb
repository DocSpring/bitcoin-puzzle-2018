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

  attr_accessor :cube_group, :puzzle_pieces, :piece_index

  def initialize
    super

    @cube_group = Mittsu::Group.new
    @scene.add(@cube_group)

    @puzzle_pieces = PuzzleGenerator.new(
      seed: 123,
      width: 3,
      height: 3,
      depth: 3,
      max_length: 3
    ).generate_pieces

    @piece_index = 0

    puts "==> Generated #{@puzzle_pieces.size} puzzle pieces"

    add_matrix
  end

  def add_matrix
    puts "Showing piece: #{piece_index + 1} / #{puzzle_pieces.size}"

    puzzle_pieces.each_with_index do |matrix, current_piece_index|
      matrix.array.each_with_index do |z_plane, z|
        z_plane.each_with_index do |rows, y|
          rows.each_with_index do |value, x|
            next if value == false

            opacity = current_piece_index == piece_index ? 1.0 : 0.2

            material = Mittsu::MeshLambertMaterial.new(
              color: COLORS[current_piece_index % COLORS.size],
              opacity: opacity,
              transparent: true
            )
            cube = Mittsu::Mesh.new(BOX_GEOMETRY, material)
            cube.position.set(x - 1, y * -1 + 1, z * -1 + 1)
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
      @piece_index = @puzzle_pieces.size if @piece_index < 0
    else
      return
    end

    reset_matrix
  end
end

PuzzleGeneratorScene.new.run!

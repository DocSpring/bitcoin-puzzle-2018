#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'base_scene'

class RotateLScene < BaseScene
  COLORS = [0xee1111, 0x11ee11, 0x1111ee, 0xdd11ee].freeze

  attr_accessor :cube_group, :matrix

  def initialize
    super

    @cube_group = Mittsu::Group.new
    @scene.add(@cube_group)
    self.matrix = Fixtures::MATRIX_3D[:L3]

    add_matrix
  end

  def add_matrix
    matrix.array.each_with_index do |z_plane, z|
      z_plane.each_with_index do |rows, y|
        rows.each_with_index do |value, x|
          next if value == 0

          material = Mittsu::MeshLambertMaterial.new(
            color: COLORS[value - 1],
            opacity: 0.4
          )
          cube = Mittsu::Mesh.new(BOX_GEOMETRY, material)
          cube.position.set(x - 1, y * -1 + 1, z * -1 + 1)
          cube_group.add(cube)
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
    when GLFW_KEY_X
      self.matrix = matrix.rotate_x(90)
    when GLFW_KEY_Y
      self.matrix = matrix.rotate_y(90)
    when GLFW_KEY_Z
      self.matrix = matrix.rotate_z(90)
    else
      return
    end

    reset_matrix
  end
end

RotateLScene.new.run!

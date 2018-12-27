# frozen_string_literal: true

$LOAD_PATH << File.expand_path('../lib', __dir__)

require 'pry-byebug'
require 'mittsu'
require_relative '../spec/support/fixtures'

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ASPECT = SCREEN_WIDTH.to_f / SCREEN_HEIGHT.to_f

@scene = Mittsu::Scene.new
renderer = Mittsu::OpenGLRenderer.new width: SCREEN_WIDTH, height: SCREEN_HEIGHT, title: '12 Orbit/Zoom Example'

light = Mittsu::DirectionalLight.new(0xffffff, 0.6)
light.position.set(0.5, 1.0, 0.0)
light_object = Mittsu::Object3D.new
light_object.add(light)
@scene.add(light_object)
light = Mittsu::AmbientLight.new(0x777777)
@scene.add(light)
light = Mittsu::HemisphereLight.new(0xFFFFFF, 0x404040, 0.5)
@scene.add(light)

axis_object = Mittsu::Object3D.new
axis_object.add(Mittsu::Mesh.new(
                  Mittsu::BoxGeometry.new(10.0, 0.05, 0.05),
                  Mittsu::MeshBasicMaterial.new(color: 0xff0000, opacity: 0.2)
                ))
axis_object.add(Mittsu::Mesh.new(
                  Mittsu::BoxGeometry.new(0.05, 10.0, 0.05),
                  Mittsu::MeshBasicMaterial.new(color: 0x00ff00, opacity: 0.2)
                ))
axis_object.add(Mittsu::Mesh.new(
                  Mittsu::BoxGeometry.new(0.05, 0.05, 10.0),
                  Mittsu::MeshBasicMaterial.new(color: 0x0000ff, opacity: 0.2)
                ))
@scene.add(axis_object)

@colors = [0xee1111, 0x11ee11, 0x1111ee, 0xdd11ee]
@group = Mittsu::Group.new

@box_geometry = Mittsu::BoxGeometry.new(1.0, 1.0, 1.0)

@matrix = Fixtures::MATRIX_3D[:L3]

def add_matrix_to_scene
  @matrix.array.each_with_index do |z_plane, z|
    z_plane.each_with_index do |rows, y|
      rows.each_with_index do |value, x|
        next if value == 0

        material = Mittsu::MeshLambertMaterial.new(
          color: @colors[value - 1],
          opacity: 0.4
        )
        cube = Mittsu::Mesh.new(@box_geometry, material)
        cube.position.set(x - 1, y * -1 + 1, z * -1 + 1)
        @group.add(cube)
      end
    end
  end
end

add_matrix_to_scene
@scene.add(@group)

X_AXIS = Mittsu::Vector3.new(1.0, 0.0, 0.0)
Y_AXIS = Mittsu::Vector3.new(0.0, 1.0, 0.0)

@camera = Mittsu::PerspectiveCamera.new(75.0, ASPECT, 0.1, 1000.0)
@camera.position.z = 5.0
@camera_container = Mittsu::Group.new
@camera_container.add(@camera)

def set_default_camera_zoom_and_rotation
  @camera_container.rotation.x = 0.91
  @camera_container.rotation.y = 0.44
  @camera_container.rotation.z = 0.36
  @camera.zoom = 0.75
  @camera.update_projection_matrix
end

set_default_camera_zoom_and_rotation

@scene.add(@camera_container)

renderer.window.on_key_typed do |key|
  case key
  when GLFW_KEY_X
    @matrix = @matrix.rotate_x(90)
  when GLFW_KEY_Y
    @matrix = @matrix.rotate_y(90)
  when GLFW_KEY_Z
    @matrix = @matrix.rotate_z(90)
  when GLFW_KEY_R
    puts 'Reset camera zoom and rotation'
    set_default_camera_zoom_and_rotation
  else
    next
  end

  # The remove method calls "delete_at", so we have to delete from the end.
  @group.children.reverse_each { |c| @group.remove(c) }

  add_matrix_to_scene
end

renderer.window.on_scroll do |offset|
  scroll_factor = (1.5**(offset.y * 0.1))
  @camera.zoom *= scroll_factor
  @camera.update_projection_matrix
  # puts "Zoom: #{@camera.zoom}"
end

mouse_delta = Mittsu::Vector2.new
last_mouse_position = Mittsu::Vector2.new

renderer.window.on_mouse_button_pressed do |button, position|
  last_mouse_position.copy(position) if button == GLFW_MOUSE_BUTTON_LEFT
end

renderer.window.on_mouse_move do |position|
  if renderer.window.mouse_button_down?(GLFW_MOUSE_BUTTON_LEFT)
    mouse_delta.copy(last_mouse_position).sub(position)
    last_mouse_position.copy(position)

    @camera_container.rotate_on_axis(Y_AXIS, mouse_delta.x * 0.01)
    @camera_container.rotate_on_axis(X_AXIS, mouse_delta.y * 0.01)

    # rotation = @camera_container.rotation
    # puts "Rotation: #{rotation.x}, #{rotation.y}, #{rotation.z}"
  end
end

renderer.window.on_resize do |width, height|
  renderer.set_viewport(0, 0, width, height)
  @camera.aspect = width.to_f / height.to_f
  @camera.update_projection_matrix
end

renderer.window.run do
  renderer.render(@scene, @camera)
end

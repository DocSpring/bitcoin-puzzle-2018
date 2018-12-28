# frozen_string_literal: true

$LOAD_PATH << File.expand_path('../lib', __dir__)

require 'pry-byebug'
require 'awesome_print'
require 'mittsu'
require_relative '../spec/support/fixtures'

class BaseScene
  SCREEN_WIDTH = 800
  SCREEN_HEIGHT = 600
  ASPECT = SCREEN_WIDTH.to_f / SCREEN_HEIGHT.to_f

  BOX_GEOMETRY = Mittsu::BoxGeometry.new(1.0, 1.0, 1.0)

  AXIS_LENGTH = 20.0
  AXIS_WIDTH = 0.02

  X_AXIS = Mittsu::Vector3.new(1.0, 0.0, 0.0)
  Y_AXIS = Mittsu::Vector3.new(0.0, 1.0, 0.0)

  attr_accessor :scene, :renderer, :camera, :camera_container

  def initialize
    @scene = Mittsu::Scene.new
    @renderer = Mittsu::OpenGLRenderer.new(
      width: SCREEN_WIDTH,
      height: SCREEN_HEIGHT,
      title: 'Cube Solver Visualization'
    )

    add_camera
    add_lighting
    add_axis
    register_event_handlers
  end

  def add_lighting
    light = Mittsu::DirectionalLight.new(0xffffff, 0.6)
    light.position.set(0.5, 1.0, 0.0)
    light_object = Mittsu::Object3D.new
    light_object.add(light)
    scene.add(light_object)
    light = Mittsu::AmbientLight.new(0x777777)
    scene.add(light)
    light = Mittsu::HemisphereLight.new(0xFFFFFF, 0x404040, 0.5)
    scene.add(light)
  end

  def add_camera
    @camera = Mittsu::PerspectiveCamera.new(75.0, ASPECT, 0.1, 1000.0)
    camera.position.z = 5.0
    @camera_container = Mittsu::Group.new
    camera_container.add(@camera)
    set_default_camera_zoom_and_rotation

    scene.add(camera_container)
  end

  def set_default_camera_zoom_and_rotation
    camera_container.rotation.x = 0.91
    camera_container.rotation.y = 0.44
    camera_container.rotation.z = 0.36
    camera.zoom = 0.75
    camera.update_projection_matrix
  end

  def add_axis
    axis_object = Mittsu::Object3D.new
    axis_object.add(Mittsu::Mesh.new(
                      Mittsu::BoxGeometry.new(AXIS_LENGTH, AXIS_WIDTH, AXIS_WIDTH),
                      Mittsu::MeshBasicMaterial.new(color: 0xff0000, opacity: 0.2)
                    ))
    axis_object.add(Mittsu::Mesh.new(
                      Mittsu::BoxGeometry.new(AXIS_WIDTH, AXIS_LENGTH, AXIS_WIDTH),
                      Mittsu::MeshBasicMaterial.new(color: 0x00ff00, opacity: 0.2)
                    ))
    axis_object.add(Mittsu::Mesh.new(
                      Mittsu::BoxGeometry.new(AXIS_WIDTH, AXIS_WIDTH, AXIS_LENGTH),
                      Mittsu::MeshBasicMaterial.new(color: 0x0000ff, opacity: 0.2)
                    ))
    scene.add(axis_object)
  end

  def register_event_handlers
    renderer.window.on_key_typed do |key|
      on_key_typed(key)
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
  end

  # Can override in subclass
  def on_key_typed(key)
    case key
    when GLFW_KEY_R
      puts 'Reset camera zoom and rotation'
      set_default_camera_zoom_and_rotation
    when GLFW_KEY_Q
      puts 'Quitting...'
      exit
    end
  end

  def next_frame; end

  def run!
    fixed_opengl = false
    start_time = Time.now
    renderer.window.run do
      next_frame
      renderer.render(@scene, @camera)

      if !fixed_opengl && Time.now - start_time > 0.5
        # Workaround for OpenGL bug on MacOS Mojave
        # Have to slightly move the window to start the rendering,
        # otherwise it stays black.
        # See: https://stackoverflow.com/a/52915794/304706
        fixed_opengl = true
        glfw_handle = renderer.window.instance_variable_get('@handle')
        x = ' ' * 8
        y = ' ' * 8
        glfwGetWindowPos(glfw_handle, x, y)
        x = x.unpack1('L')
        y = y.unpack1('L')
        glfwSetWindowPos(glfw_handle, x + 1, y)
      end
    end
  end
end

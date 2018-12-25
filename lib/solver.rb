# frozen_string_literal: true

require 'logger'

class Solver
  class SolverError < StandardError; end
  class RegisterOutOfBounds < SolverError; end

  MAX_INT = 4_294_967_295
  MOD_INT = MAX_INT + 1

  MAGIC_OUTPUT_STRING = '9eff33ffb0'

  INSTRUCTIONS = {
    '00' => :mov_const,
    '01' => :mov_reg,
    '02' => :inc,
    '03' => :dec,
    '06' => :add,
    '07' => :sub,
    '08' => :mul,
    '09' => :div,
    '0a' => :and,
    '0b' => :or,
    '0c' => :xor,
    '0d' => :not,
    '0e' => :right_shift,
    '0f' => :left_shift,
    'fe' => :print_ascii_reset,
    'ff' => :print_hex_reset
  }.freeze
  CONST_INSTRUCTIONS = %i[
    mov_const add_const sub_const
  ].freeze
  SINGLE_REGISTER_INSTRUCTIONS = %i[
    inc dec not right_shift left_shift
  ].freeze
  DOUBLE_REGISTER_INSTRUCTIONS = %i[
    mov_reg add sub mul div
    and or xor
  ].freeze

  INSTRUCTION_ARG_LENGTHS = begin
    hash = {
      print_ascii_reset: 5,
      print_hex_reset: 5
    }
    CONST_INSTRUCTIONS.each { |k| hash[k] = 5 }
    SINGLE_REGISTER_INSTRUCTIONS.each { |k| hash[k] = 1 }
    DOUBLE_REGISTER_INSTRUCTIONS.each { |k| hash[k] = 2 }
    hash
  end

  attr_accessor :log, :registers, :state, :instruction, :args, :output, :output_mode

  def initialize
    reset_state!
    @output = []
    # Set default output mode (but it is persistent once changed.)
    @output_mode = :hex

    @log = Logger.new(STDOUT)
    @log.level = Logger::WARN
    @log.level = Logger::DEBUG if ENV['DEBUG']
  end

  def reset_state!
    @state = :pending_instruction
    @registers = [0] * 16
    @instruction = nil
    @args = []
    # Don't reset the output mode every time.
    # @output_mode = :hex
  end

  def solve(input)
    # log.debug "[Input] '#{input}'"
    input.scan(/.{2}/) do |hex_byte|
      process_byte(hex_byte)
    end

    flush_registers_to_output!

    output_string = @output.join('')
    log.info "[Output] '#{output_string}'"
    output_string
  end

  def set_state(state)
    self.state = state
    case state
    when :pending_instruction
      self.instruction = nil
      args.clear
    end
  end

  def flush_registers_to_output!
    log.info 'Flushing registers to output...'

    hex_string = registers_to_hex

    if output_mode == :hex
      output << hex_string
    elsif output_mode == :ascii
      ascii = [hex_string].pack('H*').sub(/\x00+$/, '')
      output << ascii
    else
      raise "Invalid output mode! '#{output_mode}'"
    end
  end

  def registers_to_hex
    trimmed_registers = []
    found_nonzero = false
    @registers[0, 8].dup.reverse_each do |value|
      found_nonzero = true if value != 0
      trimmed_registers.unshift(value) if found_nonzero
    end
    # Always show at least the first value.
    trimmed_registers << @registers[0] if trimmed_registers.empty?

    trimmed_registers.map do |val|
      val.to_s(16).rjust(2 * 4, '0')
    end.join('')
  end

  def process_byte(byte)
    # log "Received byte: #{byte}"
    case state
    when :pending_instruction
      # Just skip unknown instructions
      return unless next_instruction = INSTRUCTIONS[byte]

      self.instruction = next_instruction
      set_state(:pending_args)
    when :pending_args
      args << byte
    end

    if instruction && args.size == INSTRUCTION_ARG_LENGTHS[instruction]
      begin
        process_instruction
      rescue SolverError
      end
      set_state(:pending_instruction)
    end
  end

  def process_instruction
    return unless instruction

    # The print_ascii_reset or print_hex_reset instructions
    # are only triggered when the args match a special value.
    # This lets us run the solver on random PDFs and images
    # without triggering it unintentionally.
    if %i[print_ascii_reset print_hex_reset].include?(instruction)
      return unless args.join('') == MAGIC_OUTPUT_STRING

      if instruction == :print_ascii_reset
        if @output_mode != :ascii
          log.info 'Setting output to ASCII...'
          @output_mode = :ascii
        end
      else
        if @output_mode != :hex
          log.info 'Setting output to Hex...'
          @output_mode = :hex
        end
      end

      flush_registers_to_output!
      reset_state!
      return
    end

    # The first arg for every instruction is always a register,
    # apart from some special cases
    register_to_hex = args.shift
    register_to = register_to_hex.to_i(16)
    ensure_valid_register!(register_to)

    register_from_hex = nil
    if DOUBLE_REGISTER_INSTRUCTIONS.include?(instruction)
      register_from_hex = args.shift
      register_from = register_from_hex.to_i(16)
      ensure_valid_register!(register_from)
    end

    log.info "Running instruction: #{instruction} " \
      "#{register_to_hex} #{register_from_hex} #{args.join(' ')}"

    case instruction
    when :mov_const
      value = args.join('').to_i(16)
      registers[register_to] = value

    when :mov_reg
      registers[register_to] = registers[register_from]

    when :inc, :dec
      diff = instruction == :inc ? 1 : -1
      registers[register_to] += diff

    when :add, :sub
      if instruction == :add
        registers[register_to] += registers[register_from]
      else
        registers[register_to] -= registers[register_from]
      end
    when :mul, :div
      if instruction == :mul
        registers[register_to] *= registers[register_from]
      else
        if registers[register_from] == 0
          # When dividing by zero, set the register to the maximum int value
          # (Emulates infinity)
          registers[register_to] = MAX_INT
        else
          registers[register_to] /= registers[register_from]
        end
      end
    when :and
      registers[register_to] &= registers[register_from]
    when :or
      registers[register_to] |= registers[register_from]
    when :xor
      registers[register_to] ^= registers[register_from]
    when :not
      registers[register_to] = ~registers[register_to]

    when :right_shift
      registers[register_to] = registers[register_to] >> 1

    when :left_shift
      registers[register_to] = registers[register_to] << 1
    end

    check_overflow(register_to) if register_to
  end

  def check_overflow(register)
    registers[register] %= MOD_INT
  end

  def ensure_valid_register!(register)
    raise RegisterOutOfBounds if register > 15
  end
end

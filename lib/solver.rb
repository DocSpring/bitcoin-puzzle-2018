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
    'fe' => :set_output_to_ascii,
    'ff' => :print_hex_and_reset
  }.freeze
  CONST_INSTRUCTIONS = %i[
    mov_const add_const sub_const
  ].freeze
  SINGLE_REGISTER_INSTRUCTIONS = %i[
    inc dec not
  ].freeze
  DOUBLE_REGISTER_INSTRUCTIONS = %i[
    mov_reg add sub mul div
    and or xor
  ].freeze

  INSTRUCTION_ARG_LENGTHS = begin
    hash = {
      set_output_to_ascii: 5,
      print_hex_and_reset: 5
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

    @log = Logger.new(STDOUT)
    @log.level = Logger::WARN
    # @log.level = Logger::INFO
  end

  def reset_state!
    @state = :pending_instruction
    @registers = [0] * 16
    @instruction = nil
    @args = []
    @output_mode = :hex
  end

  def solve(input)
    log.debug "[Input] '#{input}'"
    byte = +''
    input.scan(/.{1}/) do |char|
      next if char == ' '

      byte << char
      if byte.size == 2
        process_byte byte
        byte = +''
      end
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
    hex_string = registers_to_hex

    # puts hex_string.inspect

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

      log.debug "Setting instruction: #{next_instruction} (#{byte})"
      self.instruction = next_instruction
      set_state(:pending_args)
    when :pending_args
      log.debug "Pushing arg: #{byte}"
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

    # The set_output_to_ascii or print_hex_and_reset instructions
    # are only triggered when the args match a special value.
    # This lets us run the solver on random PDFs and images
    # without triggering this unintentionally.
    if instruction == :set_output_to_ascii
      return unless args.join('') == MAGIC_OUTPUT_STRING

      log.info 'Setting output to ASCII...'

      @output_mode = :ascii
      return
    end

    if instruction == :print_hex_and_reset
      return unless args.join('') == MAGIC_OUTPUT_STRING

      log.info 'Flushing registers to output...'

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
    end

    check_overflow(register_to) if register_to
  end

  def check_overflow(register)
    registers[register] = registers[register] % MOD_INT
  end

  def ensure_valid_register!(register)
    raise RegisterOutOfBounds if register > 15
  end
end

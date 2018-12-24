# frozen_string_literal: true

require_relative './solver.rb'
require 'pry-byebug'
require 'securerandom'

# This program compiles a string into a bytecode program
# that will print out that string.
class StringCompiler
  attr_accessor :input, :options, :as_ascii, :encrypt

  def initialize(input, options = {})
    @input = input
    @options = options

    @as_ascii = options[:ascii]
    @encrypt = options[:encrypt]
  end

  def compile
    if encrypt
      compile_encrypted
    else
      compile_plain
    end
  end

  def compile_plain
    bytes = input.unpack('C*')

    instructions = []

    register_index = 0
    bytes.each_slice(4).each do |byte_group|
      byte_group << 0 while byte_group.size < 4
      hex_group = byte_group.pack('C*').unpack1('H*')

      register = register_index.to_s(16).rjust(2, '0')
      instructions << "00#{register}#{hex_group}"

      register_index += 1

      next unless register_index > 7

      # We only have 8 registers that print output.
      # Set output to ASCII (if required), print output, then reset.
      instructions << "fe#{Solver::MAGIC_OUTPUT_STRING}" if as_ascii
      instructions << "ff#{Solver::MAGIC_OUTPUT_STRING}"

      register_index = 0
    end

    # We always need to append this instruction, even if all registers are zeroed.
    # Otherwise the output ends with 00000000
    instructions << "fe#{Solver::MAGIC_OUTPUT_STRING}" if as_ascii

    instructions.join(' ')
  end

  # Just adds some simple obfuscation using all of the instructions
  def compile_encrypted
    bytes = input.unpack('C*')

    instructions = []
    random_instructions = []
    mov_xor_instructions = []

    # xor_instructions = []
    random_values = []
    random_value_ints = []

    register_index = 0
    bytes.each_slice(4).each do |byte_group|
      if register_index.zero?
        # Initialize the random values and load them into spare registers
        random_values = Array.new(8) { SecureRandom.hex(4) }
        random_values.each_with_index do |val, i|
          register = (i + 8).to_s(16).rjust(2, '0')
          random_instructions << "00#{register}#{val}"
        end
        random_value_ints = random_values.map do |val|
          val.scan(/../).map(&:hex).pack('C*').unpack1('N')
        end

        random_instructions.shuffle!
      end

      byte_group << 0 while byte_group.size < 4

      # Don't add offset here.
      random_value_index = register_index #  (7 - register_index) % 4
      # random_hex = random_values[random_value_index]
      # random_bytes = random_hex.scan(/../).map(&:hex)
      random_int = random_value_ints[random_value_index]

      # encrypted_byte_group = byte_group.map.with_index do |byte, byte_index|
      #   # ~((byte ^ random_bytes[byte_index]) ^ (byte_index + 42))
      #   byte ^ random_bytes[byte_index]
      # end
      hex_group = byte_group.pack('C*').unpack1('H*')

      # Convert to 4-byte unsigned int
      integer = hex_group.scan(/../).map(&:hex).pack('C*').unpack1('N')

      # XOR with random byte
      integer ^= random_int

      # Increment or decrement based on register index
      # integer += register_index.even? ? -1 : 1
      # integer = integer % Solver::MOD_INT

      # Repack into hex string
      hex_group = [integer].pack('N').unpack1('H*')

      register = register_index.to_s(16).rjust(2, '0')
      mov_instruction = "00#{register}#{hex_group}"

      random_register = (random_value_index + 8).to_s(16).rjust(2, '0')
      xor_instruction = "0c#{register}#{random_register}"

      mov_xor_instructions << [
        mov_instruction,
        xor_instruction
      ]

      register_index += 1

      next unless register_index > 7

      # Add all the instructions in a random order.

      random_instructions.each { |i| instructions << i }
      mov_xor_instructions.shuffle.each do |tuple|
        tuple.each { |i| instructions << i }
      end

      random_instructions = []
      mov_xor_instructions = []

      # Now that we've loaded all of the encrypted bytes, run the code
      # that decrypts them.

      # # Start by setting 42 in the last register
      # instructions << '000f0000002a'

      # We only have 8 registers that print output.
      # Set output to ASCII (if required), print output, then reset.
      instructions << "fe#{Solver::MAGIC_OUTPUT_STRING}" if as_ascii
      instructions << "ff#{Solver::MAGIC_OUTPUT_STRING}"

      register_index = 0
      # xor_instructions = []
    end

    # Add any remaining instructions
    random_instructions.each { |i| instructions << i }
    mov_xor_instructions.shuffle.each do |tuple|
      tuple.each { |i| instructions << i }
    end

    # We always need to append this instruction, even if all registers are zeroed.
    # Otherwise the output ends with 00000000
    instructions << "fe#{Solver::MAGIC_OUTPUT_STRING}" if as_ascii

    instructions.join(' ')
  end
end

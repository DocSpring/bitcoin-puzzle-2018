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
end

# frozen_string_literal: true

require_relative './solver.rb'
require_relative './register_sorter.rb'
require 'pry-byebug'
require 'securerandom'

# This program compiles a string into a bytecode program
# that will print out that string.
class StringCompiler
  attr_accessor :input, :options, :as_ascii, :flush_instruction, :encrypt

  def initialize(input, options = {})
    @input = input
    @options = options

    @as_ascii = options[:ascii]
    flush_byte = as_ascii ? 'fe' : 'ff'
    @flush_instruction = "#{flush_byte}#{Solver::MAGIC_OUTPUT_STRING}"

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
      instructions << flush_instruction

      register_index = 0
    end

    # Make sure format is set to ASCII if required
    instructions << flush_instruction if as_ascii && instructions.last != flush_instruction

    instructions.join(' ')
  end

  # Just adds some simple obfuscation using all of the instructions
  def compile_encrypted
    bytes = input.unpack('C*')

    instructions = []

    bytes.each_slice(4 * 8).each do |register_group|
      random_instructions = []
      register_instructions = []

      # xor_instructions = []
      random_values = []
      random_value_ints = []

      variable_value = 42

      # Shuffle values
      integer_values = register_group.each_slice(4).map do |byte_group|
        byte_group << 0 while byte_group.size < 4
        byte_group.pack('C*').unpack1('N')
      end
      integer_values << 0 while integer_values.size < 8

      # Generates the sort operations needed to shuffle the registers
      # We replay these in reverse before printing the output
      shuffle_order = (0..7).to_a.shuffle
      # puts shuffle_order.inspect
      shuffle_register_operations = RegisterSorter.sort_and_generate_operations(
        values: integer_values,
        order: shuffle_order,
        # Pick a random temporary register each time
        temp_register: (8..15).to_a.sample
      )

      # Now XOR all the registers together in a sequence
      # These XOR operations needs to happen before we unshuffle the registers.
      xor_instructions = []
      xor_sequence = (0..7).to_a.shuffle

      # Also we throw in another random value in the middle.
      # Make sure we keep 0f (15) zero so we can do the divide by zero trick.
      random_register_int = (8..14).to_a.sample
      random_register = random_register_int.to_s(16).rjust(2, '0')
      random_value = SecureRandom.hex(4)
      random_int = random_value.scan(/../).map(&:hex).pack('C*').unpack1('N')

      xor_sequence.each_with_index do |xor_index, index|
        next if index.zero?

        to_index = xor_sequence[index - 1]
        from_index = xor_index
        integer_values[to_index] ^= integer_values[from_index]

        to_register = to_index.to_s(16).rjust(2, '0')
        from_register = from_index.to_s(16).rjust(2, '0')
        xor_instructions.unshift("0c#{to_register}#{from_register}")

        if index == 2
          integer_values[to_index] -= 1
          integer_values[to_index] %= Solver::MOD_INT
          xor_instructions.unshift("02#{to_register}")
        elsif index == 6
          integer_values[to_index] += 1
          integer_values[to_index] %= Solver::MOD_INT
          xor_instructions.unshift("03#{to_register}")
        end

        next unless index == 4

        # We add a random number to this index, so then we need to
        # subtract it. (Operations unshifted in reverse order)
        # This random value is un-shifted into the register below
        # (which puts it at the beginning of the array)
        integer_values[to_index] += random_int
        integer_values[to_index] %= Solver::MOD_INT
        xor_instructions.unshift "07#{to_register}#{random_register}"
      end

      # Set the random value in the temp register before running the XOR operations.
      xor_instructions.unshift "00#{random_register}#{random_value}"

      bitshift_registers = (0..7).to_a.sample(3)

      integer_values.each_with_index do |integer, register_index|
        if register_index.zero?
          # Initialize the random values and load them into spare registers
          random_values = Array.new(4) { SecureRandom.hex(4) }
          random_values.each_with_index do |val, i|
            register = (i + 8).to_s(16).rjust(2, '0')
            random_instructions << "00#{register}#{val}"
          end
          random_value_ints = random_values.map do |val|
            val.scan(/../).map(&:hex).pack('C*').unpack1('N')
          end

          # Set 42 in register 5. This is incremented,
          # subtract, decrement, added, xored, multiplied, xored,
          # then divided by 10.
          # (in a loop)
          variable_hex = variable_value.to_s(16).rjust(2, '0')
          random_instructions << "000c000000#{variable_hex}"

          # Shuffle all the random constants
          random_instructions.shuffle!
        end

        # The current register
        register = register_index.to_s(16).rjust(2, '0')

        # byte_group << 0 while byte_group.size < 4

        # Just use 4 registers for random data
        random_value_index = (7 - register_index) % 4
        # random_hex = random_values[random_value_index]
        # random_bytes = random_hex.scan(/../).map(&:hex)
        random_int = random_value_ints[random_value_index]

        # XOR with random byte
        integer ^= random_int
        random_register = (random_value_index + 8).to_s(16).rjust(2, '0')
        xor_random_instruction = "0c#{register}#{random_register}"

        # Adjust the variable, and perform the same operation in bytecode
        case register_index % 8
        when 0 # inc
          variable_value += 1
          variable_instruction = '020c'
        when 1 # sub
          # The previous register is now decrypted, so we can use this value.
          previous_register_index = register_index - 1
          previous_value = integer_values[previous_register_index]
          previous_register = previous_register_index.to_s(16).rjust(2, '0')

          variable_value -= previous_value
          variable_instruction = "070c#{previous_register}"
        when 2 # dec
          variable_value -= 1
          variable_instruction = '030c'
        when 3 # add
          variable_value += random_int
          variable_instruction = "060c#{random_register}"
        when 4 # xor previous
          previous_register_index = register_index - 1
          previous_value = integer_values[previous_register_index]
          previous_register = previous_register_index.to_s(16).rjust(2, '0')
          variable_value ^= previous_value
          variable_instruction = "0c0c#{previous_register}"
        when 5 # mul
          previous_register_index = register_index - 1
          previous_value = integer_values[previous_register_index]
          previous_register = previous_register_index.to_s(16).rjust(2, '0')

          variable_value *= previous_value
          variable_instruction = "080c#{previous_register}"
        when 6 # div
          # We need to set up another small constant in another register,
          # otherwise the result will often be zero
          variable_value /= 7
          variable_instruction = '000d00000007 090c0d'
        when 7
          # xor the actual integer with
          # some random previous registers (not including itself)
          variable_instructions = []

          # Also NOT the variable
          variable_value = ~variable_value
          variable_instructions << '0d0c'

          value_and_index = integer_values[0...-1].each_with_index.to_a

          value_and_index.sample(4).each do |(int, reg_index)|
            integer ^= int
            previous_register = reg_index.to_s(16).rjust(2, '0')
            variable_instructions << "0c#{register}#{previous_register}"
          end

          variable_instruction = variable_instructions.shuffle.join(' ')
        end

        variable_value = variable_value % Solver::MOD_INT

        # XOR with the variable
        integer ^= variable_value
        xor_variable_instruction = "0c#{register}0c"

        extra_instructions = []
        if register_index == bitshift_registers[0]
          # Right shift the integer value to zero out the last bit
          # - Divide zero by zero to get ffffffff (0f register is zero by default)
          # - Left shift to get fffffffe
          # - NOT to get 00000001
          # - Left shift the integer to restore the bits (apart from the last one)
          # - OR 00000001 with the integer to set the last bit (if necessary)
          last_bit = integer & 1
          integer >>= 1
          extra_instructions << "0f#{register}"

          extra_instructions << '090f0f'
          extra_instructions << '0f0f' if last_bit == 1
          extra_instructions << '0d0f'
          extra_instructions << "0b#{register}0f"
          # Right shift to reset 0f to 00000000 if needed
          extra_instructions << '0e0f' if last_bit == 1

        elsif register_index == bitshift_registers[1]
          # This time use a left shift instead of a right shift.
          first_bit = integer >> ((8 * 4) - 1) & 1
          integer <<= 1
          extra_instructions << "0e#{register}"

          extra_instructions << '090f0f'
          extra_instructions << '0e0f' if first_bit == 1
          extra_instructions << '0d0f'
          extra_instructions << "0b#{register}0f"
          # Left shift to reset 0f to 00000000 if needed
          extra_instructions << '0f0f' if first_bit == 1

        elsif register_index == bitshift_registers[2]
          # This time use AND instead of NOT + OR
          last_bit = integer & 1

          # 0 & 1 is always 0, so we can't do any shifting,
          # but at least we can make the 0f bytes end in 0.
          # (So we will always do 0 & 0 = 0)

          # if last_bit.zero?
          #   integer >>= 1
          #   extra_instructions << "0f#{register}"
          # end

          extra_instructions << '090f0f'
          extra_instructions << '0f0f' if last_bit.zero?

          extra_instructions << "0a#{register}0f"

          # NOT to reset to 00000000 or 00000001
          extra_instructions << '0d0f'
          # Right shift to reset to 00000000
          extra_instructions << '0e0f' if last_bit.zero?
        end

        integer %= Solver::MOD_INT

        # Repack into hex string
        hex_group = [integer].pack('N').unpack1('H*')

        # Store the current integer into the register
        mov_instruction = "00#{register}#{hex_group}"

        register_instructions << [
          mov_instruction,
          extra_instructions.join(' '),
          variable_instruction,
          xor_random_instruction,
          xor_variable_instruction
        ].compact
      end

      # Add all the random value instructions in a random order.
      random_instructions.shuffle.each { |i| instructions << i }

      # Important - We can't shuffle these, because the
      # variable instructions depend on the order of operations.
      register_instructions.each do |instruction_group|
        instruction_group.each { |i| instructions << i }
      end

      # Now that we've loaded all of the encrypted bytes, run the code
      # that decrypts them.

      # # Start by setting 42 in the last register
      # instructions << '000f0000002a'

      # Run all the XOR instructions
      xor_instructions.each { |i| instructions << i }

      # Now take all of the sort instructions from the beginning,
      # and replay them in reverse. This unshuffles the registers
      # into the original order.
      shuffle_register_operations.reverse_each do |(to, from)|
        to_reg = to.to_s(16).rjust(2, '0')
        from_reg = from.to_s(16).rjust(2, '0')
        instructions << "01#{from_reg}#{to_reg}"
      end

      # We only have 8 registers that can print to output.
      # Set output format to ascii, print output, reset state.
      instructions << flush_instruction
    end

    # Make sure format is set to ASCII if required
    instructions << flush_instruction if as_ascii && instructions.last != flush_instruction

    instructions.join(' ')
  end
end

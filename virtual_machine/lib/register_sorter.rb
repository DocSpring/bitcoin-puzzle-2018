# frozen_string_literal: true

# This class generates the instructions to randomly shuffle registers
class RegisterSorter
  # Shuffle all the registers and return the sequence of operations,
  # using a single temp register. Sometimes the shuffle can be
  # performed as a single chain, and other times the temp variable
  # needs to be flushed and then reset. Also if an index is unchanged
  # then no instructions are needed.
  def self.sort_and_generate_operations(
    values:,
    order:,
    temp_register:
  )
    # order = (0..7).to_a.shuffle
    shuffle_instructions = []

    visited_indexes = []

    current_i = nil
    tmp_value = nil
    tmp_index = nil

    while visited_indexes.length < 8
      if tmp_index.nil?
        # Find the next index that hasn't been already shuffled,
        # and where it is not itself.
        current_i = order.find do |i|
          !visited_indexes.include?(i) &&
            i != order[i]
        end
        break unless current_i

        tmp_value = values[current_i]
        tmp_index = current_i
        shuffle_instructions << [
          temp_register,
          current_i
        ]
      end

      next_i = order[current_i]
      visited_indexes << current_i

      # If the next index is stored in the temp variable,
      # move the temp variable into the current index, then start over.
      if next_i == tmp_index
        values[current_i] = tmp_value
        shuffle_instructions << [
          current_i,
          temp_register
        ]
        tmp_index = nil
        next
      end

      values[current_i] = values[next_i]
      shuffle_instructions << [
        current_i,
        next_i
      ]
      current_i = next_i
    end

    shuffle_instructions
  end
end

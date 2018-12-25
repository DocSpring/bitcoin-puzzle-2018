# frozen_string_literal: true

require_relative '../../lib/register_sorter.rb'

RSpec.describe RegisterSorter do
  describe 'sorting registers using a single temporary register' do
    it 'does nothing if the order does not change' do
      values = (0..7).to_a
      order = (0..7).to_a
      expect(
        described_class.sort_and_generate_operations(
          values: values,
          order: order,
          temp_register: 15
        )
      ).to eq []
      expect(values).to eq order
    end

    it 'swaps two indexes' do
      values = (0..7).to_a
      order = [1, 0, 2, 3, 4, 5, 6, 7]
      expect(
        described_class.sort_and_generate_operations(
          values: values,
          order: order,
          temp_register: 15
        )
      ).to eq [[15, 1], [1, 0], [0, 15]]
      expect(values).to eq order
    end

    it 'handles cycles by flushing and reusing the temporary register' do
      values = (0..7).to_a
      # [0, 1, 3], [6, 2], [5, 7] are cycles. 4 is unchanged
      order = [3, 0, 6, 1, 4, 7, 2, 5]
      expect(
        described_class.sort_and_generate_operations(
          values: values,
          order: order,
          temp_register: 15
        )
      ).to eq [
        [15, 3],
        [3, 1],
        [1, 0],
        [0, 15],
        [15, 6],
        [6, 2],
        [2, 15],
        [15, 7],
        [7, 5],
        [5, 15]
      ]
      expect(values).to eq order
    end

    it 'shuffles registers with a single chain of operations when possible' do
      # Shuffle can be performed with a single temp variable
      values = (0..7).to_a
      order = [1, 7, 4, 5, 0, 2, 6, 3]
      expect(
        described_class.sort_and_generate_operations(
          values: values,
          order: order,
          temp_register: 15
        )
      ).to eq [
        [15, 1],
        [1, 7],
        [7, 3],
        [3, 5],
        [5, 2],
        [2, 4],
        [4, 0],
        [0, 15]
      ]
      expect(values).to eq order
    end

    it 'does not add any duplicate instructions' do
      # Original code had an extra duplicate instruction at the end
      # for this order. Added a test to prevent it.
      values = (0..7).to_a
      order = [2, 6, 7, 5, 3, 1, 4, 0]
      expect(
        described_class.sort_and_generate_operations(
          values: values,
          order: order,
          temp_register: 15
        )
      ).to eq [
        [15, 2],
        [2, 7],
        [7, 0],
        [0, 15],
        [15, 6],
        [6, 4],
        [4, 3],
        [3, 5],
        [5, 1],
        [1, 15]
      ]
      expect(values).to eq order
    end
  end
end

# frozen_string_literal: true

require 'json'
TESTS = JSON.parse(File.read(File.expand_path('../tests.json', __dir__)))
# TESTS = JSON.parse(File.read(File.expand_path('../../build/puzzle.json', __dir__)))

require_relative '../../lib/solver.rb'

RSpec.describe Solver do
  TESTS.each_with_index do |(input, expected), i|
    it "passes test #{i + 1}" do
      output = Solver.new.solve(input)
      expect(output).to(
        eq(expected),
        "Wrong output for: #{input}. " \
        "Output: #{output.inspect}\tExpected: #{expected.inspect}"
      )
    end
  end
end

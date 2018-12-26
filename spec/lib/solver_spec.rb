# frozen_string_literal: true

require 'json'
require 'msgpack'

test_type = nil
TESTS =
  if ENV['JSON']
    test_type = :json
    puts 'Running tests from build/tests.json...'
    JSON.parse(File.read(File.expand_path('../../build/tests.json', __dir__)))
  elsif ENV['BINARY']
    test_type = :binary
    puts 'Running tests from build/tests.bin...'
    MessagePack.unpack(File.read(File.expand_path('../../build/tests.bin', __dir__)))
  else
    test_type = :source
    puts 'Running tests from spec/tests.json...'
    JSON.parse(File.read(File.expand_path('../tests.json', __dir__)))
  end

require_relative '../../lib/solver.rb'

RSpec.describe Solver do
  TESTS.each_with_index do |(input, expected), i|
    # Our solver program only takes hex input, so convert
    # the binary test inputs to hex strings.
    if test_type == :binary
      hex_input = +''
      bytes = input.unpack('C*')
      bytes.each { |b| hex_input << b.to_hex }
      input = hex_input
    elsif test_type == :source
      # Strip spaces here. The solver should never need to handle spaces.
      # They just make the tests a bit easier to read.
      input = input.gsub(/\s+/, '')
    end

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

# frozen_string_literal: true

require_relative '../../lib/string_compiler.rb'

def truncate(string, max)
  string.length > max ? "#{string[0...max]}..." : string
end

RSpec.describe StringCompiler do
  RANDOM_CHARS = ('0'..'z').to_a

  TEST_STRINGS = [
    'Hello World!',
    'Hello World!!',
    'What about ...                                                   ... spaces?',
    'This string is really really long.',
    'This is actually quite a long string. How does that work?',
    'This string is much longer than the string before and requires ' \
      'many register flushes.',
    'ABCDEFabcdef1234567890-=!@#$%^&*()_>?<><":}{|',
    Array.new(128) { RANDOM_CHARS.sample }.join
  ].freeze

  [false, true].each do |encrypt|
    describe "#{encrypt ? 'Encrypted' : 'Plain'} string encoding" do
      TEST_STRINGS.each do |string|
        it "compiles '#{truncate string, 20}...' into bytecode" do
          bytecode = StringCompiler.new(
            string,
            ascii: true,
            encrypt: encrypt,
            compact: true
          ).compile
          output = Solver.new.solve(bytecode)
          # puts "Test String: #{string.inspect}"
          # puts "Bytecode: #{bytecode}"
          # puts "Output:   #{output.inspect}"

          expect(output).to(
            eq(string),
            "#{bytecode} did not produce #{string.inspect}! " \
            "(Was: #{output.inspect}) (Encrypt: #{encrypt})"
          )
        end
      end
    end
  end
end

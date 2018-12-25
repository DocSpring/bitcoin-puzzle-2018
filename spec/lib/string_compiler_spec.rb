# frozen_string_literal: true

require_relative '../../lib/string_compiler.rb'

RSpec.describe StringCompiler do
  it 'compiles strings to valid bytecode' do
    random_chars = ('0'..'z').to_a

    test_strings = [
      'Hello World!',
      'Hello World!!',
      'This string is really really long.',
      'This is actually quite a long string. How does that work?',
      'This string is much longer than the string before and requires ' \
        'many register flushes.',
      'ABCDEFabcdef1234567890-=!@#$%^&*()_>?<><":}{|',
      Array.new(128) { random_chars.sample }.join
    ]

    test_strings.each do |test_string|
      # [true, false].each do |encrypt|
      [true].each do |encrypt|
        bytecode = StringCompiler.new(
          test_string, ascii: true, encrypt: encrypt
        ).compile
        output = Solver.new.solve(bytecode)
        # puts "Test String: #{test_string.inspect}"
        puts "Bytecode: #{bytecode}"
        puts "Output:   #{output.inspect}"

        expect(output).to(
          eq(test_string),
          "#{bytecode} did not produce #{test_string.inspect}! " \
          "(Was: #{output.inspect}) (Encrypt: #{encrypt})"
        )
      end
    end
  end
end

# frozen_string_literal: true

require 'json'
require 'msgpack'

require_relative '../../lib/solver.rb'

# This test is handy because we can use Simplecov to see
# the code coverage for the solver.

RSpec.describe 'Execute the bitcoin.pdf whitepaper as a program' do
  it 'should produce the correct output' do
    bitcoin_pdf_contents = File.read(File.expand_path('../../bitcoin.pdf', __dir__))

    hex_contents = +''
    bytes = bitcoin_pdf_contents.unpack('C*')
    bytes.each { |b| hex_contents << b.to_hex }

    output = Solver.new.solve(hex_contents)

    expect(output).to eq(
      '32314146e05f296c4075af0b3c28f5007c40ba13222002331804000022200234'
    )
  end
end

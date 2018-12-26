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

    expect(output).to eq 'da7cffe1fffffffc091e462c9d9306f925682760fffffffa7fb698e34bf8c817'
  end
end

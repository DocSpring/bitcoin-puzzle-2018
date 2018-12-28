#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry-byebug'
require 'awesome_print'
require 'json'
require 'securerandom'
require 'fileutils'
FileUtils.mkdir_p(File.expand_path('../build', __dir__))

$LOAD_PATH << File.expand_path('../lib', __dir__)

require 'puzzle_solver'

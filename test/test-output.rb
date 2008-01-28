#!/usr/bin/env ruby
require 'test/unit'
require 'fileutils'

# require 'rubygems'
# require 'ruby-debug'; Debugger.init

SRC_DIR = File.expand_path(File.dirname(__FILE__)) + '/' unless 
  defined?(SRC_DIR)

require File.join(SRC_DIR, 'helper.rb')

include TestHelper

# Test 'starting' annotation.
class TestStartingAnnotate < Test::Unit::TestCase
  require 'stringio'

  def test_basic
    Dir.chdir(SRC_DIR) do 
      assert_equal(true, 
                   run_debugger('output', 
                                '-A 3 --script output.cmd -- output.rb',
                                nil, nil, true))
    end
  end
end

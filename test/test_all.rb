require "rubygems"
gem "minitest"
require "minitest/autorun"

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}")
require "test_helper"
require "code_error"
require "test_gen"
require "test_masked"
require "test_pos"
require "test_config"

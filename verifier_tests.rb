require 'minitest/autorun'
require 'simplecov'
SimpleCov.start
require_relative 'blockchain_verifier.rb'

class VerifierTests < Minitest::Test
  def test_create_block
  	b = create_block('0|0|SYSTEM>Fred(100)|234.12345678|1s5d')
  	assert_equal '0', b.line_num
  	assert_equal '0', b.last_hash
  	assert_equal 'SYSTEM>Fred(100)', b.transactions
  	assert_equal '234.12345678', b.time_val
  	assert_equal '1s5d', b.end_hash
  end
end
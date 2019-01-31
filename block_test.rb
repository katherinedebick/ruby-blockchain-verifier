require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'rantly/minitest_extensions'
require_relative 'block.rb'
require_relative 'transaction.rb'

class BlockTest < Minitest::Test
  def test_split_transactions
    b = Block.new(0,0,'George>Amina(16):Henry>James(4):Henry>Cyrus(17):Henry>Kublai(4):George>Rana(1):SYSTEM>Wu(100)',0,0)
    transactions = b.split_transactions('George>Amina(16):Henry>James(4):Henry>Cyrus(17):Henry>Kublai(4):George>Rana(1):SYSTEM>Wu(100)')
    t = transactions[3]
    assert_equal t.amount, '4'
  end
  
  # Clarify this test
  def test_print_block
    test_block = Block.new(1,'1c12', 'SYSTEM>George(100)', '1518892051.740967000', 'abb2')
    test_block.print_block
    mocked_block = Minitest::Mock.new("mocked block")
    mocked_block.expect(:print_block, 1)
    assert mocked_block
  end
end
require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'rantly/minitest_extensions'
require_relative 'bitcoin_wallet.rb'

class BitcoinWalletTest < Minitest::Test
  def test_withdraw
    b = BitcoinWallet.new("Sally", 900)
    b.withdraw(100)
    assert_equal b.coins, 800
  end
  
  def test_deposit
    b = BitcoinWallet.new("Henry", 700)
    b.deposit(100)
    assert_equal b.coins, 800
  end
end
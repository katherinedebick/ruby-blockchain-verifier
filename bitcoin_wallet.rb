# A class for a bitcoin wallet. Includes
# the username of the wallet and the
# ammount of coins in that wallet
class BitcoinWallet
  attr_accessor :username
  attr_accessor :coins
  def initialize(username, coins)
    @username = username
    @coins = coins.to_i
  end

  def withdraw(withdraw_coins)
    @coins -= withdraw_coins.to_i
  end

  def deposit(deposit_coins)
    @coins += deposit_coins.to_i
  end
end

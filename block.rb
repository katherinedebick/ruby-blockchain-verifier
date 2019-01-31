require_relative 'transaction.rb'

# The Block class object: holds the info from
# the line and allows you to access it easily
class Block
  attr_accessor :line_num
  attr_accessor :last_hash
  attr_accessor :time_val
  attr_accessor :end_hash
  attr_accessor :transactions

  def initialize(line_num, last_hash, transactions, time_val, end_hash)
    @line_num = line_num
    @last_hash = last_hash
    @time_val = time_val
    @end_hash = end_hash
    @transactions = transactions
  end
end

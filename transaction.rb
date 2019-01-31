# This class takes in a transaction and splits it
# making it into 3 different accesable values
class Transaction
  attr_accessor :sender
  attr_accessor :reciever
  attr_accessor :amount

  def initialize(transaction)
    trans_split = transaction.split('>')
    @sender = trans_split[0]
    amount_split = trans_split[1].split('(')
    @reciever = amount_split[0]
    @amount = amount_split[1].delete ')'
  end
end

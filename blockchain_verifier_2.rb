require_relative 'bitcoin_wallet.rb'
require_relative 'block.rb'
require_relative 'transaction.rb'

# An object which manages the work it takes to verify a blockchain
class BlockchainVerifier
  attr_accessor :users
  # The main process that checks every block in the
  # chain and puts the wallets at the end or an
  # error code saying what was wrong with the blockchain
  def verify(file)
    @users = []
    @last_block = nil
    blockchain = File.read(file)
    blockchain.each_line do |line|
      current_block = create_block(line)
      push_block(current_block)
      line_res = verify_block(current_block)
      display_error(current_block.line_num, line_res[1]) unless line_res[0] == true
      @last_block = current_block
    end
    display_end
    exit
  end

  def convert_push_check(line)
    current_block = create_block(line)
    push_block(current_block)
    line_res = verify_block(current_block)
    display_error(current_block.line_num, line_res[1]) unless line_res[0] == true
    @last_block = current_block
  end

  # Creates a Block given a line from the text
  def create_block(line)
    # Gather variables
    elements = line.split('|')
    line_num = elements[0]
    last_hash = elements[1]
    transactors = elements[2]
    time_val = elements[3]
    end_hash = elements[4]
    # Return Block made with variables
    Block.new(line_num, last_hash, transactors, time_val, end_hash)
  end

  # Checks if a username already exists in the users array
  def check_users(username)
    yes = 0
    @users.each do |i|
      yes += 1 if i.username == username
    end
    return false if yes.zero?
    true
  end

  # Preforms the withdrawl and deposit of coins of a given transaction
  def apply_transactions(transaction)
    s = 0
    r = 0
    @users.each do |i|
      s += 1
      break if i.username == transaction.sender
    end
    unless transaction.sender == 'SYSTEM'
      @users[s - 1].withdraw(transaction.amount)
    end
    @users.each do |i|
      r += 1
      break if i.username == transaction.reciever
    end
    @users[r - 1].deposit(transaction.amount)
  end

  # Applys the block's transactions
  def push_block(block)
    transactions = split_transactions(block.transactions)
    transactions.each do |i|
      unless check_users(i.sender) == true || i.sender == 'SYSTEM'
        @users[@users.length] = BitcoinWallet.new(i.sender, 0)
      end
      unless check_users(i.reciever) == true
        @users[@users.length] = BitcoinWallet.new(i.reciever, 0)
      end
      apply_transactions(i)
    end
  end

  def split_transactions(transactions)
    trans_arr = transactions.split(':')
    transactions = []
    count = 0
    trans_arr.each do |i|
      transactions[count] = Transaction.new(i)
      count += 1
    end
    transactions
  end

  # Runs the block through all the checks and
  # returns true and nil or false and an error code
  def verify_block(block)
    hash_check = hash_check(block)
    time_check = time_check(block.time_val)
    transaction_check = transaction_check()
    prev_hash_check = prev_hash_check(block.last_hash)
    line_num_check = line_num_check(block.line_num)
    if hash_check && time_check && transaction_check && prev_hash_check && line_num_check
      return true, nil
    elsif hash_check == true && time_check == true && prev_hash_check == true && line_num_check == true
      return false, 1
    elsif time_check == true && prev_hash_check && line_num_check == true
      return false, 2
    elsif time_check == true && line_num_check == true
      return false, 3
    elsif time_check == true
      return false, 4
    else
      return false, 5
    end
  end

  # Checks the hash of a block
  def hash_check(block)
    unpacked_string = block.line_num + '|' + block.last_hash + '|' + block.transactions + '|' + block.time_val
    unpacked_string = unpacked_string.unpack('U*')
    sum = 0
    unpacked_string.each do |x|
      temp = (x**2000) * ((x + 2)**21) - ((x + 5)**3)
      sum += temp
    end
    sum = sum % 655_36
    return false unless sum.to_s(16) != block.end_hash
    true
  end

  # Checks to make sure the first hash of the current
  # block matches the ending hash on the last block
  def prev_hash_check(last_hash)
    unless @last_block.nil?
      return false if @last_block.end_hash.unpack('*U') != last_hash.unpack('*U')
    end
    true
  end

  # Checks that the epochs are equivelent and the time
  # on the current block is greater than the previous block
  def time_check(time_val)
    unless @last_block.nil?
      prev_arr = @last_block.time_val.split('.')
      curr_arr = time_val.split('.')
      if curr_arr[0].to_i == prev_arr[0].to_i
        return false unless curr_arr[1].to_i > prev_arr[1].to_i
      elsif curr_arr[0].to_i < prev_arr[0].to_i
        return false
      end
    end
    true
  end

  # Checks that none of the wallets are below 0 coins
  def transaction_check
    @users.each do |i|
      return false if i.coins < 0
    end
    true
  end

  # Checks that the line number is correct
  def line_num_check(line_num)
    return true if @last_block.nil?
    return false unless line_num.to_i == @last_block.line_num.to_i + 1
    true
  end

  # Displays the problem with the block based off the errorcode
  def display_error(line_num, errorcode)
    puts 'Error line: ' + line_num
    if errorcode == 1
      puts 'Reason: Bad Transaction'
    elsif errorcode == 2
      puts 'Reason: Bad Hash'
    elsif errorcode == 3
      puts 'Reason: Bad Previous Hash'
    elsif errorcode == 4
      puts 'Reason: Line Order Incorrect'
    else
      puts 'Reason: Time Inconsistency'
    end
    exit
  end

  # Displays the wallets and their coins at the end of a blockchain
  def display_end
    @users.each do |i|
      puts i.username + ': ' + i.coins.to_s + ' billcoins'
    end
  end
end

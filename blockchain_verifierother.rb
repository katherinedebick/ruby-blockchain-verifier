require_relative 'bitcoin_wallet.rb'
require_relative 'block.rb'
require_relative 'transaction.rb'

def verify(file)
  @users = []
  @last_block = nil 
  blockchain = File.read(file)
  blockchain.each_line do |line|
    current_block = create_block(line)
    push_block(current_block)
    line_res = verify_block(current_block)
    unless line_res[0] == true
      display_end
      display_error(current_block, line_res[1])
    end
    @last_block = current_block
  end
  display_end
  exit
end

# Create Block
def create_block(line)
  # Initialize Variables
  word = ''
  pipe_number = 0
  line_num = ''
  last_hash = ''
  transactors = ''
  time_val = ''
  end_hash = ''
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

def check_users(username)
  yes = 0
  @users.each do |i|
    if i.username == username
      yes =  yes + 1
    end
  end 
  if yes == 0
    return false
  else 
    return true
  end
end

def apply_transactions(transaction)
  s = 0
  r = 0
  @users.each do |i|
    if i.username == transaction.sender
      break
    end
    s = s + 1
  end
  @users[s].withdraw(transaction.amount)
  @users.each do |i|
    if i.username == transaction.reciever
      break
    end 
    r = r + 1
  end
  @users[r].deposit(transaction.amount)
end

# Applys the blocks transactions 
def push_block(block)
  block.transactions.each do |i|
    unless i.sender == 'SYSTEM' || check_users(i.sender) == true 
      @users[@users.length] = BitcoinWallet.new(i.sender, 0)
    end
    unless check_users(i.reciever) == true
      @users[@users.length] = BitcoinWallet.new(i.reciever, 0)
    end
    apply_transactions(i)
  end
end

# Runs the block through all the checks and returns true and nil or false and an error code
def verify_block(block)
  hash_check = hash_check(block)
  time_check = time_check(block)
  transaction_check = transaction_check(block)
  prev_hash_check = prev_hash_check(block)
  if hash_check == true && time_check == true && transaction_check == true && prev_hash_check == true
    return true, nil
  elsif hash_check == true && time_check == true && prev_hash_check == true
    return false, 1
  elsif time_check == true && prev_hash_check
    return false, 2
  elsif time_check == true
    return false, 3
  else
    return false, 4
  end
end

def hash_check(block)
  true
end

def prev_hash_check(block)
  unless @last_block == nil
    unless @last_block.end_hash.unpack('*U') == block.last_hash.unpack('*U')
      return false
    end    
  end
  true
end

def time_check(block)
  unless @last_block == nil
    prev_arr = @last_block.time_val.split('.')
    curr_arr = block.time_val.split('.')
    unless curr_arr[0] == prev_arr[0] && curr_arr[1] > prev_arr[1]
      return false
    end
  end
  true 
end

def transaction_check(block)
  @users.each do |i|
    if i.coins < 0
      return false
    end
  end
  true 
end

def display_error(block, errorcode)
  if errorcode == 1
    puts 'Error line: ' + block.line_num
    puts 'Reason: Bad Transaction'
  elsif errorcode == 2 
    puts 'Error line: ' + block.line_num
    puts 'Reason: Bad Hash'
  elsif errorcode == 3
    puts 'Error line: ' + block.line_num
    puts 'Reason: Bad Previous Hash'
  else
    puts 'Error line: ' + block.line_num
    puts 'Reason: Time Inconsistency'
  end
  exit
end

def display_end
  @users.each do |i|
    puts i.username + ': ' + i.coins.to_s + ' billcoins'
  end
end
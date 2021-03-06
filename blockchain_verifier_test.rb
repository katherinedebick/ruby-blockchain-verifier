require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'rantly/minitest_extensions'

require_relative 'transaction.rb'
require_relative 'block.rb'
require_relative 'bitcoin_wallet.rb'
require_relative 'blockchain_verifier.rb'

class BlockchainVerifierTest < Minitest::Test
  def test_verify
    test_bcv = BlockchainVerifier.new()
    mocked_file = Minitest::Mock.new("mocked_file")
    block_arr = "0|0|SYSTEM>Henry(100)|1518892051.737141000|1c12
1|1c12|SYSTEM>George(100)|1518892051.740967000|abb2
2|abb2|George>Amina(16):Henry>James(4):Henry>Cyrus(17):Henry>Kublai(4):George>Rana(1):SYSTEM>Wu(100)|1518892051.753197000|c72d
3|c72d|SYSTEM>Henry(100)|1518892051.764563000|7419
4|7419|Kublai>Pakal(1):Henry>Peter(10):Cyrus>Amina(3):Peter>Sheba(1):Cyrus>Louis(1):Pakal>Kaya(1):Amina>Tang(4):Kaya>Xerxes(1):SYSTEM>Amina(100)|1518892051.768449000|97df
5|97df|Henry>Edward(23):Rana>Alfred(1):James>Rana(1):SYSTEM>George(100)|1518892051.783448000|d072
6|d072|Wu>Edward(16):SYSTEM>Amina(100)|1518892051.793695000|949
7|949|Louis>Louis(1):George>Edward(15):Sheba>Wu(1):Henry>James(12):Amina>Pakal(22):SYSTEM>Kublai(100)|1518892051.799497000|32aa
8|32aa|SYSTEM>Tang(100)|1518892051.812065000|775a
9|775a|Henry>Pakal(10):SYSTEM>Amina(100)|1518892051.815834000|2d7f
"
    mocked_file.expect :read, block_arr
    assert_output("Henry: 120 billcoins\nGeorge: 168 billcoins\nAmina: 293 billcoins\nJames: 15 billcoins\nCyrus: 13 billcoins\nKublai: 103 billcoins\nRana: 1 billcoins\nWu: 85 billcoins\nPakal: 32 billcoins\nPeter: 9 billcoins\nSheba: 0 billcoins\nLouis: 1 billcoins\nKaya: 0 billcoins\nTang: 104 billcoins\nXerxes: 1 billcoins\nEdward: 54 billcoins\nAlfred: 1 billcoins\n") do 
        test_bcv.verify(mocked_file)
    end
  end
  
  def test_create_block
    test_bcv = BlockchainVerifier.new()
    test_block = test_bcv.create_block("0|0|SYSTEM>Henry(100)|1518892051.737141000|1c12")
    assert_equal test_block.line_num, "0"
  end
  
  def test_check_users
    test_bcv = BlockchainVerifier.new()
    test_bcv.users = [BitcoinWallet.new('katherine', 234), BitcoinWallet.new('evan', 234), BitcoinWallet.new('bob', 234), BitcoinWallet.new('steve', 234)]
    assert_equal test_bcv.check_users('katherine'), true
  end
  
  def test_apply_transactions
    test_transaction = Transaction.new("George>Amina(16)")
    test_bcv = BlockchainVerifier.new()
    test_bcv.users = [BitcoinWallet.new('George', 100), BitcoinWallet.new('Amina', 100)]
    test_bcv.apply_transactions(test_transaction)
    assert_equal test_bcv.users[0].coins, 84
  end
  
  def test_push_block
    test_bcv = BlockchainVerifier.new()
    test_block = test_bcv.create_block("0|0|SYSTEM>Henry(100)|1518892051.737141000|1c12")
    test_bcv.users = [BitcoinWallet.new('SYSTEM', 200), BitcoinWallet.new('Henry', 100)]
    test_bcv.push_block(test_block)
    assert_equal test_bcv.users[1].coins, 200
  end
  
  def test_split_transactions
    test_bcv = BlockchainVerifier.new()
    test_transaction_arr = test_bcv.split_transactions("Kublai>Pakal(1):Henry>Peter(10):Cyrus>Amina(3):Peter>Sheba(1):Cyrus>Louis(1):Pakal>Kaya(1):Amina>Tang(4):Kaya>Xerxes(1):SYSTEM>Amina(100)")
    assert_equal test_transaction_arr.length, 9
  end
  
  def test_verify_block
    test_bcv = BlockchainVerifier.new()
    
    test_block = test_bcv.create_block("4|7419|Kublai>Pakal(1):Henry>Peter(10):Cyrus>Amina(3):Peter>Sheba(1):Cyrus>Louis(1):Pakal>Kaya(1):Amina>Tang(4):Kaya>Xerxes(1):SYSTEM>Amina(100)|1518892051.768449000|97df")
    test_next_block = test_bcv.create_block("5|97df|Henry>Edward(23):Rana>Alfred(1):James>Rana(1):SYSTEM>George(100)|1518892051.783448000|d072")
    
    test_bcv.push_block(test_block)
    test_bcv.push_block(test_next_block)
    
    assert test_bcv.verify_block(test_next_block, test_block)
  end
  
  def test_hash_check
    test_bcv = BlockchainVerifier.new()
    test_block = test_bcv.create_block("5|97df|Henry>Edward(23):Rana>Alfred(1):James>Rana(1):SYSTEM>George(100)|1518892051.783448000|d072")
    refute test_bcv.hash_check(test_block)
  end
  
  def test_prev_hash_check
    test_bcv = BlockchainVerifier.new()
    
    test_last_block = test_bcv.create_block("4|7419|Kublai>Pakal(1):Henry>Peter(10):Cyrus>Amina(3):Peter>Sheba(1):Cyrus>Louis(1):Pakal>Kaya(1):Amina>Tang(4):Kaya>Xerxes(1):SYSTEM>Amina(100)|1518892051.768449000|97df")
    test_curr_block = test_bcv.create_block("5|97df|Henry>Edward(23):Rana>Alfred(1):James>Rana(1):SYSTEM>George(100)|1518892051.783448000|d072")
    
    assert test_bcv.prev_hash_check(test_curr_block, test_last_block)
  end
  
  def test_time_check
    test_bcv = BlockchainVerifier.new()
    
    test_last_block = test_bcv.create_block("4|7419|Kublai>Pakal(1):Henry>Peter(10):Cyrus>Amina(3):Peter>Sheba(1):Cyrus>Louis(1):Pakal>Kaya(1):Amina>Tang(4):Kaya>Xerxes(1):SYSTEM>Amina(100)|1518892051.768449000|97df")
    test_curr_block = test_bcv.create_block("5|97df|Henry>Edward(23):Rana>Alfred(1):James>Rana(1):SYSTEM>George(100)|1518892051.783448000|d072")
    
    assert test_bcv.time_check(test_curr_block, test_last_block)
  end
  
  def test_transaction_check
    test_bcv = BlockchainVerifier.new()
    test_bcv.users = [BitcoinWallet.new('katherine', 223), BitcoinWallet.new('evan', 1), BitcoinWallet.new('bob', 0), BitcoinWallet.new('steve', 13)]
    assert test_bcv.transaction_check
  end
  
  def test_line_num_check
    test_bcv = BlockchainVerifier.new()
    test_last_block = test_bcv.create_block("4|7419|Kublai>Pakal(1):Henry>Peter(10):Cyrus>Amina(3):Peter>Sheba(1):Cyrus>Louis(1):Pakal>Kaya(1):Amina>Tang(4):Kaya>Xerxes(1):SYSTEM>Amina(100)|1518892051.768449000|97df")
    test_curr_block = test_bcv.create_block("5|97df|Henry>Edward(23):Rana>Alfred(1):James>Rana(1):SYSTEM>George(100)|1518892051.783448000|d072")
    assert test_bcv.line_num_check(test_curr_block, test_last_block)
  end
  
  def test_display_error_1
    test_bcv = BlockchainVerifier.new()
    assert_output("Error line: 1\nReason: Bad Transaction\n") do 
      test_bcv.display_error('1', 1)
    end
  end
  
  def test_display_error_2
    test_bcv = BlockchainVerifier.new()
    assert_output("Error line: 1\nReason: Bad Hash\n") do 
      test_bcv.display_error('1', 2)
    end
  end
  
  def test_display_error_3
    test_bcv = BlockchainVerifier.new()
    assert_output("Error line: 1\nReason: Bad Previous Hash\n") do 
      test_bcv.display_error('1', 3)
    end
  end
  
  def test_display_error_4
    test_bcv = BlockchainVerifier.new()
    assert_output("Error line: 1\nReason: Line Order Incorrect\n") do 
      test_bcv.display_error('1', 4)
    end
  end
  
  def test_display_error_5
    test_bcv = BlockchainVerifier.new()
    assert_output("Error line: 1\nReason: Time Inconsistency\n") do 
      test_bcv.display_error('1', nil)
    end
  end
  
  def test_display_end
    test_bcv = BlockchainVerifier.new()
    test_bcv.users = [BitcoinWallet.new('katherine', 223), BitcoinWallet.new('evan', 1), BitcoinWallet.new('bob', 0), BitcoinWallet.new('steve', 13)]
    assert_output("katherine: 223 billcoins\nevan: 1 billcoins\nbob: 0 billcoins\nsteve: 13 billcoins\n") do 
      test_bcv.display_end
    end
  end
end
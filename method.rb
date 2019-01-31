  def test_verify
    test_bcv = BlockchainVerifier.new()
    mocked_file = Minitest::Mock.new("mocked_file")
    block_arr = [
      "0|0|SYSTEM>Henry(100)|1518892051.737141000|1c12",
      "1|1c12|SYSTEM>George(100)|1518892051.740967000|abb2",
      "2|abb2|George>Amina(16):Henry>James(4):Henry>Cyrus(17):Henry>Kublai(4):George>Rana(1):SYSTEM>Wu(100)|1518892051.753197000|c72d",
      "3|c72d|SYSTEM>Henry(100)|1518892051.764563000|7419",
      "4|7419|Kublai>Pakal(1):Henry>Peter(10):Cyrus>Amina(3):Peter>Sheba(1):Cyrus>Louis(1):Pakal>Kaya(1):Amina>Tang(4):Kaya>Xerxes(1):SYSTEM>Amina(100)|1518892051.768449000|97df",
      "5|97df|Henry>Edward(23):Rana>Alfred(1):James>Rana(1):SYSTEM>George(100)|1518892051.783448000|d072",
      "6|d072|Wu>Edward(16):SYSTEM>Amina(100)|1518892051.793695000|949",
      "7|949|Louis>Louis(1):George>Edward(15):Sheba>Wu(1):Henry>James(12):Amina>Pakal(22):SYSTEM>Kublai(100)|1518892051.799497000|32aa",
      "8|32aa|SYSTEM>Tang(100)|1518892051.812065000|775a",
      "9|775a|Henry>Pakal(10):SYSTEM>Amina(100)|1518892051.815834000|2d7f"
    ]
    mocked_file.expect :read, block_arr

    File.stub(:read, mocked_file) do
      assert_output("Henry: 120 billcoins\nGeorge: 168 billcoins\nAmina: 293 billcoins\nJames: 15 billcoins\nCyrus: 13 billcoins\nKublai: 103 billcoins\nRana: 1 billcoins\nWu: 85 billcoins\nPakal: 32 billcoins\nPeter: 9 billcoins\nSheba: 0 billcoins\nLouis: 1 billcoins\nKaya: 0 billcoins\nTang: 104 billcoins\nXerxes: 1 billcoins\nEdward: 54 billcoins\nAlfred: 1 billcoins\n") do 
        test_bcv.verify(mocked_file)
      end
    end
  end
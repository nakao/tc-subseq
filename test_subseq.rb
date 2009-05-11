
require 'test/unit'
require 'subseq'

test_tsv =<<END
1       cctggccaatttttgtatttttagtagaggtgtggtttcactatgttggc
2       caggctgatgtcgaactcctgacctcaggtgatctgcccgccttggcctc
3       ccaaagtgctggggttaacaggcgtgagctactgcgcccggccTTTTTAC
4       TTTTTTGATGCTAGAAAAATGCTCCCATATCAGCCATATACTACAATATT
5       TTTCACAGTGCAAAAGTTTATTTTAAGGAGAACTCAGTTTAAACTGTGTA
6       GTATTTAACATACACGTGAGTGCTCAATGATGTTTCTTCAATAAATATAT
7       ATGTAAAATTGAAAACTAATGTCTTTTATTTAGATTTTTATTAAACTTGG
8       AGATTTCCAGCAGGAAATACAAAGCATCTAGTACAAATCATTTCATACTT
9       GTCAAATCCAGAATGGAGAGTCACTAGAGCATTATTTTTGTAAAGGTAAT
10      TATTTAAGAAACAGGTATTTATTTTATTTTTAGTGTACTCCAAGGAGCAC
11      TGAGTAGTATTCATATGATTTCCTCCCCTTATCCTTTCCACAGTCTTACT
12      CAGATATGACTGGCCAGAAATAAGAATGGCTGAAACATATTATTGTGCTG
13      AATAACTAAGCCAAGATTTGAATTTAAAGACTTGCTTAATTCACATATTT
14      TGTGTAATGGCGGTTCTACCTTTATTCAAAAACATCTCCAGTGTTCTACC
15      ACCCAAATAAACTTTCTACatttgttcatttagcaaaaatttgctggttg
16      cctcttatatgccagacagtattccaagtactaggggaaaaaagatgaat
17      aaaacatgatccctgcccctcaggaactcagagtataataggaaaggtgg
18      gtgtgttaaGAACAGTGTAAAGTGTAATGTGAAAGTACATCAGGGTGGTG
19      ATAAATAAAAGAGTCTTAGAAGACTCTAAACTTAGTGACTTGCAGATGAT
20      GCATACCTAGAAGGTGTAGAAAGTGTGACGTAGACCTAAGAAGGGAGCCA
21      AGTAACTGTGTctttttattttgacatgattatagattcacatgcagttt
22      taagaaataatatagagggctgggcgcagtggctcatgccagtaaccaca
23      acccagccctttgggaggccaaatctggaggactgcctgaggccaggagt
24      tagagaccagcctatgcaatatagtgagaccctatatctacaaaaaacaT
END

# prepare TCF test db
["test_tcf.tsv", "test.tcf"].each { |file|
  File.delete(file) if File.exists?(file)
}

fdb = FDB::new
if !fdb.open("test.tcf", FDB::OWRITER | FDB::OCREAT)
  ecode = fdb.ecode
  STDERR.printf("open error: %s\n", fdb.errmsg(ecode))
end
width = 50
fdb.tune(width)
test_tsv.map {|x| x.chomp.split(/\s+/) }.each do |key, value|
  fdb.put(key.to_i, value)
end
fdb.close


# prepare TCH test db
["test_tch.tsv", "test.tch"].each { |file|
  File.delete(file) if File.exists?(file)
}
hdb = HDB::new
if !hdb.open("test.tch", HDB::OWRITER | HDB::OCREAT)
  ecode = hdb.ecode
  STDERR.printf("open error: %s\n", hdb.errmsg(ecode))
end
test_tsv.map {|x| x.chomp.split(/\s+/) }.each do |key, value|
  hdb.put("#{key.to_i}", value)
end
hdb.close



class TestTCF_SS < Test::Unit::TestCase
  def test_test_1_1_is_c
    assert_equal('c', TCF_SS.subseq("test", "1,1"))
  end

  def test_test_1_3_is_cct
    assert_equal('cct', TCF_SS.subseq("test", "1,3"))
  end

  def test_test_2_3_is_cct
    assert_equal('ct', TCF_SS.subseq("test", "2,3"))
  end

  def test_test_1_49_is_49
    ss = TCF_SS.subseq("test", "1,49")
    assert_equal(49, ss.length)
  end

  def test_test_1_50_is_50
    ss = TCF_SS.subseq("test", "1,50")
    assert_equal(50, ss.length)
  end

  def test_test_1_51_is_51
    ss = TCF_SS.subseq("test", "1,51")
    assert_equal(51, ss.length)
  end

  def test_test_2_51_is_50
    ss = TCF_SS.subseq("test", "2,51")
    assert_equal(50, ss.length)
  end

  def test_test_2_52_is_51
    ss = TCF_SS.subseq("test", "2,52")
    assert_equal("ctggccaatttttgtatttttagtagaggtgtggtttcactatgttggcca", ss)
    assert_equal(51, ss.length)
  end

  def test_test_10_30_is_21
    ss = TCF_SS.subseq("test", "10,30")
    assert_equal("tttttgtatttttagtagagg", ss)
    assert_equal(21, ss.length)
  end

  def test_test_10_130_is_121
    ss = TCF_SS.subseq("test", "10,130")
    assert_equal(121, ss.length)
  end

  def test_chr1_random_10_1130_is_1121
    ss = TCF_SS.subseq("test", "10,1130")
    assert_equal(1121, ss.length)
  end

  def test_test_
    i = [1,2,3,4,5,48,49,50,51,52,97,98,99,100,101,102,103,997,998,999,1000,1001,1002]
    i.each do |s|
      i.each do |e|
        next if s > e
        length = e - s + 1
        ss = TCF_SS.subseq("test", "#{s},#{e}")
        assert_equal([length, s, e], [ss.length, s, e])
      end
    end
  end

  def test_chr1_random_3_1_is_ArgumentError
    assert_raise(ArgumentError) { TCF_SS.subseq("test", "3,1") }
  end

end


class TestTCH_SS < Test::Unit::TestCase
  def test_test_1_1_is_c
    assert_equal('c', TCH_SS.subseq("test", "1,1"))
  end

  def test_test_1_3_is_cct
    assert_equal('cct', TCH_SS.subseq("test", "1,3"))
  end

  def test_test_2_3_is_cct
    assert_equal('ct', TCH_SS.subseq("test", "2,3"))
  end

  def test_test_1_49_is_49
    ss = TCH_SS.subseq("test", "1,49")
    assert_equal(49, ss.length)
  end

  def test_test_1_50_is_50
    ss = TCH_SS.subseq("test", "1,50")
    assert_equal(50, ss.length)
  end

  def test_test_1_51_is_51
    ss = TCH_SS.subseq("test", "1,51")
    assert_equal(51, ss.length)
  end

  def test_test_2_51_is_50
    ss = TCH_SS.subseq("test", "2,51")
    assert_equal(50, ss.length)
  end

  def test_test_2_52_is_51
    ss = TCH_SS.subseq("test", "2,52")
    assert_equal("ctggccaatttttgtatttttagtagaggtgtggtttcactatgttggcca", ss)
    assert_equal(51, ss.length)
  end

  def test_test_10_30_is_21
    ss = TCH_SS.subseq("test", "10,30")
    assert_equal("tttttgtatttttagtagagg", ss)
    assert_equal(21, ss.length)
  end

  def test_test_10_130_is_121
    ss = TCH_SS.subseq("test", "10,130")
    assert_equal(121, ss.length)
  end

  def test_chr1_random_10_1130_is_1121
    ss = TCH_SS.subseq("test", "10,1130")
    assert_equal(1121, ss.length)
  end

  def test_test_
    i = [1,2,3,4,5,48,49,50,51,52,97,98,99,100,101,102,103,997,998,999,1000,1001,1002]
    i.each do |s|
      i.each do |e|
        next if s > e
        length = e - s + 1
        ss = TCH_SS.subseq("test", "#{s},#{e}")
        assert_equal([length, s, e], [ss.length, s, e])
      end
    end
  end

  def test_chr1_random_3_1_is_ArgumentError
    assert_raise(ArgumentError) { TCH_SS.subseq("test", "3,1") }
  end

end


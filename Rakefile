# Human genome sequences on Tokyo Cabinet 
#
require 'tokyocabinet'

namespace :test do
  desc "remove testing files."
  task :clean do
    Dir.glob("test?t*").each do |file|
      puts "#{file} removed"
      File.delete(file)
    end
  end
  
  desc "unit test for SubSeq."
  task :subseq do
    sh "ruby test_subseq.rb"
    ["test_tch.tsv", "test_tcf.tsv", "test.tcf"].each { |file|
      File.delete(file) if File.exists?(file)
    }
  end
end


namespace :data do
  namespace :ucsc do
    def dl_ext(url)
      sh "curl -O #{url}"
      case url
      when /zip$/
        sh "unzip #{url.split("/").last}"
      when /.tar.gz$/
        sh "tar zxvf #{hg.split("/").last}"
      end
    end

    desc "UCSC hg18 chromFa.zip"
    task :hg18 do
      hg = "http://hgdownload.cse.ucsc.edu/goldenPath/10april2003/bigZips/chromFa.zip"
      dl_ext(hg)
    end

    desc "UCSC hg18 chromFaMasked.zip"
    task :hg18masked do
      hg = "http://hgdownload.cse.ucsc.edu/goldenPath/10april2003/bigZips/chromFaMasked.zip"
      dl_ext(hg)
    end

    desc "UCSC hg19 chromFa.tar.gz"
    task :hg19 do
      hg = "http://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/chromFa.tar.gz"
      dl_ext(hg)
    end

    desc "UCSC hg19 chromFaMasked.tar.gz."
    task :hg19masked do
      url = "http://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/chromFaMasked.tar.gz"
      dl_ext(url)
    end

    
    desc "UCSC mm9 chromFa.tar.gz"
    task :mm do
      url = 'http://hgdownload.cse.ucsc.edu/goldenPath/mm9/bigZips/chromFa.tar.gz'
      dl_ext(url)
    end

    desc "UCSC mm9 chromFaMasked.tar.gz."
    task :mm do
      url = 'http://hgdownload.cse.ucsc.edu/goldenPath/mm9/bigZips/chromFaMasked.tar.gz'
      dl_ext(url)
    end

  end
end


#
def fasta_postfix
  if Dir.glob("*.fa").size > 1
    ".fa"
  elsif Dir.glob("*.fa.masked").size > 1
    ".fa.masked"
  else
    raise "No *.fa nor *.fa.masked files"
  end
end

def fasta_file(entry_id)
  "#{entry_id}#{fasta_postfix}"
end

def fa_files
  Dir.glob(fasta_file("*")).map do |file|
    file.split(fasta_postfix).first
  end
end


namespace :tcf do

  def tsv_file(entry_id)
    "#{entry_id}_tcf.tsv"
  end

  def tcf_file(entry_id)
    "#{entry_id}.tcf"
  end
  
  TCF_WIDTH = 50
  TCF_LIMSIZ = 268435456
  # 268435456 -> 256M
  #
  # $ tcfmgr inform chr1.tcf
  # path: chr1.tcf
  # database type: fixed
  # additional flags:
  # minimum ID number: 1
  # maximum ID number: 4904078
  # width of the value: 50
  # limit file size: 268435456
  # limit ID number: 5263435
  # inode number: 7476687
  # modified time: 2009-05-10T23:55:09+09:00
  # record number: 4904078
  # file size: 250121137

  
  desc "create db and import data."
  task :all => [:create, :demo]

  
  # egrep -v '^>' chr1.fa | cat -n | sed -e 's/ //g' > chr1.fa
#  desc "make TSV files (#{tsv_file('chr*')}) for TCF DB."
  task :tsv do
    entry_id = ""
    fa_files.each do |entry_id|
      STDERR.print "Creating #{tsv_file(entry_id)} ... "
      File.open(tsv_file(entry_id), "w") do |f|
        File.open(fasta_file(entry_id)).each_with_index do |line, i|
          next if line =~ /^>/
          line.chomp!
          raise "[TCF] Error: line length should be <= #{TCF_WIDTH} chrs. " unless line.size <= TCF_WIDTH
          f.puts ["#{i}", line].join("\t")
        end
      end
      STDERR.puts
    end
  end

#  desc "remove TSV files (#{tsv_file('chr*')})."
  task :tsv_remove do
    fa_files.each do |entry_id|
      STDERR.print "Removing #{tsv_file(entry_id)} ... "
      begin
        File.delete(tsv_file(entry_id))
        STDERR.puts
      rescue
        STDERR.puts $!
      end
    end
  end
  
  desc "create TCF db files #{tcf_file('chr*')} from #{fasta_file('chr*')}."
  task :create do
    fa_files.each do |entry_id|
      STDERR.print entry_id
      db = TokyoCabinet::FDB.new
      db.tune(TCF_WIDTH, TCF_LIMSIZ)
      if !db.open(tcf_file(entry_id),  TokyoCabinet::FDB::OCREAT | TokyoCabinet::FDB::OWRITER)
        ecode = db.ecode
        STDERR.printf("open error: %s\n", db.errmsg(ecode))
      end
      STDERR.print " ."

      STDERR.print "."      
      File.open(fasta_file(entry_id)).each_with_index do |line, i|
        next if line =~ /^>/
        if (line = line.chomp).size <= TCF_WIDTH
          db.put(i, line)
          STDERR.print "."  if (i % 100000) == 1 
        else
          STDERR.puts
          STDERR.puts $!
          STDERR.puts i
          STDERR.puts line.inspect
          STDERR.puts line.size
          raise
        end
      end
      STDERR.puts
    end
  end

#  desc "import TSV files into TCF db."
  task :import do
    fa_files.each do |entry_id|    
      sh "tcfmgr importtsv #{tcf_file(entry_id)} #{tsv_file(entry_id)}"
    end
  end
  
  desc "get demo."
  task :demo do
    sh "time tcfmgr get #{tcf_file('chr1')} 10"
    sh "time tcfmgr get #{tcf_file('chr1')} 10000"
    sh "time tcfmgr get #{tcf_file('chr1')} 1000000"    
    sh "time tcfmgr get #{tcf_file('chrX')} 100000"
  end
end

namespace :benchmark do
  require 'benchmark'
  require 'subseq'

  def chr1q
    i = [1,2,3,4,5,6,7,11,13,16,17,23,29,32,48,49,50,51,52,64,98,99,100,101,102,128,223,256,333,512,777,998,999,1000,1024,9999,10000,10001,11111,22222,33333,44444,55555,99998,99999,100001,100002,999999,1000000,1000001] 
    i = i + i.map {|y| [y * 3, y * 5, y * 7, y * 13, y * 17, y * 103] }
    i = i.flatten.sort
  end

  namespace :tcfmgr do
    desc "chr1"
    task :chr1 do
      Benchmark.bm(13) do |x|
        x.report("14928 gets:") {
          o = 0
          chr1q.each do |x|
            chr1q.each do |y|
              next if x > y 
              next if (x - y).abs > 1000
              o += 1
              sh "tcfmgr get chr1.tcf #{x/50+1} > out.fa"
            end
          end
        }
      end
    end
  end

  namespace :tcf do
    desc "chr1"
    task :chr1 do
      Benchmark.bm(13) do |x|
        x.report("14928 gets:") {
          o = 0
          chr1q.each do |x|
            chr1q.each do |y|
              next if x > y 
              next if (x - y).abs > 1000
              o += 1
              TCF_SS.subseq("chr1", "#{x},#{y}")
            end
          end
        }
      end
    end

    desc "chr1"
    task :chr1file do
      Benchmark.bm(13) do |x|
        x.report("14928 gets:") {
          o = 0
          chr1q.each do |x|
            chr1q.each do |y|
              next if x > y 
              next if (x - y).abs > 1000
              o += 1
              fa = File.new("out.fa", 'w')
              fa.puts TCF_SS.subseq("chr1", "#{x},#{y}")
              fa.close
            end
          end
        }
      end
    end

    desc "length"
    task :length do
      Benchmark.bm(17) do |x|
        x.report("TCF   1 nt/440:") { 
          fa_files.each do |chr|
            next unless chr =~ /^chr[0-9XY]+$/  
            ["1,1", "10,10","11,11","10011,10011","10001,10001","1130,1130","120,120","751,751","3567,3567","12345,12345"].each do |pos|
              TCF_SS.subseq(chr, pos) 
            end
          end
        }
      x.report("TCF  10 nt/440:") { 
        fa_files.each do |chr|
          ["1,11", "10,20","11,21","10011,10021","10001,10011","1130,1140","120,130","751,761","3567,3577","12345,12355"].each do |pos|
            TCF_SS.subseq(chr, pos) 
          end
        end
      }
      x.report("TCF 100 nt/440:") { 
        fa_files.each do |chr|
          ["1,101", "10,110","11,111","10011,10111","10001,10101","1130,1230","120,220","751,851","3567,3667","12345,12445"].each do |pos|
            TCF_SS.subseq(chr, pos) 
          end
        end
      }
      x.report("TCF  1k nt/440:") { 
        fa_files.each do |chr|
          ["1,1001", "110,1110","11,1011","10011,11011","10001,11001","10,1010","20,1020","761,1761","3567,4567","12345,13345"].each do |pos|
            TCF_SS.subseq(chr, pos) 
          end
        end
      }
      x.report("TCF 10k nt/440:") { 
        fa_files.each do |chr|
          ["1,10000", "1,10001","11,11201","201,11201","10001,10010","10,10030","20,10200","751,10761","3000,13000","2345,13345"].each do |pos|
            TCF_SS.subseq(chr, pos) 
          end
        end
      }
      end
    end
  end # tcf

  namespace :tch do
    desc "chr1"
    task :chr1 do
      i = [1,2,3,4,5,6,7,11,13,16,17,23,29,32,48,49,50,51,52,64,98,99,100,101,102,128,223,256,333,512,777,998,999,1000,1024,9999,10000,10001,11111,22222,33333,44444,55555,99998,99999,100001,100002,999999,1000000,1000001] 
      i = i + i.map {|y| [y * 3, y * 5, y * 7, y * 13, y * 17, y * 103] }
      i = i.flatten.sort
      Benchmark.bm(13) do |x|
        x.report("14928 gets:") {
          o = 0
          i.each do |x|
            i.each do |y|
              next if x > y 
              next if (x - y).abs > 1000
              o += 1
              TCH_SS.subseq("chr1", "#{x},#{y}")
            end
          end
          #        p o
        }
      end
    end

    desc "length"
    task :length do
      Benchmark.bm(17) do |x|
        x.report("TCH   1 nt/440:") { 
          fa_files.each do |chr|
            ["1,1", "10,10","11,11","10011,10011","10001,10001","1130,1130","120,120","751,751","3567,3567","12345,12345"].each do |pos|
              TCH_SS.subseq(chr, pos) 
            end
          end
        }
        x.report("TCH  10 nt/440:") { 
          fa_files.each do |chr|
            ["1,11", "10,20","11,21","10011,10021","10001,10011","1130,1140","120,130","751,761","3567,3577","12345,12355"].each do |pos|
              TCH_SS.subseq(chr, pos) 
            end
          end
        }
        x.report("TCH 100 nt/440:") { 
          fa_files.each do |chr|
            ["1,101", "10,110","11,111","10011,10111","10001,10101","1130,1230","120,220","751,851","3567,3667","12345,12445"].each do |pos|
              TCH_SS.subseq(chr, pos) 
            end
          end
        }
        x.report("TCH  1k nt/440:") { 
          fa_files.each do |chr|
            ["1,1001", "110,1110","11,1011","10011,11011","10001,11001","10,1010","20,1020","761,1761","3567,4567","12345,13345"].each do |pos|
              TCH_SS.subseq(chr, pos) 
            end
          end
        }
        x.report("TCH 10k nt/440:") { 
          fa_files.each do |chr|
            ["1,10000", "1,10001","11,11201","201,11201","10001,10010","10,10030","20,10200","751,10761","3000,13000","2345,13345"].each do |pos|
              TCH_SS.subseq(chr, pos) 
            end
          end
        }
      end
    end
  end # tch
end # benchmark




namespace :tch do
  def tsv_file(entry_id)
    "#{entry_id}_tch.tsv"
  end

  def tch_file(entry_id)
    "#{entry_id}.tch"
  end
  
  task :all => [:create, :demo] do
    puts "try ruby tcf_subseq.rb chr1:1000010,1000100"
  end

#  desc "make TSV files for TCH DB."
  task :tsv do
    fa_files.each do |entry_id|
      STDERR.puts file_name = tsv_file(entry_id)
      File.open(file_name, "w") do |f|
        File.open(fasta_file(entry_id)).each_with_index do |line, i|
          next if line =~ /^>/
          line.chomp!
          f.puts ["#{entry_id}_#{i}", line].join("\t")
        end
      end
    end
  end

#  desc "remove TSV files (chr*_tch.tsv)."
  task :tsv_remove do
    fa_files.each do |entry_id|
      STDERR.print entry_id
      begin
        File.delete(tsv_file(entry_id))
        STDERR.puts
      rescue
        STDERR.puts $!
      end
    end
  end


  desc "create TCH db #{tch_file('chr*')} form #{fasta_file('chr*')}"
  task :create do
    fa_files.each do |entry_id|
      STDERR.print entry_id
      db = TokyoCabinet::HDB.new
      if !db.open(tch_file(entry_id), TokyoCabinet::HDB::OCREAT | TokyoCabinet::HDB::OWRITER)
        ecode = db.ecode
        STDERR.printf("open error: %s\n", db.errmsg(ecode))
      end
      STDERR.print " ."
      STDERR.print "."      
      File.open(fasta_file(entry_id)).each_with_index do |line, i|
        next if line =~ /^>/
        line.chomp!
        db.put(i, line)
        STDERR.print "."  if (i % 100000) == 1 
      end
      STDERR.puts
    end
  end

#  desc "import TSV files into TCH db"
  task :import do
    fa_files.each do |entry_id|    
      sh "tchmgr importtsv #{tch_file(entry_id)} #{tsv_file(entry_id)}"
    end
  end
  
  desc "get demo"
  task :demo do
    sh "tchmgr get #{tch_file('chr1')} 10"
    sh "tchmgr get #{tch_file('chr1')} 100"
  end
end



namespace :syn do
  desc 'syn'
  task :syn do
    orfs = File.open('genes.txt').read.split("\n").map {|x| x.split("\t") }
    orfs.each do |orf|
      gene = orf[1]
      chr = orf[2]
      start = orf[3].to_i
      stop = orf[4].to_i

      next if start < 0 or stop < 0 or chr != 'Chr'
      puts ">#{gene} [#{orf[0]}:#{chr}:#{start},#{stop}] #{orf[5]} #{orf[6]}"
      p TCF_SS.new("syn", "#{start},#{stop}", 70).subseq
    end
  end
end


__END__

namespace :tch_hg do
  desc "make TSV file."
  task "tsv" do
    entry_id = ""
    fa_files = Dir.glob("*.fa")
    STDERR.puts fa_files
    File.open("hg.tsv", "w") do |f|
      fa_files.each do |chr|
        STDERR.puts chr
        entry_id = chr.split(".fa").first
        File.open(chr).each_with_index do |line, i|
          next if line =~ /^>/
          line.chomp!
          f.puts ["#{entry_id}_#{i}", line].join("\t")
        end
      end
    end
  end

  desc "create TCH db (hg.tch)"
  task :create do
    sh "tchmgr create hg.tch"
  end

  desc "import  (time-consuming)"
  task :import do
    sh "tchmgr importtsv hg.tch hg.tsv"
  end
  
  desc "get demo"
  task :demo do
    sh "tchmgr get hg.tch chr1_10"
  end
end


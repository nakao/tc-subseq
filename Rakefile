# Human genome sequences on Tokyo Cabinet 
#

namespace :test do
  desc "unit test for subseq.rb"
  task :subseq do
    sh "ruby test_subseq.rb"
    ["test.tsv", "test.tcf"].each { |file|
      File.delete(file) if File.exists?(file)
    }
  end
end


namespace :data do
  namespace :ucsc do
    desc "UCSC hg chromFa"
    task :hg do
      hg = "http://hgdownload.cse.ucsc.edu/goldenPath/10april2003/bigZips/chromFa.zip"
      sh "curl -O #{hg}"
      sh "unzip #{hg.split("/").last}"
    end
    
    desc "UCSC mm chromFa"
    task :mm do
      puts "Not-implemented yet."
    end
  end
end


def fa_files
  Dir.glob("*.fa").map do |file|
    file.split(".fa").first
  end
end


namespace :tcf do
  def fasta_file(entry_id)
    "#{entry_id}.fa"
  end

  def tsv_file(entry_id)
    "#{entry_id}_tcf.tsv"
  end

  def tcf_file(entry_id)
    "#{entry_id}.tcf"
  end
  
  TCF_LENGTH = 50

  desc "make tsv, create db and then import."
  task :all => [:tsv, :create, :import, :demo]

  
  desc "make TSV files (#{tsv_file('chr*')}) for TCF DB."
  task :tsv do
    entry_id = ""
    fa_files.each do |entry_id|
      STDERR.print "Creating #{tsv_file(entry_id)} ... "
      File.open(tsv_file(entry_id), "w") do |f|
        File.open(fasta_file(entry_id)).each_with_index do |line, i|
          next if line =~ /^>/
          line.chomp!
          raise "[TCF] Error: line length should be <= #{TCF_LENGTH} chrs. " unless line.size <= TCF_LENGTH
          f.puts ["#{i}", line].join("\t")
        end
      end
      STDERR.puts
    end
  end

  desc "remove TSV files (#{tsv_file('chr*')})."
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
  
  desc "create TCF db files (#{tcf_file('chr*')})."
  task :create do
    fa_files.each do |entry_id|
      sh "tcfmgr create #{tcf_file(entry_id)} #{TCF_LENGTH}"
    end
  end

  desc "import TSV files into TCF db."
  task :import do
    fa_files.each do |entry_id|    
      sh "tcfmgr importtsv #{tcf_file(entry_id)} #{tsv_file(entry_id)}"
    end
  end
  
  desc "get value demo."
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
            TCF_SS.subseq("chr1", "#{x},#{y}")
          end
        end
#        p o
      }
    end
  end

  desc "length"
  task :length do
    Benchmark.bm(13) do |x|
      x.report("  1 nt/440:") { 
        fa_files.each do |chr|
          ["1,1", "10,10","11,11","10011,10011","10001,10001","1130,1130","120,120","751,751","3567,3567","12345,12345"].each do |pos|
            TCF_SS.subseq(chr, pos) 
          end
        end
      }
      x.report(" 10 nt/440:") { 
        fa_files.each do |chr|
          ["1,11", "10,20","11,21","10011,10021","10001,10011","1130,1140","120,130","751,761","3567,3577","12345,12355"].each do |pos|
            TCF_SS.subseq(chr, pos) 
          end
        end
      }
      x.report("100 nt/440:") { 
        fa_files.each do |chr|
          ["1,101", "10,110","11,111","10011,10111","10001,10101","1130,1230","120,220","751,851","3567,3667","12345,12445"].each do |pos|
            TCF_SS.subseq(chr, pos) 
          end
        end
      }
      x.report(" 1k nt/440:") { 
        fa_files.each do |chr|
          ["1,1001", "110,1110","11,1011","10011,11011","10001,11001","10,1010","20,1020","761,1761","3567,4567","12345,13345"].each do |pos|
            TCF_SS.subseq(chr, pos) 
          end
        end
      }
      x.report("10k nt/440:") { 
        fa_files.each do |chr|
          ["1,10000", "1,10001","11,11201","201,11201","10001,10010","10,10030","20,10200","751,10761","3000,13000","2345,13345"].each do |pos|
            TCF_SS.subseq(chr, pos) 
          end
        end
      }
    end
  end
end


__END__


namespace :tch do
  task :all => [:tsv, :create, :import] do
    puts "try ruby tcf_subseq.rb chr1:1000010,1000100"
  end

  desc "make TSV files for TCH DB."
  task :tsv do
    entry_id = ""
    fa_files.each do |entry_id|
      STDERR.p file_name = "tch_#{entry_id}.tsv" 
      File.open(file_name, "w") do |f|
        File.open("#{entry_id}.fa").each_with_index do |line, i|
          next if line =~ /^>/
          line.chomp!
          f.puts ["#{entry_id}_#{i}", line].join("\t")
        end
      end
    end
  end

  desc "remove TSV files (chr*_tch.tsv)."
  task :tsv_remove do
    fa_files.each do |entry_id|
      print entry_id
      begin
        File.delete("#{entry_id}_tch.tsv")
        puts
      rescue
        puts $!
      end
    end
  end


  desc "create TCH db files (chr*.tch)"
  task :create do
    fa_files.each do |entry_id|
      sh "tchmgr create #{entry_id}.tch"
    end
  end

  desc "import TSV files into TCH db"
  task :import do
    fa_files.each do |entry_id|    
      sh "tchmgr importtsv #{entry_id}.tch #{entry_id}_tch.tsv"
    end
  end
  
  desc "get demo"
  task :demo do
    sh "tchmgr get chr1.tch 10"
    sh "tchmgr get chr1.tch 100"
  end
end



namespace :tch_hg do
  desc "make TSV file."
  task "tsv" do
    entry_id = ""
    fa_files = Dir.glob("*.fa")
    STDERR.p fa_files
    File.open("hg.tsv", "w") do |f|
      fa_files.each do |chr|
        STDERR.p chr
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



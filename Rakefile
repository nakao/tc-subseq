# Human genome sequences on Tokyo Cabinet 
#


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

  namespace :benchmark do
    
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



# human genome sequences on Tokyo Cabinet (Hash database)
#

hg = "http://hgdownload.cse.ucsc.edu/goldenPath/10april2003/bigZips/chromFa.zip"

def fa_files
  Dir.glob("*.fa").map do |file|
    file.split(".fa").first
  end
end


namespace :tch do
  task :all => [:create, :import]

  desc "create"
  task :create do
    fa_files.each do |entry_id|
      sh "tchmgr create #{entry_id}.tch"
    end
  end

  desc "import"
  task :import do
    fa_files.each do |entry_id|    
      sh "tchmgr importtsv #{entry_id}.tch tch_#{entry_id}.tsv"
    end
  end
  
  desc "get demo"
  task :demo do
    sh "tchmgr get tch_chr1 10"
  end
end



namespace :tch_hg do
  desc "create"
  task :create do
    sh "tchmgr create hg.tch"
  end

  desc "import"
  task :import do
    sh "tchmgr importtsv hg.tch hg.tsv"
  end
  
  desc "get demo"
  task :demo do
    sh "tchmgr get hg.tch chr1_10"
  end
end




namespace :tcf do
  desc "create"
  task :create do
    fa_files.each do |entry_id|
      sh "tcfmgr create #{entry_id}.tcf 50"
    end
  end

  desc "import"
  task :import do
    fa_files.each do |entry_id|    
      sh "tcfmgr importtsv #{entry_id}.tcf tcf_#{entry_id}.tsv"
    end
  end
  
  desc "get demo"
  task :demo do
    sh "tcfmgr get chr1.tcf 10"
  end
end



namespace :data do
  desc "hg"
  task :hg do
    sh "curl -O #{hg}"
    sh "unzip #{hg.split("/").last}"
  end

  desc "Make tsv."
  task "hg.tsv" do
    entry_id = ""
    fa_files = Dir.glob("*.fa")
    p fa_files
    File.open("hg.tsv", "w") do |f|
      fa_files.each do |chr|
        p chr
        entry_id = chr.split(".fa").first
        File.open(chr).each_with_index do |line, i|
          next if line =~ /^>/
          line.chomp!
          f.puts ["#{entry_id}_#{i}", line].join("\t")
        end
      end
    end
  end


  desc "Make tsv for TCF."
  task :tsv_tcf do
    entry_id = ""
    fa_files.each do |entry_id|
      p entry_id
      File.open("tcf_#{entry_id}.tsv", "w") do |f|
        File.open("#{entry_id}.fa").each_with_index do |line, i|
          next if line =~ /^>/
          line.chomp!
          f.puts ["#{i}", line].join("\t")
        end
      end
    end
  end

  desc "Make tsv for TCH."
  task :tsv_tch do
    entry_id = ""
    fa_files.each do |entry_id|
      p entry_id
      File.open("tch_#{entry_id}.tsv", "w") do |f|
        File.open("#{entry_id}.fa").each_with_index do |line, i|
          next if line =~ /^>/
          line.chomp!
          f.puts ["#{entry_id}_#{i}", line].join("\t")
        end
      end
    end
  end

end


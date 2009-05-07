# human genome sequences on Tokyo Cabinet (Hash database)
#

hg = "http://hgdownload.cse.ucsc.edu/goldenPath/10april2003/bigZips/chromFa.zip"
tchmgr = "tchmgr"
dbname = 'chr'


namespace :tch do
  desc "create"
  task :create do
    sh "#{tchmgr} create #{dbname}"
  end

  desc "import"
  task :import do
    sh "#{tchmgr} importtsv #{dbname} hg.tsv"
  end
  
  desc "get demo"
  task :demo do
    sh "#{tchmgr} get #{dbname} chr1_10"
  end
end


namespace :data do
  desc "hg"
  task :hg do
    sh "curl -O #{hg}"
    sh "unzip #{hg.split("/").last}"
  end

  desc "Make tsv."
  task :tsv do
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
end


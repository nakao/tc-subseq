require 'tokyocabinet'
include TokyoCabinet

width = 50


if ARGV.size < 1
  STDERR.puts "Usage: ruby tcf_subseq.rb chr1:100,110"
  exit
end

arg = ARGV.shift
chr, pos = arg.split(":")

dbname = "tcf_#{chr}"
db = FDB::new
unless db.open(dbname)
  ecode = db.ecode
  STDERR.printf("fdb open error: #{dbname}: %s\n", db.errmsg(ecode))
  exit
end

start, stop = pos.split(",")
start = start.to_i
stop  = stop.to_i

chunk  = ((start - 1) / width) + 1
chunke = ((stop - 1) / width) + 1

subseq = ""
offset = start - (chunk - 1) * width
length = stop - (chunke - 1) * width

(chunk..chunke).each do |i|
  value = db.get("#{i}")
  if chunk == chunke
    value = value[offset-1, length]
  elsif chunk == i
    value = value[offset-1, (width - offset + 1)]
  elsif chunke == i
    value = value[0, length]
  end
  subseq.concat(value)
end

puts subseq
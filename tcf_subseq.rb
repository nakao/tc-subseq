require 'subseq'

if ARGV.size < 1
  STDERR.puts "Usage: ruby tcf_subseq.rb chr1:100,110"
  exit
end

arg = ARGV.shift
chr, pos = arg.split(":")
width = ARGV.shift
puts TCF_SS.new(chr, pos, width).subseq

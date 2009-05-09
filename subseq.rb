require 'tokyocabinet'
include TokyoCabinet

  
class SubSeq
  attr_reader :subseq
  
  def initialize(chr, pos)
    unless @db.open(@dbname)
      ecode = @db.ecode
      STDERR.printf("open error: #{@dbname}: %s\n", db.errmsg(ecode))
      exit
    end

    width = 50    
    start, stop = pos.split(",")
    start = start.to_i
    stop  = stop.to_i

    chunk  = ((start - 1) / width) + 1
    chunke = ((stop - 1) / width) + 1

    @subseq = ""
    offset = start - (chunk - 1) * width
    length = stop - (chunke - 1) * width

    (chunk..chunke).each do |i|
      value = @db.get(self.get_arg(i))
      if chunk == chunke
        value = value[offset-1, length]
      elsif chunk == i
        value = value[offset-1, (width - offset + 1)]
      elsif chunke == i
        value = value[0, length]
      end
      @subseq.concat(value)
    end
    @db.close
  end
end


class TCF_SS < SubSeq
  def initialize(chr, pos)
    @dbname = "#{chr}.tcf"
    @db = FDB::new
    super(chr, pos)
  end
  
  def get_arg(i)
    "#{i}"
  end
end

class TCH_SS < SubSeq
  def initialize(chr, pos)
    @dbname = "#{chr}.tch"
    @db = HDB::new
    super(chr, pos)
  end
  
  def get_arg(i)
    "#{chr}_#{i}"
  end
end

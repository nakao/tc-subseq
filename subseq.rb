require 'tokyocabinet'
include TokyoCabinet

# Abstract class for querying sub-sequence to Tokyo Cabinet db.
#
# Inherited class should have folowing variables and method:
#  1. @db  -- Tokyo Cabinet db instance.
#  2. @dbname -- file name of db
#  3. #get_arg(chunk) -- convert method from chunk to key
#
class SubSeq
  WIDTH = 50    

  # 
  def self.subseq(chr, pos)
    self.new(chr, pos).subseq
  end

  # 
  attr_reader :subseq
  
  # 
  def initialize(pos, path = nil)
    dbname = [path, @filename].compact.join("/")
    unless @db.open(dbname)
      ecode = @db.ecode
      STDERR.printf("open error: #{dbname}: %s\n", @db.errmsg(ecode))
      exit
    end

    start, stop = pos.split(",")
    start = start.to_i
    stop  = stop.to_i

    chunk  = ((start - 1) / WIDTH) + 1
    chunke = ((stop - 1) / WIDTH) + 1

    @subseq = ""
    offset = start - (chunk - 1) * WIDTH
    length = stop - (chunke - 1) * WIDTH

    (chunk..chunke).each do |i|
      value = @db.get(self.get_arg(i))
      if chunk == chunke
        value = value[offset-1, length]
      elsif chunk == i
        value = value[offset-1, (WIDTH - offset + 1)]
      elsif chunke == i
        value = value[0, length]
      end
      @subseq.concat(value)
    end
    @db.close
  end
end

# Implimantation of sub-sequence extraction using TCF Tokyo Cabinet Fixed-length Index.
class TCF_SS < SubSeq
  def initialize(chr, pos)
    @filename = "#{chr}.tcf"
    @db = FDB::new
    super(pos)
  end

  protected
  
  def get_arg(i)
    "#{i}"
  end
end


class TCH_SS < SubSeq
  def initialize(chr, pos)
    @filename = "#{chr}.tch"
    @db = HDB::new
    super(pos)
  end

  protected
  
  def get_arg(i)
    "#{chr}_#{i}"
  end
end

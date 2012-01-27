class Profile
  attr_reader :ts, :ns, :op, :size, :millis, :command

  def initialize hsh
    @hsh = hsh
    @ts, @ns, @millis = hsh["ts"], hsh["ns"], hsh["millis"]
    @op, @command, @query = hsh["op"], hsh["command"], hsh["query"]
    @scanned, @returned, @size = hsh["nscanned"], hsh["nreturned"], hsh["responseLength"]
    @client, @user = hsh["client"], hsh["user"]
  end

  def ns
    @ns.gsub(/.*\./, "")
  end

  def size # add 1.000 dots
    "#{@size}"
  end

  def summary
    @hsh
    "#{ns} - #@op [#@command]"
  end

  def stats
    @scanned ? "#@scanned|#@returned" : "0"
  end

  def self.all db
    # to_a.reverse
    # db.system.profile.find( { millis : { $gt : 100 } } )
    db.profiling_info.map { |prof| new prof }
  end

  def self.count db
    db.system.profile.count()
  end

end

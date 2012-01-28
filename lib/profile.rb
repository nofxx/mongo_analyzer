class Profile
  attr_reader :ts, :ns, :op, :size, :millis

  def initialize hsh
    @hsh = hsh
    @ts, @ns, @millis = hsh["ts"], hsh["ns"], hsh["millis"]
    @op, @command, @query = hsh["op"], hsh["command"], hsh["query"]
    @scanned, @size = hsh["nscanned"], hsh["responseLength"]
    @returned =  hsh["nreturned"] ||  hsh["ntoreturn"]
    @client, @user = hsh["client"], hsh["user"]
  end

  def id;    @ts.to_f              end
  def ns;    @ns.gsub(/.*\./, "")  end

  def size # add 1.000 dots
    "#{@size}"
  end

  def params
    (command || @query).to_json
  end

  def command
    @command.nil? || @command.empty? ? nil : @command
  end

  def stats
    @scanned ? "#@scanned|#@returned" : @returned
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

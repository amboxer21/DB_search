require 'mysql2'
require 'optparse'

$host 		 = "localhost"
$password  = "easypeasy"
$username  = "root"
$databases = Array.new
@results 	 = Array.new
@test			 = Array.new

FILE = '/home/anthony/Documents/Ruby/DB_search/temp1'

def truncate_file(file)
  File.open(file, "w") do |f|
    f.truncate(0)
  end
end


def query(db,table,column)
  client = Mysql2::Client.new(:host     => $host, 
			      									:username => $username, 
			      									:password => $password)

  results = client.query('show databases;')
  results.each do |key,val|
    key.each {|k,v| $databases.push v}
  end
end

query(nil,nil,nil)

def query2
	@count = 0
  $databases.each do |db|
		@count += 1
		$databases.push db unless db == db if @count == 5
		$databases.each do |db|
  		@client = Mysql2::Client.new(:host    => $host,
			      											:username => $username, 
			      											:password => $password, 
			      											:database => db)

			@client.query('show tables;').each do |res|
				res.each do |k,v|
					File.open(FILE,'a+') do |f| 
						f.write("#{k.gsub(/Tables_in_/,'')},#{v}\n")
					end
				end
			end

		end
	end

end

truncate_file(FILE)
query2

def query3
  File.open(FILE, "r") do |f|
    f.each_line do |l|

      l = l.split(/,/)
			@dbs 	  = l[0]
			@tables = l[1]  		
			@client = Mysql2::Client.new(:host     => $host,
			      											 :username => $username, 
			      											 :password => $password)

			unless @dbs.nil? || @tables.nil?
				@client.query("use #{@dbs};") 
				@client.query("select * from #{@tables};").each do |y|
					y.each {|g| puts "\n\n#{@dbs} - \n#{g}"}
				end	
			end

    end

  end
end
query3

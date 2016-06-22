require 'mysql2'
require 'optparse'

class DBSearch

$options = {}
$show_tables,$dataBases,$tables,$explain = [],[],[],[]

optparse = OptionParser.new do |opts|
  opts.banner = "\nA program to traverse an entire MySQL DB with a given string.\nWritten by Anthony Guevara amboxer21@gmail.com\n\n"
  $options[:database] = false
  opts.on('-D','--database') do 
    $options[:database] = true
  end
  $options[:table] = false
  opts.on('-T','--table') do 
    $options[:table] = true
  end
  $options[:file] = false
  opts.on('-F','--file') do 
    $options[:file] = true
  end
  $options[:dblist] = false
  opts.on('-l','--list') do 
    $options[:dblist] = true
  end
  $options[:help] = false
  opts.on('-h','--help') do 
    $options[:help] = true
    puts opts.banner
  end
  $options[:verbose] = false
  opts.on('-v','--verbose') do 
    $options[:verbose] = true
  end
end

optparse.parse!

def usage
  puts "\nA program to traverse an entire MySQL DB with a given string.\nWritten by Anthony Guevara amboxer21@gmail.com\n\n"
  puts "\nUSAGE: DB_search.rb <string> [options]\n\n"
  puts "OPTIONS:"
  puts "     <string>               \"String is the word you want to search the db for.\""
  puts "    -v or --verbose         \"Print queries in real time.\""
  puts "    -h or --help            \"Displays this help dialog.\""
  puts "    -F or --file            \"Config file to pass into DB_search.rb.\""
  puts "    -T or --table           \"Specific MySQL table to search.\""
  puts "    -D or --database        \"Specific MySQL DataBase to search.\"\n\n"
  puts "    -l or --list            \"List all MySQL DataBases.\"\n\n"
  exit
end

if $options[:help] || ARGV[0].nil?
  usage
end

$host = "host"
$password = "password"
$username = "uname"
$databases, @results = [], []

FILE = '/home/anthony/Documents/Ruby/DB_search/temp1'

# Zero out file before writing to it.
def truncate_file
  File.open(FILE, "w") do |f|
    f.truncate(0)
  end
end

def connect(host,username,password,db)
  if $options[:database] 
    db = ARGV[1]
  end
  if $options[:file] 
    File.open('db_search.conf', 'r').each do |cfg|
      $host = cfg.split(/,/)[0].split(/:/)[1]
      $password = cfg.split(/,/)[1].split(/:/)[1]
      $username = cfg.split(/,/)[2].split(/:/)[1]
    end
  end 
	if db.nil?
  	client = Mysql2::Client.new(:host     => host, 
			      										:username => username, 
			      										:password => password)	
	else
  	client = Mysql2::Client.new(:host     => host, 
			      										:username => username, 
			      										:password => password,
																:database => db)
	end
end

def query_dbs
  client = connect($host,$username,$password,nil)
  results = client.query('show databases;')
  results.each do |key,val|
    key.each {|k,v| $databases.push v}
  end
end

def query_tables
	@count = 0
  $databases.each do |db|
		@count += 1
		$databases.push db unless db == db if @count == 5
		$databases.each do |db|
			@client = connect($host,$username,$password,db)
			@client.query('show tables;').each do |res|
				res.each do |k,v|
					File.open(FILE,'a+') do |f| 
						f.write("#{k.gsub(/^Tables_in_/,'')},#{v}\n")
					end
				end
			end
		end
	end
end

def traverse_db
  File.open(FILE, "r") do |f|
    f.each_line do |l|

      l = l.split(/,/)
			@dbs 	  = l[0]
			@tables = l[1]  		
			@client = connect($host,$username,$password,nil)

			unless @dbs.nil? || @tables.nil?
				@client.query("use #{@dbs};") 
				@client.query("explain #{@tables};").each do |y|
					puts "\n\nDatabase: #{@dbs}\nTable: #{@tables}\n#{y}" if $options[:verbose]
					sleep 1
					begin
						@client.query("select * from #{@tables} where #{y.values[0]} like \"#{ARGV[0]}\";").each do |q|
							puts "-> FOUND #{q}. \n   Database: #{@dbs}\n   Table: #{@tables}   Query: #{ARGV[0]}" if q
							return
						end
					rescue
						next
					end
				end
			end
    end
  end
end

end
db_search = DBSearch.new
db_search.query_dbs
db_search.truncate_file
db_search.query_tables
db_search.traverse_db

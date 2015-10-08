#!/usr/bin/ruby

require 'mysql2'
require 'optparse'

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
  $options[:help] = false
  opts.on('-h','--help') do 
    $options[:help] = true
    puts opts.banner
  end
end

optparse.parse!

def usage
  puts "\nA program to traverse an entire MySQL DB with a given string.\nWritten by Anthony Guevara amboxer21@gmail.com\n\n"
  puts "\nUSAGE: DB_search.rb <string> [options]\n\n"
  puts "OPTIONS:"
  puts "     <string>               \"String is the word you want to search the db for.\""
  puts "    -h or --help            \"Displays this help dialog.\""
  puts "    -F or --file            \"Config file to pass into DB_search.rb.\""
  puts "    -T or --table           \"Specific MySQL table to search.\""
  puts "    -D or --database        \"Specific MySQL DataBase to search.\"\n\n"
  exit
end

if $options[:help] || ARGV[0].nil?
  usage
end

def cleanup(var)
  return var.to_s.gsub(/\[|\]|\"|\n+/,"")
end

def string_check(ref,arg)
  if ARGV[0].downcase =~ /#{cleanup(ref).downcase}/
    if arg == "database" 
      puts "\n#{ARGV[0]} is a database. Please provide a string to search for."
      usage
    elsif arg == "tables" 
      puts "\n#{ARGV[0]} is a table. Please provide a string to search for."
      usage
    elsif arg == "file"
      puts "\n#{ARGV[0]} is a conf file. Please provide a string to search for."
      usage
    else
      puts "\nString not provided."
      usage
    end
  end
end

def connect(db,command,action,table)
  if $options[:database] 
    dbf = cleanup(ARGV[1])
  else  
    dbf = cleanup(db)
  end
  if $options[:file] 
    File.open('db_search.conf', 'r').each do |cfg|
      $host = cfg.split(/,/)[0].split(/:/)[1]
      $password = cfg.split(/,/)[1].split(/:/)[1]
      $username = cfg.split(/,/)[2].split(/:/)[1]
    end
  else
    $host = "localhost"
    $password = "easypeasy"
    $username = "root"
  end 
  client = Mysql2::Client.new(:host => cleanup($host), :username => cleanup($username), :password => cleanup($password), :database => dbf)
  results = client.query(command)
  results.each do |db1|
    if action == "initial_query"
      $dataBases.push db1.values
      string_check(db1.values,"database")
    elsif action == "query_tables"
      $tables.push db1.values
      string_check(db1.values,"tables")
    elsif action == "explain_tables" 
      db1.values.each do |explain|
        if explain =~ /#{ARGV[0]}/
          puts "FOUND \"#{ARGV[0]}\" in => DATABASES(#{dbf}), TABLE(#{table})"
          open('results', 'w') do |write|
            write.puts "FOUND \"#{ARGV[0]}\" in => DATABASES(#{dbf}), TABLE(#{table})"
          end
          sleep 10
        else
          puts "\"#{ARGV[0]}\" NOT FOUND in => DATABASES(#{dbf}), TABLE(#{table})" unless explain.nil?
        end
      end
    end
  end
end

connect("mysql","show databases","initial_query",nil)

def databases
  $dataBases.each do |dbs|
    connect(dbs,"show tables","query_tables",nil)
    $tables.each do |tables|
      $show_tables.push "#{dbs},#{tables}"
    end
  end
end

databases

def show_tables
  $show_tables.each do |tables|
    begin
      if $options[:table] 
        table = ARGV[2]
      else    
        hash_split = cleanup(tables).split(/,/)
        db = hash_split[0]
        table = hash_split[1]
      end 
      connect(db, "select * from #{table}","explain_tables",table)
    rescue
      next
    end
  end
end

show_tables

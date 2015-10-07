#!/usr/bin/ruby

require 'mysql2'
require 'optparse'

$options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "\nUSAGE: DB_search.rb <string> [options]\n\n"
  $options[:database] = false
  opts.on('-D','--database') do 
    $options[:database] = true
  end
  opts.on('-h','--help') do 
    $options[:help] = true
  end
end

optparse.parse!

if $options[:help] || ARGV[0].nil?
  puts "\nUSAGE: DB_search.rb <string> [options]\n\n"
  exit
end

$show_tables,$dataBases,$tables,$explain = [],[],[],[]

def cleanup(var)
  return var.to_s.gsub(/\[|\]|\"/,"")
end

def connect(db,command,action,table)
  if $options[:database] 
    dbf = cleanup(ARGV[1])
  else  
    dbf = cleanup(db)
  end
  client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "easypeasy", :database => dbf)
  results = client.query(command)
  results.each do |db1|
    if action == "initial_query"
      $dataBases.push db1.values
    elsif action == "query_tables"
      $tables.push db1.values
    elsif action == "explain_tables" 
      db1.values.each do |explain|
        if explain =~ /#{ARGV[0]}/
          puts "FOUND \"#{ARGV[0]}\" in => DATABASES(#{dbf}), TABLE(#{table})"
          exit
        else
          puts "\"#{ARGV[0]}\" NOT FOUND in => DATABASES(#{dbf}), TABLE(#{table})" unless explain.nil?
        end
      end
    end
  end
end

connect("hpbx_development","show databases","initial_query",nil)

$dataBases.each do |dbs|
  connect(dbs,"show tables","query_tables",nil)
  $tables.each do |tables|
    $show_tables.push "#{dbs},#{tables}"
  end
end

$show_tables.each do |tables|
  begin
    hash_split = cleanup(tables).split(/,/)
    connect(hash_split[0], "select * from #{hash_split[1]}","explain_tables",hash_split[1])
  rescue
    next
  end
end

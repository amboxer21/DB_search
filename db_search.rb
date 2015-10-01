#!/usr/bin/ruby

require 'mysql2'

def cleanup(var)
  return var.to_s.gsub(/\[|\]|\"/,"")
end

$show_tables,$dataBases,$tables,$explain = [],[],[],[]

def connect(db,command,action)
  dbf = cleanup(db)
  client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "easypeasy", :database => dbf)
  results = client.query(command)
  results.each do |db1|
    if action == "initial_query"
      $dataBases.push db1.values
      client.close
    elsif action == "query_tables"
      $tables.push db1.values
      client.close
    elsif action == "explain_tables" 
      $explain.push db1.values[0]
      client.close
    elsif action == "traverse_db"
      client.close  
    end
  end
end

connect("hpbx_development","show databases","initial_query")

$dataBases.each do |dbs|
  connect(dbs,"show tables","query_tables")
  $tables.each do |tables|
    $show_tables.push "#{dbs},#{tables}"
  end
end

$show_tables.each do |tables|
  begin
    hash_split = cleanup(tables).split(/,/)
    connect(hash_split[0], "explain #{hash_split[1]}","explain_tables")
  rescue
    next
  end
end

$dataBases.each do |dbs|
  $tables.each do |tables|
    $explain.each do |finalOne|
        #puts "#{cleanup(dbs)},#{cleanup(tables)},#{cleanup(finalOne)}"
      begin
        puts connect(cleanup(dbs),"select * from #{cleanup(tables)} where #{cleanup(finalOne)} like \"%#{ARGV[0]}%\"","traverse_db") unless finalOne.empty?
        sleep 3
      rescue
        next
      end
        #puts "#{cleanup(dbs)}, select * from #{cleanup(tables)} where #{cleanup(finalOne)} like \"%#{ARGV[0]}%\"" unless finalOne.empty?
    end
  end  
end

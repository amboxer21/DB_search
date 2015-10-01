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
      #client.close  
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
        # DOes not run with this below disconnect. I assume its due to me closing the connection after every pass. So it reiterates over the arrays from the beginning.
        con = connect(cleanup(dbs),"select * from #{cleanup(tables)} where #{cleanup(finalOne)} like \"%#{ARGV[0]}%\"","traverse_db") unless finalOne.empty?
        if con 
          puts "found"
          #puts "#{cleanup(dbs)},#{cleanup(tables)},#{cleanup(finalOne)}"
          puts "#{cleanup(dbs)}, select * from #{cleanup(tables)} where #{cleanup(finalOne)} like \"%#{ARGV[0]}%\"" unless finalOne.empty?
          exit
        end
        sleep 1
        #puts "#{cleanup(dbs)}, select * from #{cleanup(tables)} where #{cleanup(finalOne)} like \"%#{ARGV[0]}%\"" unless finalOne.empty?
      rescue
        next
      end
        #puts "#{cleanup(dbs)}, select * from #{cleanup(tables)} where #{cleanup(finalOne)} like \"%#{ARGV[0]}%\"" unless finalOne.empty?
    end
  end  
end

#!/usr/bin/ruby

require 'mysql2'

def cleanup(var)
  return var.to_s.gsub(/\[|\]|\"/,"")
end

$show_tables,$dataBases,$tables,$explain = [],[],[],[]
def connect(db,command,flag)
  dbf = cleanup(db)
  client = Mysql2::Client.new(:host => "localhost", :username => "username", :password => "password", :database => dbf)
  results = client.query(command)
  results.each do |db1|
    if flag == 0
      $dataBases.push db1.values
    elsif flag == 1
      $tables.push db1.values
    elsif flag == 2
      $explain.push db1.values
    elsif flag == 3
      puts db1
    end
  client.close  
  end
end

connect("hpbx_development","show databases",0)

$dataBases.each do |dbs|
  connect(dbs,"show tables",1)
  $tables.each do |tables|
    $show_tables.push "#{dbs},#{tables}"
  end
end

$show_tables.each do |tables|
  begin
    hash_split = cleanup(tables).split(/,/)
    connect(hash_split[0], "explain #{hash_split[1]}",2)
  rescue
    next
  end
end

$dataBases.each do |dbs|
  $tables.each do |tables|
    $explain.each do |finalOne|
        #puts "#{cleanup(dbs)},#{cleanup(tables)},#{cleanup(finalOne)}"
        cleanup(finalOne).split(/,/).each do |e|
          puts e
        end
        sleep 3
        #connect(dbs,"select * from #{tables} where #{finalOne} like \"%#{ARGV[0]}%\"",3)
    end
  end  
end

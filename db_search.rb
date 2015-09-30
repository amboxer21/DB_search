#!/usr/bin/ruby

require 'mysql2'

$show_tables,$dataBases,$tables,$explain = [],[],[],[]
def connect(db,command,flag)
  dbf = db.to_s.gsub(/\[|\]|\"/,"")
  client = Mysql2::Client.new(:host => "localhost", :username => "username", :password => "password", :database => dbf)
  results = client.query(command)
  results.each do |db1|
    if flag == 0
      $dataBases.push db1.values
    elsif flag == 1
      $tables.push db1.values
    elsif flag == 2
      $explain.push "#{db1.values}"
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
    hash_split = tables.to_s.gsub(/\[|\]|\"|\\/,"").split(/,/)
    connect(hash_split[0], "explain #{hash_split[1]}",2)
  rescue
    next
  end
end

$dataBases.each do |dbs|
  $tables.each do |tables|
    $explain.each do |finalOne|
        #puts "#{dbs},#{tables},#{finalOne}"
        connect(dbs,"select * from #{tables} where #{finalOne} like \"%#{ARGV[0]}%\"",3)
    end
  end  
end

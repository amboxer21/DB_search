#!/usr/bin/ruby

require 'mysql2'

$show_tables,$dataBases,$tables = [],[],[]
def connect(db,command,flag)
  client = Mysql2::Client.new(:host => "localhost", :username => "user", :password => "password", :database => db.to_s.gsub(/\[|\]|\"/,""))
  results = client.query(command)
  results.each do |db1|
    if flag == 0
      $dataBases.push db1.values
      #puts databases = db.values
    elsif flag == 1
      $tables.push db1.values
    elsif flag == 3
      puts "#{db1.keys} #{db1.values}"
    end
  end
end

#connect("hpbx_development","show tables")
connect("hpbx_development","show databases",0)

$dataBases.each do |dbs|
  #puts dbs
  connect(dbs,"show tables",1)
  $tables.each do |tables|
    $show_tables.push "#{dbs},#{tables}"
  end
end

$show_tables.each do |tables|
  hash_split = tables.to_s.gsub(/\[|\]|\"|\\/,"").split(/,/)
  connect(hash_split[0], "explain #{hash_split[1]}",3)
end

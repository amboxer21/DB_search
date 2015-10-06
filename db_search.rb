#!/usr/bin/ruby

require 'mysql2'

$show_tables,$dataBases,$tables,$explain = [],[],[],[]

def cleanup(var)
  return var.to_s.gsub(/\[|\]|\"/,"")
end

def connect(db,command,action,table)
  dbf = cleanup(db)
  client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "easypeasy", :database => dbf)
  results = client.query(command)
  results.each do |db1|
    if action == "initial_query"
      $dataBases.push db1.values
    elsif action == "query_tables"
      $tables.push db1.values
    elsif action == "explain_tables" 
      #$explain.push db1.values
      #$explain.each do |explain|
      db1.values.each do |explain|
        #puts "#{explain}"
        #x = cleanup(explain)
        if explain =~ /#{ARGV[0]}/
          puts "FOUND \"#{ARGV[0]}\" in => DATABASES(#{dbf}), TABLE(#{table})"
          exit
        else
          puts "\"#{ARGV[0]}\" NOT FOUND in => DATABASES(#{dbf}), TABLE(#{table})" unless explain.nil?
        end
      end

      #sleep 1
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
    #sleep 1
  rescue
    next
  end
end

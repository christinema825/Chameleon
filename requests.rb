require 'uri'
require 'net/http'
require 'csv'
require 'time'
require 'algorithms'

uri = URI('https://chmln-east.s3.amazonaws.com/tmp/recruiting/fullstack/requests.csv')
res = Net::HTTP.get_response(uri)
csv = CSV.parse(res.body, headers: true)

puts "Raw CSV size: #{res.body.size / 1000 / 1000}MB"

##
# 1. what is the average response time?
# =>
total_time = 0
csv.each do |row|
  total_time += row['response time'].to_i
end

average_response_time = total_time / csv.size
puts "1. The average rersponse time:  #{average_response_time}ms"

##
# 2. how many users online?
# =>
users = []
csv.each do |row|
  users << row['user id']
end

unique_users = users.uniq.length
puts "2. The number of users online: #{unique_users}"

##
# 3. what are the ids of the 5 slowest requests?
# =>
sorted_by_response_time = csv.sort_by do |row|
  -row['response time'].to_i
end

slowest_5_requests = sorted_by_response_time.first(5)

slowest_request_ids = slowest_5_requests.map do |row|
  row['request id']
end

puts "3. The IDs of the 5 slowest requests: #{slowest_request_ids.join(', ')}"

##
# 4. who is overusing this system?
# =>
usage = Hash.new(0)

csv.each do |row|
  usage[row['user id']] += 1
end

over_usage_user = usage.max_by do |_, count|
  count
end

puts "4. User overusing the system: #{over_usage_user[0]} with #{over_usage_user[1]} requests"

##
# 5. analyze this data to find a key insight

request_methods = Hash.new(0)

csv.each do |row|
  request_methods[row['method']] += 1
end

most_requested_array = request_methods.max_by do |_method, count|
  count
end

most_requested_method = most_requested_array[0]
most_requested_count = most_requested_array[1]

puts "5. By observing the patterns in method usage, a key insight we could derive from the CSV data
is understanding the distribution of request methods used in the system.
The most common request method is #{most_requested_method} with #{most_requested_count} requests.
This insight provides significant information on how clients interact with the server and what types
of operations are most common or potentially problematic.
By analyzing this key insight, it provides guidelines on system performance and resource allocation,
which in turn helps to make decisions on how to improve our application."

##
# Bonus question: Imagine you received this CSV as a "stream" -- like tailing a log file
#  and had to maintain a list of the "current top 10 slowest requests" so that we could
#  read the current top 10 at any time during the stream.
#
# Said another way, it's like keeping running top 10 of the slowest requests
#
# 6. what are the slowest 10 requests directly after row number 75121 is processed?
#
#=>
class Request
  include Comparable
  attr_reader :request_id, :response_time

  def initialize(row)
    @request_id = row['request id']
    @response_time = row['response time'].to_i
  end

  def <=>(other)
    other.response_time <=> response_time
  end
end

slowest_requests = Containers::MaxHeap.new

csv.each_with_index do |row, index|
  next if index < 75_121

  request = Request.new(row)
  slowest_requests.push(request)

  slowest_requests.pop if slowest_requests.size > 10
end

puts '6. Top 10 Slowest Requests directly after row number 75121:'
top_slowest = []
top_slowest << slowest_requests.pop until slowest_requests.empty?
top_slowest.reverse.each_with_index do |request, index|
  puts "#{index + 1}. #{request.response_time}"
end

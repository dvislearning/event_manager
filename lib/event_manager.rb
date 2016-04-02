require "csv"
require "sunlight/congress"
require "erb"

def sort_by_frequency(times)
	frequencies = Hash.new(0)
	times.each { |time| frequencies[time] +=1 }
	frequencies = frequencies.sort_by { |time, occurance| occurance }.reverse
  highest = [frequencies[0]]
	frequencies.select do |time, occurance|
		if occurance == frequencies[0][1]
		  highest.push(time)
		end
	end
	highest[1..-1].join(", ")
end

template_letter = File.read("form_letter.erb")

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
	zipcode.to_s.rjust(5,"0")[0..4]
end

def is_good_number?(phone_number)
	clean_phone_number = phone_number.gsub(/[^\d]/, "")
	if clean_phone_number.length == 10 || clean_phone_number.length == 11
		if clean_phone_number.length == 10
	  elsif clean_phone_number[0] == 1.to_s
	  	clean_phone_number = clean_phone_number[1..-1]
	  else
	  	false
	  end
  true
	else
		false
	end
end

def time_finder(regdate)
	dates = DateTime.strptime(regdate, '%m/%d/%y %H:%M')
	time = dates.strftime('%l %p')
end

def day_finder(regdate)
	dates = DateTime.strptime(regdate, '%m/%d/%y %H:%M')
	dates.strftime('%A')
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
	Dir.mkdir('output') unless Dir.exists?('output')

	filename = "output/thanks #{id}.html"

	File.open(filename,"w") do |file|
		file.puts form_letter
	end
end

puts "EventManager Initialized!"

template_letter = File.read("form_letter.erb")
erb_template = ERB.new (template_letter)


contents = CSV.open("event_attendees.csv", headers: true, header_converters: :symbol)

times = []
days = []
contents.each do |row|
	name = row[:first_name]
	id = row[0]
	phone_number = row[:homephone]
	regdate = row[:regdate]
	
	zipcode = clean_zipcode(row[:zipcode])

	legislators = legislators_by_zipcode(zipcode)

	form_letter = erb_template.result(binding)

	save_thank_you_letters(id, form_letter)

	is_good_number?(phone_number)

	times << time_finder(regdate)

	days << day_finder(regdate)
end

puts "The following time(s) are when most sign-ups occur: #{sort_by_frequency(times)}"
puts "The following days(s) are when most sign-ups occur: #{sort_by_frequency(days)}"
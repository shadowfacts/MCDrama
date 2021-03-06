class MissingData < StandardError; end

def select_from_dict(dict, item)
	throw MissingData.new unless item
	hash = Hash[File.read("data/#{dict}").split("\n").map { |x| x.split ":" }]
	throw MissingData.new unless hash[item]
	hash[item]
end

def select_from_file(name, selections = {})
	File.read("data/#{name}").split("\n").sample
	.gsub(/\%([a-z]+)/) do
		type = $1
		value = select_from_file type, selections
		selections[type] = value unless selections[type]
		value
	end
end

def draminate
	begin
		selections = {}
		drama = select_from_file 'root', selections
		drama.gsub(/\$([a-z]+):([a-z]+)/) do
			source_type = $1
			attr = $2
			p source_type if source_type == 'mentioned'
			if attr == 'mentioned'
				throw MissingData.new unless selections[source_type]
				selections[source_type]
			else	
				select_from_dict(attr, selections[source_type])
			end
		end
	rescue StandardError => e
		puts "retrying for #{e}"
		retry
	end
end

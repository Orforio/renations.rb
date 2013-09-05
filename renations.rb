def rename_files(directory_source, directory_destination, directory_fileextension = "png")
	source = Dir.new(directory_source) if File.directory?(directory_source)
	destination = Dir.new(directory_destination) if File.directory?(directory_destination)
	destination_ids = Array.new

	unless source && destination
		puts "Could not find directories given"
		exit
	end

	puts "Source: #{directory_source}"
	puts "Destination: #{directory_destination}"

	destination_list = Dir.glob(directory_source + "*." + directory_fileextension)

	destination_list.each do |destination_filename|
		destination_ids.push(destination_filename[/\/(p?\d+)_/, 1])
		puts destination_filename[/\/(p?\d+)_/, 1]
	end

	puts destination_ids

	source.each do |source_filename|
		# Stuff
	end
end

# Hardcoded values for testing
# TODO: Ask user for input

directory_source = "d:/Temporary/Rename/naiseanta5_stills/"
directory_destination = "d:/Temporary/Rename/photographs_cropped/"
directory_fileextension = "jpg"

rename_files(directory_source, directory_destination, directory_fileextension)
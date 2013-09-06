def rename_files(directory_source, directory_destination, directory_fileextension = "png")
	source = Dir.new(directory_source) if File.directory?(directory_source)
	destination = Dir.new(directory_destination) if File.directory?(directory_destination)
	destination_ids = Array.new
	files_changed, files_skipped = 0, 0

	unless source && destination
		puts "Could not find directories given"
		exit
	end

	puts "Source: #{directory_source}"
	puts "Destination: #{directory_destination}"

	source_list = Dir.glob(directory_source + "*." + directory_fileextension)
	destination_list = Dir.glob(directory_destination + "*." + directory_fileextension)

	destination_list.each do |destination_filename|
		destination_ids.push(destination_filename[/\/(p?\d+)_/, 1])
	end

	source_list.each do |source_filename|
		if destination_index = destination_ids.index(source_filename[/\/(p?\d+)_/, 1])
			#puts "#{destination_list[destination_index]} => #{directory_destination + File.basename(source_filename)}"
			File.rename(destination_list[destination_index], directory_destination + File.basename(source_filename))
			files_changed += 1
		else
			puts "Skipping #{source_filename}..."
			files_skipped += 1
		end
	end

	puts "Renaming finished."
	puts "Renamed: #{files_changed}, Skipped: #{files_skipped}"
end

# Hardcoded values for testing
# TODO: Ask user for input

directory_source = "D:/Richard/Developer/renations.rb/naiseanta5_stills/"
directory_destination = "D:/Richard/Developer/renations.rb/photographs_cropped/"
directory_fileextension = "jpg"

rename_files(directory_source, directory_destination, directory_fileextension)
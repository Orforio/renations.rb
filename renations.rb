def check_arguments
	directory_source = ARGV[0]
	directory_destination = ARGV[1]
	directory_fileextension = ARGV[2] ||= "png"

	unless directory_source && directory_destination
		puts "Usage: $> ruby renations.rb source_folder destination_folder file_extension"
		puts "Example: $> ruby renations.rb images/welsh/ images/english/ jpg"
		exit
	end

	puts "Source directory: #{directory_source}"
	puts "Destination directory: #{directory_destination}"
	puts "File extension: #{directory_fileextension}"
	puts "Is this correct? Type y to continue."

	rename_files(directory_source, directory_destination, directory_fileextension) if STDIN.gets.chomp == "y"
end

def rename_files(directory_source, directory_destination, directory_fileextension)
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

check_arguments
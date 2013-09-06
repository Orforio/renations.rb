def check_arguments
	directory_source = ARGV[0]
	directory_destination = ARGV[1]
	directory_fileextension = ARGV[2] ||= "png"

	unless directory_source && directory_destination
		puts "Usage: $> ruby renations.rb source_folder destination_folder file_extension"
		puts "Example: $> ruby renations.rb images/welsh/ images/english/ jpg"
		exit
	end

	directory_source += "/" unless directory_source[/\/\z/]
	directory_destination += "/" unless directory_destination[/\/\z/]

	unless File.directory?(directory_source)
		puts "Source directory not found."
		exit
	end

	unless File.directory?(directory_destination)
		puts "Destination directory not found."
		exit
	end

	puts "Source directory: #{directory_source}"
	puts "Destination directory: #{directory_destination}"
	puts "File extension: #{directory_fileextension}"
	puts "Is this correct? Type y to continue."

	rename_files(directory_source, directory_destination, directory_fileextension) if STDIN.gets.chomp == "y"
end

def rename_files(directory_source, directory_destination, directory_fileextension)
	destination_ids = Array.new
	files_changed, files_skipped = 0, 0

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
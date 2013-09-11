# TODO: turn stuff into classes and DRYer

def check_arguments
	directory_source = ARGV[0]
	directory_destination = ARGV[1]
	directory_fileextension = ARGV[2] ||= "png"
	spreadsheet_sheet = ARGV[3] ||= 1
	use_spreadsheet = false

	unless directory_source && directory_destination
		puts "Usage: $> ruby renations.rb source_folder destination_folder file_extension"
		puts "Example: $> ruby renations.rb images/welsh/ images/english/ jpg"
		exit
	end

	if directory_source[/\.xlsx\z/]
		if File.exists?(directory_source)
			use_spreadsheet = true
		else
			puts "Source spreadsheet does not exist"
			exit
		end
	else
		directory_source += "/" unless directory_source[/\/\z/]
		unless File.directory?(directory_source)
			puts "Source not found."
			exit
		end
	end
	
	directory_destination += "/" unless directory_destination[/\/\z/]

	unless File.directory?(directory_destination)
		puts "Destination not found."
		exit
	end

	puts use_spreadsheet ? "Source migration log: #{directory_source}" : "Source directory: #{directory_source}"
	puts "Destination directory: #{directory_destination}"
	puts "File extension: #{directory_fileextension}"
	puts "Is this correct? Type y to continue."

	STDIN.gets.chomp == "y" ? use_spreadsheet ? rename_spreadsheet(directory_source, directory_destination, directory_fileextension, spreadsheet_sheet) : rename_files(directory_source, directory_destination, directory_fileextension) : exit
end

def rename_spreadsheet(spreadsheet_source, directory_destination, directory_fileextension, spreadsheet_sheet = 1)
	require 'spreadsheet'

	source_list, destination_ids = Array.new, Array.new
	
	puts "Spreadsheet time!"

	spreadsheet = Spreadsheet.open(spreadsheet_source)
	sheet = spreadsheet.worksheet(1) # Currently hardcoded for testing purposes

	sheet.each 11 do |row| # Currently hardcoded, 12 refers to data starting at row 12
		source_list.push(row[9]) # Currently hardcoded, complete filenames are stored in column J/9
	end

	destination_list = Dir.glob(directory_destination + "*." + directory_fileextension)

	destination_list.each do |destination_filename|
		destination_ids.push(destination_filename[/\/(p?\d+)_/, 1])
	end

	puts source_list
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
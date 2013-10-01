IMAGE_SIZES = [624, 464, 304]
REGEX_SPREADSHEET_FILEEXT = /\.xlsx\z/
REGEX_SPREADSHEET_JOBNO = /\A(p?\d{3}|s\d{3}[a-z])/ # Extract the job number only for regular graphics, photos or slideshows
REGEX_FILENAME_JOBNO = /\/(p?\d{3}|s\d{3}[a-z])_/
REGEX_ILLEGAL_FILENAME = /\W+|[A-Z]+/

def check_arguments
	directory_source = ARGV[0]
	directory_destination = ARGV[1]
	directory_fileext = ARGV[2] ||= "png"
	spread_sheet = ARGV[3] ||= 0
	use_spreadsheet = false

	unless directory_source && directory_destination
		puts "Usage: $ ruby renations.rb source_folder|migration_log.xlsx destination_folder (file_extension) (graphics|photos)"
		puts "Directory Example: $ ruby renations.rb images/welsh/ images/english/ jpg"
		puts "Spreadsheet Example: $ ruby renations.rb images/welsh/migration_log.xlsx images/english/ jpg photos"
		exit
	end

	if directory_source[REGEX_SPREADSHEET_FILEEXT]
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

	directory_fileextension = directory_fileext.delete(".").downcase
	
	directory_destination += "/" unless directory_destination[/\/\z/]

	spread_sheet == "photos" ? spreadsheet_sheet = 1 : spreadsheet_sheet = 0

	unless File.directory?(directory_destination)
		puts "Destination not found."
		exit
	end

	puts use_spreadsheet ? "Source migration log: #{directory_source}" : "Source directory: #{directory_source}"
	puts "Destination directory: #{directory_destination}"
	puts "File extension: #{directory_fileextension}"
	puts "Sheet: #{spreadsheet_sheet}" if use_spreadsheet
	puts "Is this correct? Type y to continue."

	if STDIN.gets.chomp == "y"
		use_spreadsheet ? rename_spreadsheet(directory_source, directory_destination, directory_fileextension, spreadsheet_sheet) : rename_files(directory_source, directory_destination, directory_fileextension)
	else
		exit
	end
end

def rename_spreadsheet(spreadsheet_source, directory_destination, directory_fileextension, spreadsheet_sheet)
	require 'roo'

	single_size_operation = false || (spreadsheet_sheet == 1 || directory_fileextension == "ai")

	source_list, destination_ids = Array.new, Array.new
	files_changed, files_skipped = 0, 0
	
	puts "Please wait..."

	sheet = Roo::Excelx.new(spreadsheet_source)
	sheet.sheet(spreadsheet_sheet)

	if single_size_operation
		sheet.each(:job => 'Job No.', :filename => '^New\sfilename\s') { |hash| source_list << hash if hash[:job] && hash[:job][REGEX_SPREADSHEET_JOBNO, 1] }
	else
		sheet.each(:job => 'Job No.', :filename => '^New\sfilename\s', :wlarge => '^large\swidth', :wmedium => '^medium\swidth', :wsmall => '^small\swidth') do |hash|
			if hash[:job] && hash[:job][REGEX_SPREADSHEET_JOBNO, 1]
				if hash[:wlarge] && hash[:wmedium] && hash[:wsmall]
					puts "WARNING: #{hash[:job]} has an invalid LARGE width." unless hash[:wlarge] == IMAGE_SIZES[0] || hash[:wlarge] == IMAGE_SIZES[2]
					puts "WARNING: #{hash[:job]} has an invalid MEDIUM width." unless hash[:wmedium] == IMAGE_SIZES[1] || hash[:wmedium] == IMAGE_SIZES[2]
					puts "WARNING: #{hash[:job]} has an invalid SMALL width." unless hash[:wsmall] == IMAGE_SIZES[2]
					hash[:wlarge], hash[:wmedium], hash[:wsmall] = hash[:wlarge].to_i, hash[:wmedium].to_i, hash[:wsmall].to_i
					source_list << hash
				else
					puts "WARNING: #{hash[:job]} has one or more missing widths, skipping."
					files_skipped += 1
				end
			end
		end
	end

	destination_list = Dir.glob(directory_destination + "*." + directory_fileextension)

	destination_ids = destination_list.collect do |destination_filename|
		if single_size_operation
			destination_filename[REGEX_FILENAME_JOBNO, 1]
		else
			{:job => destination_filename[REGEX_FILENAME_JOBNO, 1], :size => destination_filename[/_([0-9]{3})\.#{directory_fileextension}$/, 1].to_i}
		end
	end

	source_list.each do |source_hash|
		if source_hash[:filename][REGEX_ILLEGAL_FILENAME]
			puts "WARNING: #{source_hash[:filename]} contains illegal characters, skipping."
			files_skipped += 1
		elsif single_size_operation
			if destination_index = destination_ids.index(source_hash[:job])
				#puts "Renaming #{destination_list[destination_index]} to #{directory_destination + source_hash[:filename].to_s + "." + directory_fileextension}"
				File.rename(destination_list[destination_index], "#{directory_destination}#{source_hash[:filename]}.#{directory_fileextension}")
				files_changed += 1
			else
				puts "Skipping #{source_hash[:filename]}"
				files_skipped += 1
			end
		else
			image_widths = [source_hash[:wlarge], source_hash[:wmedium], source_hash[:wsmall]].uniq

			image_widths.each do |image_width|
				if destination_index = destination_ids.index { |destination_hash| (destination_hash[:job] == source_hash[:job]) && (destination_hash[:size] == image_width) }
					#puts "Renaming #{destination_list[destination_index]} to #{directory_destination + source_hash[:filename].to_s + "_" + image_width.to_s + "." + directory_fileextension}"
					File.rename(destination_list[destination_index], "#{directory_destination}#{source_hash[:filename]}_#{image_width}.#{directory_fileextension}")
					files_changed += 1
				else
					puts "Skipping #{source_hash[:filename]}_#{image_width}"
					files_skipped += 1
				end
			end
		end
	end

	puts "Renaming finished."
	puts "Renamed: #{files_changed}, Skipped: #{files_skipped}"
end

def rename_files(directory_source, directory_destination, directory_fileextension)
	destination_ids = Array.new
	files_changed, files_skipped = 0, 0

	puts "Source: #{directory_source}"
	puts "Destination: #{directory_destination}"

	source_list = Dir.glob(directory_source + "*." + directory_fileextension)
	destination_list = Dir.glob(directory_destination + "*." + directory_fileextension)

	destination_ids = destination_list.collect { |destination_filename| destination_filename[REGEX_FILENAME_JOBNO, 1] }

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
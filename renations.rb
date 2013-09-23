# TODO: turn stuff into classes and DRYer
IMAGE_SIZES = [624, 464, 304]

def check_arguments
	directory_source = ARGV[0]
	directory_destination = ARGV[1]
	directory_fileext = ARGV[2] ||= "png"
	spreadsheet_sheet = ARGV[3] ||= 1
	use_spreadsheet = false

	directory_fileextension = directory_fileext.delete(".")

	unless directory_source && directory_destination
		puts "Usage: $ ruby renations.rb source_folder|migration_log.xlsx destination_folder file_extension"
		puts "Example: $ ruby renations.rb images/welsh/ images/english/ jpg"
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
	require 'roo'

	source_list, destination_ids = Array.new, Array.new
	files_changed, files_skipped = 0, 0
	
	puts "Please wait..."

	sheet = Roo::Excelx.new(spreadsheet_source)
	sheet.sheet(0) # Currently hardcoded for testing purposes

	sheet.each(:job => 'Job No.', :filename => '^New\sfilename\s', :wlarge => '^large\swidth', :wmedium => '^medium\swidth', :wsmall => '^small\swidth') do |hash|
		if hash[:job] && hash[:job][/^(p?\d+)/, 1]
			if hash[:wlarge] && hash[:wmedium] && hash[:wsmall]
				puts "WARNING: #{hash[:job]} has an invalid LARGE width." unless hash[:wlarge] == IMAGE_SIZES[0] || hash[:wlarge] == IMAGE_SIZES[2]
				puts "WARNING: #{hash[:job]} has an invalid MEDIUM width." unless hash[:wmedium] == IMAGE_SIZES[1] || hash[:wmedium] == IMAGE_SIZES[2]
				puts "WARNING: #{hash[:job]} has an invalid SMALL width." unless hash[:wsmall] == IMAGE_SIZES[2]
				hash[:wlarge], hash[:wmedium], hash[:wsmall] = hash[:wlarge].to_i, hash[:wmedium].to_i, hash[:wsmall].to_i
			end
			source_list << hash
		end
	end

	destination_list = Dir.glob(directory_destination + "*." + directory_fileextension)

	destination_list.each do |destination_filename|
		destination_ids << [:job => destination_filename[/\/(p?\d+)_/, 1], :size => destination_filename[/_([0-9]{3})\.#{directory_fileextension}$/, 1].to_i]
	end

	source_list.each do |source_hash|
		image_widths = [source_hash[:wlarge], source_hash[:wmedium], source_hash[:wsmall]].uniq

		image_widths.each do |image_width|
			if destination_index = destination_ids.index do |destination_hash, x|
					(destination_hash[:job] == source_hash[:job]) && (destination_hash[:size] == image_width)
				end
				#puts "Renaming #{destination_list[destination_index]} to #{directory_destination + source_hash[:filename].to_s + "_" + image_width.to_s + "." + directory_fileextension}"
				File.rename(destination_list[destination_index], directory_destination + source_hash[:filename].to_s + "_" + image_width.to_s + "." + directory_fileextension)
				files_changed += 1
			else
				puts "Skipping #{source_hash[:filename]}_#{image_width}"
				files_skipped += 1
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
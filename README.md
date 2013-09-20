# renations.rb

A batch rename tool for the K&amp;L Infographics Nations teams.
It takes the filenames from the source directory and applies them to the files in the destination directory.
Only files with matching job numbers will be modified.

## Installation

On Windows: go to http://rubyinstaller.org/ and follow the instructions. You should enable the option to add ruby to your PATH. Reboot your machine.

On Mac: you already have ruby! Go you.

On both: copy renations.rb into a directory, then copy the two directories you want to rename from and to into the same directory. Note this isn't necessary, as you can run the script from anywhere and supply the right directories when your run it, but it'll save you typing.

In order to use the migration log functionality, you must also install the "roo" Ruby gem by running this command. You only need to do it once.

    gem install -p http://www-cache.reith.bbc.co.uk:80 roo

## Usage

You can use this in two ways. The first is by supplying two directories containing images.

From the command prompt, run:

    ruby renations.rb source_folder destination_folder file_extension
replacing "source_folder", "destination_folder" and "file_extention" to the relevant details. If no file_extension is supplied, it will default to png.

The second way is to supply a migration log and the directory containing the images to be renamed.

    ruby renations.rb migration_log.xlsx destination_folder file_extension
    
The script will currently only accept spreadsheets with an .xlsx extension.

## Known Issues

- Slideshows (s001a, s001b, etc) are not supported and will be skipped.
- Multiple filenames with the same job number will cause the script to error out (ie, 001_image_304.jpg, 001_image_464.jpg, etc).
- The quality of the code is atrocious and needs some serious refactoring.

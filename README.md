# renations.rb

A batch rename tool for the K&amp;L Infographics Nations teams.
It takes the filenames from the source directory and applies them to the files in the destination directory.
Only files with matching job numbers will be modified.

## Installation

On Windows: go to http://rubyinstaller.org/ and follow the instructions. You should enable the option to add ruby to your PATH. Reboot your machine.

On Mac: you already have ruby! Go you.

On both: copy renations.rb into a directory, then copy the two directories you want to rename from and to into the same directory. Note this isn't necessary, as you can run the script from anywhere and supply the right directories when your run it, but it'll save you typing.

## Usage
At the moment you can only use this with two directories, migration log support is coming.

From the command prompt, run:
    ruby renations.rb source_folder destination_folder file_extension
replacing "source_folder", "destination_folder" and "file_extention" to the relevant details. If no file_extension is supplied, it will default to png.

## TODO: Migration log spreadsheet support

Run the following to install the necessary dependencies:
    gem install -p http://www-cache.reith.bbc.co.uk:80 spreadsheet

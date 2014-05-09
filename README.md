# renations.rb

A batch rename tool for the K&amp;L Bitesize Nations teams.
It takes the filenames from the source directory and applies them to the files in the destination directory.
Only files with matching job numbers will be modified.

## Installation

On Windows: go to http://rubyinstaller.org/ and follow the instructions. You should enable the option to add ruby to your PATH. Reboot your machine.

On Mac: you already have ruby! Go you.

On both: copy renations.rb into a directory, then copy the two directories you want to rename from and to into the same directory. Note this isn't necessary, as you can run the script from anywhere and supply the right directories when your run it, but it'll save you typing.

In order to use the migration log functionality, you must also install the "roo" Ruby gem by running this command. You only need to do it once.

    gem install -p http://www-cache.reith.bbc.co.uk:80 roo
    
As an alternative, if you have Bundler you can just run

    bundle install

## Usage

You can use this in two ways. The first is by supplying two directories containing images.

From the command prompt, run:

    ruby renations.rb source_folder destination_folder file_extension
replacing "source_folder", "destination_folder" and "file_extention" to the relevant details. If no file_extension is supplied, it will default to png.

The second way is to supply a migration log and the directory containing the images to be renamed.

    ruby renations.rb migration_log.xlsx destination_folder file_extension graphics|photos
where graphics or photos refers to the sheet you want to use. As above, if file_extension and/or graphics/photos are not supplied, they will default to png and graphics. If you want to use photos, you must specify the file extension too (which is usually jpg).
    
The script will currently only accept spreadsheets with an .xlsx extension.

## Known Issues

- Slideshow .ai files only work if they are in separate files for each slide (s001a, s001b, etc). Single-version .ai files (s001 containing a, b and c artboards) will be skipped and must be done manually.
- Duplicates (_d001) are not supported and will be skipped.
- The quality of the code is atrocious and needs some serious refactoring.

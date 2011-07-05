frakup
======

frakup is a file-related, incremental, database-dependent backup tool, for when it all goes wrong. :)

frakup is a *very* immature project, and, as such, is only suitable for testing and development. Indeed, it doesn't even support the restoration of files, yet! It also has no tests whatsoever ([RSpec](http://relishapp.com/rspec) tests yet to be added!). And it only works locally. You have been warned.

frakup stores three main things in the target directory:

*   `frakup.sqlite3`: This is a [SQLite](http://www.sqlite.org/) database which contains all information about the backup, including: paths; timestamps; modes; owners; and groups.
*   `fileobjects/`: This contains all the files themselves.
*   `frakup.log`: This is a comprehensive log. Currently, there is no way to turn this off or set logging levels. As a result, expect this to get fairly large.

frakup has three main concepts:

*   Backupset: One of these is created every time a backup is run.
*   Fileobject: Each one of these correlates to a file. Normally, there will be no duplicates.
*   Backupelement: One of these is created for every file and folder, each time the backup is run. It is linked to a Backupset, a Fileobject, and stores the metadata. The concept of a file path only exists here.

frakup has some interesting features:

*   Files are identified by size in bytes and a SHA512 hash. Using this has a number of advantages: renames, moves, and copies are automatically 'detected' - in fact, frakup doesn't care; corruption of files on the target can easily be detected (by using `verify`). It also has some disadvantages: it is theoretically possible for the hashes to collide, which would damage the integrity of the backup - this is very unlikely, though, and methods to help detect this can easily be added; it is necessary to compute the hash for every file each time a backup is run, and this can be slow for large files.
*   frakup is designed for backing up files that don't change often - archives, photos, music, and videos are good examples of this. If a file changes, it will get backed up again in its entirety. Thus, the concept of incremental backups only exists on a backup-level, and diffs are unheard-of. It does mean, however, that there is no cost to moving large files around - this was one of the guiding principles in its design.
*   Backups made with frakup are designed to be manually-recoverable. That means, it should not be impossibly-hard for a competent person to restore a backup, even without frakup.

Getting Started
---------------

1.  Install dependencies using [RubyGems](http://rubygems.org/) and the `Gemfile` included. If you are using [RVM](https://rvm.beginrescueend.com/), then the `.rvmrc` will automatically create a gemset (called frakup), `gem install bundler`, and `bundle install`.

2. In the root folder of the repository, run the tool from the command-line with something like:

        ./bin/frakup backup "/home/user/" "/mnt/backup/user/"

Run `./bin/frakup --help` to see a list of parameters.

It is possible to verify backed-up files by running the verify feature:

        ./bin/frakup verify "/mnt/backup/user/"

This will output the results to the log, as well as setting a flag for each Fileobject in the database. If the file is corrupted, a new file will be transferred the next time a backup is run. This effectively marks that file as requiring a full backup, rather than the usual incremental one.

Contributing
------------

Contributions are encouraged! Please fork the repository and write your code, write tests to cover the new functionality, then send a pull request. Have a look in [Issues](https://github.com/tiredpixel/frakup/issues) for ideas about what to write. :)

Credits
-------

frakup was written by [tiredpixel](https://github.com/tiredpixel/).

License
-------

frakup is © 2011 tiredpixel. It is free software, released under the MIT License, and may be redistributed under the terms specified in `LICENSE`.

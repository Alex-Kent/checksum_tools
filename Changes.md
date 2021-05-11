v1.1.1 2021-05-10 Refactored ProcessDir, minor tweaks and bug fixes

 - Refactored ProcessDir by moving logical sections into subroutines.
 - Changed directory leave callback to get the name of the object that ProcessDir was called with, not the directory path was the case previously.
 - Renamed $CURRENT_VERSION to $CURRENT_CHECKSUM_FILE_VERSION.

v1.1.0 2021-05-10 Additional output formats, minor changes, additions, and bug fixes.

 - Added `show-all-checksums` output mode.
 - Added `terse` output mode.
 - Fixed minor typo in top-level `%user` initialization.
 - Consolidated common output callback code.
 - Cleaned up `md5` string names in `find_dupes` : `user-finalize-loop`.
 - Added `REFERENCE_TO` function to get a reference to name named command function.
 - Fixed option naming for move-dupes (was move-to in some places).
 - Fixed incorrect option name comments.
 - Added fullpath to get_metadata output.
 - Fixed bug in ProcessDir that incorrectly used old checksums in certain circumstances.
 - Checksums for symlinks are no longer displayed or stored in .md5sums files.

v1.0.0 2021-04-27 First public release

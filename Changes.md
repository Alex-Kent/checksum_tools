v1.2.0 2025-07-12 Added user defaults file support

- Added ability to specify per-user default settings user defaults to be specified (via ~/.checksum_tool).
- Updated documentation.

v1.1.11 2025-07-12 Don't compute checksums for symlinks or anything that isn't a file.

v1.1.10 2025-07-12 Cleaned up vestigial code. (no changes to logic)

v1.1.9 2025-07-12 Clarified documentation and fixed typos, etc. therein. (no changes to logic)

v1.1.8 2025-07-12 Removed diked out debugging statements. (no changes to logic)

v1.1.7 2025-07-12 Restored correct behaviour for link_dupes and symlink_dupes

 - Fixed bug introduced by code refactoring that had caused link_dupes and symlink_dupes to behave incorrectly.

v1.1.6 2021-07-08 Updated man pages

 - Updated man pages to document the --only-write-xa and --ignore-no_md5sums options.  No code changes.

v1.1.5 2021-07-08 Added ignore-no_md5sums option

 - Added --ignore-no_md5sums option that forces processing of directories even when a .no_md5sums file is present.

v1.1.4 2021-07-08 Added only-write-xa option

 - Added --only-write-xa option that supresses writes to .md5sums files.

v1.1.3 2021-05-11 Added quiet and silent options, minor improvements

 - Added --quiet (-q) option that supresses progress messages.
 - Added --silent (-Q) option that supresses all post-initialization STDERR output.
 - Improved the string output when objects are entered (at head of ProcessDir).
 - Command options can now utilize an initialize callback. (not currently used)
 - find_dupes and find_orphans now accept a single file as their last object.  This can, e.g., be used to test for the presence a file in a set of files.
 - All strings are now localized.

v1.1.2 2021-05-11 Improved find_dupes, find_orphans, extended attribute and .md5sums writing

 - Removed symlinks, etc. from find_dupes : user-finalize-loop results.
 - Removed symlinks, etc. from find_orphans : user-finalize-loop results.
 - Improved heuristic used to determine if checksums are written to .md5sums.
 - Extended attributes can now be written to write-protected files (permissions are temporarily made writable).

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

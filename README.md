# Checksum tools

checksum_tools &copy; 2021 Alexander Hajnal

---


Checksum tools is a collection of scripts that can:

* Verify the integrity of files.
* Find and/or remove duplicate files.
* Find files that differ between two directories (or that only exist in one).
* Move files across devices while ensuring their integrity.

A sister project (`jpeg_checksum_tools`) has similar functionality but is specifically tailored to EXIF-tagged JPEG files.

For usage example see **Examples**, below.  For software requirements see **Requisites and additional files**, below.  For information on how the program is structured, see `Internals.md`. For information of localizing the program, see `Localization.md`.

These scripts work best when the files they operate on are on filesystems with user-specified extended attribute (`user_xattr`) support.  Currently Linux and Mac OS X are fully supported.  In addition, FreeBSD 5.0+, NetBSD 3.0+, and Solaris are supported but untested.

These commands are very powerful but some (e.g. `cull_dupes`) can potentially cause a lot of damage.  Always double-check that a command makes sense (using, e.g., the `--no-act` option) before running a potentially damaging command.  While the author has used these scripts without issue, you, by using this software, accept all responsibility for any damage or losses that may occur.


## Commands

The full set of commands is:

    clear_checksums
    cull_dupes 
    find_dupes
    find_orphans
    get_metadata
    link_dupes
    prune_dirs
    restore_to_xa_location
    symlink_dupes
    update_checksums
    verify_checksums

Use the `--help` option to view usage information for a specific command.  Use the `--help-core` for a list of core options (available in all commands).  Run `checksum_tool --help-all` for detailed usage information for all commands.

Commands display their progress through the filesystem on `STDERR`; to suppress this use the `--quiet` option (`-q`).  To suppress all post-initialization output on `STDERR` use the `--silent` (`-Q`) option.  To suppress all `STDERR` output (even during initialization) use:

> `COMMAND OPTIONS 2>/dev/null`

---

### clear_checksums

`clear_checksums ( FILE | DIRECTORY ) [ ... ] [ OPTIONS ]`

In the case of files, removes checksum metadata from the files' user-defined extended attributes (namely `user._`, `user.md5`, `user.md5_size`, and `user.md5_time`) as well as from their directory's `.md5sums` file.

In the case of directories, each directory's `.md5sums` file is removed and the extended attributes listed above are removed from each file in the directory.

Options:

    -r | --recurse          Recurse into subdirectories (default)
    -R | --no-recurse       Do not recurse into subdirectories
    -x | --one-filesystem   Don't cross filesystem boundaries while recursing


---

### cull_dupes

`cull_dupes OBJECTS KEEP_DIRECTORY [ OPTIONS ]`  
`cull_dupes OBJECTS KEEP_FILE [ OPTIONS ]`  
`cull_dupes DIRECTORY [ OPTIONS ]`

`OBJECTS` := `( FILE | DIRECTORY ) [ ... ]`

This command can run in three modes:

 - Delete any files in `OBJECTS` that exist in `KEEP_DIRECTORY`.
 - Delete any files in `OBJECTS` that are the same as `KEEP_FILE`.
 - When called with a single directory then delete any duplicate files in the directory (one copy is kept).

Checksums will be computed and stored for all files that are missing them.

This operates the same as `find_dupes` except that all files determined to be duplicates are deleted.

**Options:**

    -A | --no-act              Do not delete or move any files (.md5sums and
                               extended attribute metadata may be updated)
    -b | --built-in-copy       Use a built-in function to copy files (instead of
                               using e.g. "cp -ap"); this is also used when copying
                               files or moving files across devices.
                               (not currently implemented)
    -d | --discard-existing    Discard existing checksums and recompute them
    -m DIR | --move-dupes DIR  Move duplicate files into the directory DIR
    -n | --same-name           For a file to match it must have same filename (case-
                               insensitive) as well as the same fingerprint.
                               At some point a --case-insensitive option may be
                               added; if this is done, the --same-name option will
                               be case-sensitive unless case-insensitivity is
                               explicitly requested.
    -O | --overwrite           Allow overwriting of existing files
    -P | --preserve            Never overwrite existing files
                               Attempting to overwrite an exising file will display
                               a warning to STDERR then continue.
    -r | --recurse             Recurse into subdirectories (default)
    -R | --no-recurse          Do not recurse into subdirectories
    -x | --one-filesystem      Don't cross filesystem boundaries while recursing
    --show-all-checksums       Show checksum on all lines, not just the first
    --terse=MODE               Use terse output; MODE controls what is shown:
                               dupe -> only duplicate file paths
                               keep -> only kept file paths
                               both -> both types, prefixed with DUPE: or keep:

---

### find_dupes
`find_dupes OBJECTS REFERENCE_DIRECTORY [ OPTIONS ]`  
`find_dupes OBJECTS REFERENCE_FILE [ OPTIONS ]`  
`find_dupes DIRECTORY [ OPTIONS ]`

`OBJECTS` := `( FILE | DIRECTORY ) [ ... ]`

This command can run in three modes:

 - Display any files in `OBJECTS` that exist in `REFERENCE_DIRECTORY`.
 - Display any files in `OBJECTS` that are the same as `REFERENCE_FILE`.
 - When  called with a single directory then any duplicate files found in it are displayed.

Checksums will be computed and stored for all files that are missing them.

This operates the same as `cull_dupes`  except that all files determined to be duplicates are just listed (not deleted).

**Options:**

    -d | --discard-existing    Discard existing checksums and recompute them
    -n | --same-name           For a file to match it must have same filename (case-
                               insensitive) as well as the same fingerprint.
                               At some point a --case-insensitive option may be
                               added; if this is done, the --same-name option will
                               be case-sensitive unless case-insensitivity is
                               explicitly requested.
    -N | --long-names          Also show full path when displaying duplicates or
                               orphans
    -r | --recurse             Recurse into subdirectories (default)
    -R | --no-recurse          Do not recurse into subdirectories
    -x | --one-filesystem      Don't cross filesystem boundaries while recursing
    --escape-filenames=MODE    Escape special characters in file and directory names
                               MODE can be octal, hex, HEX, shell, uri, or URI.
    
                               In shell mode strings with special characters will
                               have them octal encoded and wrapped so as to be
                               suitable for direct shell usage (i.e. ESCAPED
                               becomes $'ESCAPED').
    
                               In both URI modes strings with special characters
                               will have them hex encoded in a format suitable for
                               usage in a URI (i.e. as %XX where X is a hex digit).
    
                               Lowercase hex digits are output in hex and uri modes.
                               Uppercase hex digits are output in HEX and URI modes.
    --show-all-checksums       Show checksum on all lines, not just the first
    --terse=MODE               Use terse output; MODE controls what is shown:
                               dupe -> only duplicate file paths
                               keep -> only kept file paths
                               both -> both types, prefixed with DUPE: or keep:

Output is multiple lines for each matched fingerprint (`MD5:size` or `MD5:size:lowercase_name` in same-name mode).  The first line for each set of duplicates has the fingerprint followed by spaces with additional lines being prefixed with spaces.  When called with a single directory, all files but the last are marked as `DUPE` except the last which is marked `keep`; when a `REFERENCE_DIRECTORY` is given then multiple `keep` lines may be shown.  Files marked `DUPE` are those that would be deleted, moved, or replaced with links when the cull, move, or link modes are used.  The remainder of each line is a tab, the filename, a tab, and the file's directory.  If the `--long-names` option is given then each line ends with two tabs followed by the full path of the file.

Sample output (without `--long-names`):

    02c538f8e34d252ae22df357fcf75ea3:123              DUPE  filename_1      directory_1
                                                      keep  filename_2      directory_2
    8b93959cee28415ffafd56da99c1a268:98765            DUPE  filename_3      directory_1
                                                      DUPE  filename_4      directory_1
                                                      keep  filename_5      directory_2
                                                      keep  filename_6      directory_2

Sample output (with `--long-names`):

    02c538f8e34d252ae22df357fcf75ea3:123              DUPE  filename_1      directory_1       directory_1/filename_1
                                                      keep  filename_2      directory_2       directory_2/filename_2
    8b93959cee28415ffafd56da99c1a268:98765            DUPE  filename_3      directory_1       directory_1/filename_3
                                                      DUPE  filename_4      directory_1       directory_1/filename_4
                                                      keep  filename_5      directory_2       directory_2/filename_5
                                                      keep  filename_6      directory_2       directory_2/filename_6


---

### find_orphans
`find_orphans DIRECTORY_1 DIRECTORY_2 [ OPTIONS ]`

Show all files that exist only in one of the two directories (not both).

Checksums will be computed and stored for all files that are missing them.

**Options:**

    -d | --discard-existing    Discard existing checksums and recompute them
    -n | --same-name           For a file to match it must have same filename (case-
                               insensitive) as well as the same fingerprint.
                               At some point a --case-insensitive option may be
                               added; if this is done, the --same-name option will
                               be case-sensitive unless case-insensitivity is
                               explicitly requested.
    -N | --long-names          Also show full path when displaying duplicates or
                               orphans
    -r | --recurse             Recurse into subdirectories (default)
    -R | --no-recurse          Do not recurse into subdirectories
    -x | --one-filesystem      Don't cross filesystem boundaries while recursing
    --escape-filenames=MODE    Escape special characters in file and directory names
                               MODE can be octal, hex, HEX, shell, uri, or URI.
    
                               In shell mode strings with special characters will
                               have them octal encoded and wrapped so as to be
                               suitable for direct shell usage (i.e. ESCAPED
                               becomes $'ESCAPED').
    
                               In both URI modes strings with special characters
                               will have them hex encoded in a format suitable for
                               usage in a URI (i.e. as %XX where X is a hex digit).
    
                               Lowercase hex digits are output in hex and uri modes.
                               Uppercase hex digits are output in HEX and URI modes.


Output is one line for each orphan file found.  Each line consists of the directory, a tab, the filename, a tab, and the fingerprint (`MD5:size` or `MD5:size:lowercase_name` in same-name mode).  If the `--long-names` option is given then each line ends with two tabs followed by the full path of the file.

Sample output (without `--long-names`):

    directory_1     filename_1      02c538f8e34d252ae22df357fcf75ea3:123
    directory_2     filename_2      8b93959cee28415ffafd56da99c1a268:98765

Sample output (with `--long-names`):

    directory_1     filename_1      02c538f8e34d252ae22df357fcf75ea3:123            directory_1/filename_1
    directory_2     filename_2      8b93959cee28415ffafd56da99c1a268:98765          directory_2/filename_2


---

### get_metadata
`get_metadata ( FILE | DIRECTORY ) [ ... ] [ OPTIONS ]`

Display file metadata.  One use for this is making a backup copy of the files' attributes. Note that there is currently no way to explicitly set file metadata using checksum_tools.

**Options:**

    -c | --compute-missing     Compute and store MD5 checksums when not present
                               (default)
    --no-compute-missing       Don't compute or store MD5 checksums
    -d | --discard-existing    Discard existing checksums and recompute them
    -r | --recurse             Recurse into subdirectories (default)
    -R | --no-recurse          Do not recurse into subdirectories
    -x | --one-filesystem      Don't cross filesystem boundaries while recursing
    --escape-filenames=MODE    Escape special characters in file and directory names
                               MODE can be octal, hex, HEX, shell, uri, or URI.
    
                               In shell mode strings with special characters will
                               have them octal encoded and wrapped so as to be
                               suitable for direct shell usage (i.e. ESCAPED
                               becomes $'ESCAPED').
    
                               In both URI modes strings with special characters
                               will have them hex encoded in a format suitable for
                               usage in a URI (i.e. as %XX where X is a hex digit).
    
                               Lowercase hex digits are output in hex and uri modes.
                               Uppercase hex digits are output in HEX and URI modes.

Metadata for all files is written to `STDOUT` (one file per line).  Metadata is reported as key/value pairs (`KEY:VALUE`) with a single tab between each pair.  If an attribute is not present for a file (e.g. `jpeg.md5` for a text file) then the attribute is not listed (i.e. attributes do not have `NULL` values).  The following attributes may be reported:

    path        Path (either relative or absolute)
    name        Name
    fullpath    Path and name (either relative or absolute)
    type        One of: dir file link block char fifo socket
    mode        Mode bits (4-digit octal)
    user        Owner: NUMBER (NAME)
    group       Group: NUMBER (NAME)
    size        Size (only for files)
    mtime       Modification time (UNIX timestamp)
    target      Symlink's target
    device      Device major and minor values: MAJOR,MINOR
    original    Original location (path and filename)
    md5         MD5 checksum of entire file
    md5.mtime   File's mtime when MD5 checksum was computed
    md5.size    File's size when MD5 checksum was computed
    md5.valid   Whether stored file checksum is probably accurate (yes or no).
    md5.source  Source of checksum data (either attributes or md5sums)

Extended attributes are also reported as `xa.NAMESPACE.NAME`.  On platforms that don't support extended attribute namespaces all attributes appear under the user namespace (e.g. `xa.user.NAME`).

Of interest is `xa.user.jpeg.md5` (`xa.jpeg.md5` on some platforms) which, for JPEG files is the MD5 checksum  of file's JPEG data (as computed by `jpeg_checksum_tools`).

Missing file checksums will be computed unless the `--no-compute-missing` option is specified.

---

### link_dupes

`link_dupes OBJECTS REFERENCE_DIRECTORY [ OPTIONS ]`  
`link_dupes OBJECTS REFERENCE_FILE [ OPTIONS ]`  
`link_dupes DIRECTORY [ OPTIONS ]`

`OBJECTS` := `( FILE | DIRECTORY ) [ ... ]`

This command can run in three modes:

 - Replace any files in `OBJECTS` that exist in `REFERENCE_DIRECTORY` with links to the latter.
 - Replace any files in `OBJECTS` that are the same as `REFERENCE_FILE` with links to the latter.
 - When called with a single directory then any duplicate files in the directory are linked to one of the copies.

**Options:**

    -A | --no-act              Do not delete or move any files (.md5sums and
                               extended attribute metadata may be updated)
    -b | --built-in-copy       Use a built-in function to copy files (instead of
                               using e.g. "cp -ap"); this is also used when copying
                               files or moving files across devices.
                               (not currently implemented)
    -d | --discard-existing    Discard existing checksums and recompute them
    -l | --link-relative       When symlinking always use relative links
    -L | --link-absolute       When symlinking always use absolute links
    -m DIR | --move-dupes DIR  Move duplicate files into the directory DIR
    -n | --same-name           For a file to match it must have same filename (case-
                               insensitive) as well as the same fingerprint.
                               At some point a --case-insensitive option may be
                               added; if this is done, the --same-name option will
                               be case-sensitive unless case-insensitivity is
                               explicitly requested.
    -O | --overwrite           Allow overwriting of existing files
    -P | --preserve            Never overwrite existing files
                               Attempting to overwrite an exising file will display
                               a warning to STDERR then continue.
    -r | --recurse             Recurse into subdirectories (default)
    -R | --no-recurse          Do not recurse into subdirectories
    -x | --one-filesystem      Don't cross filesystem boundaries while recursing
    --show-all-checksums       Show checksum on all lines, not just the first
    --terse=MODE               Use terse output; MODE controls what is shown:
                               dupe -> only duplicate file paths
                               keep -> only kept file paths
                               both -> both types, prefixed with DUPE: or keep:

Hard links will be used whenever possible; if this cannot be done (e.g. cross-device links) then symbolic links will be used.  When symbolic links are used, relative links are used if the file being pointed by the link to has a relative path and absolute links are used if the file being pointed to has an absolute path.  The the `--link-absolute` option can be used to force the use of absolute links and `--link-relative` can be used to force use of relative links.

The `symlink_dupes` command behaves similar to this one except that it always uses symbolic links (not hard links).

Checksums will be computed and stored for all files that are missing them.

---

### prune_dirs
`prune_dirs DIRECTORY [ ... ] [ OPTIONS ]`

Recursively delete empty directories

Options:

    -a | --all-or-nothing      Only act if the entire object would be affected.
                               For example, running prune_dirs on an object with
                               this option active will only perform deletions if
                               the entire object would be deleted.
    -A | --no-act              Do not delete or move any files (.md5sums and
                               extended attribute metadata may be updated)
    -E | --ignore-symlinks     Directories holding only symlinks or subdirectories
                               (no regular files) are considered empty.
    -r | --recurse             Recurse into subdirectories (default)
    -R | --no-recurse          Do not recurse into subdirectories
    -x | --one-filesystem      Don't cross filesystem boundaries while recursing


Directories are considered empty if they contain no files besides `.md5sums`, `.img-md5sums`, `.atom`, `.DS_Store`, `.directory`, `.folder.png`, `Thumbs.db`, `Desktop.ini`, `BBThumbs.dat`, or .`DS_Store` and no non-empty subdirectories besides `.xvpics`, `.pics`, or `.AppleDouble`.  In addition, if the `--ignore-symlinks` option is given then directories containing only symbolic links and no files (special or otherwise, beyond those mentioned above) are also considered to be empty.

Normally, empty subdirectories are deleted even when there parent isn't empty. To only allow deletion of fully-empty top-level directories specify `--all-or-nothing` on the commandline.

---

### restore_to_xa_location
`restore_to_xa_location ( FILE | DIRECTORY ) [ ... ] [ OPTIONS ]`

Move files back to the their original locations (as stored in each file's `user.meta.original_path` attribute).

**Options:**

    -A | --no-act              Do not delete or move any files (.md5sums and
                               extended attribute metadata may be updated)
    -b | --built-in-copy       Use a built-in function to copy files (instead of
                               using e.g. "cp -ap"); this is also used when copying
                               files or moving files across devices.
                               (not currently implemented)
    -O | --overwrite           Allow overwriting of existing files
    -P | --preserve            Never overwrite existing files
                               Attempting to overwrite an exising file will display
                               a warning to STDERR then continue.
    -r | --recurse             Recurse into subdirectories (default)
    -R | --no-recurse          Do not recurse into subdirectories
    -x | --one-filesystem      Don't cross filesystem boundaries while recursing

By default, existing symlinks will be overwritten but not files.  To always allow overwriting use the `--overwrite` (`-O`) option; to never allow overwriting use the `--preserve` (`-P`) option.  In any case, attempting to overwrite a directory or special file will display a (non-fatal) warning to `STDERR` and the source file will not be moved.  The same applies when `--preserve` is active.

No action will be taken on a file being restored if it is not a regular file or has no `user.meta.original_path` attribute.

Missing directories will be recreated but their ownership, permissions, and extended attributes will not be restored.

This command requires filesystem support for user-defined extended attributes.  Currently, `.md5sums` files are not updated.

---

### symlink_dupes
`symlink_dupes OBJECTS REFERENCE_DIRECTORY [ OPTIONS ]`  
`symlink_dupes OBJECTS REFERENCE_FILE [ OPTIONS ]`  
`symlink_dupes DIRECTORY [ OPTIONS ]`

`OBJECTS` := `( FILE | DIRECTORY ) [ ... ]`

This command can run in three modes:

 - Replace any files in `OBJECTS` that exist in `REFERENCE_DIRECTORY` with symbolic links to the latter.
 - Replace any files in `OBJECTS` that are the same as `REFERENCE_FILE` with symbolic links to the latter.
 - When called with a single directory then any duplicate files in the directory are symbolically linked to one of the copies.

**Options:**

    -A | --no-act              Do not delete or move any files (.md5sums and
                               extended attribute metadata may be updated)
    -b | --built-in-copy       Use a built-in function to copy files (instead of
                               using e.g. "cp -ap"); this is also used when copying
                               files or moving files across devices.
                               (not currently implemented)
    -d | --discard-existing    Discard existing checksums and recompute them
    -l | --link-relative       When symlinking always use relative links
    -L | --link-absolute       When symlinking always use absolute links
    -m DIR | --move-dupes DIR  Move duplicate files into the directory DIR
    -n | --same-name           For a file to match it must have same filename (case-
                               insensitive) as well as the same fingerprint.
                               At some point a --case-insensitive option may be
                               added; if this is done, the --same-name option will
                               be case-sensitive unless case-insensitivity is
                               explicitly requested.
    -O | --overwrite           Allow overwriting of existing files
    -P | --preserve            Never overwrite existing files
                               Attempting to overwrite an exising file will display
                               a warning to STDERR then continue.
    -r | --recurse             Recurse into subdirectories (default)
    -R | --no-recurse          Do not recurse into subdirectories
    -x | --one-filesystem      Don't cross filesystem boundaries while recursing
    --show-all-checksums       Show checksum on all lines, not just the first
    --terse=MODE               Use terse output; MODE controls what is shown:
                               dupe -> only duplicate file paths
                               keep -> only kept file paths
                               both -> both types, prefixed with DUPE: or keep:

Relative links are used if the file being pointed by the link to has a relative path and absolute links are used if the file being pointed to has an absolute path.  The `--link-absolute` option can be used to force the use of absolute links for all links and `--link-relative` can be used to force use of relative links for all links.

The `link_dupes` command behaves similar to this one except that it uses hard links whenever possible (symbolic links are only used as a fall-back).

Checksums will be computed and stored for all files that are missing them.

---

### update_checksums
`update_checksums ( FILE | DIRECTORY ) [ ... ] [ OPTIONS ]`

Update file checksums.

**Options:**

    -d | --discard-existing    Discard existing checksums and recompute them
    -r | --recurse             Recurse into subdirectories (default)
    -R | --no-recurse          Do not recurse into subdirectories
    -x | --one-filesystem      Don't cross filesystem boundaries while recursing

Updates the file checksums for all specified files and directories.  If a file does not appear to have been modified (same size and last-modified date) then the checksum will not be recomputed.  To recompute checksums for all files (not just those that appear to have changed) use the `--discard-existing` (`-d`) option.

---

### verify_checksums
`verify_checksums ( FILE | DIRECTORY ) [ ... ] [ OPTIONS ]`

Verify that files match their checksums.

**Options:**

    -n | --same-name           For a file to match it must have same filename (case-
                               insensitive) as well as the same fingerprint.
                               At some point a --case-insensitive option may be
                               added; if this is done, the --same-name option will
                               be case-sensitive unless case-insensitivity is
                               explicitly requested.
    -r | --recurse             Recurse into subdirectories (default)
    -R | --no-recurse          Do not recurse into subdirectories
    -x | --one-filesystem      Don't cross filesystem boundaries while recursing

If no files have changed then `NO CHANGES` is output.  If files have changed then they are listed along with the nature of the change.  For example, if the checksum, modification time, and size of a file named `filename` in a directory named `directory` have changed then the following will be output:

    CHANGED directory/filename      MD5 changed, mtime changed, size changed

This command always recomputes the MD5 checksums but never writes them.


## Excluding directories

If a directory contains a file name `.no_md5sums` then no checksums will be computed and no `.md5sums` files will be created in the directory or any of its subdirectories.  This is needed for certain system directories where the presence of any extraneous files causes errors (in this case `.no_md5sums` should be placed in the parent of the problematic directory).  It can also be used to block processing of temporary directories, database directories, or directories that contain extraordinarily large numbers of files (by placing `.no_md5sums` in the directory to skip).

## Supressing creation of `.md5sums` files

By default `.md5sums` files are written.  To suppress this, pass the `--only-write-xa` option on the commandline.  With this option active, checksums will only be written to files' extended attributes.

## Requisites and additional files

These scripts run best when user-specified extended attribute support is available.  Most will, however, work fine with filesystems that do not have that feature available or enabled.  On Linux, filesystems should be mounted with the `user_xattr` option.  On Debian/Ubuntu, the `libattr1` library is required.  The following Perl libraries are also required:

- **`Cwd`**
- **`Digest::MD5`**
- **`File::Basename`**
- **`File::ExtAttr`**
- **`File::Spec`**

These modules can be installed by running:

    sudo cpan Cwd Digest::MD5 File::Basename File::ExtAttr File::Spec

For debug purposes, the `Data::Dumper` module can be used; this library is not required for normal use and is not `use`d by default.

---

**Adding extended user attribute support to older software**

Many older software packages (such as KDE3 a.k.a. Trinity) do not copy user-specified extended attributes when copying files.  A patch<sup>1</sup> is provided that adds this functionality to the KDE3/Trinity `kio` subsystem.  To use it download the `kdelibs` sources<sup>2</sup>, apply the patch, then build the libraries but do not install them.  Copy only the `libkio.so.4.2.0` file from the build directory to where your KDE3/Trinity libraries are installed then restart KDE3/Trinity.  If you don't wish to build from source a pre-built library (compiled for Linux x64) is provided that may work on your system.

This patch can be easily adapted to work with other third-party software.  To do so, modify any functions/methods that copy or move files by adding the call to `attr_copy_file(...)` immediately after the new file has been written.  You will, of course, also need to include the support code (the includes, the `error(...)` function, etc.).  Note that most modern Linux software already includes support for user-supplied extended attributes.

<sup>1</sup> `kdelibs-trinity-3.5.13.2.with_xattr_changes.patch`  
<sup>2</sup> See [`https://wiki.trinitydesktop.org/Category:Documentation#Installing_from_Source`](https://wiki.trinitydesktop.org/Category:Documentation#Installing_from_Source) to get started.  
<sup>3</sup> IIRC, this should be something like:

    sudo mv /opt/trinity/lib/libkio.so.4.2.0 /opt/trinity/lib/libkio.so.4.2.0.disabled
    sudo cp -a /tmp/kdelibs.build/kio/libkio.so.4.2.0 /opt/trinity/lib/libkio.so.4.2.0

## Ignored files

When processing files, all files named `.md5sums`, `.folder.png`, `.folder.jpg`, `.atom`, `.directory`, or `swapfile` are skipped.  To change this list, modify the `%ignore` hash in `checksum_tool`.


## Examples

Here are a few examples of what can be done with `checksum_tools`:

- ### Verify the integrity of files

    First generate the checksums:
    
        update_checksums DIRECTORY
    
    At a later date verify that the files have not changed:
    
        verify_checksums DIRECTORY
    
    This will output `NO CHANGES` if the files in the directory are unaltered.  Note that this will not indicate whether files have been removed,
    
- ### Find duplicate files within a single directory

    
        find_dupes DIRECTORY
    
- ### Find files in one directory that also exist in a second

        find_dupes DIRECTORY_1 DIRECTORY_2
    
- ### Remove files in one directory that also exist in a second

        cull_dupes DIRECTORY_1 DIRECTORY_2
    
    Any files in `DIRECTORY_1` that also exist in `DIRECTORY_2` will be removed from `DIRECTORY_1`.

- ### Find files that differ between two directories or that exist only in one of the directories

        find_orphans DIRECTORY_1 DIRECTORY_2

    Both files whose contents differ and those that only exist in one of the directories will be listed.  Only file size and checksum are considered.

        find_orphans --same-name DIRECTORY_1 DIRECTORY_2

    This behaves the same as the previous example except that in addition to file size and checksum, files must have the same name (case-insensitive) to be considered the same.

- ### Move files across devices while ensuring their integrity

    Recompute checksums:
    
        update_checksums --discard-existing SOURCE
    
    Copy to new location<sup>1</sup>:
    
        cp -ap SOURCE DESTINATION
    
    Verify that the files were copied correctly:
    
        verify_checksums DESTINATION
    
    This will output `NO CHANGES` if the file contents were correctly copied.  This, however, won't indicate if any files failed to copy at all.  To determine this run:
    
        find_orphans SOURCE DESTINATION
    
    If no missing files were found then the above will produce no output.  If missing files were found, they will be listed.
    
    If the copy appears correct one can then remove the source:
    
        cull_dupes SOURCE DESTINATION
        prune_dirs SOURCE

    <sup>1</sup> Command shown works on Linux and Mac OS X.   For Solaris or FreeBSD use `/usr/bin/cp -p`, and for NetBSD use `cp -p`.

- ### Replace duplicate files with links to a canonical directory

    First generate the checksums for the `ADDITIONAL` and `CANONICAL` directories:
    
        update_checksums ADDITIONAL CANONICAL
    
    Replace duplicate files in `ADDITIONAL` with links to their copies in `CANONICAL`:
    
        link_dupes ADDITIONAL CANONICAL
    
    For the above command, hard links will be used whenever possible (i.e. when both locations are on the same device).  If hard links can't be used then symlinks will be used.  To always use symlinks one can run:
    
        symlink_dupes --link-absolute ADDITIONAL CANONICAL

    Depending on your specific circumstances you may wish to use the `--link-relative` option, the `--link-absolute` option, or neither option.

## Known issues

There are no known functional issues on GNU/Linux or Mac OS X systems.  On other platforms one may encounter problems.

If you encounter any problems please report them to the project's [issue tracker](https://github.com/Alex-Kent/checksum_tools/issues).

Rooms for improvement include localization and full support for platforms/filesystems lacking extended attributes.


## Localization

The program source is encoded in UTF-8 and there is a `Localize(...)` function for strings but currently there are no translations to languages other than English ('`en`').  See the `Localization.md` file for details.


## Theory of operation

`checksum_tools` works by generating a fingerprint (checksum) for each file.  This is stored in the file's extended attributes and also in a `.md5sums` file in the file's directory.  By later recomputing the checksum and comparing it with the stored value the program can determine whether the file has changed<sup>1</sup>.  The fingerprints of two different files can also be compared.  If the fingerprints match then so do the files' content.

<sup>1</sup> While there is a remote possibility that two files with different contents may have the same fingerprint this is extraordinarily unlikely in practice (both the 128-bit checksum and the file size would need to match; the same-name option can provide further protection against false matches).

## Checksum formats

As mentioned above, checksums are stored in two place: a `.md5sums` file in the file's directory and, when possible, in the file's extended attributes.


### .md5sums file

The `md5sums` file contains checksums for all files in a directory.  The first line contains the version number (`v2` for the current version of `checksum_tools`).  Following this are the checksums for each file in the directory, one per line.  Each line consists of the file's MD5 checksum (32 characters), a tab, the file's timestamp at the time the checksum was computed, a tab, the file's size at the time the checksum was computed, a tab, and then the file's name (UTF-8 encoded).  A sample file is:

    v2
    d41d8cd98f00b204e9800998ecf8427e        1618272540      0       Empty file 1
    d41d8cd98f00b204e9800998ecf8427e        1618272528      0       Empty_File_2
    97fca274dd26cfbebd186b9de3aff397        1618273502      6817    Another file



### Extended attributes

The fingerprints are also stored in the files' extended attributes.  The `user._` attribute contains the file's 32-character MD5 checksum, a colon (`:`), the file's timestamp at the time the checksum was computed, another colon (`:`), and the file's size at the time the checksum was computed.<sup>1</sup>

Additional metadata may also be stored in the extended attributes.  When the `--move-dupes` option is active, a moved file's original location (absolute path) is stored in the `user.meta.original_path` attribute<sup>2</sup>.  When processed using `jpeg_checksum_tools`, JPEG files may have further extended attributes giving, for example, the location where they were taken.

<sup>1</sup> Formerly the `user.md5`, `user.md5_mtime`, and `user.md5_size` attributes were used.  This was found to waste a lot of disk space (typically 4kB per file, ~0.5% overall) so the new, compact, format was switched to.  The compact format fits well within the 68 characters that can be stored in-inode for single-character keys on `ext4` filesystems (i.e. on Linux).

<sup>2</sup> This, unfortunately, is too large to store within the file's inode.  At least on Linux/`ext4`, an additional filesystem block (typically 4kB) will be allocated to store it.


# License

`checksum_tools` is licensed under version 3 of the GNU Affero General Public License.  See the `LICENSE` file to view the full text of the license.


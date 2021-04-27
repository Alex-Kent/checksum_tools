# Internals

## Program flow

The basic program flow is described here.  Minor details (like loading localizations with `GetStrings()`) are skipped.

First, the set of available commands and the set of available options are constructed with `GetAvailableCommands()` and `GetAvailableOptions()`.  Next, `GetOptions()` is called to parse the commandline options, determine the running command, and do basic sanity-checking on the commandline options.

Next, the chosen command is run.  First, the command's `initialize` callback is called.  Object processing then begins.  This occurs in either one or two phases:

In single-phase mode all objects passed on the commandline are processed in a single pass.  The callbacks used for this phase all start with `phase-1-`.

In two-phase mode all objects passed on the commandline except for the last are processed as described for single-phase mode.  Next, the last object on the commandline is processed in an additional pass.  The callbacks used for this all start with `phase-2-`.

Lastly, the command's `finalize` callback is called.

If a callback is not defined then it won't be run.  The available callbacks are:

- **initialize**  
    Called when the command starts.

- **phase-1-per-tree-pre**  
    In phase 1, called before before each top-level object is processed,

- **phase-1-dir-enter**  
    In phase 1, called when a directory is entered,

- **phase-1-per-object**  
    In phase 1, called for every object in a directory or, if the top-level object is not a directory, for the top-level object,

- **phase-1-per-subdirectory**  
    In phase 1, called from the parent after a subdirectory has been processed,

- **phase-1-dir-leave**  
    In phase 1, called upon leaving a directory.

- **phase-1-per-tree-post**  
    In phase 1, called after a top-level object is processed,

- **phase-2-pre**  
    Called before phase 2 begins,

- **phase-2-dir-enter**  
    In phase 2, called when a directory is entered,

- **phase-2-per-object**  
    In phase 2, called for every object in a directory or, if the top-level object is not a directory, for the top-level object,

- **phase-2-per-subdirectory**  
    In phase 2, called from the parent after a subdirectory has been processed,

- **phase-2-dir-leave**  
    In phase 2, called upon leaving a directory.

- **phase-2-post**  
    Called once phase 2 is completed,


- **finalize**  
    Called after all objects have been processed,


## Localization

When strings shown to the user are the program attempts to localize the text to match their locale.  See `Localization.md` for details.

## Commands

Commands are constructed by the `GetAvailableCommands()` function.  This returns a hash describing all available commands and the callbacks used to run them.  Each command is a key in the hash (its internal name) and an anonymous hash defining it.  The hash for each command is structured as follows:

- **short**  
    The short-form option used to request the command when called via `checksum_tool`.

- **long**  
    The long-form option used to request the command when called via `checksum_tool`.

- **alias**  
    The name of the command when run directly.  This is the filename that is symlinked to `checksum_tool`.

- **supported_options**  
    List reference with the names of all non-core options that the command supports.

    May be `undef` if no non-core options are supported.

- **syntax**  
    Human-readable string with the command's commandline syntax.

    This is given as a reference to a list of localized strings.  If a command supports multiple syntaxes (e.g if it can run in both 1- and 2-phase modes) there should be one entry in the list for each.

- **usage**  
    Brief human-readable help message shown in the available command summary when `checksum_tool --help` is run.  This value is a localizable string.

- **usage_long**  
    Detailed human-readable help message shown when a command is run with the `--help` or `-h` option.  This value is a localizable string.

- **phases**  
    Set to `1` to run in a single phase or set to `2` to run in two-phase mode.  This option is required but may be set by a command's `initialize` callback.

- **use-checksums**  
    Set to `1` if checksums should should be read and/or computed.  Set to `0` otherwise.

    Default is `1` (use checksums).

- **skip-if-no_md5sums-present**  
    If set to `1` and a directory contains a file named `.no_md5sums` then the directory will not processed.  Note that parent directories are not checked for `.no_md5sums` files.  Set to `0` to ignore `.no_md5sums` files.

    Default is `1` (don't process directory if a `.no-md5sums` file exists).

- **Callback functions**  
    Each command's behavior is defined by its callbacks.  These are `initialize`, `phase-1-per-tree-pre`, `phase-1-dir-enter`, `phase-1-per-object`, `phase-1-per-subdirectory`, `phase-1-dir-leave`, `phase-1-per-tree-post`, `phase-2-pre`, `phase-2-dir-enter`, `phase-2-per-object`, `phase-2-per-subdirectory`, `phase-2-dir-leave`, `phase-2-post`, `finalize`, described previously.  If a command does not use a particular callback it should be set to `undef` or simply omitted.

    A more detailed description of the above (including callback function parameters) can be found in the "Command definitions" section of the `checksum_tool` source.


### Aliases

To avoid code duplication and ensure consistent behavior between related commands, function aliases are available.  To have a callback function in one command use a callback function in a different command, use the following syntax in the hash:

    ALIAS 'function-name' => '{command}{function}',

For the above, when a call is made to the command's `function-name` callback, the call will actually be made to the `function` callback in the `command` command.  See, for example, the implementation of `find_dupes` and `cull_dupes`.

## Options

The set of available commandline options is returned by the `GetAvailableOptions()` function.  This returns a hash describing all available commandline options.  Each option is a key in the hash (its internal name) and an anonymous hash defining it.  The hash for each option is structured as follows:

- **short**  
    The short form of the option as given on the commandline.  This should be set to `undef` if only a long form is supported.

- **long**  
    The long form of the option as given on the commandline.

- **core-option**  
    Set to `1` if the option is available to all commands or `0` if a command must explicitly request it via `supported_options`.

- **default**  
    The default value to assign to the option if not specified on the commandline.  Set to `undef` to not assign a default value.

- **takes-arg**  
    Set to `1` if the option takes an argument or `0` if it does not.  Arguments can be specified on the commandline in any of the following forms:

         --option argument
         --option=argument
         -o argument
         -o=argument

    In the above, `--option` is the option's long form and `-o` is its short form.  If `argument` contains spaces it must be quoted on the commandline (or be in a single parameter if called via the `system()` call).

- **set-key**  
    If defined then use specified key when setting the option (instead of the option's name).

- **set-value**  
    If defined then use specified value when setting the option (instead of `1`).

- **set-additional**  
    An optional list reference containing an additional key/value pair to set when the option is present on the commandline.

- **error-check**  
    An optional anonymous subroutine to use for validating the option.  This can, e.g., make sure there are no conflicting options, check validity of additional arguments, etc.  Returns an exception or `undef` if the option is valid.  See the source for details.

- **usage**  
    Brief human-readable description of the option.  The is shown when `--help` or `--help-core` (for command-specific and core options, respectively) is run.  The value is a localizable string.

See the "Option definitions" section of the `checksum_tool` source for more details on all of the above.

# Localization

Checksum tools includes basic localization support.

Localization is performed by calling the `Localize` function with a hash of translations of a string for all supported languages.  These hashes have the following structure:

    { language_code => translation, ... }

An example might be:

    { 'en' => 'Hi!',    'de' => 'Hallo!', 'es' => '¡Hola!', 
      'fr' => 'Salut!', 'nl' => 'Hai!',   'sv' => 'Hej!'    }

If the hash reference shown above were stored in a variable named `$greeting` then an appropriately-translated string could be displayed by calling:

    print Localize( $greeting ) . "\n";

Most of these hashes are stored in one of three global hashes: `%AVAILABLE_COMMANDS`, `%AVAILABLE_OPTIONS`, and `%STRINGS` (the first two also contain non-localization information).  These are initialized by the `GetAvailableCommands`, `GetAvailableOptions`, and `GetStrings` functions, respectively.  The `Usage` function also contains additional strings that need to be localized; look for calls similar to:

    	print Localize( { 'en' => <<EOF
    English translation
    over
    multiple lines
    
    EOF
    	} ); # END localize

To add a French translation for the above, one might change that statement to read:

    	print Localize( { 
    	                  'en' => <<EOF
    English translation
    over
    multiple lines
    
    EOF
    	                , 'fr' => <<EOF
    Traduction française
    sur
    plusieurs lignes
    
    EOF
     	} ); # END localize

Note that [here documents](https://en.wikipedia.org/wiki/Here_document#Perl) are used for the multi-line strings.  One quirk is that one may need to place two newlines at the end of these strings (as shown above) since `Localize` will always strip the final one.

The hashes in the `GetAvailableCommands`, `GetAvailableOptions`, and `GetStrings` functions are similar.  For example, to add a translation for the `help` command one might change (in `GetAvailableCommands`):

    			'usage' => { 'en' => <<EOF
    -h | --help                Show brief usage message
    EOF
    			},

to:

    			'usage' => {
    			             'en' => <<EOF
    -h | --help                Show brief usage message
    EOF
    			           , 'nl' => <<EOF
    -h | --help                Toon kort gebruiksbericht
    EOF
    			},

Note that only the message has been changed, and not the option names.  This is done to ensure compatibility of commandline options for all languages.

When choosing which string to use, `Localize` first determines the current language from (in order of preference) the `LANG`, `LANGUAGE`, `LC_ALL`, and `KDE_LANG` environment variables; if none of these is set then the string 'en' (for English) is used.  Next, an appropriate translated string is sought by looking for the full locale, then the locale less any character encoding, then also less any region code.  If no match is found then 'en' (for English) is used.  For example, if `LANG` is `fr_CA.UTF-8` then first a translation for `fr_CA.UTF-8` is sought, then `fr_CA`, then `fr`, and lastly `en`.

All strings should be formatted to 80 characters or less in width.  This is simply to make things look nice on-screen and is not a technical limitation.

The current system may lead to a lot of bloat if many translations are added but it's a start...
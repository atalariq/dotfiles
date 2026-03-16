# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_typst_global_optspecs
	string join \n color= cert= h/help V/version
end

function __fish_typst_needs_command
	# Figure out if the current invocation already has a command.
	set -l cmd (commandline -opc)
	set -e cmd[1]
	argparse -s (__fish_typst_global_optspecs) -- $cmd 2>/dev/null
	or return
	if set -q argv[1]
		# Also print the command, so this can be used to figure out what it is.
		echo $argv[1]
		return 1
	end
	return 0
end

function __fish_typst_using_subcommand
	set -l cmd (__fish_typst_needs_command)
	test -z "$cmd"
	and return 1
	contains -- $cmd[1] $argv
end

complete -c typst -n "__fish_typst_needs_command" -l color -d 'Whether to use color. When set to `auto` if the terminal to supports it' -r -f -a "auto\t''
always\t''
never\t''"
complete -c typst -n "__fish_typst_needs_command" -l cert -d 'Path to a custom CA certificate to use when making network requests' -r -F
complete -c typst -n "__fish_typst_needs_command" -s h -l help -d 'Print help'
complete -c typst -n "__fish_typst_needs_command" -s V -l version -d 'Print version'
complete -c typst -n "__fish_typst_needs_command" -f -a "compile" -d 'Compiles an input file into a supported output format'
complete -c typst -n "__fish_typst_needs_command" -f -a "c" -d 'Compiles an input file into a supported output format'
complete -c typst -n "__fish_typst_needs_command" -f -a "watch" -d 'Watches an input file and recompiles on changes'
complete -c typst -n "__fish_typst_needs_command" -f -a "w" -d 'Watches an input file and recompiles on changes'
complete -c typst -n "__fish_typst_needs_command" -f -a "init" -d 'Initializes a new project from a template'
complete -c typst -n "__fish_typst_needs_command" -f -a "query" -d 'Processes an input file to extract provided metadata'
complete -c typst -n "__fish_typst_needs_command" -f -a "fonts" -d 'Lists all discovered fonts in system and custom font paths'
complete -c typst -n "__fish_typst_needs_command" -f -a "update" -d 'Self update the Typst CLI'
complete -c typst -n "__fish_typst_needs_command" -f -a "completions" -d 'Generates shell completion scripts'
complete -c typst -n "__fish_typst_needs_command" -f -a "info" -d 'Displays debugging information about Typst'
complete -c typst -n "__fish_typst_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c typst -n "__fish_typst_using_subcommand compile" -s f -l format -d 'The format of the output file, inferred from the extension by default' -r -f -a "pdf\t''
png\t''
svg\t''
html\t''"
complete -c typst -n "__fish_typst_using_subcommand compile" -l root -d 'Configures the project root (for absolute paths)' -r -F
complete -c typst -n "__fish_typst_using_subcommand compile" -l input -d 'Add a string key-value pair visible through `sys.inputs`' -r
complete -c typst -n "__fish_typst_using_subcommand compile" -l font-path -d 'Adds additional directories that are recursively searched for fonts' -r -F
complete -c typst -n "__fish_typst_using_subcommand compile" -l package-path -d 'Custom path to local packages, defaults to system-dependent location' -r -F
complete -c typst -n "__fish_typst_using_subcommand compile" -l package-cache-path -d 'Custom path to package cache, defaults to system-dependent location' -r -F
complete -c typst -n "__fish_typst_using_subcommand compile" -l creation-timestamp -d 'The document\'s creation date formatted as a UNIX timestamp' -r
complete -c typst -n "__fish_typst_using_subcommand compile" -l pages -d 'Which pages to export. When unspecified, all pages are exported' -r
complete -c typst -n "__fish_typst_using_subcommand compile" -l pdf-standard -d 'One (or multiple comma-separated) PDF standards that Typst will enforce conformance with' -r -f -a "1.4\t'PDF 1.4'
1.5\t'PDF 1.5'
1.6\t'PDF 1.6'
1.7\t'PDF 1.7'
2.0\t'PDF 2.0'
a-1b\t'PDF/A-1b'
a-1a\t'PDF/A-1a'
a-2b\t'PDF/A-2b'
a-2u\t'PDF/A-2u'
a-2a\t'PDF/A-2a'
a-3b\t'PDF/A-3b'
a-3u\t'PDF/A-3u'
a-3a\t'PDF/A-3a'
a-4\t'PDF/A-4'
a-4f\t'PDF/A-4f'
a-4e\t'PDF/A-4e'
ua-1\t'PDF/UA-1'"
complete -c typst -n "__fish_typst_using_subcommand compile" -l ppi -d 'The PPI (pixels per inch) to use for PNG export' -r
complete -c typst -n "__fish_typst_using_subcommand compile" -l make-deps -d 'File path to which a Makefile with the current compilation\'s dependencies will be written' -r -F
complete -c typst -n "__fish_typst_using_subcommand compile" -l deps -d 'File path to which a list of current compilation\'s dependencies will be written. Use `-` to write to stdout' -r -F
complete -c typst -n "__fish_typst_using_subcommand compile" -l deps-format -d 'File format to use for dependencies' -r -f -a "json\t'Encodes as JSON, failing for non-Unicode paths'
zero\t'Separates paths with NULL bytes and can express all paths'
make\t'Emits in Make format, omitting inexpressible paths'"
complete -c typst -n "__fish_typst_using_subcommand compile" -s j -l jobs -d 'Number of parallel jobs spawned during compilation. Defaults to number of CPUs. Setting it to 1 disables parallelism' -r
complete -c typst -n "__fish_typst_using_subcommand compile" -l features -d 'Enables in-development features that may be changed or removed at any time' -r -f -a "html\t''
a11y-extras\t''"
complete -c typst -n "__fish_typst_using_subcommand compile" -l diagnostic-format -d 'The format to emit diagnostics in' -r -f -a "human\t''
short\t''"
complete -c typst -n "__fish_typst_using_subcommand compile" -l open -d 'Opens the output file with the default viewer or a specific program after compilation. Ignored if output is stdout' -r
complete -c typst -n "__fish_typst_using_subcommand compile" -l timings -d 'Produces performance timings of the compilation process. (experimental)' -r -F
complete -c typst -n "__fish_typst_using_subcommand compile" -l ignore-system-fonts -d 'Ensures system fonts won\'t be searched, unless explicitly included via `--font-path`'
complete -c typst -n "__fish_typst_using_subcommand compile" -l ignore-embedded-fonts -d 'Ensures fonts embedded into Typst won\'t be considered'
complete -c typst -n "__fish_typst_using_subcommand compile" -l no-pdf-tags -d 'By default, even when not producing a `PDF/UA-1` document, a tagged PDF document is written to provide a baseline of accessibility. In some circumstances (for example when trying to reduce the size of a document) it can be desirable to disable tagged PDF'
complete -c typst -n "__fish_typst_using_subcommand compile" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c typst -n "__fish_typst_using_subcommand c" -s f -l format -d 'The format of the output file, inferred from the extension by default' -r -f -a "pdf\t''
png\t''
svg\t''
html\t''"
complete -c typst -n "__fish_typst_using_subcommand c" -l root -d 'Configures the project root (for absolute paths)' -r -F
complete -c typst -n "__fish_typst_using_subcommand c" -l input -d 'Add a string key-value pair visible through `sys.inputs`' -r
complete -c typst -n "__fish_typst_using_subcommand c" -l font-path -d 'Adds additional directories that are recursively searched for fonts' -r -F
complete -c typst -n "__fish_typst_using_subcommand c" -l package-path -d 'Custom path to local packages, defaults to system-dependent location' -r -F
complete -c typst -n "__fish_typst_using_subcommand c" -l package-cache-path -d 'Custom path to package cache, defaults to system-dependent location' -r -F
complete -c typst -n "__fish_typst_using_subcommand c" -l creation-timestamp -d 'The document\'s creation date formatted as a UNIX timestamp' -r
complete -c typst -n "__fish_typst_using_subcommand c" -l pages -d 'Which pages to export. When unspecified, all pages are exported' -r
complete -c typst -n "__fish_typst_using_subcommand c" -l pdf-standard -d 'One (or multiple comma-separated) PDF standards that Typst will enforce conformance with' -r -f -a "1.4\t'PDF 1.4'
1.5\t'PDF 1.5'
1.6\t'PDF 1.6'
1.7\t'PDF 1.7'
2.0\t'PDF 2.0'
a-1b\t'PDF/A-1b'
a-1a\t'PDF/A-1a'
a-2b\t'PDF/A-2b'
a-2u\t'PDF/A-2u'
a-2a\t'PDF/A-2a'
a-3b\t'PDF/A-3b'
a-3u\t'PDF/A-3u'
a-3a\t'PDF/A-3a'
a-4\t'PDF/A-4'
a-4f\t'PDF/A-4f'
a-4e\t'PDF/A-4e'
ua-1\t'PDF/UA-1'"
complete -c typst -n "__fish_typst_using_subcommand c" -l ppi -d 'The PPI (pixels per inch) to use for PNG export' -r
complete -c typst -n "__fish_typst_using_subcommand c" -l make-deps -d 'File path to which a Makefile with the current compilation\'s dependencies will be written' -r -F
complete -c typst -n "__fish_typst_using_subcommand c" -l deps -d 'File path to which a list of current compilation\'s dependencies will be written. Use `-` to write to stdout' -r -F
complete -c typst -n "__fish_typst_using_subcommand c" -l deps-format -d 'File format to use for dependencies' -r -f -a "json\t'Encodes as JSON, failing for non-Unicode paths'
zero\t'Separates paths with NULL bytes and can express all paths'
make\t'Emits in Make format, omitting inexpressible paths'"
complete -c typst -n "__fish_typst_using_subcommand c" -s j -l jobs -d 'Number of parallel jobs spawned during compilation. Defaults to number of CPUs. Setting it to 1 disables parallelism' -r
complete -c typst -n "__fish_typst_using_subcommand c" -l features -d 'Enables in-development features that may be changed or removed at any time' -r -f -a "html\t''
a11y-extras\t''"
complete -c typst -n "__fish_typst_using_subcommand c" -l diagnostic-format -d 'The format to emit diagnostics in' -r -f -a "human\t''
short\t''"
complete -c typst -n "__fish_typst_using_subcommand c" -l open -d 'Opens the output file with the default viewer or a specific program after compilation. Ignored if output is stdout' -r
complete -c typst -n "__fish_typst_using_subcommand c" -l timings -d 'Produces performance timings of the compilation process. (experimental)' -r -F
complete -c typst -n "__fish_typst_using_subcommand c" -l ignore-system-fonts -d 'Ensures system fonts won\'t be searched, unless explicitly included via `--font-path`'
complete -c typst -n "__fish_typst_using_subcommand c" -l ignore-embedded-fonts -d 'Ensures fonts embedded into Typst won\'t be considered'
complete -c typst -n "__fish_typst_using_subcommand c" -l no-pdf-tags -d 'By default, even when not producing a `PDF/UA-1` document, a tagged PDF document is written to provide a baseline of accessibility. In some circumstances (for example when trying to reduce the size of a document) it can be desirable to disable tagged PDF'
complete -c typst -n "__fish_typst_using_subcommand c" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c typst -n "__fish_typst_using_subcommand watch" -s f -l format -d 'The format of the output file, inferred from the extension by default' -r -f -a "pdf\t''
png\t''
svg\t''
html\t''"
complete -c typst -n "__fish_typst_using_subcommand watch" -l root -d 'Configures the project root (for absolute paths)' -r -F
complete -c typst -n "__fish_typst_using_subcommand watch" -l input -d 'Add a string key-value pair visible through `sys.inputs`' -r
complete -c typst -n "__fish_typst_using_subcommand watch" -l font-path -d 'Adds additional directories that are recursively searched for fonts' -r -F
complete -c typst -n "__fish_typst_using_subcommand watch" -l package-path -d 'Custom path to local packages, defaults to system-dependent location' -r -F
complete -c typst -n "__fish_typst_using_subcommand watch" -l package-cache-path -d 'Custom path to package cache, defaults to system-dependent location' -r -F
complete -c typst -n "__fish_typst_using_subcommand watch" -l creation-timestamp -d 'The document\'s creation date formatted as a UNIX timestamp' -r
complete -c typst -n "__fish_typst_using_subcommand watch" -l pages -d 'Which pages to export. When unspecified, all pages are exported' -r
complete -c typst -n "__fish_typst_using_subcommand watch" -l pdf-standard -d 'One (or multiple comma-separated) PDF standards that Typst will enforce conformance with' -r -f -a "1.4\t'PDF 1.4'
1.5\t'PDF 1.5'
1.6\t'PDF 1.6'
1.7\t'PDF 1.7'
2.0\t'PDF 2.0'
a-1b\t'PDF/A-1b'
a-1a\t'PDF/A-1a'
a-2b\t'PDF/A-2b'
a-2u\t'PDF/A-2u'
a-2a\t'PDF/A-2a'
a-3b\t'PDF/A-3b'
a-3u\t'PDF/A-3u'
a-3a\t'PDF/A-3a'
a-4\t'PDF/A-4'
a-4f\t'PDF/A-4f'
a-4e\t'PDF/A-4e'
ua-1\t'PDF/UA-1'"
complete -c typst -n "__fish_typst_using_subcommand watch" -l ppi -d 'The PPI (pixels per inch) to use for PNG export' -r
complete -c typst -n "__fish_typst_using_subcommand watch" -l make-deps -d 'File path to which a Makefile with the current compilation\'s dependencies will be written' -r -F
complete -c typst -n "__fish_typst_using_subcommand watch" -l deps -d 'File path to which a list of current compilation\'s dependencies will be written. Use `-` to write to stdout' -r -F
complete -c typst -n "__fish_typst_using_subcommand watch" -l deps-format -d 'File format to use for dependencies' -r -f -a "json\t'Encodes as JSON, failing for non-Unicode paths'
zero\t'Separates paths with NULL bytes and can express all paths'
make\t'Emits in Make format, omitting inexpressible paths'"
complete -c typst -n "__fish_typst_using_subcommand watch" -s j -l jobs -d 'Number of parallel jobs spawned during compilation. Defaults to number of CPUs. Setting it to 1 disables parallelism' -r
complete -c typst -n "__fish_typst_using_subcommand watch" -l features -d 'Enables in-development features that may be changed or removed at any time' -r -f -a "html\t''
a11y-extras\t''"
complete -c typst -n "__fish_typst_using_subcommand watch" -l diagnostic-format -d 'The format to emit diagnostics in' -r -f -a "human\t''
short\t''"
complete -c typst -n "__fish_typst_using_subcommand watch" -l open -d 'Opens the output file with the default viewer or a specific program after compilation. Ignored if output is stdout' -r
complete -c typst -n "__fish_typst_using_subcommand watch" -l timings -d 'Produces performance timings of the compilation process. (experimental)' -r -F
complete -c typst -n "__fish_typst_using_subcommand watch" -l port -d 'The port where HTML is served' -r
complete -c typst -n "__fish_typst_using_subcommand watch" -l ignore-system-fonts -d 'Ensures system fonts won\'t be searched, unless explicitly included via `--font-path`'
complete -c typst -n "__fish_typst_using_subcommand watch" -l ignore-embedded-fonts -d 'Ensures fonts embedded into Typst won\'t be considered'
complete -c typst -n "__fish_typst_using_subcommand watch" -l no-pdf-tags -d 'By default, even when not producing a `PDF/UA-1` document, a tagged PDF document is written to provide a baseline of accessibility. In some circumstances (for example when trying to reduce the size of a document) it can be desirable to disable tagged PDF'
complete -c typst -n "__fish_typst_using_subcommand watch" -l no-serve -d 'Disables the built-in HTTP server for HTML export'
complete -c typst -n "__fish_typst_using_subcommand watch" -l no-reload -d 'Disables the injected live reload script for HTML export. The HTML that is written to disk isn\'t affected either way'
complete -c typst -n "__fish_typst_using_subcommand watch" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c typst -n "__fish_typst_using_subcommand w" -s f -l format -d 'The format of the output file, inferred from the extension by default' -r -f -a "pdf\t''
png\t''
svg\t''
html\t''"
complete -c typst -n "__fish_typst_using_subcommand w" -l root -d 'Configures the project root (for absolute paths)' -r -F
complete -c typst -n "__fish_typst_using_subcommand w" -l input -d 'Add a string key-value pair visible through `sys.inputs`' -r
complete -c typst -n "__fish_typst_using_subcommand w" -l font-path -d 'Adds additional directories that are recursively searched for fonts' -r -F
complete -c typst -n "__fish_typst_using_subcommand w" -l package-path -d 'Custom path to local packages, defaults to system-dependent location' -r -F
complete -c typst -n "__fish_typst_using_subcommand w" -l package-cache-path -d 'Custom path to package cache, defaults to system-dependent location' -r -F
complete -c typst -n "__fish_typst_using_subcommand w" -l creation-timestamp -d 'The document\'s creation date formatted as a UNIX timestamp' -r
complete -c typst -n "__fish_typst_using_subcommand w" -l pages -d 'Which pages to export. When unspecified, all pages are exported' -r
complete -c typst -n "__fish_typst_using_subcommand w" -l pdf-standard -d 'One (or multiple comma-separated) PDF standards that Typst will enforce conformance with' -r -f -a "1.4\t'PDF 1.4'
1.5\t'PDF 1.5'
1.6\t'PDF 1.6'
1.7\t'PDF 1.7'
2.0\t'PDF 2.0'
a-1b\t'PDF/A-1b'
a-1a\t'PDF/A-1a'
a-2b\t'PDF/A-2b'
a-2u\t'PDF/A-2u'
a-2a\t'PDF/A-2a'
a-3b\t'PDF/A-3b'
a-3u\t'PDF/A-3u'
a-3a\t'PDF/A-3a'
a-4\t'PDF/A-4'
a-4f\t'PDF/A-4f'
a-4e\t'PDF/A-4e'
ua-1\t'PDF/UA-1'"
complete -c typst -n "__fish_typst_using_subcommand w" -l ppi -d 'The PPI (pixels per inch) to use for PNG export' -r
complete -c typst -n "__fish_typst_using_subcommand w" -l make-deps -d 'File path to which a Makefile with the current compilation\'s dependencies will be written' -r -F
complete -c typst -n "__fish_typst_using_subcommand w" -l deps -d 'File path to which a list of current compilation\'s dependencies will be written. Use `-` to write to stdout' -r -F
complete -c typst -n "__fish_typst_using_subcommand w" -l deps-format -d 'File format to use for dependencies' -r -f -a "json\t'Encodes as JSON, failing for non-Unicode paths'
zero\t'Separates paths with NULL bytes and can express all paths'
make\t'Emits in Make format, omitting inexpressible paths'"
complete -c typst -n "__fish_typst_using_subcommand w" -s j -l jobs -d 'Number of parallel jobs spawned during compilation. Defaults to number of CPUs. Setting it to 1 disables parallelism' -r
complete -c typst -n "__fish_typst_using_subcommand w" -l features -d 'Enables in-development features that may be changed or removed at any time' -r -f -a "html\t''
a11y-extras\t''"
complete -c typst -n "__fish_typst_using_subcommand w" -l diagnostic-format -d 'The format to emit diagnostics in' -r -f -a "human\t''
short\t''"
complete -c typst -n "__fish_typst_using_subcommand w" -l open -d 'Opens the output file with the default viewer or a specific program after compilation. Ignored if output is stdout' -r
complete -c typst -n "__fish_typst_using_subcommand w" -l timings -d 'Produces performance timings of the compilation process. (experimental)' -r -F
complete -c typst -n "__fish_typst_using_subcommand w" -l port -d 'The port where HTML is served' -r
complete -c typst -n "__fish_typst_using_subcommand w" -l ignore-system-fonts -d 'Ensures system fonts won\'t be searched, unless explicitly included via `--font-path`'
complete -c typst -n "__fish_typst_using_subcommand w" -l ignore-embedded-fonts -d 'Ensures fonts embedded into Typst won\'t be considered'
complete -c typst -n "__fish_typst_using_subcommand w" -l no-pdf-tags -d 'By default, even when not producing a `PDF/UA-1` document, a tagged PDF document is written to provide a baseline of accessibility. In some circumstances (for example when trying to reduce the size of a document) it can be desirable to disable tagged PDF'
complete -c typst -n "__fish_typst_using_subcommand w" -l no-serve -d 'Disables the built-in HTTP server for HTML export'
complete -c typst -n "__fish_typst_using_subcommand w" -l no-reload -d 'Disables the injected live reload script for HTML export. The HTML that is written to disk isn\'t affected either way'
complete -c typst -n "__fish_typst_using_subcommand w" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c typst -n "__fish_typst_using_subcommand init" -l package-path -d 'Custom path to local packages, defaults to system-dependent location' -r -F
complete -c typst -n "__fish_typst_using_subcommand init" -l package-cache-path -d 'Custom path to package cache, defaults to system-dependent location' -r -F
complete -c typst -n "__fish_typst_using_subcommand init" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c typst -n "__fish_typst_using_subcommand query" -l field -d 'Extracts just one field from all retrieved elements' -r
complete -c typst -n "__fish_typst_using_subcommand query" -l format -d 'The format to serialize in' -r -f -a "json\t''
yaml\t''"
complete -c typst -n "__fish_typst_using_subcommand query" -l target -d 'The target to compile for' -r -f -a "paged\t'PDF and image formats'
html\t'HTML'"
complete -c typst -n "__fish_typst_using_subcommand query" -l root -d 'Configures the project root (for absolute paths)' -r -F
complete -c typst -n "__fish_typst_using_subcommand query" -l input -d 'Add a string key-value pair visible through `sys.inputs`' -r
complete -c typst -n "__fish_typst_using_subcommand query" -l font-path -d 'Adds additional directories that are recursively searched for fonts' -r -F
complete -c typst -n "__fish_typst_using_subcommand query" -l package-path -d 'Custom path to local packages, defaults to system-dependent location' -r -F
complete -c typst -n "__fish_typst_using_subcommand query" -l package-cache-path -d 'Custom path to package cache, defaults to system-dependent location' -r -F
complete -c typst -n "__fish_typst_using_subcommand query" -l creation-timestamp -d 'The document\'s creation date formatted as a UNIX timestamp' -r
complete -c typst -n "__fish_typst_using_subcommand query" -s j -l jobs -d 'Number of parallel jobs spawned during compilation. Defaults to number of CPUs. Setting it to 1 disables parallelism' -r
complete -c typst -n "__fish_typst_using_subcommand query" -l features -d 'Enables in-development features that may be changed or removed at any time' -r -f -a "html\t''
a11y-extras\t''"
complete -c typst -n "__fish_typst_using_subcommand query" -l diagnostic-format -d 'The format to emit diagnostics in' -r -f -a "human\t''
short\t''"
complete -c typst -n "__fish_typst_using_subcommand query" -l one -d 'Expects and retrieves exactly one element'
complete -c typst -n "__fish_typst_using_subcommand query" -l pretty -d 'Whether to pretty-print the serialized output'
complete -c typst -n "__fish_typst_using_subcommand query" -l ignore-system-fonts -d 'Ensures system fonts won\'t be searched, unless explicitly included via `--font-path`'
complete -c typst -n "__fish_typst_using_subcommand query" -l ignore-embedded-fonts -d 'Ensures fonts embedded into Typst won\'t be considered'
complete -c typst -n "__fish_typst_using_subcommand query" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c typst -n "__fish_typst_using_subcommand fonts" -l font-path -d 'Adds additional directories that are recursively searched for fonts' -r -F
complete -c typst -n "__fish_typst_using_subcommand fonts" -l ignore-system-fonts -d 'Ensures system fonts won\'t be searched, unless explicitly included via `--font-path`'
complete -c typst -n "__fish_typst_using_subcommand fonts" -l ignore-embedded-fonts -d 'Ensures fonts embedded into Typst won\'t be considered'
complete -c typst -n "__fish_typst_using_subcommand fonts" -l variants -d 'Also lists style variants of each font family'
complete -c typst -n "__fish_typst_using_subcommand fonts" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c typst -n "__fish_typst_using_subcommand update" -l backup-path -d 'Custom path to the backup file created on update and used by `--revert`, defaults to system-dependent location' -r -F
complete -c typst -n "__fish_typst_using_subcommand update" -l force -d 'Forces a downgrade to an older version (required for downgrading)'
complete -c typst -n "__fish_typst_using_subcommand update" -l revert -d 'Reverts to the version from before the last update (only possible if `typst update` has previously ran)'
complete -c typst -n "__fish_typst_using_subcommand update" -s h -l help -d 'Print help'
complete -c typst -n "__fish_typst_using_subcommand completions" -s h -l help -d 'Print help'
complete -c typst -n "__fish_typst_using_subcommand info" -s f -l format -d 'The format to serialize in, if it should be machine-readable' -r -f -a "json\t''
yaml\t''"
complete -c typst -n "__fish_typst_using_subcommand info" -l pretty -d 'Whether to pretty-print the serialized output'
complete -c typst -n "__fish_typst_using_subcommand info" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c typst -n "__fish_typst_using_subcommand help; and not __fish_seen_subcommand_from compile watch init query fonts update completions info help" -f -a "compile" -d 'Compiles an input file into a supported output format'
complete -c typst -n "__fish_typst_using_subcommand help; and not __fish_seen_subcommand_from compile watch init query fonts update completions info help" -f -a "watch" -d 'Watches an input file and recompiles on changes'
complete -c typst -n "__fish_typst_using_subcommand help; and not __fish_seen_subcommand_from compile watch init query fonts update completions info help" -f -a "init" -d 'Initializes a new project from a template'
complete -c typst -n "__fish_typst_using_subcommand help; and not __fish_seen_subcommand_from compile watch init query fonts update completions info help" -f -a "query" -d 'Processes an input file to extract provided metadata'
complete -c typst -n "__fish_typst_using_subcommand help; and not __fish_seen_subcommand_from compile watch init query fonts update completions info help" -f -a "fonts" -d 'Lists all discovered fonts in system and custom font paths'
complete -c typst -n "__fish_typst_using_subcommand help; and not __fish_seen_subcommand_from compile watch init query fonts update completions info help" -f -a "update" -d 'Self update the Typst CLI'
complete -c typst -n "__fish_typst_using_subcommand help; and not __fish_seen_subcommand_from compile watch init query fonts update completions info help" -f -a "completions" -d 'Generates shell completion scripts'
complete -c typst -n "__fish_typst_using_subcommand help; and not __fish_seen_subcommand_from compile watch init query fonts update completions info help" -f -a "info" -d 'Displays debugging information about Typst'
complete -c typst -n "__fish_typst_using_subcommand help; and not __fish_seen_subcommand_from compile watch init query fonts update completions info help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'

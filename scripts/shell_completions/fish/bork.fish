# Completions for bork
# https://www.borkbackup.org/
# Note:
# Listing archives works on password protected repositories only if $BORK_PASSPHRASE is set.
# Install:
# Copy this file to /usr/share/fish/vendor_completions.d/

# Commands

complete -c bork -f -n __fish_is_first_token -a 'init' -d 'Initialize an empty repository'
complete -c bork -f -n __fish_is_first_token -a 'create' -d 'Create new archive'
complete -c bork -f -n __fish_is_first_token -a 'extract' -d 'Extract archive contents'
complete -c bork -f -n __fish_is_first_token -a 'check' -d 'Check repository consistency'
complete -c bork -f -n __fish_is_first_token -a 'rename' -d 'Rename an existing archive'
complete -c bork -f -n __fish_is_first_token -a 'list' -d 'List archive or repository contents'
complete -c bork -f -n __fish_is_first_token -a 'diff' -d 'Find differences between archives'
complete -c bork -f -n __fish_is_first_token -a 'delete' -d 'Delete a repository or archive'
complete -c bork -f -n __fish_is_first_token -a 'prune' -d 'Prune repository archives'
complete -c bork -f -n __fish_is_first_token -a 'compact' -d 'Free repository space'
complete -c bork -f -n __fish_is_first_token -a 'info' -d 'Show archive details'
complete -c bork -f -n __fish_is_first_token -a 'mount' -d 'Mount archive or a repository'
complete -c bork -f -n __fish_is_first_token -a 'umount' -d 'Un-mount the mounted archive'

function __fish_bork_seen_key
    if __fish_seen_subcommand_from key
        and not __fish_seen_subcommand_from import export change-passphrase
        return 0
    end
    return 1
end
complete -c bork -f -n __fish_is_first_token -a 'key' -d 'Manage a repository key'
complete -c bork -f -n __fish_bork_seen_key  -a 'import' -d 'Import a repository key'
complete -c bork -f -n __fish_bork_seen_key  -a 'export' -d 'Export a repository key'
complete -c bork -f -n __fish_bork_seen_key  -a 'change-passphrase' -d 'Change key file passphrase'

complete -c bork -f -n __fish_is_first_token -a 'serve' -d 'Start in server mode'
complete -c bork -f -n __fish_is_first_token -a 'upgrade' -d 'Upgrade a repository'
complete -c bork -f -n __fish_is_first_token -a 'recreate' -d 'Recreate contents of existing archives'
complete -c bork -f -n __fish_is_first_token -a 'export-tar' -d 'Create tarball from an archive'
complete -c bork -f -n __fish_is_first_token -a 'with-lock' -d 'Run a command while repository lock held'
complete -c bork -f -n __fish_is_first_token -a 'break-lock' -d 'Break the repository lock'
complete -c bork -f -n __fish_is_first_token -a 'config' -d 'Get/set options in repo/cache config'

function __fish_bork_seen_benchmark
    if __fish_seen_subcommand_from benchmark
        and not __fish_seen_subcommand_from crud
        return 0
    end
    return 1
end
complete -c bork -f -n __fish_is_first_token -a 'benchmark' -d 'Benchmark bork operations'
complete -c bork -f -n __fish_bork_seen_benchmark -a 'crud' -d 'Benchmark bork CRUD operations'

function __fish_bork_seen_help
    if __fish_seen_subcommand_from help
        and not __fish_seen_subcommand_from patterns placeholders compression
        return 0
    end
    return 1
end
complete -c bork -f -n __fish_is_first_token -a 'help' -d 'Miscellaneous Help'
complete -c bork -f -n __fish_bork_seen_help -a 'patterns' -d 'Help for patterns'
complete -c bork -f -n __fish_bork_seen_help -a 'placeholders' -d 'Help for placeholders'
complete -c bork -f -n __fish_bork_seen_help -a 'compression' -d 'Help for compression'

# Common options
complete -c bork -f -s h -l 'help'                  -d 'Show help information'
complete -c bork -f      -l 'version'               -d 'Show version information'
complete -c bork -f      -l 'critical'              -d 'Log level CRITICAL'
complete -c bork -f      -l 'error'                 -d 'Log level ERROR'
complete -c bork -f      -l 'warning'               -d 'Log level WARNING (default)'
complete -c bork -f      -l 'info'                  -d 'Log level INFO'
complete -c bork -f -s v -l 'verbose'               -d 'Log level INFO'
complete -c bork -f      -l 'debug'                 -d 'Log level DEBUG'
complete -c bork -f      -l 'debug-topic'           -d 'Enable TOPIC debugging'
complete -c bork -f -s p -l 'progress'              -d 'Show progress information'
complete -c bork -f      -l 'log-json'              -d 'Output one JSON object per log line'
complete -c bork -f      -l 'lock-wait'             -d 'Wait for lock max N seconds [1]'
complete -c bork -f      -l 'show-version'          -d 'Log version information'
complete -c bork -f      -l 'show-rc'               -d 'Log the return code'
complete -c bork -f      -l 'umask'                 -d 'Set umask to M [0077]'
complete -c bork         -l 'remote-path'           -d 'Use PATH as remote bork executable'
complete -c bork -f      -l 'remote-ratelimit'      -d 'Set remote network upload RATE limit'
complete -c bork -f      -l 'consider-part-files'   -d 'Treat part files like normal files'
complete -c bork         -l 'debug-profile'         -d 'Write execution profile into FILE'
complete -c bork         -l 'rsh'                   -d 'Use COMMAND instead of ssh'

# bork init options
set -l encryption_modes "none keyfile keyfile-blake2 repokey repokey-blake2 authenticated authenticated-blake2"
complete -c bork -f -s e -l 'encryption'            -d 'Encryption key MODE' -a "$encryption_modes" -n "__fish_seen_subcommand_from init"
complete -c bork -f      -l 'append-only'           -d 'Create an append-only mode repository'      -n "__fish_seen_subcommand_from init"
complete -c bork -f      -l 'storage-quota'         -d 'Set storage QUOTA of the repository'        -n "__fish_seen_subcommand_from init"
complete -c bork -f      -l 'make-parent-dirs'      -d 'Create parent directories'                  -n "__fish_seen_subcommand_from init"

# bork create options
complete -c bork -f -s n -l 'dry-run'               -d 'Do not change the repository'                   -n "__fish_seen_subcommand_from create"
complete -c bork -f -s s -l 'stats'                 -d 'Print verbose statistics'                       -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'list'                  -d 'Print verbose list of items'                    -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'filter'                -d 'Only items with given STATUSCHARS'              -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'json'                  -d 'Print verbose stats as json'                    -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'no-cache-sync'         -d 'Do not synchronize the cache'                   -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'stdin-name'            -d 'Use NAME in archive for stdin data'             -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'content-from-command'  -d 'Interpret PATH as command and store its stdout' -n "__fish_seen_subcommand_from create"
# Exclusion options
complete -c bork    -s e -l 'exclude'               -d 'Exclude paths matching PATTERN'                 -n "__fish_seen_subcommand_from create"
complete -c bork         -l 'exclude-from'          -d 'Read exclude patterns from EXCLUDEFILE'         -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'pattern'               -d 'Include/exclude paths matching PATTERN'         -n "__fish_seen_subcommand_from create"
complete -c bork         -l 'patterns-from'         -d 'Include/exclude paths from PATTERNFILE'         -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'exclude-caches'        -d 'Exclude directories tagged as cache'            -n "__fish_seen_subcommand_from create"
complete -c bork         -l 'exclude-if-present'    -d 'Exclude directories that contain FILENAME'      -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'keep-exclude-tags'     -d 'Keep tag files of excluded directories'         -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'keep-tag-files'        -d 'Keep tag files of excluded directories'         -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'exclude-nodump'        -d 'Exclude files flagged NODUMP'                   -n "__fish_seen_subcommand_from create"
# Filesystem options
complete -c bork -f -s x -l 'one-file-system'       -d 'Stay in the same file system'                   -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'numeric-owner'         -d 'Only store numeric user:group identifiers'      -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'noatime'               -d 'Do not store atime'                             -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'noctime'               -d 'Do not store ctime'                             -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'nobirthtime'           -d 'Do not store creation date'                     -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'nobsdflags'            -d 'Do not store bsdflags'                          -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'noacls'                -d 'Do not read and store ACLs into archive'        -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'noxattrs'              -d 'Do not read and store xattrs into archive'      -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'noflags'               -d 'Do not store flags'                             -n "__fish_seen_subcommand_from create"
set -l files_cache_mode "ctime,size,inode mtime,size,inode ctime,size mtime,size rechunk,ctime rechunk,mtime size disabled"
complete -c bork -f      -l 'files-cache'           -d 'Operate files cache in MODE' -a "$files_cache_mode" -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'read-special'          -d 'Open device files like regular files'           -n "__fish_seen_subcommand_from create"
# Archive options
complete -c bork -f      -l 'comment'               -d 'Add COMMENT to the archive'                     -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'timestamp'             -d 'Set creation TIME (yyyy-mm-ddThh:mm:ss)'        -n "__fish_seen_subcommand_from create"
complete -c bork         -l 'timestamp'             -d 'Set creation time by reference FILE'            -n "__fish_seen_subcommand_from create"
complete -c bork -f -s c -l 'checkpoint-interval'   -d 'Write checkpoint every N seconds [1800]'        -n "__fish_seen_subcommand_from create"
complete -c bork -f      -l 'chunker-params'        -d 'Chunker PARAMETERS [19,23,21,4095]'             -n "__fish_seen_subcommand_from create"
set -l compression_methods "none auto lz4 zstd,1 zstd,2 zstd,3 zstd,4 zstd,5 zstd,6 zstd,7 zstd,8 zstd,9 zstd,10 zstd,11 zstd,12 zstd,13 zstd,14 zstd,15 zstd,16 zstd,17 zstd,18 zstd,19 zstd,20 zstd,21 zstd,22 zlib,1 zlib,2 zlib,3 zlib,4 zlib,5 zlib,6 zlib,7 zlib,8 zlib,9 lzma,0 lzma,1 lzma,2 lzma,3 lzma,4 lzma,5 lzma,6 lzma,7 lzma,8 lzma,9"
complete -c bork -f -s C -l 'compression'           -d 'Select compression ALGORITHM,LEVEL [lz4]' -a "$compression_methods" -n "__fish_seen_subcommand_from create"

# bork extract options
complete -c bork -f      -l 'list'                  -d 'Print verbose list of items'                -n "__fish_seen_subcommand_from extract"
complete -c bork -f -s n -l 'dry-run'               -d 'Do not actually extract any files'          -n "__fish_seen_subcommand_from extract"
complete -c bork -f      -l 'numeric-owner'         -d 'Only obey numeric user:group identifiers'   -n "__fish_seen_subcommand_from extract"
complete -c bork -f      -l 'nobsdflags'            -d 'Do not extract/set bsdflags'                -n "__fish_seen_subcommand_from extract"
complete -c bork -f      -l 'noflags'               -d 'Do not extract/set flags'                   -n "__fish_seen_subcommand_from extract"
complete -c bork -f      -l 'noacls'                -d 'Do not extract/set ACLs'                    -n "__fish_seen_subcommand_from extract"
complete -c bork -f      -l 'noxattrs'              -d 'Do not extract/set xattrs'                  -n "__fish_seen_subcommand_from extract"
complete -c bork -f      -l 'stdout'                -d 'Write all extracted data to stdout'         -n "__fish_seen_subcommand_from extract"
complete -c bork -f      -l 'sparse'                -d 'Create holes in output sparse file'         -n "__fish_seen_subcommand_from extract"
# Exclusion options
complete -c bork    -s e -l 'exclude'               -d 'Exclude paths matching PATTERN'             -n "__fish_seen_subcommand_from extract"
complete -c bork         -l 'exclude-from'          -d 'Read exclude patterns from EXCLUDEFILE'     -n "__fish_seen_subcommand_from extract"
complete -c bork         -l 'pattern'               -d 'Include/exclude paths matching PATTERN'     -n "__fish_seen_subcommand_from extract"
complete -c bork         -l 'patterns-from'         -d 'Include/exclude paths from PATTERNFILE'     -n "__fish_seen_subcommand_from extract"
complete -c bork -f      -l 'strip-components'      -d 'Remove NUMBER of leading path elements'     -n "__fish_seen_subcommand_from extract"

# bork check options
complete -c bork -f      -l 'repository-only'       -d 'Only perform repository checks'             -n "__fish_seen_subcommand_from check"
complete -c bork -f      -l 'archives-only'         -d 'Only perform archives checks'               -n "__fish_seen_subcommand_from check"
complete -c bork -f      -l 'verify-data'           -d 'Cryptographic integrity verification'       -n "__fish_seen_subcommand_from check"
complete -c bork -f      -l 'repair'                -d 'Attempt to repair found inconsistencies'    -n "__fish_seen_subcommand_from check"
complete -c bork -f      -l 'save-space'            -d 'Work slower but using less space'           -n "__fish_seen_subcommand_from check"
complete -c bork -f      -l 'max-duration'          -d 'Partial repo check for max. SECONDS'        -n "__fish_seen_subcommand_from check"
# Archive filters
complete -c bork -f -s P -l 'prefix'                -d 'Only archive names starting with PREFIX'    -n "__fish_seen_subcommand_from check"
complete -c bork -f -s a -l 'glob-archives'         -d 'Only archive names matching GLOB'           -n "__fish_seen_subcommand_from check"
set -l sort_keys "timestamp name id"
complete -c bork -f      -l 'sort-by'               -d 'Sorting KEYS [timestamp]' -a "$sort_keys"   -n "__fish_seen_subcommand_from check"
complete -c bork -f      -l 'first'                 -d 'Only first N archives'                      -n "__fish_seen_subcommand_from check"
complete -c bork -f      -l 'last'                  -d 'Only last N archives'                       -n "__fish_seen_subcommand_from check"

# bork rename
# no specific options

# bork list options
complete -c bork -f      -l 'short'                 -d 'Only print file/directory names'            -n "__fish_seen_subcommand_from list"
complete -c bork -f      -l 'format'                -d 'Specify FORMAT for file listing'            -n "__fish_seen_subcommand_from list"
complete -c bork -f      -l 'json'                  -d 'List contents in json format'               -n "__fish_seen_subcommand_from list"
complete -c bork -f      -l 'json-lines'            -d 'List contents in json lines format'         -n "__fish_seen_subcommand_from list"
# Archive filters
complete -c bork -f -s P -l 'prefix'                -d 'Only archive names starting with PREFIX'    -n "__fish_seen_subcommand_from list"
complete -c bork -f -s a -l 'glob-archives'         -d 'Only archive names matching GLOB'           -n "__fish_seen_subcommand_from list"
complete -c bork -f      -l 'sort-by'               -d 'Sorting KEYS [timestamp]' -a "$sort_keys"   -n "__fish_seen_subcommand_from list"
complete -c bork -f      -l 'first'                 -d 'Only first N archives'                      -n "__fish_seen_subcommand_from list"
complete -c bork -f      -l 'last'                  -d 'Only last N archives'                       -n "__fish_seen_subcommand_from list"
# Exclusion options
complete -c bork    -s e -l 'exclude'               -d 'Exclude paths matching PATTERN'             -n "__fish_seen_subcommand_from list"
complete -c bork         -l 'exclude-from'          -d 'Read exclude patterns from EXCLUDEFILE'     -n "__fish_seen_subcommand_from list"
complete -c bork -f      -l 'pattern'               -d 'Include/exclude paths matching PATTERN'     -n "__fish_seen_subcommand_from list"
complete -c bork         -l 'patterns-from'         -d 'Include/exclude paths from PATTERNFILE'     -n "__fish_seen_subcommand_from list"

# bork diff options
complete -c bork -f      -l 'numeric-owner'         -d 'Only consider numeric user:group'           -n "__fish_seen_subcommand_from diff"
complete -c bork -f      -l 'same-chunker-params'   -d 'Override check of chunker parameters'       -n "__fish_seen_subcommand_from diff"
complete -c bork -f      -l 'sort'                  -d 'Sort the output lines by file path'         -n "__fish_seen_subcommand_from diff"
complete -c bork -f      -l 'json-lines'            -d 'Format output as JSON Lines'                -n "__fish_seen_subcommand_from diff"
# Exclusion options
complete -c bork    -s e -l 'exclude'               -d 'Exclude paths matching PATTERN'             -n "__fish_seen_subcommand_from diff"
complete -c bork         -l 'exclude-from'          -d 'Read exclude patterns from EXCLUDEFILE'     -n "__fish_seen_subcommand_from diff"
complete -c bork -f      -l 'pattern'               -d 'Include/exclude paths matching PATTERN'     -n "__fish_seen_subcommand_from diff"
complete -c bork         -l 'patterns-from'         -d 'Include/exclude paths from PATTERNFILE'     -n "__fish_seen_subcommand_from diff"

# bork delete options
complete -c bork -f -s n -l 'dry-run'               -d 'Do not change the repository'               -n "__fish_seen_subcommand_from delete"
complete -c bork -f -s s -l 'stats'                 -d 'Print verbose statistics'                   -n "__fish_seen_subcommand_from delete"
complete -c bork -f      -l 'cache-only'            -d "Delete only the local cache"                -n "__fish_seen_subcommand_from delete"
complete -c bork -f      -l 'force'                 -d 'Force deletion of corrupted archives'       -n "__fish_seen_subcommand_from delete"
complete -c bork -f      -l 'save-space'            -d 'Work slower but using less space'           -n "__fish_seen_subcommand_from delete"
# Archive filters
complete -c bork -f -s P -l 'prefix'                -d 'Only archive names starting with PREFIX'    -n "__fish_seen_subcommand_from delete"
complete -c bork -f -s a -l 'glob-archives'         -d 'Only archive names matching GLOB'           -n "__fish_seen_subcommand_from delete"
complete -c bork -f      -l 'sort-by'               -d 'Sorting KEYS [timestamp]' -a "$sort_keys"   -n "__fish_seen_subcommand_from delete"
complete -c bork -f      -l 'first'                 -d 'Only first N archives'                      -n "__fish_seen_subcommand_from delete"
complete -c bork -f      -l 'last'                  -d 'Only last N archives'                       -n "__fish_seen_subcommand_from delete"

# bork prune options
complete -c bork -f -s n -l 'dry-run'               -d 'Do not change the repository'               -n "__fish_seen_subcommand_from prune"
complete -c bork -f      -l 'force'                 -d 'Force pruning of corrupted archives'        -n "__fish_seen_subcommand_from prune"
complete -c bork -f -s s -l 'stats'                 -d 'Print verbose statistics'                   -n "__fish_seen_subcommand_from prune"
complete -c bork -f      -l 'list'                  -d 'Print verbose list of items'                -n "__fish_seen_subcommand_from prune"
complete -c bork -f      -l 'keep-within'           -d 'Keep archives within time INTERVAL'         -n "__fish_seen_subcommand_from prune"
complete -c bork -f      -l 'keep-last'             -d 'NUMBER of secondly archives to keep'        -n "__fish_seen_subcommand_from prune"
complete -c bork -f      -l 'keep-secondly'         -d 'NUMBER of secondly archives to keep'        -n "__fish_seen_subcommand_from prune"
complete -c bork -f      -l 'keep-minutely'         -d 'NUMBER of minutely archives to keep'        -n "__fish_seen_subcommand_from prune"
complete -c bork -f -s H -l 'keep-hourly'           -d 'NUMBER of hourly archives to keep'          -n "__fish_seen_subcommand_from prune"
complete -c bork -f -s d -l 'keep-daily'            -d 'NUMBER of daily archives to keep'           -n "__fish_seen_subcommand_from prune"
complete -c bork -f -s w -l 'keep-weekly'           -d 'NUMBER of weekly archives to keep'          -n "__fish_seen_subcommand_from prune"
complete -c bork -f -s m -l 'keep-monthly'          -d 'NUMBER of monthly archives to keep'         -n "__fish_seen_subcommand_from prune"
complete -c bork -f -s y -l 'keep-yearly'           -d 'NUMBER of yearly archives to keep'          -n "__fish_seen_subcommand_from prune"
complete -c bork -f      -l 'save-space'            -d 'Work slower but using less space'           -n "__fish_seen_subcommand_from prune"
# Archive filters
complete -c bork -f -s P -l 'prefix'                -d 'Only archive names starting with PREFIX'    -n "__fish_seen_subcommand_from prune"
complete -c bork -f -s a -l 'glob-archives'         -d 'Only archive names matching GLOB'           -n "__fish_seen_subcommand_from prune"

# bork compact options
complete -c bork -f -s n -l 'cleanup-commits'       -d 'Cleanup commit-only segment files'          -n "__fish_seen_subcommand_from compact"

# bork info options
complete -c bork -f      -l 'json'                  -d 'Format output in json format'               -n "__fish_seen_subcommand_from info"
# Archive filters
complete -c bork -f -s P -l 'prefix'                -d 'Only archive names starting with PREFIX'    -n "__fish_seen_subcommand_from info"
complete -c bork -f -s a -l 'glob-archives'         -d 'Only archive names matching GLOB'           -n "__fish_seen_subcommand_from info"
complete -c bork -f      -l 'sort-by'               -d 'Sorting KEYS [timestamp]' -a "$sort_keys"   -n "__fish_seen_subcommand_from info"
complete -c bork -f      -l 'first'                 -d 'Only first N archives'                      -n "__fish_seen_subcommand_from info"
complete -c bork -f      -l 'last'                  -d 'Only last N archives'                       -n "__fish_seen_subcommand_from info"

# bork mount options
complete -c bork -f -s f -l 'foreground'            -d 'Stay in foreground, do not daemonize'       -n "__fish_seen_subcommand_from mount"
# FIXME This list is probably not full, but I tried to pick only those that are relevant to bork mount -o:
set -l fuse_options "ac_attr_timeout= allow_damaged_files allow_other allow_root attr_timeout= auto auto_cache auto_unmount default_permissions entry_timeout= gid= group_id= kernel_cache max_read= negative_timeout= noauto noforget remember= remount rootmode= uid= umask= user user_id= versions"
complete -c bork -f -s o                            -d 'Fuse mount OPTION' -a "$fuse_options"       -n "__fish_seen_subcommand_from mount"
# Archive filters
complete -c bork -f -s P -l 'prefix'                -d 'Only archive names starting with PREFIX'    -n "__fish_seen_subcommand_from mount"
complete -c bork -f -s a -l 'glob-archives'         -d 'Only archive names matching GLOB'           -n "__fish_seen_subcommand_from mount"
complete -c bork -f      -l 'sort-by'               -d 'Sorting KEYS [timestamp]' -a "$sort_keys"   -n "__fish_seen_subcommand_from mount"
complete -c bork -f      -l 'first'                 -d 'Only first N archives'                      -n "__fish_seen_subcommand_from mount"
complete -c bork -f      -l 'last'                  -d 'Only last N archives'                       -n "__fish_seen_subcommand_from mount"
# Exclusion options
complete -c bork    -s e -l 'exclude'               -d 'Exclude paths matching PATTERN'             -n "__fish_seen_subcommand_from mount"
complete -c bork         -l 'exclude-from'          -d 'Read exclude patterns from EXCLUDEFILE'     -n "__fish_seen_subcommand_from mount"
complete -c bork -f      -l 'pattern'               -d 'Include/exclude paths matching PATTERN'     -n "__fish_seen_subcommand_from mount"
complete -c bork         -l 'patterns-from'         -d 'Include/exclude paths from PATTERNFILE'     -n "__fish_seen_subcommand_from mount"
complete -c bork -f      -l 'strip-components'      -d 'Remove NUMBER of leading path elements'     -n "__fish_seen_subcommand_from mount"

# bork umount
# no specific options

# bork key change-passphrase
# no specific options

# bork key export
complete -c bork -f      -l 'paper'                 -d 'Create an export for printing'              -n "__fish_seen_subcommand_from export"
complete -c bork -f      -l 'qr-html'               -d 'Create an html file for printing and qr'    -n "__fish_seen_subcommand_from export"

# bork key import
complete -c bork -f      -l 'paper'                 -d 'Import from a backup done with --paper'     -n "__fish_seen_subcommand_from import"

# bork upgrade
complete -c bork -f -s n -l 'dry-run'               -d 'Do not change the repository'               -n "__fish_seen_subcommand_from upgrade"
complete -c bork -f      -l 'inplace'               -d 'Rewrite repository in place'                -n "__fish_seen_subcommand_from upgrade"
complete -c bork -f      -l 'force'                 -d 'Force upgrade'                              -n "__fish_seen_subcommand_from upgrade"
complete -c bork -f      -l 'tam'                   -d 'Enable manifest authentication'             -n "__fish_seen_subcommand_from upgrade"
complete -c bork -f      -l 'disable-tam'           -d 'Disable manifest authentication'            -n "__fish_seen_subcommand_from upgrade"

# bork recreate
complete -c bork -f      -l 'list'                  -d 'Print verbose list of items'                -n "__fish_seen_subcommand_from recreate"
complete -c bork -f      -l 'filter'                -d 'Only items with given STATUSCHARS'          -n "__fish_seen_subcommand_from recreate"
complete -c bork -f -s n -l 'dry-run'               -d 'Do not change the repository'               -n "__fish_seen_subcommand_from recreate"
complete -c bork -f -s s -l 'stats'                 -d 'Print verbose statistics'                   -n "__fish_seen_subcommand_from recreate"
# Exclusion options
complete -c bork    -s e -l 'exclude'               -d 'Exclude paths matching PATTERN'             -n "__fish_seen_subcommand_from recreate"
complete -c bork         -l 'exclude-from'          -d 'Read exclude patterns from EXCLUDEFILE'     -n "__fish_seen_subcommand_from recreate"
complete -c bork -f      -l 'pattern'               -d 'Include/exclude paths matching PATTERN'     -n "__fish_seen_subcommand_from recreate"
complete -c bork         -l 'patterns-from'         -d 'Include/exclude paths from PATTERNFILE'     -n "__fish_seen_subcommand_from recreate"
complete -c bork -f      -l 'exclude-caches'        -d 'Exclude directories tagged as cache'        -n "__fish_seen_subcommand_from recreate"
complete -c bork         -l 'exclude-if-present'    -d 'Exclude directories that contain FILENAME'  -n "__fish_seen_subcommand_from recreate"
complete -c bork -f      -l 'keep-exclude-tags'     -d 'Keep tag files of excluded directories'     -n "__fish_seen_subcommand_from recreate"
# Archive options
complete -c bork -f      -l 'target'                -d "Create a new ARCHIVE"                       -n "__fish_seen_subcommand_from recreate"
complete -c bork -f -s c -l 'checkpoint-interval'   -d 'Write checkpoint every N seconds [1800]'    -n "__fish_seen_subcommand_from recreate"
complete -c bork -f      -l 'comment'               -d 'Add COMMENT to the archive'                 -n "__fish_seen_subcommand_from recreate"
complete -c bork -f      -l 'timestamp'             -d 'Set creation TIME (yyyy-mm-ddThh:mm:ss)'    -n "__fish_seen_subcommand_from recreate"
complete -c bork         -l 'timestamp'             -d 'Set creation time using reference FILE'     -n "__fish_seen_subcommand_from recreate"
complete -c bork -f -s C -l 'compression'           -d 'Select compression ALGORITHM,LEVEL [lz4]' -a "$compression_methods" -n "__fish_seen_subcommand_from recreate"
set -l recompress_when "if-different always never"
complete -c bork -f      -l 'recompress'            -d 'Recompress chunks CONDITION' -a "$recompress_when" -n "__fish_seen_subcommand_from recreate"
complete -c bork -f      -l 'chunker-params'        -d 'Chunker PARAMETERS [19,23,21,4095]'         -n "__fish_seen_subcommand_from recreate"

# bork export-tar options
complete -c bork         -l 'tar-filter'            -d 'Filter program to pipe data through'        -n "__fish_seen_subcommand_from export-tar"
complete -c bork -f      -l 'list'                  -d 'Print verbose list of items'                -n "__fish_seen_subcommand_from export-tar"
# Exclusion options
complete -c bork    -s e -l 'exclude'               -d 'Exclude paths matching PATTERN'             -n "__fish_seen_subcommand_from recreate"
complete -c bork         -l 'exclude-from'          -d 'Read exclude patterns from EXCLUDEFILE'     -n "__fish_seen_subcommand_from recreate"
complete -c bork -f      -l 'pattern'               -d 'Include/exclude paths matching PATTERN'     -n "__fish_seen_subcommand_from recreate"
complete -c bork         -l 'patterns-from'         -d 'Include/exclude paths from PATTERNFILE'     -n "__fish_seen_subcommand_from recreate"
complete -c bork -f      -l 'strip-components'      -d 'Remove NUMBER of leading path elements'     -n "__fish_seen_subcommand_from recreate"

# bork serve
complete -c bork         -l 'restrict-to-path'      -d 'Restrict repository access to PATH'         -n "__fish_seen_subcommand_from serve"
complete -c bork         -l 'restrict-to-repository' -d 'Restrict repository access at PATH'        -n "__fish_seen_subcommand_from serve"
complete -c bork -f      -l 'append-only'           -d 'Only allow appending to repository'         -n "__fish_seen_subcommand_from serve"
complete -c bork -f      -l 'storage-quota'         -d 'Override storage QUOTA of the repository'   -n "__fish_seen_subcommand_from serve"

# bork config
complete -c bork -f -s c -l 'cache'                 -d 'Get/set/list values in the repo cache'      -n "__fish_seen_subcommand_from config"
complete -c bork -f -s d -l 'delete'                -d 'Delete the KEY from the config'             -n "__fish_seen_subcommand_from config"
complete -c bork -f      -l 'list'                  -d 'List the configuration of the repo'         -n "__fish_seen_subcommand_from config"

# bork with-lock
# no specific options

# bork break-lock
# no specific options

# bork benchmark
# no specific options

# bork help
# no specific options


# List repositories::archives

function __fish_bork_is_argument_n --description 'Test if current argument is on Nth place' --argument n
    set tokens (commandline --current-process --tokenize --cut-at-cursor)
    set -l tokencount 0
    for token in $tokens
        switch $token
            case '-*'
                # ignore command line switches
            case '*'
                set tokencount (math $tokencount+1)
        end
    end
    return (test $tokencount -eq $n)
end

function __fish_bork_is_dir_a_repository
    set -l config_content
    if test -f $argv[1]/README
    and test -f $argv[1]/config
        read config_content < $argv[1]/config 2>/dev/null
    end
    return (string match --quiet '[repository]' $config_content)
end

function __fish_bork_list_repos_or_archives
    if string match --quiet --regex '.*::' '"'(commandline --current-token)'"'
        # If the current token contains "::" then list the archives:
        set -l repository_name (string replace --regex '::.*' '' (commandline --current-token))
        bork list --format="$repository_name::{archive}{TAB}{comment}{NEWLINE}" "$repository_name" 2>/dev/null
    else
        # Otherwise list the repositories, directories and user@host entries:
        set -l directories (commandline --cut-at-cursor --current-token)*/
        for directoryname in $directories
            if __fish_bork_is_dir_a_repository $directoryname
                printf '%s::\t%s\n' (string trim --right --chars='/' $directoryname) "Repository"
            else
                printf '%s\n' $directoryname
            end
        end
        __fish_complete_user_at_hosts | string replace --regex '$' ':'
    end
end

complete -c bork -f -n "__fish_bork_is_argument_n 2" -a '(__fish_bork_list_repos_or_archives)'


# Additional archive listings

function __fish_bork_is_diff_second_archive
    return (string match --quiet --regex ' diff .*::[^ ]+ '(commandline --current-token)'$' (commandline))
end

function __fish_bork_is_delete_additional_archive
    return (string match --quiet --regex ' delete .*::[^ ]+ ' (commandline))
end

function __fish_bork_list_only_archives
    set -l repo_matches (string match --regex '([^ ]*)::' (commandline))
    bork list --format="{archive}{TAB}{comment}{NEWLINE}" "$repo_matches[2]" 2>/dev/null
end

complete -c bork -f -n __fish_bork_is_diff_second_archive -a '(__fish_bork_list_only_archives)'
complete -c bork -f -n __fish_bork_is_delete_additional_archive -a '(__fish_bork_list_only_archives)'

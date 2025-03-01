import argparse
import textwrap
import json
import sys
import os

from ._common import with_repository, with_archive, build_matcher, Highlander
from ..archive import Archive
from ..constants import *  # NOQA
from ..helpers import BaseFormatter, DiffFormatter, archivename_validator, BorkJsonEncoder
from ..manifest import Manifest
from ..logger import create_logger

logger = create_logger()


class DiffMixIn:
    @with_repository(compatibility=(Manifest.Operation.READ,))
    @with_archive
    def do_diff(self, args, repository, manifest, archive):
        """Diff contents of two archives"""
        if args.format is not None:
            format = args.format
        elif args.content_only:
            format = "{content}{link}{directory}{blkdev}{chrdev}{fifo} {path}{NL}"
        else:
            format = os.environ.get("BORK_DIFF_FORMAT", "{change} {path}{NL}")

        archive1 = archive
        archive2 = Archive(manifest, args.other_name)

        can_compare_chunk_ids = (
            archive1.metadata.get("chunker_params", False) == archive2.metadata.get("chunker_params", True)
            or args.same_chunker_params
        )
        if not can_compare_chunk_ids:
            self.print_warning(
                "--chunker-params might be different between archives, diff will be slow.\n"
                "If you know for certain that they are the same, pass --same-chunker-params "
                "to override this check."
            )

        matcher = build_matcher(args.patterns, args.paths)

        diffs_iter = Archive.compare_archives_iter(
            archive1, archive2, matcher, can_compare_chunk_ids=can_compare_chunk_ids
        )
        # Conversion to string and filtering for diff.equal to save memory if sorting
        diffs = (diff for diff in diffs_iter if not diff.equal(args.content_only))

        if args.sort:
            diffs = sorted(diffs, key=lambda diff: diff.path)

        formatter = DiffFormatter(format, args.content_only)
        for diff in diffs:
            if args.json_lines:
                print(
                    json.dumps(
                        {
                            "path": diff.path,
                            "changes": [
                                change.to_dict()
                                for name, change in diff.changes().items()
                                if not args.content_only or (name not in DiffFormatter.METADATA)
                            ],
                        },
                        sort_keys=True,
                        cls=BorkJsonEncoder,
                    )
                )
            else:
                res: str = formatter.format_item(diff)
                if res.strip():
                    sys.stdout.write(res)

        for pattern in matcher.get_unmatched_include_patterns():
            self.print_warning("Include pattern '%s' never matched.", pattern)

        return self.exit_code

    def build_parser_diff(self, subparsers, common_parser, mid_common_parser):
        from ._common import process_epilog
        from ._common import define_exclusion_group

        diff_epilog = (
            process_epilog(
                """
        This command finds differences (file contents, metadata) between ARCHIVE1 and ARCHIVE2.

        For more help on include/exclude patterns, see the :ref:`bork_patterns` command output.

        .. man NOTES

        The FORMAT specifier syntax
        +++++++++++++++++++++++++++

        The ``--format`` option uses python's `format string syntax
        <https://docs.python.org/3.9/library/string.html#formatstrings>`_.

        Examples:
        ::

            $ bork diff --format '{content:30} {path}{NL}' ArchiveFoo ArchiveBar
            modified:  +4.1 kB  -1.0 kB    file-diff
            ...

            # {VAR:<NUMBER} - pad to NUMBER columns left-aligned.
            # {VAR:>NUMBER} - pad to NUMBER columns right-aligned.
            $ bork diff --format '{content:>30} {path}{NL}' ArchiveFoo ArchiveBar
               modified:  +4.1 kB  -1.0 kB file-diff
            ...

        The following keys are always available:


        """
            )
            + BaseFormatter.keys_help()
            + textwrap.dedent(
                """

        Keys available only when showing differences between archives:

        """
            )
            + DiffFormatter.keys_help()
        )
        subparser = subparsers.add_parser(
            "diff",
            parents=[common_parser],
            add_help=False,
            description=self.do_diff.__doc__,
            epilog=diff_epilog,
            formatter_class=argparse.RawDescriptionHelpFormatter,
            help="find differences in archive contents",
        )
        subparser.set_defaults(func=self.do_diff)
        subparser.add_argument(
            "--numeric-ids",
            dest="numeric_ids",
            action="store_true",
            help="only consider numeric user and group identifiers",
        )
        subparser.add_argument(
            "--same-chunker-params",
            dest="same_chunker_params",
            action="store_true",
            help="Override check of chunker parameters.",
        )
        subparser.add_argument("--sort", dest="sort", action="store_true", help="Sort the output lines by file path.")
        subparser.add_argument(
            "--format",
            metavar="FORMAT",
            dest="format",
            action=Highlander,
            help='specify format for differences between archives (default: "{change} {path}{NL}")',
        )
        subparser.add_argument("--json-lines", action="store_true", help="Format output as JSON Lines. ")
        subparser.add_argument(
            "--content-only",
            action="store_true",
            help="Only compare differences in content (exclude metadata differences)",
        )
        subparser.add_argument("name", metavar="ARCHIVE1", type=archivename_validator, help="ARCHIVE1 name")
        subparser.add_argument("other_name", metavar="ARCHIVE2", type=archivename_validator, help="ARCHIVE2 name")
        subparser.add_argument(
            "paths",
            metavar="PATH",
            nargs="*",
            type=str,
            help="paths of items inside the archives to compare; patterns are supported",
        )
        define_exclusion_group(subparser)

.. include:: global.rst.inc
.. highlight:: bash
.. _development:

Development
===========

This chapter will get you started with Bork development.

Bork is written in Python (with a little bit of Cython and C for
the performance critical parts).

Contributions
-------------

... are welcome!

Some guidance for contributors:

- Discuss changes on the GitHub issue tracker, on IRC or on the mailing list.

- Make your PRs on the ``master`` branch (see `Branching Model`_ for details).

- Do clean changesets:

  - Focus on some topic, resist changing anything else.
  - Do not do style changes mixed with functional changes.
  - Try to avoid refactorings mixed with functional changes.
  - If you need to fix something after commit/push:

    - If there are ongoing reviews: do a fixup commit you can
      squash into the bad commit later.
    - If there are no ongoing reviews or you did not push the
      bad commit yet: amend the commit to include your fix or
      merge the fixup commit before pushing.
  - Have a nice, clear, typo-free commit comment.
  - If you fixed an issue, refer to it in your commit comment.
  - Follow the style guide (see below).

- If you write new code, please add tests and docs for it.

- Run the tests, fix any issues that come up.

- Make a pull request on GitHub.

- Wait for review by other developers.

Branching model
---------------

Bork development happens on the ``master`` branch and uses GitHub pull
requests (if you don't have GitHub or don't want to use it you can
send smaller patches via the borkbackup mailing list to the maintainers).

Stable releases are maintained on maintenance branches named ``x.y-maint``, eg.
the maintenance branch of the 1.2.x series is ``1.2-maint``.

Most PRs should be filed against the ``master`` branch. Only if an
issue affects **only** a particular maintenance branch a PR should be
filed against it directly.

While discussing / reviewing a PR it will be decided whether the
change should be applied to maintenance branches. Each maintenance
branch has a corresponding *backport/x.y-maint* label, which will then
be applied.

Changes that are typically considered for backporting:

- Data loss, corruption and inaccessibility fixes.
- Security fixes.
- Forward-compatibility improvements.
- Documentation corrections.

.. rubric:: Maintainer part

From time to time a maintainer will backport the changes for a
maintenance branch, typically before a release or if enough changes
were collected:

1. Notify others that you're doing this to avoid duplicate work.
2. Branch a backporting branch off the maintenance branch.
3. Cherry pick and backport the changes from each labelled PR, remove
   the label for each PR you've backported.

   To preserve authorship metadata, do not follow the ``git cherry-pick``
   instructions to use ``git commit`` after resolving conflicts. Instead,
   stage conflict resolutions and run ``git cherry-pick --continue``,
   much like using ``git rebase``.

   To avoid merge issues (a cherry pick is a form of merge), use
   these options (similar to the ``git merge`` options used previously,
   the ``-x`` option adds a reference to the original commit)::

     git cherry-pick --strategy recursive -X rename-threshold=5% -x

4. Make a PR of the backporting branch against the maintenance branch
   for backport review. Mention the backported PRs in this PR, e.g.:

       Includes changes from #2055 #2057 #2381

   This way GitHub will automatically show in these PRs where they
   were backported.

.. rubric:: Historic model

Previously (until release 1.0.10) Bork used a `"merge upwards"
<https://git-scm.com/docs/gitworkflows#_merging_upwards>`_ model where
most minor changes and fixes where committed to a maintenance branch
(eg. 1.0-maint), and the maintenance branch(es) were regularly merged
back into the main development branch. This became more and more
troublesome due to merges growing more conflict-heavy and error-prone.

Code and issues
---------------

Code is stored on GitHub, in the `Borkbackup organization
<https://github.com/furikuda/bork/>`_. `Issues
<https://github.com/furikuda/bork/issues>`_ and `pull requests
<https://github.com/furikuda/bork/pulls>`_ should be sent there as
well. See also the :ref:`support` section for more details.

Style guide / Automated Code Formatting
---------------------------------------

We use `black`_ for automatically formatting the code.

If you work on the code, it is recommended that you run black **before each commit**
(so that new code is always using the desired formatting and no additional commits
are required to fix the formatting).

::

    pip install -r requirements.d/codestyle.txt     # everybody use same black version
    black --check .                                 # only check, don't change
    black .                                         # reformat the code


The CI workflows will check the code formatting and will fail if it is not formatted correctly.

When (mass-)reformatting existing code, we need to avoid ruining `git blame`, so please
follow their `guide about avoiding ruining git blame`_:

.. _black: https://black.readthedocs.io/
.. _guide about avoiding ruining git blame: https://black.readthedocs.io/en/stable/guides/introducing_black_to_your_project.html#avoiding-ruining-git-blame

Continuous Integration
----------------------

All pull requests go through `GitHub Actions`_, which runs the tests on misc.
Python versions and on misc. platforms as well as some additional checks.

.. _GitHub Actions: https://github.com/borkbackup/bork/actions

Output and Logging
------------------
When writing logger calls, always use correct log level (debug only for
debugging, info for informative messages, warning for warnings, error for
errors, critical for critical errors/states).

When directly talking to the user (e.g. Y/N questions), do not use logging,
but directly output to stderr (not: stdout, it could be connected to a pipe).

To control the amount and kinds of messages output emitted at info level, use
flags like ``--stats`` or ``--list``, then create a topic logger for messages
controlled by that flag.  See ``_setup_implied_logging()`` in
``bork/archiver.py`` for the entry point to topic logging.

Building a development environment
----------------------------------

First, just install bork into a virtual env :ref:`as described before <git-installation>`.

To install some additional packages needed for running the tests, activate your
virtual env and run::

  pip install -r requirements.d/development.txt


This project utilizes pre-commit to format and lint code before it is committed.
Although pre-commit is installed when running the command above, the pre-commit hooks
will have to be installed separately. Run this command to install the pre-commit hooks::

  pre-commit install


Running the tests
-----------------

The tests are in the bork/testsuite package.

To run all the tests, you need to have fakeroot installed. If you do not have
fakeroot, you still will be able to run most tests, just leave away the
`fakeroot -u` from the given command lines.

To run the test suite use the following command::

  fakeroot -u tox  # run all tests

Some more advanced examples::

  # verify a changed tox.ini (run this after any change to tox.ini):
  fakeroot -u tox --recreate

  fakeroot -u tox -e py39  # run all tests, but only on python 3.9

  fakeroot -u tox bork.testsuite.locking  # only run 1 test module

  fakeroot -u tox bork.testsuite.locking -- -k '"not Timer"'  # exclude some tests

  fakeroot -u tox bork.testsuite -- -v  # verbose py.test

Important notes:

- When using ``--`` to give options to py.test, you MUST also give ``bork.testsuite[.module]``.


Adding a compression algorithm
------------------------------

If you want to add a new compression algorithm, please refer to :issue:`1633`
and leave a post there in order to discuss about the proposal.

Documentation
-------------

Generated files
~~~~~~~~~~~~~~~

Usage documentation (found in ``docs/usage/``) and man pages
(``docs/man/``) are generated automatically from the command line
parsers declared in the program and their documentation, which is
embedded in the program (see archiver.py). These are committed to git
for easier use by packagers downstream.

When a command is added, a command line flag changed, added or removed,
the usage docs need to be rebuilt as well::

  python setup.py build_usage
  python setup.py build_man

However, we prefer to do this as part of our :ref:`releasing`
preparations, so it is generally not necessary to update these when
submitting patches that change something about the command line.

Building the docs with Sphinx
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The documentation (in reStructuredText format, .rst) is in docs/.

To build the html version of it, you need to have Sphinx installed
(in your Bork virtualenv with Python 3)::

  pip install -r requirements.d/docs.txt

Now run::

  cd docs/
  make html

Then point a web browser at docs/_build/html/index.html.

The website is updated automatically by ReadTheDocs through GitHub web hooks on the
main repository.

Using Vagrant
-------------

We use Vagrant for the automated creation of testing environments and borkbackup
standalone binaries for various platforms.

For better security, there is no automatic sync in the VM to host direction.
The plugin `vagrant-scp` is useful to copy stuff from the VMs to the host.

The "windows10" box requires the `reload` plugin (``vagrant plugin install vagrant-reload``).

Usage::

   # To create and provision the VM:
   vagrant up OS
   # same, but use 6 VM cpus and 12 workers for pytest:
   VMCPUS=6 XDISTN=12 vagrant up OS
   # To create an ssh session to the VM:
   vagrant ssh OS
   # To execute a command via ssh in the VM:
   vagrant ssh OS -c "command args"
   # To shut down the VM:
   vagrant halt OS
   # To shut down and destroy the VM:
   vagrant destroy OS
   # To copy files from the VM (in this case, the generated binary):
   vagrant scp OS:/vagrant/bork/bork.exe .


Creating standalone binaries
----------------------------

Make sure you have everything built and installed (including fuse stuff).
When using the Vagrant VMs, pyinstaller will already be installed.

With virtual env activated::

  pip install pyinstaller  # or git checkout master
  pyinstaller -F -n bork-PLATFORM bork/__main__.py
  for file in dist/bork-*; do gpg --armor --detach-sign $file; done

If you encounter issues, see also our `Vagrantfile` for details.

.. note:: Standalone binaries built with pyinstaller are supposed to
          work on same OS, same architecture (x86 32bit, amd64 64bit)
          without external dependencies.


.. _releasing:

Creating a new release
----------------------

Checklist:

- Make sure all issues for this milestone are closed or moved to the
  next milestone.
- Check if there are any pending fixes for security issues.
- Find and fix any low hanging fruit left on the issue tracker.
- Check that GitHub Actions CI is happy.
- Update ``CHANGES.rst``, based on ``git log $PREVIOUS_RELEASE..``.
- Check version number of upcoming release in ``CHANGES.rst``.
- Render ``CHANGES.rst`` via ``make html`` and check for markup errors.
- Verify that ``MANIFEST.in`` and ``setup.py`` are complete.
- ``python setup.py build_usage ; python setup.py build_man`` and commit.
- Tag the release::

    git tag -s -m "tagged/signed release X.Y.Z" X.Y.Z

- Create a clean repo and use it for the following steps::

    git clone bork bork-clean

  This makes sure no uncommitted files get into the release archive.
  It will also reveal uncommitted required files.
  Moreover, it makes sure the vagrant machines only get committed files and
  do a fresh start based on that.
- Run tox and/or binary builds on all supported platforms via vagrant,
  check for test failures.
- Create sdist, sign it, upload release to (test) PyPi:

  ::

    scripts/sdist-sign X.Y.Z
    scripts/upload-pypi X.Y.Z test
    scripts/upload-pypi X.Y.Z

  Note: the signature is not uploaded to PyPi any more, but we upload it to
  github releases.
- Put binaries into dist/bork-OSNAME and sign them:

  ::

    scripts/sign-binaries 201912312359

- Close the release milestone on GitHub.
- `Update borkbackup.org
  <https://github.com/furikuda/borkbackup.github.io/pull/53/files>`_ with the
  new version number and release date.
- Announce on:

 - Mailing list.
 - Twitter.
 - IRC channel (change ``/topic``).

- Create a GitHub release, include:

  * pypi dist package and signature
  * Standalone binaries (see above for how to create them).

    + For macOS, document the macFUSE version in the README of the binaries.
      macFUSE uses a kernel extension that needs to be compatible with the
      code contained in the binary.
  * A link to ``CHANGES.rst``.

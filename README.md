# linux-builds

These directories track how individual pieces of software were configured and
deployed to their locations in /ad/eng/opt/ on the BU Engineering Grid, mainly
for reference.

The usual workflow is:

 1. Build and install a package
 2. Fix any hardcoded paths as needed (see `eng-fix-install-paths`)
 3. Add any needed symlinks in /ad/eng/bin/ (and 32/ and/or 64/ when needed)
 4. Add a [shell module] at /ad/eng/etc/modulefiles/
 5. Add test cases to [grid-tests] repo
 6. Document on [Grid/Software] page

The build scripts can be run from any grid node with the necessary `-devel`
packages installed.  `qlogin` works, but for long builds it's helpful to add
the `qsub` directives to the build script and submit it as a batch job instead.
(Then run `make install` or equivalent manually to write to the kerberized
install path.)

See the [EXAMPLE.md](EXAMPLE.md) file for a full example.

[shell module]: https://github.com/eng-it/modulefiles
[grid-tests]: https://github.com/eng-it/grid-tests
[Grid/Software]: http://collaborate.bu.edu/engit/Grid/Software

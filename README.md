# linux-builds

These directories track how individual pieces of software were configured and
deployed to their locations in /ad/eng/opt/ on the BU Engineering Grid, mainly
for reference.

The usual workflow is:

 1. Build and install a package
 2. Add any needed symlinks in /ad/eng/bin/ (and 32/ and/or 64/ when needed)
 3. Add a [shell module] at /ad/eng/etc/modulefiles/
 4. Add test cases to [grid-tests] repo
 5. Document on [Grid/Software] page

[shell module]: https://github.com/eng-it/modulefiles
[grid-tests]: https://github.com/eng-it/grid-tests
[Grid/Software]: http://collaborate.bu.edu/engit/Grid/Software

# Example Linux Build Process

Here we will set up an installation of
[libctl](http://ab-initio.mit.edu/wiki/index.php/Libctl).  The steps will
follow the list given in [README.md](README.md).  This assumes you are logged
into engineering-grid1 or 2 and sitting in `/mnt/nokrb/$USER/linux-builds`.
The tasks below that refer to `opt/64` and `bin/64` would just be `bin` and
`opt` for packages that don't contain compiled code or that handle multiple
architectures internally.

## Build and Install the Package

Make a directory for libctl and copy over the skeleton build script:

    mkdir libctl
    cp build-skel.sh libctl/build.sh

Then, edit build.sh to specify `APP_NAME` in the beginning, and everything
marked by `TODO`.  Specifically, these lines:

    # name to use when compiling as a grid job
    #$ -N build-libctl
    # program version
    VER=3.2.2
    # install prefix
    PREFIX="$ENGOPT/64/libctl-${VER}"
    # install command
    configure_make_install "http://ab-initio.mit.edu/libctl/libctl-${VER}.tar.gz"

The `common.sh` script sourced by this build script provides a bunch of
functions for common things like downloading packages, decompressing archives,
and runing `configure` and `make`.  This makes most of the build scripts very
simple.

Now, run the build script.  When written in this way it will submit a grid job
to do the compilation.  It won't be able to finish the build and do the install
itself since that needs kerberos permissions, though.  We can just run `make
install` manually at the end.  This isn't such a big help for simple programs,
but for ones that take a long time to build, running it as a grid job can be
useful.  If you'd rather just build it directly, run `qlogin` first to get to a
grid node and then run `build.sh` with bash.

`configure_make_install` will do the usual `./configure; make; make install`,
with some output redirection to log files.  You can watch the logs for progress
as the commands run.

Looking at the end of `configure_libctl.log`, we see:

    checking if linking to guile works... no
    configure: error: Guile could not be found
    make: *** No targets specified and no makefile found.  Stop.
    make: *** No rule to make target 'install'.  Stop.

Oops, looks like libctl requires guile, but it isn't installed.  It actually
requires the -devel package since it's compiling from source here.  We can push
that out to the nodes being used for compilation with `ansible budge -m yum -a
name=guile-devel`.  Since guile itself will be required too, we should add
`guile` to the package list in the `software-scitech` role in [ansible] and push
out the package update to all nodes using that role.

After that, re-run `./build.sh` and note that there are no errors in the
configure log this time.

But wait!  Now there are errors in the `make` log.  Something about missing
references to math functions, like `undefined reference to symbol
'atan2@@GLIBC_2.2.5'`.  If I trace down those gcc commands and manually append
`-lm` (for the math library), and then re-run the build script, it works!
Mysterious.

Finding a solution was helped by these pages:

 * <http://stackoverflow.com/questions/19901934/strange-linking-error-dso-missing-from-command-line#39211166>
 * <http://stackoverflow.com/questions/23809404/issue-with-simple-makefile-undefined-reference-to-symbol-cosglibc-2-2-5#23809470>

The completed build script is:

    #!/usr/bin/env qsub
    #$ -cwd
    #$ -N build-libctl
    #$ -l s_vmem=4G
    #$ -q budge.q
    #$ -j y
    
    # http://ab-initio.mit.edu/wiki/index.php/Libctl
    
    # Don't let common.sh use script path, since for batch job the script is
    # copied to another location.  We want paths relative to this directory.
    WD="$PWD"
    source "$PWD/../common.sh"
    
    VER=3.2.2
    PREFIX="$ENGOPT/64/libctl-${VER}"
    
    if [[ ! $0 == "-bash" ]]
    then
    	# why isn't the math library included by default?
    	export LIBS=-lm
    	configure_make_install libctl "http://ab-initio.mit.edu/libctl/libctl-${VER}.tar.gz"
    fi


Finally, run `make install` to copy all the compiled files over to the
installation directory.  Now we should see this directory appear:

    /ad/eng/opt/64/libctl-3.2.2/

Once everything looks good, add the build script to the repository:

    rm -rf libctl/build-libctl.o* libctl/libctl-3.2.2/
    git add libctl/build.sh
    git commit -m libctl/3.2.2
    → [master a875b37] libctl/3.2.2
    →  1 files changed, 23 insertions(+), 0 deletions(-)
    →  create mode 100755 libctl/build.sh
    git push
    → Counting objects: 5, done.
    → Delta compression using up to 4 threads.
    → Compressing objects: 100% (3/3), done.
    → Writing objects: 100% (4/4), 690 bytes, done.
    → Total 4 (delta 1), reused 0 (delta 0)
    → remote: Resolving deltas: 100% (1/1), completed with 1 local objects.
    → To git@github.com:eng-it/linux-builds.git
    →    59f2725..a875b37  master -> master

## Fix Hardcoded Paths

If the install process left references to /ad/eng/support lying around, access
could fail when users try to access it from the non-kerberized mountpoint.  We
can do a simple search-and-replace of the one mountpoint string for the other.
Note that this isn't particularly clever in how it does it (it literally just
scans for one string and substitutes it for another, using grep and sed).

    eng-fix-install-paths /ad/eng/support/software/linux/opt/64/libctl-3.2.2/

## Add Symlinks

We can make a symbolic link with just the package name to point to this particular version.

    ln -s libctl-3.2.2 /ad/eng/support/software/linux/opt/64/libctl

For software that has self-contained binaries that can be called, we can set up
symlinks to those in /ad/eng/bin/64 as well.

    pushd /ad/eng/support/software/linux/bin/64/
    for binary in ../../opt/64/libctl/bin/*; do ln -s $binary $(basename $binary); done
    popd

In this case we just get one utility so it's not all that important.  For some
programs (like those starting with `scuff`, `blast`, or `lumerical`) it can be
more helpful.  Custom prefixes (again, like `lumerical`) can be used to
organize things.

    ls -l /ad/eng/bin/64  | grep libctl
    lrwxrwxrwx. 1 jesse08 bin      34 Oct 27 12:56 gen-ctl-io -> ../../opt/64/libctl/bin/gen-ctl-io

## Add a Shell Module

Now we should add a shell module file for easy loading and unloading of the
settings for the software.  This is especially helpful when one package depends
on another as the loading can be automatic.

This is handled in the [modulefiles] repository.

    cd /mnt/nokrb/$USER
    git clone git@github.com:eng-it/modulefiles.git
    cd modulefiles

See the existing modules for more information on how it works.  For
directories, note the hidden `.version` file that defines a default version.
This is a helpful structure for any package that will have multiple versions
installed, or that has versioning support at all.

Create a directory and `.version` file for libctl 3.2.2:

    mkdir libctl
    echo -e '#%Module\nset ModulesVersion 3.2.2' > libctl/.version

Now create `libctl/3.2.2`.  Generally these can be copied from existing module
files and modified.  The `set` commands are only used within the modulefile
itself; it's the `setenv` and `prepend-path` commands in this example that
modify the user's environment.  (The exact variables will depend on the
software; for example, some packages include `share/info` so we can set
INFOPATH to make the `info` command find the documentation.)

    #%Module1.0#####################################################################
    ##
    ## libctl: flexible control files for scientific simulations
    ##
    proc ModulesHelp { } {
            global version
    
            puts stderr "\tlibctl: flexible control files for scientific simulations"
            puts stderr "\thttp://ab-initio.mit.edu/wiki/index.php/Libctl"
            puts stderr "\n\tVersion: $version\n"
    }
    
    module-whatis   "libctl: flexible control files for scientific simulations"
    
    # If other modules are required, load them here with "module load name"
    
    # for Tcl script use only
    set     version      "3.2.2"
    set     LIBCTL_DIR   /ad/eng/opt/64/libctl-$version
    
    setenv        LIBCTL_HOME      "$LIBCTL_DIR"
    prepend-path  PATH             "$LIBCTL_DIR/bin"
    prepend-path  LD_LIBRARY_PATH  "$LIBCTL_DIR/lib"
    prepend-path  LIBRARY_PATH     "$LIBCTL_DIR/lib"
    prepend-path  INCLUDE          "$LIBCTL_DIR/include"
    prepend-path  CPATH            "$LIBCTL_DIR/include"
    prepend-path  MANPATH          "$LIBCTL_DIR/share/man"


If you put your local copy of `modulefiles` into your MODULEPATH, you can test
out the module before you commit it to the central copy.

    module help libctl
    → ----------- Module Specific Help for 'libctl/3.2.2' ---------------
    → 
    → 	libctl: flexible control files for scientific simulations
    → 	http://ab-initio.mit.edu/wiki/index.php/Libctl
    → 
    → 	Version: 3.2.2
    →
    module load libctl
    which gen-ctl-io
    → /ad/eng/opt/64/libctl-3.2.2/bin/gen-ctl-io
    module unload libctl

If all looks good, commit the new module, and pull it down into the main copy.

    git add libctl
    git commit -m 'libctl/3.2.2'
    → [master 304ef57] libctl/3.2.2
    →  2 files changed, 29 insertions(+), 0 deletions(-)
    →  create mode 100644 libctl/.version
    →  create mode 100644 libctl/3.2.2
    git push
    → Counting objects: 6, done.
    → Delta compression using up to 4 threads.
    → Compressing objects: 100% (4/4), done.
    → Writing objects: 100% (5/5), 782 bytes, done.
    → Total 5 (delta 1), reused 0 (delta 0)
    → remote: Resolving deltas: 100% (1/1), completed with 1 local objects.
    → To git@github.com:eng-it/modulefiles.git
    →    b88d640..304ef57  master -> master
    
    pushd /ad/eng/support/software/linux/etc/modulefiles
    → /ad/eng/support/software/linux/etc/modulefiles /mnt/nokrb/jesse08/modulefiles
    git pull
    → remote: Counting objects: 5, done.
    → remote: Compressing objects: 100% (3/3), done.
    → remote: Total 5 (delta 1), reused 5 (delta 1), pack-reused 0
    → Unpacking objects: 100% (5/5), done.
    → From github.com:eng-it/modulefiles
    →    b88d640..304ef57  master     -> origin/master
    → Updating b88d640..304ef57
    → Fast-forward
    →  libctl/.version |    2 ++
    →  libctl/3.2.2    |   27 +++++++++++++++++++++++++++
    →  2 files changed, 29 insertions(+), 0 deletions(-)
    →  create mode 100644 libctl/.version
    →  create mode 100644 libctl/3.2.2
    popd
    → mnt/nokrb/jesse08/modulefiles


## Add Test Cases

If there are any examples of how to use this software in a grid job, add them
to the [grid-tests] repository in a new subdirectory.

## Document on Grid Software List

Now we can add the software and its version to the list in the wiki page
[Grid/Sofware][Grid/Software].  If there's a particular binary that represents
the main part of the software, enter it as well.  (This is most useful for
things like MATLAB or COMSOL, but here we have just one binary so we may as
well specify it.)  The location "ENG" refers to `/ad/eng/opt`.

    ||<|1> libctl ||<|1> control files for simulations || 3.2.2 || gen-ctl-io || ENG || ||

[ansible]: https://github.com/eng-it/ansible
[modulefiles]: https://github.com/eng-it/modulefiles
[grid-tests]: https://github.com/eng-it/grid-tests
[Grid/Software]: http://collaborate.bu.edu/engit/Grid/Software

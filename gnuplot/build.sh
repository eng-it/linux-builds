dir="gnuplot-5.0.2"
installpath="/ad/eng/support/software/linux/opt/64/$dir"
cd "$dir"
./configure --prefix="$installpath" --with-x --with-readline=gnu --with-qt | tee configure.log

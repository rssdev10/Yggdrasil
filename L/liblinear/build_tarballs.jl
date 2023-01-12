# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "liblinear"
version = v"2.45.0"

julia_compat = "1.6"

# Collection of sources required to complete build
sources = [
    ArchiveSource("https://github.com/cjlin1/liblinear/archive/refs/tags/v245.tar.gz", "ce29f42c2c0d10e4627ac50a953fe3c130d2802868e6a2dc9a396356b96e8abc"),
    DirectorySource("./bundled")
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
for f in ${WORKSPACE}/srcdir/patches/*.patch; do
    atomic_patch -p1 ${f}
done
cd liblinear-245/
mkdir -p ${prefix}/bin
mkdir -p ${prefix}/lib
if [[ "${target}" == *-freebsd* ]] || [[ "${target}" == *-apple-* ]]; then
    CC=gcc
    CXX=g++
fi
make 
make lib
cp train${exeext} ${bindir}
cp predict${exeext} ${bindir}
cp liblinear.${dlext} ${libdir}
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products = [
    LibraryProduct("liblinear", :liblinear),
    ExecutableProduct("train", :train),
    ExecutableProduct("predict", :predict)
]

# Dependencies that must be installed before this package can be built
dependencies = Dependency[
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat=julia_compat)

pkg_name=ncurses5
pkg_distname=ncurses
pkg_origin=core
pkg_version=6.2
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="\
ncurses (new curses) is a programming library providing an application \
programming interface (API) that allows the programmer to write text-based \
user interfaces in a terminal-independent manner.\
"
pkg_upstream_url="https://www.gnu.org/software/ncurses/"
pkg_license=('ncurses')
pkg_dirname="${pkg_distname}-${pkg_version}"
pkg_source="http://ftp.gnu.org/gnu/${pkg_distname}/${pkg_dirname}.tar.gz"
pkg_shasum="30306e0c76e0f9f1f0de987cf1c82a5c21e1ce6568b9227f7da5b71cbea86c9d"
pkg_deps=(
  core/glibc
)
pkg_build_deps=(
  core/coreutils
  core/diffutils
  core/patch
  core/make
  core/gcc
  core/bzip2
)
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

do_build() {
  # API Version 5 doesn't compile with --enable-ext-colors
  ./configure --prefix="$pkg_prefix" \
    --with-shared \
    --with-termlib \
    --with-cxx-binding \
    --with-cxx-shared \
    --without-ada \
    --enable-sigwinch \
    --enable-pc-files \
    --with-pkg-config-libdir="$pkg_prefix/lib/pkgconfig" \
    --enable-symlinks \
    --enable-widec \
    --without-debug \
    --with-normal \
    --enable-overwrite \
    --disable-rpath-hack \
    --with-abi-version=5
  make
}

do_install() {
  make install

  # Many packages that use Ncurses will compile just fine against the widechar
  # libraries, but won't know to look for them. Create linker scripts and
  # symbolic links to allow older and non-widec compatible programs to build
  # properly
  #
  # Thanks to: http://clfs.org/view/sysvinit/x86_64-64/final-system/ncurses.html
  for x in curses ncurses form panel menu tinfo; do
    ln -sv lib${x}w.so "$pkg_prefix/lib/lib${x}.so"
    ln -sv lib${x}w.so "$pkg_prefix/lib/lib${x}.so.5"
    ln -sv ${x}w.pc "$pkg_prefix/lib/pkgconfig/${x}.pc"
  done
  ln -sfv libncursesw.so "$pkg_prefix/lib/libcursesw.so"
  ln -sfv libncursesw.a "$pkg_prefix/lib/libcursesw.a"
  ln -sfv libncursesw.a "$pkg_prefix/lib/libcurses.a"

  # Install the license, which comes from the README
  install -dv "$pkg_prefix/share/licenses"
  # shellcheck disable=SC2016
  grep -B 100 '$Id' README > "$pkg_prefix/share/licenses/LICENSE"
}

# ----------------------------------------------------------------------------
# **NOTICE:** What follows are implementation details required for building a
# first-pass, "stage1" toolchain and environment. It is only used when running
# in a "stage1" Studio and can be safely ignored by almost everyone. Having
# said that, it performs a vital bootstrapping process and cannot be removed or
# significantly altered. Thank you!
# ----------------------------------------------------------------------------
if [[ "$STUDIO_TYPE" = "stage1" ]]; then
  pkg_build_deps=(
    core/gcc
  )
fi

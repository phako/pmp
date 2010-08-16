AC_INIT([pmp], [0.2], [mail@jensge.org], [pmp])
AM_INIT_AUTOMAKE([1.11 dist-bzip2])
AC_CONFIG_SRCDIR([pmp/main.vala])
AC_CONFIG_HEADERS([config.h])
AM_MAINTAINER_MODE

AC_PROG_CC
AM_PROG_CC_C_O
AC_DISABLE_STATIC
AM_PROG_LIBTOOL
AC_CONFIG_MACRO_DIR([m4])

AC_SUBST(CFLAGS)
AC_SUBST(CPPFLAGS)
AC_SUBST(LDFLAGS)

VALA_REQUIRED=0.7.5
GTK_REQUIRED=2.16.0
WEBKIT_REQUIRED=1.1.4
LIBXML_REQUIRED=2.6.0
LIBSOUP_REQUIRED=2.26.0

PKG_CHECK_MODULES(LIBGTK, gtk+-2.0 >= $GTK_REQUIRED)
PKG_CHECK_MODULES(WEBKIT, webkit-1.0 >= $WEBKIT_REQUIRED)
PKG_CHECK_MODULES(LIBXML, libxml-2.0 >= $LIBXML_REQUIRED)
PKG_CHECK_MODULES(LIBSOUP, libsoup-2.4 >= $LIBSOUP_REQUIRED)

AC_ARG_ENABLE(vala,
              [  --enable vala          enable checks for vala],,
              enable_vala=no)

if test "x$enable_vala" = "xyes" ; then
    AM_PROG_VALAC([$VALA_REQUIRED])

    if test "x$VALAC" = "x" ; then
        AC_MSG_ERROR([Cannot find the "valac" compiler in your PATH])
    fi

    VALA_CHECK_PACKAGES([gtk+-2.0 webkit-1.0])
fi

AM_SILENT_RULES([yes])
AC_OUTPUT([Makefile])

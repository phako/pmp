AUTOMAKE_OPTIONS = subdir-objects
ACLOCAL_AMFLAGS=-I m4
MAINTAINERCLEANFILES = aclocal.m4 compile config.guess config.sub configure depcomp install-sh ltmain.sh Makefile.in missing config.h.in pmp/edge.vapi

NULL=

AM_VALAFLAGS = \
			   --vapidir=$(top_srcdir)/pmp \
			   --pkg edge \
			   --pkg libxml-2.0 \
			   --pkg libsoup-2.4 \
			   --thread

AM_CFLAGS = \
			-I $(top_srcdir)/pmp \
			$(LIBGTK_CFLAGS) \
			$(WEBKIT_CFLAGS) \
			$(LIBXML_CFLAGS) \
			$(LIBSOUP_CFLAGS) \
			$(NULL)


bin_PROGRAMS = \
			   pmp/pmp-run \
			   pmp/pmp-create \
			   $(NULL)
noinst_LIBRARIES = \
				   pmp/libedge.a

pmp_libedge_a_SOURCES = \
					  pmp/Edge.vala \
					  $(NULL)
pmp_libedge_a_VALAFLAGS = \
						  -H $(top_srcdir)/pmp/Edge.h \
						  --vapi=$(top_srcdir)/pmp/edge.vapi \
						  --pkg gio-2.0

pmp_pmp_run_SOURCES = \
					  pmp/MainWindow.vala \
					  pmp/main.vala \
					  $(NULL)

pmp_pmp_create_SOURCES = \
						 pmp/FaviconDownloader.vala \
						 pmp/create.vala \
						 $(NULL)

pmp_pmp_create_LDFLAGS = \
						 pmp/libedge.a \
						 $(LIBXML_LIBS) \
						 $(LIBSOUP_LIBS) \
						 $(NULL)

pmp_pmp_run_VALAFLAGS = \
						$(AM_VALAFLAGS) \
						--pkg gtk+-2.0 \
						--pkg webkit-1.0 \
						$(NULL)

pmp_pmp_run_LDFLAGS = \
					  pmp/libedge.a \
					  $(LIBGTK_LIBS) \
					  $(WEBKIT_LIBS) \
					  $(LIBXML_LIBS) \
					  $(LIBSOUP_LIBS) \
					  $(NULL)

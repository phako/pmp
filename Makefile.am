AUTOMAKE_OPTIONS = subdir-objects
ACLOCAL_AMFLAGS=-I m4

NULL=
bin_PROGRAMS = \
			   pmp/pmp \
			   pmp/pmp-create \
			   $(NULL)

pmp_pmp_SOURCES = \
				  pmp/Edge.vala \
				  pmp/MainWindow.vala \
				  pmp/main.vala \
				  $(NULL)

pmp_pmp_create_SOURCES = \
						 pmp/Edge.vala \
						 pmp/FaviconDownloader.vala \
						 pmp/create.vala \
						 $(NULL)

pmp_pmp_create_LDFLAGS = \
				  $(LIBXML_LIBS) \
				  $(LIBSOUP_LIBS) \
				  $(NULL)

pmp_pmp_create_VALAFLAGS = \
						   --pkg libxml-2.0 \
						   --pkg libsoup-2.4 \
						   --thread \
						   $(NULL)

AM_VALAFLAGS = \
			   --pkg webkit-1.0 \
			   --pkg gtk+-2.0 \
			   --pkg libxml-2.0 \
			   --pkg libsoup-2.4 \
			   --thread

AM_CFLAGS = \
			$(LIBGTK_CFLAGS) \
			$(WEBKIT_CFLAGS) \
			$(LIBXML_CFLAGS) \
			$(LIBSOUP_CFLAGS) \
			$(NULL)

pmp_pmp_LDFLAGS = \
				  $(LIBGTK_LIBS) \
				  $(WEBKIT_LIBS) \
				  $(LIBXML_LIBS) \
				  $(LIBSOUP_LIBS) \
				  $(NULL)

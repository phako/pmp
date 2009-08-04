mkdir -p m4
autoreconf -vi
./configure --enable-vala --enable-maintainer-mode $@

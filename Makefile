COSMO_VERSION=3.2.4
LIBXML_VERSION=2.12.3
LIBXSLT_VERSION=1.1.39

COSMO=$(realpath cosmocc)
CC=$(COSMO)/bin/cosmocc -I$(COSMO)/include -L$(COSMO)/lib
CXX=$(COSMO)/bin/cosmoc++ -I$(COSMO)/include -L$(COSMO)/lib
PKG_CONFIG=pkg-config --with-path=$(COSMO)/lib/pkgconfig
INSTALL=$(COSMO)/bin/cosmoinstall
AR=$(COSMO)/bin/cosmoar
RANLIB=$(AR) s

split-dot = $(word $2,$(subst ., ,$1))

LIBXML_URL=https://download.gnome.org/sources/libxml2/$(call split-dot,$(LIBXML_VERSION),1).$(call split-dot,$(LIBXML_VERSION),2)/libxml2-$(LIBXML_VERSION).tar.xz
LIBXSLT_URL=https://download.gnome.org/sources/libxslt/$(call split-dot,$(LIBXSLT_VERSION),1).$(call split-dot,$(LIBXSLT_VERSION),2)/libxslt-$(LIBXSLT_VERSION).tar.xz

.PHONY: all
all: cosmocc xmlcatalog.com xmllint.com xsltproc.com
	file $^

cosmocc:
	mkdir -p $@
	cd $@ && curl -L https://cosmo.zip/pub/cosmocc/cosmocc-$(COSMO_VERSION).zip -o cosmocc-$(COSMO_VERSION).zip && unzip cosmocc-$(COSMO_VERSION).zip

.SECONDEXPANSION:
xmlcatalog.com xmllint.com: libxml2/$$(subst .com,,$$@)
	cp $< $@

xsltproc.com: libxslt/xsltproc/xsltproc
	cp $< $@

libxml2/%: libxml2
	cd $< && AR="$(AR)" CC="$(CC)" RANLIB="$(RANLIB)" ./configure --prefix=$(COSMO) --disable-shared --without-python --without-zlib --without-lzma
	$(MAKE) --directory $< -j

libxslt/%: libxslt
	cd $< && AR="$(AR)" CC="$(CC)" RANLIB="$(RANLIB)" ./configure --prefix=$(COSMO) --with-libxml-src="../libxml2" --disable-shared --without-python
	$(MAKE) --directory $< -j

libxml2:
	curl -L $(LIBXML_URL) -o libxml2.tar.xz
	tar xf libxml2.tar.xz
	rm libxml2.tar.xz
	mv libxml2-* $@

libxslt:
	curl -L $(LIBXSLT_URL) -o libxslt.tar.xz
	tar xf libxslt.tar.xz
	rm libxslt.tar.xz
	mv libxslt-* $@

clean:
	rm -rf libxslt libxml2 xmlcatalog.com xmllint.com xsltproc.com

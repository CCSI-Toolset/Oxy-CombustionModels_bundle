# A simple makefile for creating the Oxy-Combustion Models bundled product
VERSION    := $(shell git describe --tags --dirty)
PRODUCT    := Oxy-Combustion Models Bundle
PROD_SNAME := Oxy-CombustionModels_bundle
PKG_DIR    := CCSI_$(PROD_SNAME)_$(VERSION)
PACKAGE    := $(PKG_DIR).zip

SUBDIRS  := boiler_model oxyfuel
TARBALLS := *.tgz
ZIPFILES := *.zip
DOCS     := docs/*.pdf

# OS detection & changes
UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
  MD5BIN=md5sum
endif
ifeq ($(UNAME), Darwin)
  MD5BIN=md5
endif
ifeq ($(UNAME), FreeBSD)
  MD5BIN=md5
endif

.PHONY: all clean $(SUBDIRS)

all: $(PACKAGE)
# Go into each category's subdir and break open the archives there
# into the corresponding subdir in the PKG_DIR
$(SUBDIRS):
	@echo "Packaging $@"
	@mkdir -p $(PKG_DIR)/$@
	@$(MAKE) -C $@ clean
	@$(MAKE) -C $@

# Make compressed tar file without timestamp (gzip -n) so md5sum
# doesn't change if the payload hasn't
$(PACKAGE): $(SUBDIRS) $(DOCS)
	@mkdir -p $(PKG_DIR)/docs

	@for tb in */$(TARBALLS); do \
	  tar -xzf $$tb -C $(PKG_DIR); \
	done

	@for zf in */$(ZIPFILES); do \
	  unzip -qo $$zf -d $(PKG_DIR); \
	done

	@cp $(DOCS) $(PKG_DIR)/docs/
	@zip -qXr $(PACKAGE) $(PKG_DIR)
	@$(MD5BIN) $(PACKAGE)
	@rm -rf $(PKG_DIR)

clean:
	@rm -rf $(PACKAGE) $(PKG_DIR)

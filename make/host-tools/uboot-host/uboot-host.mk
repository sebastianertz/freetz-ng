$(call TOOLS_INIT, 2024.07)
$(PKG)_SOURCE_DOWNLOAD_NAME:=v$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=b7f6137acc89e4a939075600de3a04cc3a8602fa936194c27bd9a14005bc61fd
$(PKG)_SITE:=https://github.com/u-boot/u-boot/archive/refs/tags
### CHANGES:=https://github.com/u-boot/u-boot/tags
### CVSREPO:=https://github.com/u-boot/u-boot
### SUPPORT:=fda77

$(PKG)_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/fit

$(PKG)_DEPENDS_ON+=$(if $(FREETZ_TOOLS_UBOOT_STATIC),openssl-host)

$(PKG)_BINARIES            := dumpimage fdtgrep mkimage
$(PKG)_BINARIES_BUILD_DIR  := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/tools/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DESTDIR)/%)

$(PKG)_REBUILD_SUBOPTS += FREETZ_TOOLS_UBOOT_STATIC
ifeq ($(FREETZ_TOOLS_UBOOT_STATIC),y)
$(PKG)_CONDITIONAL_PATCHES+=static_openssl
$(PKG)_MAKE_VARS += HOSTLDFLAGS="-Wl,-L$(OPENSSL_HOST_DIR)"
endif


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) -C $(UBOOT_HOST_DIR) \
		tools-only_defconfig
	touch $@

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(UBOOT_HOST_DIR) \
		$(UBOOT_HOST_MAKE_VARS) \
		tools-only

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DESTDIR)/%: $($(PKG)_DIR)/tools/%
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)


$(pkg)-clean:
	-$(MAKE) -C $(UBOOT_HOST_DIR) clean
	-$(RM) $(UBOOT_HOST_DIR)/.{configured,compiled}

$(pkg)-dirclean:
	$(RM) -r $(UBOOT_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) \
		$(UBOOT_HOST_BINARIES_TARGET_DIR)

$(TOOLS_FINISH)

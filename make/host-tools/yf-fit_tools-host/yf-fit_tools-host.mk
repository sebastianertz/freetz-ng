$(call TOOLS_INIT, 24011d3735c6935f81792d017438be3bbf1a39d3)
$(PKG)_SOURCE:=yf-fit_tools-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=1aae6d570e937520f37e64c9226fc71771450318f8271465a7c73832306c77b6
$(PKG)_SITE:=git_sparse@https://github.com/PeterPawn/YourFritz.git,fit_tools
### VERSION:=0.2 24011d3
### CHANGES:=https://github.com/PeterPawn/YourFritz/commits/fit_tools/
### CVSREPO:=https://github.com/PeterPawn/YourFritz/tree/fit_tools/fit_tools
### SUPPORT:=fda77

$(PKG)_DESTDIR             := $(FREETZ_BASE_DIR)/$(TOOLS_BUILD_DIR)


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	mkdir -p $(TOOLS_DIR)/yf/
	$(call COPY_USING_TAR,$(YF_FIT_TOOLS_HOST_DIR)/,$(TOOLS_DIR)/yf/,fit_tools/)
	touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:
	-$(RM) $(YF_FIT_TOOLS_HOST_DIR)/.{configured,compiled,installed}

$(pkg)-dirclean:
	$(RM) -r $(YF_FIT_TOOLS_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(TOOLS_DIR)/yf/fit_tools/

$(TOOLS_FINISH)

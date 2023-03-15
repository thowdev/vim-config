# Get the (root) directory where this Makefile is located
ROOT_DIR := $(shell pwd)

CURRENT_DATE := $(shell date +'%Y%m%d-%H%M')

USER_DIR		:= ~
USER_CONFIG_DIR := $(USER_DIR)/.thwi885

VIM_DIR			:= .vim
VIM_DIR_ROOT	:= $(ROOT_DIR)/$(VIM_DIR)
VIM_DIR_FOLDERS	:= 'autoload' 'backup' 'plugged' 'tmp' 'undo'
VIM_DIR_BACKUP	:= $(ROOT_DIR)/$(VIM_DIR)-$(CURRENT_DATE)
VIMRC			:= .vimrc
VIMRC_ROOT		:= $(ROOT_DIR)/$(VIMRC)

# Symlinks
VIM_DIR_USER	:= $(USER_DIR)/$(VIM_DIR)
VIMRC_USER		:= $(USER_DIR)/$(VIMRC)

# - Phony Targets:
#   - "A phony target is one that is not really the name of a file"
#   - https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
PHONY: clean debug help install targets
.DEFAULT_GOAL := install

clean: preserve-history
	@echo "################################################################################"
	@echo "Delete $(VIM_DIR_ROOT) ..."
	@rm -rf $(VIM_DIR_ROOT)
	@echo "Delete symlinks ..."
	@rm -rf $(VIM_DIR_USER)
	@rm -rf $(VIMRC_USER)

debug:
	@echo "ROOT_DIR: $(ROOT_DIR)"
	@echo "CURRENT_DATE: $(CURRENT_DATE)"
	@echo "USER_DIR: $(USER_DIR)"
	@echo "USER_CONFIG_DIR: $(USER_CONFIG_DIR)"
	@echo "VIM_DIR: $(VIM_DIR)"
	@echo "VIM_DIR_ROOT: $(VIM_DIR_ROOT)"
	@echo "VIM_DIR_BACKUP: $(VIM_DIR_BACKUP)"
	@echo "VIM_DIR_FOLDERS: $(VIM_DIR_FOLDERS)"
	@echo "VIMRC: $(VIMRC)"
	@echo "VIMRC_ROOT: $(VIMRC_ROOT)"
	@echo "VIM_DIR_USER: $(VIM_DIR_USER)"
	@echo "VIMRC_USER: $(VIMRC_USER)"

# Gruvbox is required because it is define in .vimrc. But whereas the other
# plugins are not required at executing the "PlugInstall" command, the "gruvbox"
# plugin blocks the command execution if it isn't available. Therefore it will
# downloaded "manually" directly from github.
install: clean
	@echo "################################################################################"
	@echo "Prepare .vim folder structure ..."
	@mkdir -p -m 750 $(addprefix $(VIM_DIR_ROOT)/,$(VIM_DIR_FOLDERS))
	@echo "Download plug.vim ..."
	@curl -sfLo $(VIM_DIR_ROOT)/autoload/plug.vim \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	@echo "Download gruvbox ..."
	@git clone --quiet https://github.com/morhetz/gruvbox $(VIM_DIR_ROOT)/plugged/gruvbox
	@echo "Install plugins and filetypes ..."
	@cp -r $(ROOT_DIR)/ftplugin $(VIM_DIR_ROOT)
	ln -sf $(VIM_DIR_ROOT) $(VIM_DIR_USER)
	ln -sf $(VIMRC_ROOT) $(VIMRC_USER)
	@vim -c 'PlugInstall --sync' -c 'qa'
	@if [ -d $(VIM_DIR_BACKUP) ]; then \
		echo "################################################################################";\
		echo "Restore .vim/undo and .vim/backup folder ...";\
		cp -r $(VIM_DIR_BACKUP)/undo  $(VIM_DIR_ROOT);\
		cp -r $(VIM_DIR_BACKUP)/backup  $(VIM_DIR_ROOT);\
		rm -rf $(VIM_DIR_BACKUP);\
	fi

help targets: help-common

help-common:
	@echo "################################################################################"
	@echo "# ______________________________________________________________________________"
	@echo "# List of important targets:"
	@echo "# --------------------------"
	@echo "# > clean        - Remove: $(VIM_DIR_USER) (with its complete vim history)"
	@echo "#                  and delete symlinks"
	@echo "# > install      - Create $(VIM_DIR_USER) and its subfolders:"
	@echo "#                  $(VIM_DIR_FOLDERS)"
	@echo "#                - Create appropriate symlinks to"
	@echo "#                    $(VIMRC_USER)"
	@echo "#                    $(VIM_DIR_USER)"
	@echo "#                - Installs vim plugins"
	@echo "#                - Executes a cleanup before but saves all undos and backup files"
	@echo "# > help         - this target list (default target)"
	@echo "# > targets      - this target list (default target)"

preserve-history:
	@echo "################################################################################"
	@if [ -d $(VIM_DIR_ROOT) ]; then \
		echo "Preserve .vim folder ...";\
		mv $(VIM_DIR_ROOT) $(VIM_DIR_BACKUP);\
	fi

# Get the (root) directory where Makefile is located
ROOT_DIR := $(shell pwd)

CURRENT_DATE := $(shell date +'%Y%m%d-%H%M')

USER_HOME_DIR	:= ~
USER_CONFIG_DIR := $(USER_HOME_DIR)/.thwi885
VIM_DIR			:= .vim
VIM_DIR_FOLDERS	:= 'autoload' 'backup' 'plugged' 'tmp' 'undo'
VIMRC			:= .vimrc

# - Phony Targets:
#   - "A phony target is one that is not really the name of a file"
#   - https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
PHONY: clean debug help install targets
.DEFAULT_GOAL := install

clean: preserve-history
	@echo "################################################################################"
	@echo "Delete $(ROOT_DIR)/$(VIM_DIR) ..."
	@rm -rf $(ROOT_DIR)/$(VIM_DIR)
	@echo "Delete symlinks ..."
	@rm -rf $(USER_HOME_DIR)/$(VIM_DIR)
	@rm -rf $(USER_HOME_DIR)/$(VIMRC)

debug:
	@echo "ROOT_DIR: $(ROOT_DIR)"
	@echo "USER_HOME_DIR: $(USER_HOME_DIR)"
	@echo "USER_CONFIG_DIR: $(USER_CONFIG_DIR)"
	@echo "VIM_DIR: $(VIM_DIR)"
	@echo "VIM_DIR_FOLDERS: $(VIM_DIR_FOLDERS)"
	@echo "VIMRC: $(VIMRC)"
	@echo "CURRENT_DATE: $(CURRENT_DATE)"
	@echo "MAKEFILE_LIST: $(MAKEFILE_LIST)"
	@echo "lastword MAKEFILE_LIST: $(lastword $(MAKEFILE_LIST))"
	@echo "dir lastword MAKEFILE_LIST: $(dir $(lastword $(MAKEFILE_LIST)))"

# Gruvbox is required because it is define in .vimrc. But whereas the other
# plugins are not required at executing the "PlugInstall" command, the "gruvbox"
# plugin blocks the command execution if it isn't available. Therefore it will
# downloaded "manually" directly from github.
install: clean
	@echo "################################################################################"
	@echo "Prepare .vim folder structure ..."
	@mkdir -p -m 750 $(addprefix $(ROOT_DIR)/$(VIM_DIR)/,$(VIM_DIR_FOLDERS))
	@echo "Download plug.vim ..."
	@curl -sfLo $(ROOT_DIR)/$(VIM_DIR)/autoload/plug.vim \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	@echo "Download gruvbox ..."
	@git clone --quiet https://github.com/morhetz/gruvbox $(ROOT_DIR)/$(VIM_DIR)/plugged/gruvbox
	@echo "Install plugins and filetypes ..."
	@cp -r $(ROOT_DIR)/ftplugin $(ROOT_DIR)/$(VIM_DIR)
	ln -sf $(ROOT_DIR)/$(VIM_DIR) $(USER_HOME_DIR)/$(VIM_DIR)
	ln -sf $(ROOT_DIR)/$(VIMRC) $(USER_HOME_DIR)/$(VIMRC)
	@vim -c 'PlugInstall --sync' -c 'qa'
	@if [ -d $(ROOT_DIR)/$(CURRENT_DATE)-$(VIM_DIR) ]; then \
		echo "################################################################################";\
		echo "Restore .vim/undo and .vim/backup folder ...";\
		cp -r $(ROOT_DIR)/$(CURRENT_DATE)-$(VIM_DIR)/undo  $(ROOT_DIR)/$(VIM_DIR);\
		cp -r $(ROOT_DIR)/$(CURRENT_DATE)-$(VIM_DIR)/backup  $(ROOT_DIR)/$(VIM_DIR);\
		rm -rf $(ROOT_DIR)/$(CURRENT_DATE)-$(VIM_DIR);\
	fi

help targets: help-common

help-common:
	@echo "################################################################################"
	@echo "# ______________________________________________________________________________"
	@echo "# List of important targets:"
	@echo "# --------------------------"
	@echo "# > all          - Run clean and install"
	@echo "# > clean        - Remove: $(USER_HOME_DIR)/$(VIM_DIR) (with its complete vim history)"
	@echo "#                  and delete symlinks"
	@echo "# > install      - Create $(USER_HOME_DIR)/$(VIM_DIR) and its subfolders:"
	@echo "#                  $(VIM_DIR_FOLDERS)"
	@echo "#                - Create appropriate symlinks to"
	@echo "#                    $(USER_HOME_DIR)/$(VIMRC)"
	@echo "#                    $(USER_HOME_DIR)/$(VIM_DIR)"
	@echo "#                - Installs vim plugins"
	@echo "# > help         - this target list (default target)"
	@echo "# > targets      - this target list (default target)"

preserve-history:
	@echo "################################################################################"
	@if [ -d $(ROOT_DIR)/$(VIM_DIR) ]; then \
		echo "Preserve .vim folder ...";\
		mv $(ROOT_DIR)/$(VIM_DIR) $(ROOT_DIR)/$(CURRENT_DATE)-$(VIM_DIR);\
	fi

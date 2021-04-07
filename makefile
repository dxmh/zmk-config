board=nice_nano
shield=cradioz
zmk_app=~/code/zmk/app
zmk_config=~/zmk-config
build=${zmk_config}/.build
deps=${zmk_config}/.deps
bootloader=/media/${USER}/NICENANO

define do_build
	mkdir -pv ${build}/${shield}_$(1)
	cd ${zmk_app} && \
		west build --pristine -d ${build}/${shield}_left -b ${board} \
			-- -DSHIELD=${shield}_$(1) -DZMK_CONFIG=${zmk_config}/config
endef

define do_flash
	@ printf "\nWaiting for $(1) ${board} bootloader to appear at ${bootloader} ."
	@ while [ ! -f ${bootloader}/current.uf2 ]; do sleep 1; printf "."; done
	@ printf "\n";
	cp -av ${build}/${shield}_$(1)/zephyr/zmk.uf2 ${bootloader}/
endef

.PHONY: deps build flash clean

deps:
	git clone --depth=1 https://github.com/davidphilipbarr/zmk-shields.git ${deps}/
	mkdir -pv config/boards/shields/
	ln -srvfn ${deps}/cradioz config/boards/shields/

build:
	$(call do_build,left)
	$(call do_build,right)

flash:
	$(call do_flash,left)
	$(call do_flash,right)

clean:
	rm -rf ${build} ${deps} ./config/boards

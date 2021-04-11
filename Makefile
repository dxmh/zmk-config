board=nice_nano
shield=cradio
zmk_app=${HOME}/code/zmk/app
zmk_config=${HOME}/zmk-config
build=${zmk_config}/.build
bootloader=/media/${USER}/NICENANO

define do_build
	mkdir -pv "${build}/${shield}_$(1)"
	cd "${zmk_app}" && \
		west build --pristine -d "${build}/${shield}_$(1)" -b "${board}" \
			-- -DSHIELD="${shield}_$(1)" -DZMK_CONFIG="${zmk_config}/config"
endef

define do_flash
	@ printf "\nWaiting for $(1) ${board} bootloader to appear at ${bootloader} ."
	@ while [ ! -f "${bootloader}/current.uf2" ]; do sleep 1; printf "."; done
	@ printf "\n";
	cp -av "${build}/${shield}_$(1)/zephyr/zmk.uf2" "${bootloader}/"
endef

.PHONY: build flash clean

build:
	$(call do_build,left)
	$(call do_build,right)

flash-left:
	$(call do_flash,left)

flash-right:
	$(call do_flash,right)

clean:
	rm -rf ${build}

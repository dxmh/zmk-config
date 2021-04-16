board=nice_nano
shield=cradio
zmk_config=${HOME}/zmk-config
zmk=${zmk_config}/zmk
zmk_image=zmkfirmware/zmk-dev-arm:2.4
build=${zmk}/build
bootloader=/media/${USER}/NICENANO

define do_build
	mkdir -pv "${build}/${shield}_$(1)"
	cd "${zmk}/app" && \
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

zmk:
	# Get ZMK codebase:
	git clone https://github.com/zmkfirmware/zmk ${zmk}
	# Apply patches:
	git -C ${zmk} remote add -ft macros okke-formsa https://github.com/okke-formsma/zmk
	git -C ${zmk} remote add -ft cradio-v2 davidphilipbarr https://github.com/davidphilipbarr/zmk
	git -C ${zmk} merge davidphilipbarr/cradio-v2 --no-edit --no-gpg-sign
	git -C ${zmk} merge okke-formsa/macros --no-edit --no-gpg-sign
	# Set up workspace:
	docker run --rm --userns=host --user=$(shell id -u) \
		--workdir="/zmk" --volume="${zmk}:/zmk" "${zmk_image}" \
		sh -c 'west init -l app; west update'

build: zmk
	$(call do_build,left)
	$(call do_build,right)

flash-left:
	$(call do_flash,left)

flash-right:
	$(call do_flash,right)

clean:
	rm -rf ${build} ${zmk}

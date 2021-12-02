.PHONY: default all flash show $(builds)

SHELL:=/bin/bash
zmk=${PWD}/zmk
uf2=${PWD}/uf2
config=${PWD}/config
nicenano_device=/dev/disk/by-label/NICENANO
nicenano_mount=/media/${USER}/NICENANO
zmk_image=zmkfirmware/zmk-dev-arm:2.5
docker_run=docker run --rm -it -h make.zmk -w /zmk -v "${zmk}:/zmk" \
	-v "${config}:/zmk-config" -v "${uf2}:/uf2" ${zmk_image}
builds=hypergolic hypergolic-peripheral adux adux-peripheral
log=${PWD}/build.log

define _build
	make combo_count
	${docker_run} 2> >(tee ${log} >&2) sh -c '\
		west build --pristine --board "$(1)" app -- \
			-DSHIELD="$(2)" \
			-DZMK_CONFIG="/zmk-config" \
			-DCONFIG_ZMK_KEYBOARD_NAME="\"$(3)\"" \
		&& cp -av /zmk/build/zephyr/zmk.uf2 /uf2/$(3).uf2'
endef

define _flash
	findmnt /dev/disk/by-id/usb-Adafruit_nRF_UF2_$(1)-0:0 \
		&& cp -av "${uf2}/$(2).uf2" "${nicenano_mount}/" || true
endef

define _merge
	git remote add -ft $(2) $(1) https://github.com/$(1)/zmk; \
	git merge $(1)/$(2) --no-edit;
endef

default: adux

hypergolic: zmk
	$(call _build,nice_nano,cradio_left,Hypergolic)

hypergolic-peripheral: zmk
	$(call _build,nice_nano,cradio_right,Hypergolic-P)

adux: zmk
	$(call _build,nice_nano,a_dux_left,Architeuthis\ Dux)

adux-peripheral: zmk
	$(call _build,nice_nano,a_dux_right,A.\ Dux-P)

all: $(builds)

flash:
	@ printf "\nWaiting for a nice!nano to appear\n"
	@ while [ ! -b ${nicenano_device} ]; do sleep 1; printf "."; done
	@ findmnt ${nicenano_device} || udisksctl mount --block-device ${nicenano_device}
	@ $(call _flash,8AA1DA68593FABC1,Architeuthis Dux)
	@ $(call _flash,21CA6AAAD49DF81A,A. Dux-P)
	@ $(call _flash,D33E2CFB15C7D816,Hypergolic)
	@ $(call _flash,45C483E59AD308DE,Hypergolic-P)

zmk:
	${docker_run} sh -c '\
		git clone https://github.com/zmkfirmware/zmk .; \
		git checkout c4ad3bc5dcfdf01f86b7538b42b7546487a694b0; \
		$(call _merge,okke-formsma,macros) \
		$(call _merge,aumuell,modmorph) \
		west init -l app; \
		west update'

shell:
	${docker_run} bash

# Count the amount of combos per key and update the value in config files
combo_count:
	count=$$(grep -Eo '[0-9]+' config/combos.dtsi \
		| sort | uniq -c | sort -nr | awk 'NR==1{ print $$1 }'); \
	sed -Ei "/CONFIG_ZMK_COMBO_MAX_COMBOS_PER_KEY/s/=.+/=$$count/" config/*.conf

test:
	${docker_run} west test

# Pinpoint the cause of the most recent build failure by opening the
# nice_nano.dts.pre.tmp file at the line and column that caused the error
show:
	$(shell sed -nE 's|.+(nice_nano.dts.pre.tmp):([0-9]+)\.([0-9]+)-.+|\
		vim -c "call cursor(+\2, \3)" -c "set cursorline cursorcolumn" zmk/build/zephyr/\1|p' ${log})

clean:
	sudo rm -rf "${uf2}" "${zmk}"

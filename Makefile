.PHONY: default all clean flash $(builds)

zmk=${PWD}/zmk
uf2=${PWD}/uf2
config=${PWD}/config
nicenano_device=/dev/disk/by-label/NICENANO
nicenano_mount=/media/${USER}/NICENANO
zmk_image=zmkfirmware/zmk-dev-arm:2.4
docker_run=docker run --rm -h make.zmk -w /zmk -v "${zmk}:/zmk" \
	-v "${config}:/zmk-config" -v "${uf2}:/uf2" ${zmk_image}
builds=hypergolic hypergolic-peripheral sweep sweep-peripheral

define _build
	${docker_run} sh -c '\
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

default: sweep

hypergolic: zmk fresh
	$(call _build,nice_nano,cradio_left,Hypergolic)

hypergolic-peripheral: zmk fresh
	$(call _build,nice_nano,cradio_right,Hypergolic-P)

sweep: zmk sweep_prototype
	$(call _build,nice_nano,cradio_left,Sweep)

sweep-peripheral: zmk sweep_prototype
	$(call _build,nice_nano,cradio_right,Sweep-P)

adux: zmk fresh
	$(call _build,nice_nano,architeuthis_dux_left,Architeuthis\ Dux)

adux-peripheral: zmk fresh
	$(call _build,nice_nano,architeuthis_dux_right,A.\ Dux-P)

all: $(builds)

flash:
	@ printf "\nWaiting for a nice!nano to appear\n"
	@ while [ ! -b ${nicenano_device} ]; do sleep 1; printf "."; done
	@ findmnt ${nicenano_device} || udisksctl mount --block-device ${nicenano_device}
	@ $(call _flash,8AA1DA68593FABC1,Architeuthis Dux)
	@ $(call _flash,21CA6AAAD49DF81A,A. Dux-P)
	@ $(call _flash,D33E2CFB15C7D816,Sweep)
	@ $(call _flash,45C483E59AD308DE,Sweep-P)

zmk:
	${docker_run} sh -c '\
		git clone https://github.com/zmkfirmware/zmk .; \
		git remote add -ft macros okke-formsa https://github.com/okke-formsma/zmk; \
		git merge okke-formsa/macros --no-edit; \
		west init -l app; \
		west update'

fresh:
	${docker_run} git checkout --force --quiet

# Fix thumb keys on this particular Sweep PCB
sweep_prototype: fresh
	${docker_run} sed -i \
		-e 's/RC(0,15) RC(0,16)/RC(0,16) RC(0,15)/' \
		-e 's/RC(0,33) RC(0,32)/RC(0,32) RC(0,33)/' \
		/zmk/app/boards/shields/cradio/cradio.dtsi

test:
	${docker_run} west test

clean:
	sudo rm -rf "${uf2}" "${zmk}"

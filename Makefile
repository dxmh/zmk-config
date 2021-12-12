shields=a_dux_left a_dux_right cradio_left cradio_right
config=${PWD}/config
nicenano_device=/dev/disk/by-label/NICENANO
nicenano_mount=/media/${USER}/NICENANO
zmk_image=zmkfirmware/zmk-dev-arm:2.5

define _flash
	findmnt /dev/disk/by-id/usb-Adafruit_nRF_UF2_$(1)-0:0 \
		&& cp -av "uf2/$(2).uf2" "${nicenano_mount}/" || true
endef

# Default shield to build
default: a_dux_left

# Install ZMK and initiate west inside a volume for use by build containers
zmk:
	docker run -it --name zmk -h zmk.local -w /zmk -v zmk:/zmk ${zmk_image} sh -c '\
		git clone https://github.com/zmkfirmware/zmk .; \
		git checkout c4ad3bc5dcfdf01f86b7538b42b7546487a694b0; \
		west init -l app; \
		west update'

# Count the amount of combos per key and update the value in config files
combo_count:
	count=$$(grep -Eo '[0-9]+' config/combos.dtsi | sort | uniq -c | sort -nr | awk 'NR==1{ print $$1 }'); \
	sed -Ei "/CONFIG_ZMK_COMBO_MAX_COMBOS_PER_KEY/s/=.+/=$$count/" config/*.conf

# Build the firmware for a given shield
$(shields): combo_count
	docker run --rm -it --name zmk-$@ -w /zmk -v zmk:/zmk -v "${config}:/zmk-config:Z" ${zmk_image} \
		sh -c 'west build --pristine --board "nice_nano" app -- -DSHIELD="$@" -DZMK_CONFIG="/zmk-config"'
	docker cp zmk:/zmk/build/zephyr/zmk.uf2 uf2/$@.uf2

# Flash the appropriate firmware to the connected controller
flash:
	@ printf "\nWaiting for a nice!nano to appear\n"
	@ while [ ! -b ${nicenano_device} ]; do sleep 1; printf "."; done
	@ findmnt ${nicenano_device} || udisksctl mount --block-device ${nicenano_device}
	@ $(call _flash,8AA1DA68593FABC1,a_dux_left)
	@ $(call _flash,21CA6AAAD49DF81A,a_dux_right)
	@ $(call _flash,D33E2CFB15C7D816,cradio_left)
	@ $(call _flash,45C483E59AD308DE,cradio_right)

clean:
	docker ps -aq --filter name='^zmk$$' | xargs -r docker container rm
	docker volume list -q --filter name='zmk' | xargs -r docker volume rm
	find uf2/ -type f -delete

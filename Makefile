shields=a_dux_left a_dux_right cradio_left cradio_right
config=${PWD}/config
nicenano_device=/dev/disk/by-label/NICENANO
nicenano_mount=/media/${USER}/NICENANO
zmk_image=zmkfirmware/zmk-dev-arm:3.0-branch
# TODO: Switch to `stable` image tag once it is arm64 compatible
# https://hub.docker.com/r/zmkfirmware/zmk-dev-arm/tags
docker_opts= \
	--interactive \
	--tty \
	--name zmk-$@ \
	--workdir /zmk \
	--volume zmk:/zmk \
	--volume "${config}:/zmk-config:Z" \
	${zmk_image}

define _flash
	findmnt /dev/disk/by-id/usb-Adafruit_nRF_UF2_$(1)-0:0 \
		&& cp -av "uf2/$(2).uf2" "${nicenano_mount}/" || true
endef

# Default shield to build
default: a_dux_left

# Install ZMK and initiate west inside a volume for use by build containers
codebase:
	docker run ${docker_opts} sh -c '\
		git clone https://github.com/dxmh/zmk -b tipper_tf_zephyr30 /zmk/; \
		west init -l /zmk/app/; \
		west update'

# Count the amount of combos per key and update the value in config files
combo_count:
	count=$$(grep -Eo '[0-9]+' config/combos.dtsi | sort | uniq -c | sort -nr | awk 'NR==1{ print $$1 }'); \
	sed -Ei "/CONFIG_ZMK_COMBO_MAX_COMBOS_PER_KEY/s/=.+/=$$count/" config/*.conf

# Build the firmware for a given shield
$(shields): combo_count
	docker run --rm ${docker_opts} \
		west build /zmk/app --pristine --board "nice_nano" -- -DSHIELD="$@" -DZMK_CONFIG="/zmk-config"
	docker cp zmk-codebase:/zmk/build/zephyr/zmk.uf2 uf2/$@.uf2

# Build the firmware for Tipper TF
tipper_tf: combo_count
	docker run --rm ${docker_opts} \
		west build /zmk/app --pristine --board "tipper_tf" -- -DZMK_CONFIG="/zmk-config"
	docker cp zmk-codebase:/zmk/build/zephyr/zmk.uf2 uf2/$@.uf2

# Open a shell within the ZMK environment
shell:
	docker run --rm ${docker_opts} /bin/bash

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
	docker ps -aq --filter name='^zmk' | xargs -r docker container rm
	docker volume list -q --filter name='zmk' | xargs -r docker volume rm
	find uf2/ -type f -delete

shields=a_dux_left a_dux_right cradio_left cradio_right
config=${PWD}/config
nicenano_mount=/media/psf/NICENANO
tipper_mount=/media/psf/TIPPERTF
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

# Default keyboard to build
kb=tipper_tf
default: ${kb}

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

# Determine where to find the bootloader
ifeq (${kb},tipper_tf)
  mountpoint=${tipper_mount}
else
  mountpoint=${nicenano_mount}
endif

# Flash the appropriate firmware to the bootloader
flash:
	@ printf "Waiting for ${kb} bootloader to appear at ${mountpoint}.."
	@ while [ ! -d ${mountpoint} ]; do sleep 1; printf "."; done; printf "\n"
	cp -av uf2/${kb}.uf2 ${mountpoint}

clean:
	docker ps -aq --filter name='^zmk' | xargs -r docker container rm
	docker volume list -q --filter name='zmk' | xargs -r docker volume rm
	find uf2/ -type f -delete

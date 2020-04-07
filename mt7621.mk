#
# MT7621 Profiles
#

include ./common-tp-link.mk

DEFAULT_SOC := mt7621

KERNEL_DTB += -d21
DEVICE_VARS += UIMAGE_MAGIC

# The OEM webinterface expects an kernel with initramfs which has the uImage
# header field ih_name.
# We don't want to set the header name field for the kernel include in the
# sysupgrade image as well, as this image shouldn't be accepted by the OEM
# webinterface. It will soft-brick the board.
define Build/custom-initramfs-uimage
	mkimage -A $(LINUX_KARCH) \
		-O linux -T kernel \
		-C lzma -a $(KERNEL_LOADADDR) $(if $(UIMAGE_MAGIC),-M $(UIMAGE_MAGIC),) \
		-e $(if $(KERNEL_ENTRY),$(KERNEL_ENTRY),$(KERNEL_LOADADDR)) \
		-n '$(1)' -d $@ $@.new
	mv $@.new $@
endef

define Build/elecom-gst-factory
  $(eval product=$(word 1,$(1)))
  $(eval version=$(word 2,$(1)))
  ( $(STAGING_DIR_HOST)/bin/mkhash md5 $@ | tr -d '\n' ) >> $@
  ( \
    echo -n "ELECOM $(product) v$(version)" | \
      dd bs=32 count=1 conv=sync; \
    dd if=$@; \
  ) > $@.new
  mv $@.new $@
  echo -n "MT7621_ELECOM_$(product)" >> $@
endef

define Build/elecom-wrc-factory
  $(eval product=$(word 1,$(1)))
  $(eval version=$(word 2,$(1)))
  $(STAGING_DIR_HOST)/bin/mkhash md5 $@ >> $@
  ( \
    echo -n "ELECOM $(product) v$(version)" | \
      dd bs=32 count=1 conv=sync; \
    dd if=$@; \
  ) > $@.new
  mv $@.new $@
endef

define Build/iodata-factory
  $(eval fw_size=$(word 1,$(1)))
  $(eval fw_type=$(word 2,$(1)))
  $(eval product=$(word 3,$(1)))
  $(eval factory_bin=$(word 4,$(1)))
  if [ -e $(KDIR)/tmp/$(KERNEL_INITRAMFS_IMAGE) -a "$$(stat -c%s $@)" -lt "$(fw_size)" ]; then \
    $(CP) $(KDIR)/tmp/$(KERNEL_INITRAMFS_IMAGE) $(factory_bin); \
    $(STAGING_DIR_HOST)/bin/mksenaofw \
      -r 0x30a -p $(product) -t $(fw_type) \
      -e $(factory_bin) -o $(factory_bin).new; \
    mv $(factory_bin).new $(factory_bin); \
    $(CP) $(factory_bin) $(BIN_DIR)/; \
	else \
		echo "WARNING: initramfs kernel image too big, cannot generate factory image" >&2; \
	fi
endef

define Build/iodata-mstc-header
  ( \
    data_size_crc="$$(dd if=$@ ibs=64 skip=1 2>/dev/null | \
      gzip -c | tail -c 8 | od -An -tx8 --endian little | tr -d ' \n')"; \
    echo -ne "$$(echo $$data_size_crc | sed 's/../\\x&/g')" | \
      dd of=$@ bs=8 count=1 seek=7 conv=notrunc 2>/dev/null; \
  )
  dd if=/dev/zero of=$@ bs=4 count=1 seek=1 conv=notrunc 2>/dev/null
  ( \
    header_crc="$$(dd if=$@ bs=64 count=1 2>/dev/null | \
      gzip -c | tail -c 8 | od -An -N4 -tx4 --endian little | tr -d ' \n')"; \
    echo -ne "$$(echo $$header_crc | sed 's/../\\x&/g')" | \
      dd of=$@ bs=4 count=1 seek=1 conv=notrunc 2>/dev/null; \
  )
endef

define Build/netis-tail
	echo -n $(1) >> $@
	echo -n $(UIMAGE_NAME)-yun | $(STAGING_DIR_HOST)/bin/mkhash md5 | \
		sed 's/../\\\\x&/g' | xargs echo -ne >> $@
endef

define Build/ubnt-erx-factory-image
	if [ -e $(KDIR)/tmp/$(KERNEL_INITRAMFS_IMAGE) -a "$$(stat -c%s $@)" -lt "$(KERNEL_SIZE)" ]; then \
		echo '21001:6' > $(1).compat; \
		$(TAR) -cf $(1) --transform='s/^.*/compat/' $(1).compat; \
		\
		$(TAR) -rf $(1) --transform='s/^.*/vmlinux.tmp/' $(KDIR)/tmp/$(KERNEL_INITRAMFS_IMAGE); \
		mkhash md5 $(KDIR)/tmp/$(KERNEL_INITRAMFS_IMAGE) > $(1).md5; \
		$(TAR) -rf $(1) --transform='s/^.*/vmlinux.tmp.md5/' $(1).md5; \
		\
		echo "dummy" > $(1).rootfs; \
		$(TAR) -rf $(1) --transform='s/^.*/squashfs.tmp/' $(1).rootfs; \
		\
		mkhash md5 $(1).rootfs > $(1).md5; \
		$(TAR) -rf $(1) --transform='s/^.*/squashfs.tmp.md5/' $(1).md5; \
		\
		echo '$(BOARD) $(VERSION_CODE) $(VERSION_NUMBER)' > $(1).version; \
		$(TAR) -rf $(1) --transform='s/^.*/version.tmp/' $(1).version; \
		\
		$(CP) $(1) $(BIN_DIR)/; \
	else \
		echo "WARNING: initramfs kernel image too big, cannot generate factory image" >&2; \
	fi
endef

define Device/hiwifi_hc5962
  UBINIZE_OPTS := -E 5
  IMAGE_SIZE := 16064k
  IMAGES += factory.bin
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
  IMAGE/factory.bin := append-kernel | pad-to $$(KERNEL_SIZE) | append-ubi | \
	check-size $$$$(IMAGE_SIZE)
  DEVICE_VENDOR := HiWiFi
  DEVICE_MODEL := HC5962
  DEVICE_PACKAGES := kmod-mt7603 kmod-mt76x2 kmod-usb3 wpad-openssl
endef
TARGET_DEVICES += hiwifi_hc5962

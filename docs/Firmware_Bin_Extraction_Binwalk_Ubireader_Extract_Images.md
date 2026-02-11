# Cudy Firmware Extraction Notes
## Updated Notes for Cudy Official 2.5.0 M3000-R37-2.5.0-20260112-084313-sysupgrade.zip

```
binwalk M3000-R37-2.5.0-20260112-084313-sysupgrade.bin
```

### Find HEXADECIMAL offset (example: 0x200800) to create `.itb`

| DECIMAL | HEXADECIMAL | DESCRIPTION |
| --- | --- | --- |
| 511981 | 0x7CFED | CRC32 polynomial table, little endian |                                                                
| 605225 | 0x93C29 | Device tree blob (DTB), version: 17, CPU ID: 0, total size: 7216 bytes |
| 2099200 | 0x200800 |  Device tree blob (DTB), version: 17, CPU ID: 0, total size: 18875692 bytes |

### Create `.itb`

```
dd if=<FIRMWARE>.bin of=firmware_fit.itb bs=1 skip=$((0x200800))
```

**Example:**
```
dd if=M3000-R37-2.5.0-20260112-084313-sysupgrade.bin of=firmware_fit.itb bs=1 skip=$((0x200800))
```

### Find UBI offset in `.itb`

```
grep -oba 'UBI#' firmware_fit.itb | head -n1
```

### Set variable for UBI offset

```
OFFSET=$(grep -oba 'UBI#' firmware_fit.itb | head -n1 | cut -d: -f1)
```

```
echo $OFFSET
```

### Create `ubi.img` with ubi offset with `dd`

```
dd if=firmware_fit.itb of=ubi.img bs=1 skip="$OFFSET" status=progress
```

### Extract images using `ubireader_extract_images`

```
ubireader_extract_images ubi.img
```

This will return a warning that can be disregarded:

> ubireader_extract_images ubi.img  
UBI_File Warning: end_offset - start_offset length is not block aligned, could mean missing data.

This will create: `ubifs-root/ubi.img`

### Unsquash extracted image

```
cd ubifs-root/ubi.img 
```

Binwalk root img to verify type:

```
binwalk img-<SOME_VAL>_vol-rootfs.ubifs
```

**Example:**

```
binwalk img-1768029500_vol-rootfs.ubifs
```

**Output:**

| DECIMAL | HEXADECIMAL | DESCRIPTION |
| --- | --- | --- |
| 0 | 0x0 |  SquashFS file system, little endian, version: 4.0, compression: xz, inode count: 2438, block size: 262144, image size: 13781596 bytes, created: 2026-01-10 07:18:20|

Image is Squashfs, so unsquash:

```
sudo unsquashfs img-<SOME_VAL>_vol-rootfs.ubifs
```

**Example:**
```
sudo unsquashfs img-1768029500_vol-rootfs.ubifs
```
---

# Legacy Notes 2025-01-19

## Extraction Steps:

```
binwalk M3000-R37-2.4.19-20250828-183718-sysupgrade.bin
```

### This will return the hexadecimal offset

| DECIMAL | HEXADECIMAL | DESCRIPTION |
| --- | --- | --- |
| 511981 | 0x7CFED | CRC32 polynomial table, little endian |                                                                
| 605209 | 0x93C19 | Device tree blob (DTB), version: 17, CPU ID: 0, total size: 7216 bytes |
| 2099200 | 0x200800 | Device tree blob (DTB), version: 17, CPU ID: 0, total size: 18089260 bytes |

## Create *.itb file with `dd`. 
Flattened Image Tree (FIT) binary file used in embedded systems (like those running U-Boot) to bundle multiple boot components (kernel, ramdisk, device tree) into one file for easier loading by a bootloader, generated from a text-based Image Tree Source (.its) file

```
dd if=M3000-R37-2.4.19-20250828-183718-sysupgrade.bin of=firmware_fit.itb bs=1 skip=$((0x200800))
```

### Binwalk 2.x (pre-rust rewrite) -- Searching for UBI# in hex-encoded byte sequence

| Hex    | ASCII |
| ------ | ----- |
| `0x55` | `U`   |
| `0x42` | `B`   |
| `0x49` | `I`   |
| `0x23` | `#`   |

```
binwalk -R '\x55\x42\x49#' firmware_fit.itb
```

### Newer Version of Binwalk 3.x removed the `-R` and `--raw` (raw regex) search

### Options:

- Grep (for exact byte offset)
```
grep -oba 'UBI#' firmware_fit.itb
```

Return first offset
```
grep -oba 'UBI#' firmware_fit.itb | head -n1
```

- Hexdump (not as easy)
```
hexdump -Cv firmware_fit.itb | grep '55 42 49 23'
```

Return first offset
```
hexdump -Cv firmware_fit.itb | grep '55 42 49 23' | head -n1
```

Will have to add the returned values to find the offset

`000000a0  55 42 49 23 01 00 00 00  00 00 00 00 00 00 00 00  |UBI#............| = 160`

### Set ENV for first offset:
```
OFFSET=$(grep -oba 'UBI#' firmware_fit.itb | head -n1 | cut -d: -f1)
```

### Create ubi.img (still a mystery as to how I found the count length)
```
dd if=firmware_fit.itb of=ubi.img bs=1 skip="$OFFSET" count=18087936 status=progress
```

### Extract ubi.img

- History of all commands that were run (for context)
```
ubireader_extract_images ubi.img
cd ubifs-root
cd ubi.img
ubireader_extract_files img-1756376495_vol-rootfs_data.ubifs
ubireader_extract_files --start-offset 0 img-1756376495_vol-rootfs_data.ubifs
binwalk img-1756376495_vol-rootfs_data.ubifs
ubireader_extract_files --start-offset 2048 img-1756376495_vol-rootfs_data.ubifs
binwalk img-1756376495_vol-rootfs_data.ubifs | head
ubireader_extract_files --start-offset 0 img-1756376495_vol-rootfs.ubifs
binwalk img-1756376495_vol-rootfs.ubifs
unsquashfs -d rootfs_extracted img-1756376495_vol-rootfs.ubifs
```

### The final commands for ubi extraction:
```
ubireader_extract_images ubi.img
```

```
ubireader_extract_files --start-offset 0 img-1756376495_vol-rootfs.ubifs
```
### Check what type of fs and if SquashFS, unsquash

```
file img-1756376495_vol-rootfs.ubifs
```

- or

```
binwalk img-1756376495_vol-rootfs.ubifs
```
- then 
```
unsquashfs -d rootfs_extracted img-1756376495_vol-rootfs.ubifs
```

---

## All that was required for this firmware was:

```
tar -xf openwrt-24.10.4-e02ce31c063e-mediatek-filogic-cudy_m3000-v1-squashfs-sysupgrade.bin
```

- and 

```
unsquashfs -d rootfs_extracted root
```

## Helpful `dumpimage` information. This was not used, but good for notes.

### Use `dumpimage` for information of `firmware_fit.itb`

```
dumpimage -l firmware_fit.itb
```

**Output:**
```
Image contains unit addresses @, this will break signing
FIT description: R37
Created:         Fri Jan  9 23:18:20 2026
 Image 0 (ubi)
  Description:  kernel-rootfs image
  Created:      Fri Jan  9 23:18:20 2026
  Type:         Firmware
  Compression:  uncompressed
  Data Size:    18874368 Bytes = 18432.00 KiB = 18.00 MiB
  Architecture: ARM
  OS:           Unknown OS
  Load Address: unavailable
  Hash algo:    crc32
  Hash value:   2a82c82d
```

**Note** `Image 0` is an index.

### Create `.bin` with dumpimage with `flat_dt` type and using the `0` index

```
dumpimage -T flat_dt -p 0 -o ubi.bin firmware_fit.itb
```
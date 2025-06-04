#!/bin/bash

#commit_hash_1="08ab82c57081b6ae49ca453954e3f1cf8141a3c5 88cc81eb9fcba13d3c25ce52d73fb41265810a86 3a8bf7115761859320bcd391654c315d07187986 dc918089ed959758abac94831e479489ff9ba159 a3432d04cacad2d41055f91d0b7743e85945abe8"
commit_hash_2="8eccc7ea3c315628d6d09d5d11c8ecd9467a27e8"

_log() { echo "[LOG] $*"; }
_err() { echo "[ERROR] $*" >&2; exit 1; }

download_and_apply() {
    local url=$1
    local patch_id=$2
    local attempts=5
    local delay=60

    for attempt in $(seq $attempts); do
        _log "Attempting to download patch $patch_id... [$attempt/$attempts]"
        curl -sL "$url" -o tmp.patch
        if grep -q "<!DOCTYPE html>" tmp.patch; then
            _log "Rate limit detected, retrying in ${delay}s... [$attempt/$attempts]"
            sleep $delay
            delay=$((delay + 5))  # Increase delay with each retry
        else
            _log "Applying $patch_id"
            patch -p1 < tmp.patch || _err "Failed to apply $patch_id"
            rm -f tmp.patch
            return
        fi
    done

    _err "Failed to download $patch_id after $attempts attempts"
}

rm -f *.patch
a=0

# # Apply muichiro's commits
# for i in $commit_hash_1; do
#     download_and_apply "https://github.com/Muichiro-mt6768/kernel_xiaomi_mt6768/commit/$i.patch" "$i"
#     sleep 2  # 2 seconds delay between each patch application
# done

echo

# Apply backslashxx's commits
for i in $commit_hash_2; do
    download_and_apply "https://github.com/DimasAkbr29/Styrofoam-Kernel/commit/$i.patch" "$i"
    sleep 2  # 2 seconds delay between each patch application
done

git 
_log "All patches applied successfully!"

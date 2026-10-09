#!/bin/bash
# Rebinds the SYNA8019 I2C-HID touchpad without a full suspend/resume.
# Workaround for the AMDI0010/i2c_designware touchpad slowdown bug.
set -euo pipefail

DRIVER_PATH="/sys/bus/i2c/drivers/i2c_hid_acpi/"
DEVICE="i2c-SYNA32A5:00"

write() {
    local file="$1" value="$2"
    if ( echo -n "$value" > "$file" ) 2>/dev/null; then
        return 0
    fi
    echo -n "$value" | sudo tee "$file" >/dev/null
}

if [[ -e "$DRIVER_PATH/$DEVICE" ]]; then
    echo "Unbinding $DEVICE..."
    write "$DRIVER_PATH/unbind" "$DEVICE"
    sleep 1
else
    echo "$DEVICE not currently bound, skipping unbind."
fi

echo "Binding $DEVICE..."
write "$DRIVER_PATH/bind" "$DEVICE"
echo "Done."

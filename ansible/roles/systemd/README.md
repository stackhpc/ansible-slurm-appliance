# systemd

Create drop-in files for systemd services.

# Role Variables
- `systemd_dropins`: Required. A mapping where keys = systemd service name, values are a dict as follows:
    - `group`: Required str. Inventory group this drop-in applies to.
    - `comment`: Optional str. Comment describing reason for drop-in.
    - `content`: Required str. Content of drop-in file.
# systemd

Create drop-in files for systemd services.

# Role Variables
- `systemd_dropins`: Required. A mapping where keys = systemd service name, values are a dict as follows:
    - `group`: Required str. Inventory group this drop-in applies to.
    - `comment`: Optional str. Comment describing reason for drop-in.
    - `content`: Required str. Content of drop-in file.
- `systemd_restart`: Optional bool. Whether to reload unit definitions and restart services. Default `false`.

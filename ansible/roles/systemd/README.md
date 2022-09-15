# systemd

Create drop-in files for systemd units.

# Role Variables
- `systemd_dropins`: Optionalist. Each element is a mapping with 
    - `unit`: Required str, name of systemd unit.
    - `group`: Required str. Inventory group this drop-in applies to.
    - `comment`: Optional str. Comment describing reason for drop-in.
    - `content`: Required str. Content of drop-in file.
# systemd

# systemd

Create drop-in files for systemd units.

# Role Variables
- `systemd_dropins`: Optional list. Each element is a mapping with:
    - `unit`: Required str, name of systemd unit.
    - `group`: Required str. Inventory group this drop-in applies to.
    - `comment`: Optional str. Comment describing reason for drop-in.
    - `content`: Required str. Content of drop-in file.
- `systemd_restart`: Optional bool. Whether to reload relevant unit definitions and restart. Default `false`, as usually 
  this role will run before the units even exist.

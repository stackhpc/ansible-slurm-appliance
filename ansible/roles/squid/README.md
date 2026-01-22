# squid

Deploy a caching proxy.

**NB:** This role provides two default configurations, selected by setting
`squid_conf_mode`:

- `eessi`: Default. This provides a proxy server for EESSI clients. It uses the
  [recommended configuration](https://www.eessi.io/docs/tutorial/access/proxy/#configuration).
  See [docs/eessi.md#eessi-proxy-configuration](./eessi.md#eessi-proxy-configuration)
  for more information and general proxy node recommendations.

- `general`: This is aimed at providing a proxy for package installs etc.
  for nodes which do not have direct internet connectivity. It assumes access
  to the proxy is protected by the OpenStack security groups applied to the
  cluster. The generated configuration should be reviewed if this is not case.

## Role Variables

Where noted these map to squid parameters of the same name without the `squid_` prefix - see [squid documentation](https://www.squid-cache.org/Doc/config) for details.

## Both modes
These role variables apply to both `squid_conf_mode` settings.

- `squid_conf_mode`: Optional str, `default` (the default) or `eessi`. See above.
- `squid_conf_template`: Optional str. Path (using Ansible search paths) to
  squid.conf template. Default is in-role templates. If this is overriden then
  `squid_conf_mode` has no effect.
- `squid_http_port`: Optional str. Socket addresses to listen for client requests,
  default '3128'. See squid parameter.
- `squid_cache_mem`: Optional str. Size of memory cache, e.g "1024 KB", "12 GB"
  etc. Default`'1024 MB'` which is recommended size for EESSI cache - should
  probably be increased for `general` mode. See squid parameter.
- `squid_cache_dir`: Optional. Path to cache directory. Default `/var/spool/squid`.
- `squid_cache_disk`: Optional int. Size of IFS disk cache in MB. Default 50000
  (50GB) which is recommended size for EESSI cache. For general use, see advice
  for `Mbytes` parameter under "ufs" type of [cache_dir](https://www.squid-cache.org/Doc/config/cache_dir/).
- `squid_maximum_object_size_in_memory`: Optional str. Upper size limit for
  objects in memory cache. Default '128 KB'/'64 MB' for `eessi`/`general` modes
  respectively. See squid parameter.
- `squid_maximum_object_size`: Optional str. Upper size limit for objects in
  disk cache. Default '1024 MB'/'200 MB' for `eessi`/`general` modes
  respectively. See squid parameter.
- `squid_local_nodes_cidr`: Optional str. CIDR or address range of nodes allowed
  to connect to squid. Default is CIDR of subnet for first cluster network. See
  squid docs for [acl src](https://www.squid-cache.org/Doc/config/acl/).
- `squid_started`: Optional bool. Whether to start squid service. Default `true`.
- `squid_enabled`: Optional bool. Whether squid service is enabled on boot. Default `true`.

### Role Variables for squid_conf_mode: general

- `squid_acls`: Optional str, can be multiline. Define access lists. Default is
  `acl local_nodes src {{ squid_local_nodes_cidr }}`, i.e. only permit connections
  from address in defined CIDR. In this mode acls for `SSL_ports` and `Safe_ports`
  are also defined as is common practice.
- `squid_http_access`: Optional str, can be multiline. Allow/deny access based
  on access lists. Default:

    ```text
    # Deny requests to certain unsafe ports
    http_access deny !Safe_ports
    # Deny CONNECT to other than secure SSL ports
    http_access deny CONNECT !SSL_ports
    # Only allow cachemgr access from localhost
    http_access allow localhost manager
    http_access deny manager
    # Rules allowing http access
    http_access allow local_nodes
    http_access allow localhost
    # Finally deny all other access to this proxy
    http_access deny all
    ```

  See squid parameter.

### Role Variables for squid_conf_mode: eessi

- `squid_eessi_stratum_1`: Optional str. Domain (in squid `acl dstdomain`
  format) of Stratum 1 replica servers. Defaults to upstream EEESI Stratum 1
  servers.

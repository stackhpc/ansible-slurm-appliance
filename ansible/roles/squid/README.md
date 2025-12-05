# squid

Deploy a caching proxy.

**NB:** This role provides two default configurations, selected by setting
`squid_conf_mode`:
- `default`: This is aimed at providing a proxy for package installs etc.
  for nodes which do not have direct internet connectivity. It assumes access
  to the proxy is protected by the OpenStack security groups applied to the
  cluster. The generated configuration should be reviewed if this is not case.
- `eessi`: This provides a proxy server for EESSI clients. It uses the
  [recommended configuration](https://www.eessi.io/docs/tutorial/access/proxy/#configuration)
  which assumes a server with:
      - 10Gbit link or faster to the client systems
      - a sufficiently powerful CPU
      - a decent amount of memory for the kernel cache (tens of GBs)
      - fast local storage - 50GB is used for cache
  For this use-case the above link recommends at least two squid servers and at
  least one for every (100-500) client nodes.

## Role Variables

- `squid_conf_mode`: Optional str, `default` (the default) or `eessi`. See above.
- `squid_conf_template`: Optional str. Path (using Ansible search paths) to
  squid.conf template. Default is in-role templates. If this is overriden then
  `squid_conf_mode` has no effect.

### Role Variables for squid_conf_mode: default

Where noted these map to squid parameters of the same name without the `squid_` prefix - see [squid documentation](https://www.squid-cache.org/Doc/config) for details.
- `squid_started`: Optional bool. Whether to start squid service. Default `true`.
- `squid_enabled`: Optional bool. Whether squid service is enabled on boot. Default `true`.
- `squid_cache_mem`: Required str. Size of memory cache, e.g "1024 KB", "12 GB" etc. See squid parameter.
- `squid_cache_dir`: Optional. Path to cache directory. Default `/var/spool/squid`.
- `squid_cache_disk`: Required int. Size of disk cache in MB. See Mbytes under "ufs" store type for squid parameter [cache_dir](https://www.squid-cache.org/Doc/config/cache_dir/).
- `squid_maximum_object_size_in_memory`: Optional str. Upper size limit for objects in memory cache, default '64 MB'. See squid parameter.
- `squid_maximum_object_size`: Optional str. Upper size limit for objects in disk cache, default '200 MB'. See squid parameter.
- `squid_http_port`: Optional str. Socket addresses to listen for client requests, default '3128'. See squid parameter.
- `squid_acls`: Optional str, can be multiline. Define access lists. Default `acl anywhere src all`, i.e. rely on OpenStack security groups (or other firewall if deployed). See squid parameter `acl`. NB: The default template also defines acls for `SSL_ports` and `Safe_ports` as is common practice.
- `squid_http_access`: Optional str, can be multiline. Allow/deny access based on access lists. Default:

        # Deny requests to certain unsafe ports
        http_access deny !Safe_ports
        # Deny CONNECT to other than secure SSL ports
        http_access deny CONNECT !SSL_ports
        # Only allow cachemgr access from localhost
        http_access allow localhost manager
        http_access deny manager
        # Rules allowing http access
        http_access allow anywhere
        http_access allow localhost
        # Finally deny all other access to this proxy
        http_access deny all

  See squid parameter.

### Role Variables for squid_conf_mode: eessi

- `squid_eessi_clients`: Optional str. CIDR specifying clients allowed to access
  this proxy. Default is the CIDR for the subnet of the [access network](../../../docs/networks.md),
  i.e. the first cluster network. For clusters with multiple networks this may
  need overriding.
- `squid_eessi_stratum_1`: Optional str. Domain (in squid `acl dstdomain`
  format) of Stratum 1 replica servers. Defaults to upstream EEESI Stratum 1
  servers.
- `squid_cache_dir`: See definition for default mode above.

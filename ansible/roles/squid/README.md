# squid

Deploy a caching proxy.

**NB:** The default configuration is aimed at providing a proxy for package installs etc. for
nodes which do not have direct internet connectivity. It assumes access to the proxy is protected
by the OpenStack security groups applied to the cluster. The generated configuration should be
reviewed if this is not case.

## Role Variables

Where noted these map to squid parameters of the same name without the `squid_` prefix - see [squid documentation](https://www.squid-cache.org/Doc/config) for details.

- `squid_conf_template`: Optional str. Path (using Ansible search paths) to squid.conf template. Default is in-role template.
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

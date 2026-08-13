flavor = "vm.ska.cpu.general.small"
networks = ["4b6b2722-ee5b-40ec-8e52-a6610e14cc51"] # portal-internal (DNS broken on ilab-60)
security_groups = ["default", "SSH"]
floating_ip_network = "CUDN-Internet" # Use FIP to avoid docker ratelimits on portal-internal outbound IP

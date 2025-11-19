variable "environment_root" {
   type = string
   description = "Path to environment root, automatically set by activate script"
}

module "cluster" {
    source = "../../site/tofu/"

    cluster_name = "slurm-production"
    cluster_image_id = "8cdcd255-c6c2-4131-9901-6a6b25b859f0" # openhpc-250910-1710-f605b7d8
    cluster_networks = [
      {
        network = "slurm-production-control-net"
        subnet = "slurm-production-control-subnet"
        set_dns_name = true
      },
      {
        network = "slurm-production-rdma-net"
        subnet = "slurm-production-rdma-subnet"
        no_security_groups: true
        port_security_enabled: false
      },
      {
        network = "external-ceph"
        subnet = "external-ceph"
      }
    ]
    compute = {
      # Group name used for compute node partition definition
      general-compute1 = {
          nodes: [
           "vcompute000",
           "vcompute001",
           "vcompute002",
           "vcompute003",
           "vcompute004",
           "vcompute005",
           "vcompute006",
          ]
          hypervisor_hostname: "compute1"
          flavor: "hpc.v1.32cpu.128ram"
          availability_zone = "DL-Rack-5"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
	    "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-compute2 = {
          nodes: [
           "vcompute007",
           "vcompute008",
           "vcompute009",
           "vcompute010",
           "vcompute011",
           "vcompute012",
           "vcompute013",
          ]
          hypervisor_hostname: "compute2"
          flavor: "hpc.v1.32cpu.128ram"
          availability_zone = "DL-Rack-5"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-compute3 = {
          nodes: [
           "vcompute014",
           "vcompute015",
           "vcompute016",
           "vcompute017",
           "vcompute018",
           "vcompute019",
           "vcompute020",
          ]
          hypervisor_hostname: "compute3"
          flavor: "hpc.v1.32cpu.128ram"
          availability_zone = "DL-Rack-5"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-compute4 = {
          nodes: [
           "vcompute021",
           "vcompute022",
           "vcompute023",
           "vcompute024",
           "vcompute025",
           "vcompute026",
           "vcompute027",
          ]
          hypervisor_hostname: "compute4"
          flavor: "hpc.v1.32cpu.128ram"
          availability_zone = "DL-Rack-5"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-compute5 = {
          nodes: [
           "vcompute028",
           "vcompute029",
           "vcompute030",
           "vcompute031",
           "vcompute032",
           "vcompute033",
           "vcompute034",
          ]
          hypervisor_hostname: "compute5"
          flavor: "hpc.v1.32cpu.128ram"
          availability_zone = "DL-Rack-5"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-compute6 = {
          nodes: [
           "vcompute035",
           "vcompute036",
           "vcompute037",
           "vcompute038",
           "vcompute039",
           "vcompute040",
          ]
          hypervisor_hostname: "compute6"
          flavor: "hpc.v1.32cpu.128ram"
          availability_zone = "DL-Rack-5"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute9 = {
          nodes: [
           "vcompute041",
           "vcompute042",
           "vcompute043",
           "vcompute044",
           "vcompute045",
           "vcompute046",
           "vcompute047",
           "vcompute048",
           "vcompute049",
           "vcompute050",
           "vcompute051",
          ]
          hypervisor_hostname: "compute9"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-6"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute10 = {
          nodes: [
           "vcompute052",
           "vcompute053",
           "vcompute054",
           "vcompute055",
           "vcompute056",
           "vcompute057",
           "vcompute058",
           "vcompute059",
           "vcompute060",
           "vcompute061",
           "vcompute062",
          ]
          hypervisor_hostname: "compute10"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-6"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute11 = {
          nodes: [
           "vcompute063",
           "vcompute064",
           "vcompute065",
           "vcompute066",
           "vcompute067",
           "vcompute068",
           "vcompute069",
           "vcompute070",
           "vcompute071",
           "vcompute072",
           "vcompute073",
          ]
          hypervisor_hostname: "compute11"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-6"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute12 = {
          nodes: [
           "vcompute074",
           "vcompute075",
           "vcompute076",
           "vcompute077",
           "vcompute078",
           "vcompute079",
           "vcompute080",
           "vcompute081",
           "vcompute082",
           "vcompute083",
           "vcompute084",
          ]
          hypervisor_hostname: "compute12"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-6"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute13 = {
          nodes: [
           "vcompute085",
           "vcompute086",
           "vcompute087",
           "vcompute088",
           "vcompute089",
           "vcompute090",
           "vcompute091",
           "vcompute092",
           "vcompute093",
           "vcompute094",
           "vcompute095",
          ]
          hypervisor_hostname: "compute13"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-6"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
#      general-gen2-compute14 = {
#          nodes: [
#           "vcompute096",
#           "vcompute097",
#           "vcompute098",
#           "vcompute099",
#           "vcompute100",
#           "vcompute101",
#           "vcompute102",
#           "vcompute103",
#           "vcompute104",
#           "vcompute105",
#           "vcompute106",
#          ]
#          hypervisor_hostname: "compute14"
#          flavor: "hpc.v2.32cpu.128ram"
#          availability_zone = "DL-Rack-6"
#          vnic_types = {
#            "slurm-production-control-net": "normal"
#            "slurm-production-rdma-net": "direct"
#            "external-ceph": "direct"
#          }
#          ignore_image_changes: true
#          compute_init_enable = [
#            "compute",
#            "etc_hosts",
#            "tuned",
#            "nfs",
#            "manila",
#            "basic_users",
#            "eessi",
#          ]
#      }
      general-gen2-compute15 = {
          nodes: [
           "vcompute107",
           "vcompute108",
           "vcompute109",
           "vcompute110",
           "vcompute111",
           "vcompute112",
           "vcompute113",
           "vcompute114",
           "vcompute115",
           "vcompute116",
           "vcompute117",
          ]
          hypervisor_hostname: "compute15"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-6"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute16 = {
          nodes: [
           "vcompute118",
           "vcompute119",
           "vcompute120",
           "vcompute121",
           "vcompute122",
           "vcompute123",
           "vcompute124",
           "vcompute125",
           "vcompute126",
           "vcompute127",
           "vcompute128",
          ]
          hypervisor_hostname: "compute16"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-6"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute17 = {
          nodes: [
          #  "vcompute129", vf error
          #  "vcompute130", vf error
           "vcompute131",
           "vcompute132",
           "vcompute133",
           "vcompute134",
           "vcompute135",
          #  "vcompute136", vf error
           "vcompute137",
           "vcompute138",
           "vcompute139",
          ]
          hypervisor_hostname: "compute17"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-6"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute18 = {
          nodes: [
           "vcompute140",
           "vcompute141",
           "vcompute142",
           "vcompute143",
           "vcompute144",
           "vcompute145",
          #  "vcompute146", vf error
           "vcompute147",
           "vcompute148",
          #  "vcompute149", vf error
           "vcompute150",
          ]
          hypervisor_hostname: "compute18"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-6"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute19 = {
          nodes: [
           "vcompute151",
           "vcompute152",
           "vcompute153",
           "vcompute154",
           "vcompute155",
           "vcompute156",
           "vcompute157",
          #  "vcompute158", not enough space, due to stuck vm rocky-ldap
           "vcompute159",
           "vcompute160",
           "vcompute161",
          ]
          hypervisor_hostname: "compute19"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-11"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute20 = {
          nodes: [
           "vcompute162",
           "vcompute163",
           "vcompute164",
           "vcompute165",
           "vcompute166",
           "vcompute167",
           "vcompute168",
           "vcompute169",
           "vcompute170",
           "vcompute171",
           "vcompute172",
          ]
          hypervisor_hostname: "compute20"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-11"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute21 = {
          nodes: [
           "vcompute173",
           "vcompute174",
           "vcompute175",
           "vcompute176",
           "vcompute177",
           "vcompute178",
           "vcompute179",
           "vcompute180",
           "vcompute181",
           "vcompute182",
           "vcompute183",
          ]
          hypervisor_hostname: "compute21"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-11"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute22 = {
          nodes: [
           "vcompute184",
           "vcompute185",
           "vcompute186",
           "vcompute187",
           "vcompute188",
           "vcompute189",
           "vcompute190",
           "vcompute191",
           "vcompute192",
           "vcompute193",
           "vcompute194",
          ]
          hypervisor_hostname: "compute22"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-11"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute23 = {
          nodes: [
           "vcompute195",
           "vcompute196",
           "vcompute197",
           "vcompute198",
           "vcompute199",
           "vcompute200",
           "vcompute201",
           "vcompute202",
           "vcompute203",
           "vcompute204",
           "vcompute205",
          ]
          hypervisor_hostname: "compute23"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-11"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute24 = {
          nodes: [
           "vcompute206",
           "vcompute207",
           "vcompute208",
           "vcompute209",
           "vcompute210",
           "vcompute211",
           "vcompute212",
           "vcompute213",
           "vcompute214",
           "vcompute215",
           "vcompute216",
          ]
          hypervisor_hostname: "compute24"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-11"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute25 = {
          nodes: [
           "vcompute217",
           "vcompute218",
           "vcompute219",
           "vcompute220",
           "vcompute221",
           "vcompute222",
           "vcompute223",
           "vcompute224",
           "vcompute225",
           "vcompute226",
           "vcompute227",
          ]
          hypervisor_hostname: "compute25"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-11"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute26 = {
          nodes: [
           "vcompute228",
           "vcompute229",
           "vcompute230",
           "vcompute231",
           "vcompute232",
           "vcompute233",
           "vcompute234",
           "vcompute235",
           "vcompute236",
           "vcompute237",
           "vcompute238",
          ]
          hypervisor_hostname: "compute26"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-11"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute27 = {
          nodes: [
           "vcompute239",
           "vcompute240",
           "vcompute241",
           "vcompute242",
           "vcompute243",
           "vcompute244",
           "vcompute245",
           "vcompute246",
           "vcompute247",
           "vcompute248",
           "vcompute249",
          ]
          hypervisor_hostname: "compute27"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-11"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      # general-gen2-compute28 = {
      #     nodes: [
      #      "vcompute250",
      #      "vcompute251",
      #      "vcompute252",
      #      "vcompute253",
      #      "vcompute254",
      #      "vcompute255",
      #      "vcompute256",
      #      "vcompute257",
      #      "vcompute258",
      #      "vcompute259",
      #      "vcompute260",
      #     ]
      #     hypervisor_hostname: "compute28"
      #     flavor: "hpc.v2.32cpu.128ram"
      #     availability_zone = "DL-Rack-11"
      #     vnic_types = {
      #       "slurm-production-control-net": "normal"
      #       "slurm-production-rdma-net": "direct"
      #       "external-ceph": "direct"
      #     }
      #     ignore_image_changes: true
      #     compute_init_enable = [
      #       "compute",
      #       "etc_hosts",
      #       "tuned",
      #       "nfs",
      #       "manila",
      #       "basic_users",
      #       "eessi",
      #     ]
      # }
      general-gen2-compute29 = {
          nodes: [
           "vcompute261",
           "vcompute262",
           "vcompute263",
           "vcompute264",
           "vcompute265",
           "vcompute266",
           "vcompute267",
           "vcompute268",
           "vcompute269",
           "vcompute270",
           "vcompute271",
          ]
          hypervisor_hostname: "compute29"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-12"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute30 = {
          nodes: [
           "vcompute272",
           "vcompute273",
           "vcompute274",
           "vcompute275",
           "vcompute276",
           "vcompute277",
           "vcompute278",
           "vcompute279",
           "vcompute280",
           "vcompute281",
           "vcompute282",
          ]
          hypervisor_hostname: "compute30"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-12"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute31 = {
          nodes: [
           "vcompute283",
           "vcompute284",
           "vcompute285",
           "vcompute286",
           "vcompute287",
           "vcompute288",
           "vcompute289",
           "vcompute290",
           "vcompute291",
           "vcompute292",
           "vcompute293",
          ]
          hypervisor_hostname: "compute31"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-12"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute32 = {
          nodes: [
           "vcompute294",
           "vcompute295",
           "vcompute296",
           "vcompute297",
           "vcompute298",
           "vcompute299",
           "vcompute300",
           "vcompute301",
           "vcompute302",
           "vcompute303",
           "vcompute304",
          ]
          hypervisor_hostname: "compute32"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-12"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute33 = {
          nodes: [
           "vcompute305",
           "vcompute306",
           "vcompute307",
           "vcompute308",
           "vcompute309",
           "vcompute310",
           "vcompute311",
           "vcompute312",
           "vcompute313",
           "vcompute314",
           "vcompute315",
          ]
          hypervisor_hostname: "compute33"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-12"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute34 = {
          nodes: [
           "vcompute316",
           "vcompute317",
           "vcompute318",
           "vcompute319",
           "vcompute320",
           "vcompute321",
           "vcompute322",
           "vcompute323",
           "vcompute324",
           "vcompute325",
           "vcompute326",
          ]
          hypervisor_hostname: "compute34"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-12"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute35 = {
          nodes: [
           "vcompute327",
           "vcompute328",
           "vcompute329",
           "vcompute330",
           "vcompute331",
           "vcompute332",
           "vcompute333",
           "vcompute334",
           "vcompute335",
           "vcompute336",
           "vcompute337",
          ]
          hypervisor_hostname: "compute35"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-12"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute36 = {
          nodes: [
           "vcompute338",
           "vcompute339",
           "vcompute340",
           "vcompute341",
           "vcompute342",
           "vcompute343",
           "vcompute344",
           "vcompute345",
           "vcompute346",
           "vcompute347",
           "vcompute348",
          ]
          hypervisor_hostname: "compute36"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-12"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute37 = {
          nodes: [
           "vcompute349",
           "vcompute350",
           "vcompute351",
           "vcompute352",
           "vcompute353",
           "vcompute354",
           "vcompute355",
           "vcompute356",
           "vcompute357",
           "vcompute358",
           "vcompute359",
          ]
          hypervisor_hostname: "compute37"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-12"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
      general-gen2-compute38 = {
          nodes: [
           "vcompute360",
           "vcompute361",
           "vcompute362",
           "vcompute363",
           "vcompute364",
           "vcompute365",
           "vcompute366",
           "vcompute367",
           "vcompute368",
           "vcompute369",
           "vcompute370",
          ]
          hypervisor_hostname: "compute38"
          flavor: "hpc.v2.32cpu.128ram"
          availability_zone = "DL-Rack-12"
          vnic_types = {
            "slurm-production-control-net": "normal"
            "slurm-production-rdma-net": "direct"
            "external-ceph": "direct"
          }
          ignore_image_changes: true
          compute_init_enable = [
            "compute",
            "etc_hosts",
            "tuned",
            "nfs",
            "manila",
            "basic_users",
            "eessi",
          ]
      }
     gpu-gpu1 = {
         nodes: [
           "vgpu000",
           "vgpu001",
         ]
         hypervisor_hostname: "gpu1"
         flavor: "gpu.v1.16cpu.128ram.a100"
         availability_zone = "DL-Rack-5"
         vnic_types = {
           "slurm-production": "direct"
           "external-ceph": "direct"
         }
         ignore_image_changes: true
     }
     gpu-gpu2 = {
         nodes: [
           "vgpu002",
           "vgpu003",
         ]
         hypervisor_hostname: "gpu2"
         flavor: "gpu.v1.16cpu.128ram.a100"
         availability_zone = "DL-Rack-5"
         vnic_types = {
           "slurm-production": "direct"
           "external-ceph": "direct"
         }
         ignore_image_changes: true
     }
     highmem-compute7 = {
         nodes: [
           "vhighmem000",
           "vhighmem001",
         ]
         hypervisor_hostname: "compute7"
         flavor: "mem.v1.56cpu.448ram"
         availability_zone = "DL-Rack-5"
         vnic_types = {
           "slurm-production": "direct"
           "external-ceph": "direct"
         }
         ignore_image_changes: true
     }
     highmem-compute8 = {
         nodes: [
           "vhighmem002",
           "vhighmem003",
         ]
         hypervisor_hostname: "compute8"
         flavor: "mem.v1.56cpu.448ram"
         availability_zone = "DL-Rack-5"
         vnic_types = {
           "slurm-production": "direct"
           "external-ceph": "direct"
         }
         ignore_image_changes: true
     }
    }

    login = {
        interactive = {
            nodes: ["bc5-login01"]
            flavor: "hpc.v1.16cpu.64ram"
            vnic_types = {
              "slurm-production-control-net": "normal"
              "slurm-production-rdma-net": "direct"
              "external-ceph": "direct"
            }
            hypervisor_hostname = "compute6"
            root_volume_size = 100
            server_group_id = openstack_compute_servergroup_v2.control.id
            fip_addresses:  ["10.3.0.89"]
            fip_network: "slurm-production-control-net"
        }
    }

    control_server_group_id = openstack_compute_servergroup_v2.control.id
    control_node_hypervisor_hostname = "compute6"

    environment_root = var.environment_root
}

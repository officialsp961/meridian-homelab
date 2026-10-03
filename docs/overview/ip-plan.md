Based on struture from current employer, with my own changes.

10.10.10.1			            	Gateway (Hyper-V host NAT)
10.10.10.10			            	DC01 (also primary DNS)
10.10.10.11			            	DC02 (also secondary DNS)
10.10.10.20			            	FS01 file server
10.10.10.21			            	PS01 print server
10.10.10.30			            	MGMT01 admin workstation
10.10.10.50 to 10.10.10.59	    	Printers (static)
10.10.10.100 to 10.10.10.200		DHCP scope for clients
Subnet mask				            255.255.255.0 (/24)
DNS				                	10.10.10.10, 10.10.10.11
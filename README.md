# hetzner-ip-floater

Minimalistic floating IP setter for container clusters using Docker Swarm running on [Hetzner Cloud](https://www.hetzner.com/cloud).

## Usage

This project should be used as a container. It will run once and update a given floating IP to point to the node currently running it. This can be used to ensure the floating IP will be reassigned upon node failure, by relying on the underlying cluster to redeploy this service on a healthy node.

### Configure IPs

You need to configure the floating IPs for the machines you'll use. If you have 3 IPs you'll need to add all 3. Even though the IPs conflict, Hetzner has assured me there will be no issues `You can have the floating IP configured within multiple servers but as it is routed only to the server where the IP is assinged to no issue will occur.` (Hetzner Support).

https://wiki.hetzner.de/index.php/Cloud_floating_IP_persistent/en

Or add these for each IP. On debian flavours `vi /etc/network/interfaces.d/60-my-floating-ip.cfg`:
```
auto eth0:1
iface eth0:1 inet static
    address your.Float.ing.IP
    netmask 32
```

If you have more than one, do eth0:2, eth0:3 etc...

### Configure Docker Swarm

This is an example deployment for `docker stack deploy`:
```yaml
services:
  lb1:
    image: costela/hetzner-ip-floater
    secrets:
      - hetzner_api_key_for_floating_ip  # set via `docker secret create`
    environment:
      API_KEY_FILE: /run/secrets/hetzner_api_key_for_floating_ip
      TARGET_HOST: '{{ .Node.Hostname }}'  # uses docker swarm's templating to get node name
      FLOATING_IP_ID: 12345  # taken from Hetzner cloud console
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.labels.load_balancer == true      
      restart_policy:
        condition: any          
```

This assumes the node's hostnames are the same as their API names, which is the case unless the hostname has been changed after provisioning.

## Other considerations

The deployment of `hetzner-ip-floater` should be limited to those nodes where the floating IP is locally configured, otherwise incoming trafic will be dropped. I use the constraint veriable in the docker stack compose file to achieve this.

The same nodes should also be configured as ingress nodes. When using the [default mesh networking](https://docs.docker.com/engine/swarm/ingress/) on docker swarm, this is already the case for all worker nodes.

## Credits
* Thanks to this fella I didn't have to write it.
[Original Author](https://github.com/costela)

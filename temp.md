**Peerings for Vnet-to-Vnet connectivity:**

- For the Vnet-to-Vnet connectivity, we will use Peering. The Vnets will be all connected using **Vnet Peering**, the cross-region peering is also called **Global Vnet Peering**. This approach will demonstrate that Virtual Networks can establish connectivity with each other easily by using Virtual Network Peering, including the usage of a remote Gateway to communicate with On-Premises environments.

<br>

### Network Security Groups (NSG)

Five Network Security Groups will be created, one for each Subnet of each Vnet, for firewall (layer 4-ACLs) protection. This offers initial network traffic protection for all Virtual Machines.

   > <div class="alert is-info">
   > **NOTE:**
   >
   > Additional protection layers/resources such as Azure Firewall, Application Gateway, Network Virtual Appliances (NVAs – Layer 7 Firewalls), are out of the scope of this PoC in this current version.
   > </div>

<br>

# pcf-patch
A temporary repository to store scripts for patching Ops Manager, and the deployed director.

If you are upgrading 1.4.2.0, follow these steps top to bottom.  If you are upgrading 1.5.2.0, then skip the second section.

## Patching Ops Manager
1. If you didn't already have Ops Manager deployed, upload and deploy a clean Ops Manager OVA to your vCA environment. Configure the OVA properties appropriately, and then start it up. Login to the web UI, and make sure it is running ok. Don't configure the vCloud tile or add any other tiles yet!
2. SSH to Ops Manager with the tempest account and the password you used to deploy the OVA.
3. Run the patcher script:
	curl raw.githubuserc...aster/patchy.sh | bash
4. Restart tempest-web:
	sudo service tempest-web stop; sudo service tempest-web start
5. Now, if this is fresh deploy of Ops Manager, go back to the Ops Manager web interface, and configure the vCloud tile with the settings appropriate for your environment, and save the config. Don't add any other tiles yet. Click "Apply" to let Ops Manager deploy the Director VM, which we'll patch next to allow you to install other products.

## Patching the Director VM
Skip these steps if you are upgrading Ops Manager 1.5.2.0

1. After Ops Manager has successfully deployed the Director VM, you need to get the VM credentials and IP for the that VM. Click on the vCloud Tile in Ops Manager, and select the "Status" tab to find the IP for the deployed director VM. Then click on the "Credentials" tab to get the password for the vcap user for the VM.
2. SSH to the Director VM, and run the patcher script:
	curl raw.githubuserc...aster/patchy.sh | bash
3. Exit out of the director VM SSH session, and then exit out of the Ops Manager SSH session.
4. Install the rest of your products as normal.
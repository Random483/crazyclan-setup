


### Step 1: Ensure your network is set up correctly

``` bash
hostnamectl set-hostname vm1.crazyclan.lan
```

### Step 2: Install Git

``` bash
sudo apt update
sudo apt install -y git
```

### Step 3: Clone the crazyclan-setup repository

``` bash
git clone https://github.com/Random483/crazyclan-setup.git
cd crazyclan-setup
```

### Step 4: Make Executable and Run the Setup Script

``` bash
chmod +x bootstrap.sh scripts/*.sh
sudo ./bootstrap.sh
```
### Step 5: Ensure users can log in

If using a distribution that doesn't allow usernames to be typed by default, change this setting.

Edit the SSSD settings to ensure correct configuration

``` bash
sudo nano /etc/sssd/sssd.conf
```

Then under 

```
[domain/yourdomain]
sudo_provider = ipa
enumerate = true
filter_users = admin,jellyfin-bind,nextcloud-bind,organizr-bind
```

Then restart SSSD via:

``` bash
sudo systemctl restart sssd
```

### Step 6: Connect Nextcloud

In one of the steps, we installed Nextcloud desktop app. Now, for each user, we need to configure it.

1. Open the Nextcloud configuration app
2. Add the URL for your Nextcloud install: `cloud.crazyclan.lan`
3. Follow the on-screen instructions to log in and sync
4. Run the DE sync file to create symbolic links `sudo bash scripts/22-sync-de-settings.sh`

### Step 7: Set up Minecraft

For kids who play Minecraft, using MultiMC set the Instance and Skins folders to connect to the Nextcloud folder.

### Step 8: Set up sym-links

After Minecraft has been run, it's safe to create the symlinks for all folders:

``` bash
mc -r ~/Documents/* ~/Nextcloud/Documents
rm -r ~/Documents
ln -s ~/Nextcloud/Documents ~/Documents
mc -r ~/Pictures/* ~/Nextcloud/Photos
rm -r ~/Pictures
ln -s ~/Nextcloud/Photos ~/Pictures
ln -s ~/Nextcloud/.Minecraft/saves ~/.minecraft/saves
```

### Step 9: Set-up hosts file

This is a fallback in case the DNS goes down. I don't want to maintain this on every PC, but DNS hasn't always been reliable, so below is the MVP I want to remember:

```
192.168.10.26     ipa.crazyclan.lan
192.168.10.25     nas.crazyclan.lan
192.168.10.25     cloud.crazyclan.lan
192.168.10.25     jelly.crazyclan.lan
```
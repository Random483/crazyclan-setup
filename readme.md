


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


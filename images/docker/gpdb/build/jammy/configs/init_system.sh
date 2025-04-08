# --------------------------------------------------------------------
# Container Initialization Script
# --------------------------------------------------------------------

# --------------------------------------------------------------------
# Configure passwordless SSH access for 'gpadmin' user
# --------------------------------------------------------------------
# The script sets up SSH key-based authentication for the 'gpadmin' user,
# allowing passwordless SSH access. It generates a new SSH key pair if one
# does not already exist, and configures the necessary permissions.
# --------------------------------------------------------------------
mkdir -p /home/gpadmin/.ssh
chmod 700 /home/gpadmin/.ssh

ssh-keygen -f /home/gpadmin/.ssh/id_rsa -N ''
cat /home/gpadmin/.ssh/id_rsa.pub >> /home/gpadmin/.ssh/authorized_keys
chmod 600 /home/gpadmin/.ssh/authorized_keys

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
sudo service ssh start
ssh -o StrictHostKeyChecking=no gpadmin@$(hostname) "echo 'Hello world'"

# --------------------------------------------------------------------
# Configure limits
# --------------------------------------------------------------------
sudo bash -c 'cat >> /etc/ld.so.conf <<-EOF
/usr/local/lib

EOF'
sudo ldconfig

sudo bash -c 'cat >> /etc/sysctl.conf <<-EOF
kernel.shmmax = 500000000
kernel.shmmni = 4096
kernel.shmall = 4000000000
kernel.sem = 500 1024000 200 4096
kernel.sysrq = 1
kernel.core_uses_pid = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.msgmni = 2048
net.ipv4.tcp_syncookies = 1
net.ipv4.ip_forward = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.conf.all.arp_filter = 1
net.ipv4.ip_local_port_range = 1025 65535
net.core.netdev_max_backlog = 10000
net.core.rmem_max = 2097152
net.core.wmem_max = 2097152
vm.overcommit_memory = 2

EOF'

sudo bash -c 'cat >> /etc/security/limits.conf <<-EOF
* soft nofile 65536
* hard nofile 65536
* soft nproc 131072
* hard nproc 131072

EOF'

# --------------------------------------------------------------------
# Display a Welcome Banner
# --------------------------------------------------------------------
# The following ASCII art and welcome message are displayed when the
# container starts. This banner provides a visual indication that the
# container is running in the Greenplum Build Environment.
# --------------------------------------------------------------------
cat <<-'EOF'

======================================================================

                          ++++++++++       ++++++
                        ++++++++++++++   +++++++
                       ++++        +++++ ++++
                      ++++          +++++++++
                   =+====         =============+
                 ========       =====+      =====
                ====  ====     ====           ====
               ====    ===     ===             ====
               ====            === ===         ====
               ====            ===  ==--       ===
                =====          ===== --       ====
                 =====================     ======
                   ============================
                                     =-----=
        __  __                     _     _         _____  ____  
       |  \/  |                   | |   | |       |  __ \|  _ \ 
       | \  / | ___  _ __ ___  ___| |__ | | ____ _| |  | | |_) |
       | |\/| |/ _ \| '__/ _ \/ __| '_ \| |/ / _` | |  | |  _ < 
       | |  | | (_) | | | (_) \__ \ | | |   < (_| | |__| | |_) |
       |_|  |_|\___/|_|  \___/|___/_| |_|_|\_\__,_|_____/|____/ 
----------------------------------------------------------------------

EOF

# --------------------------------------------------------------------
# Display System Information
# --------------------------------------------------------------------
# The script sources the /etc/os-release file to retrieve the operating
# system name and version. It then displays the following information:
# - OS name and version
# - Current user
# - Container hostname
# - IP address
# - CPU model name and number of cores
# - Total memory available
# - Greenplum version (if installed)
# This information is useful for users to understand the environment they
# are working in.
# --------------------------------------------------------------------
source /etc/os-release

# First, create the CPU info detection function
get_cpu_info() {
   ARCH=$(uname -m)
   if [ "$ARCH" = "x86_64" ]; then
       lscpu | grep 'Model name:' | awk '{print substr($0, index($0,$3))}'
   elif [ "$ARCH" = "aarch64" ]; then
       VENDOR=$(lscpu | grep 'Vendor ID:' | awk '{print $3}')
       if [ "$VENDOR" = "Apple" ] || [ "$VENDOR" = "0x61" ]; then
           echo "Apple Silicon ($ARCH)"
       else
           if [ -f /proc/cpuinfo ]; then
               IMPL=$(grep "CPU implementer" /proc/cpuinfo | head -1 | awk '{print $3}')
               PART=$(grep "CPU part" /proc/cpuinfo | head -1 | awk '{print $3}')
               if [ ! -z "$IMPL" ] && [ ! -z "$PART" ]; then
                   echo "ARM $ARCH (Implementer: $IMPL, Part: $PART)"
               else
                   echo "ARM $ARCH"
               fi
           else
               echo "ARM $ARCH"
           fi
       fi
   else
       echo "Unknown architecture: $ARCH"
   fi
}

# Check if Greenplum is installed and display its version
if dpkg -l greenplum-db-6 > /dev/null 2>&1; then
    GPDB_VERSION=$(/opt/greenplum-db-6/bin/postgres --gp-version)
else
    GPDB_VERSION="Not installed"
fi

cat <<-EOF
Welcome to the Greebplum Test Environment!

Greenplum version ... : $GPDB_VERSION
Container OS ........ : $NAME $VERSION
User ................ : $(whoami)
Container hostname .. : $(hostname)
IP Address .......... : $(hostname -I | awk '{print $1}')
CPU Info ............ : $(get_cpu_info)
CPU(s) .............. : $(nproc)
Memory .............. : $(free -h | grep Mem: | awk '{print $2}') total
======================================================================

EOF

# --------------------------------------------------------------------
# Start an interactive bash shell
# --------------------------------------------------------------------
# Finally, the script starts an interactive bash shell to keep the
# container running and allow the user to interact with the environment.
# --------------------------------------------------------------------
/bin/bash
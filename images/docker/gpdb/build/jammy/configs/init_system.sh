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
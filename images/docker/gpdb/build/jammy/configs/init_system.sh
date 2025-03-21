# --------------------------------------------------------------------
# Container Initialization Script
# --------------------------------------------------------------------


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
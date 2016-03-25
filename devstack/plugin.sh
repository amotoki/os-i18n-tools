# plugin.sh - DevStack plugin.sh dispatch script translation checksite

function preinstall_checksite_dependencies {
    :
}

function install_checksite_dependencies {
    :
}

function configure_checksite_dependencies {
    if is_service_enabled designate && is_service_enabled horizon; then
         # Bug 1561202
         echo "ADD_INSTALLED_APPS = ['designatedashboard']" \
             >> $HORIZON_DIR/openstack_dashboard/local/enabled/_1720_project_dns_panel.py

         # Compile message catalogs
         if [ -d ${DESIGNATEDASHBOARD_DIR}/designatedashboard/locale ]; then
             (cd ${DESIGNATEDASHBOARD_DIR}/designatedashboard; DJANGO_SETTINGS_MODULE=openstack_dashboard.settings ../manage.py compilemessages)
         fi
    fi
    if is_service_enabled murano && is_service_enabled horizon; then
         # Compile message catalogs
         if [ -d ${MURANO_DASHBOARD_DIR}/muranodashboard/locale ]; then
             (cd ${MURANO_DASHBOARD_DIR}/muranodashboard; DJANGO_SETTINGS_MODULE=openstack_dashboard.settings ../manage.py compilemessages)
         fi
    fi
}

# check for service enabled
if [[ "$1" == "stack" && "$2" == "pre-install"  ]]; then
    # Set up system services
    echo_summary "Preparing translation checksite"
    preinstall_checksite_dependencies

elif [[ "$1" == "stack" && "$2" == "install"  ]]; then
    # Perform installation of service source
    echo_summary "Installing translation checksite"
    install_checksite_dependencies

elif [[ "$1" == "stack" && "$2" == "post-config"  ]]; then
    # Configure after the other layer 1 and 2 services have been configured
    echo_summary "Configuring translation checksite"
    configure_checksite_dependencies

elif [[ "$1" == "stack" && "$2" == "extra"  ]]; then
    # Initialize and start the service
    # no-op
    :
fi

if [[ "$1" == "unstack"  ]]; then
    # Shut down services
    # Remove Horizon plugin enabled files
    rm -f $HORIZON_DIR/openstack_dashboard/local/enabled/_[0-9]*.{py,pyc}
fi

if [[ "$1" == "clean"  ]]; then
    # Remove state and transient data
    # Remember clean.sh first calls unstack.sh
    # no-op
    :
fi

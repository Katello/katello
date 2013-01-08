Set of scripts for generating dummy repos

Usage:
 create_repo.sh -d <DEFINITION_DIRECTORY> -o <OUTPUT_DIRECTORY>

Environment:

Various prerequisites are required to use this script correctly. We
recommend installing the Katello stack using the katello-configure
tool for the simplicity of usage.

Once Katello installed, we need pulp-admin set up (which these scripts
rely on):

    yum install pulp-admin
    sed -i "s/localhost\\.localdomain/$(hostname)/" /etc/pulp/admin/admin.conf
    service-wait pulp-server restart
    PULP_PWD="$(cat /etc/pulp/pulp.conf | grep '^default_password' | cut -d' ' -f 2)"
    pulp-admin auth login --username admin \
                          --password "$PULP_PWD"

Also rpmbuild is required.

Definition directory must contain:
packagelist.txt
  File with package definition. One package per line.
  Format:  name  version  release  "comma,separated,list,of,dependencies"

grouplist.txt
  Holds package group definition. One group/category per line.
  Format:  @groupname     comma.separated,list,of,packages
           #categoryname  @list,@of,@categories

errata.txt
  Holds errata deinition. One erratum per line.
  Format:  erratum-id  erratum-title  list,of,package,filenames


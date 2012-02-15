Set of scripts for generating dummy repos

Usage:
 create_repo.sh <PULP_REPO_ID> <DEFINITION_DIRECTORY>

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


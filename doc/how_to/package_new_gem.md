# How to package new gem

This document is roughly describing what has to be done to add new gem dependency. Right now this
process involves `katello-thirdparty` repository which is not publicly accessible. We are sorry about that 
and we will try to fix it in future. For now please contact one of the core developers for help.

*   go to `katello-thirdparty` repo

        cd katello-thirdparty

    `katello-thirdparty` is currently not public, we are sorry about that. To 

*   create directory for new gem

        mkdir rubygem-#{gemname} 
        cd rubygem-#{gemname}

*   download the gem

        !!!txt
        gem fetch #{gemname}

*   copy template

        cp ../rubygem-template.spec ./rubygem-#{gemname}.spec

*   edit parts marked with `# EDIT` in the copied template
*   commit the spec file and downloaded gem
*   tag the new gem

        tito tag

*   test if it builds locally (example taken from rhel6)

        tito build --test --rpm
        tito build --test --rpm --scl ruby193

*   tag it in Koji (tags may change)

        koji -c ~/.koji/katello-config add-pkg --owner=#{your_name} katello-thirdparty-fedora18 rubygem-#{gemname}
        koji -c ~/.koji/katello-config add-pkg --owner=#{your_name} katello-thirdparty-fedora19 rubygem-#{gemname}
        koji -c ~/.koji/katello-config add-pkg --owner=#{your_name} katello-thirdparty-rhel6    ruby193-rubygem-#{gemname}

*   test scratch build (match --dist with tag)

        tito build --test --srpm --dist=.el6
        koji -c ~/.koji/katello-config build --scratch katello-thirdparty-rhel6 <name-of-src-rpm-from-previous-command>

*   push to `katello-thirdparty`, commit and tags

        git push origin master <tag-name>

*   release to Koji

        tito release koji

*   add package to comps files in `Katello/katello` repo

        rel-eng/comps/comps-katello-server-fedora18.xml
        rel-eng/comps/comps-katello-server-fedora19.xml
        rel-eng/comps/comps-katello-server-rhel6.xml


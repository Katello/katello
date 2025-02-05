 locales['katello'] = locales['katello'] || {}; locales['katello']['fr'] = {
  "domain": "katello",
  "locale_data": {
    "katello": {
      "": {
        "Project-Id-Version": "katello 2.4.0-RC1",
        "Report-Msgid-Bugs-To": "",
        "PO-Revision-Date": "2017-12-19 20:14+0000",
        "Last-Translator": "Amit Upadhye <aupadhye@redhat.com>, 2023",
        "Language-Team": "French (https://www.transifex.com/foreman/teams/114/fr/)",
        "MIME-Version": "1.0",
        "Content-Type": "text/plain; charset=UTF-8",
        "Content-Transfer-Encoding": "8bit",
        "Language": "fr",
        "Plural-Forms": "nplurals=3; plural=(n == 0 || n == 1) ? 0 : n != 0 && n % 1000000 == 0 ? 1 : 2;",
        "lang": "fr",
        "domain": "katello",
        "plural_forms": "nplurals=3; plural=(n == 0 || n == 1) ? 0 : n != 0 && n % 1000000 == 0 ? 1 : 2;"
      },
      "\\n* Product = '%{product}', Repository = '%{repository}'": [
        "\\n* Produit: '%%{product}', Repo: '%%{repository}'"
      ],
      " %{errata_count} Errata": [
        " %{errata_count} Errata"
      ],
      " %{modulemd_count} Module Stream(s)": [
        " %{modulemd_count} Flux de Module(s)"
      ],
      " %{package_count} Package(s)": [
        " %{package_count} Package(s)"
      ],
      " (${item.published_at_words} ago)": [
        ""
      ],
      " (${version.published_at_words} ago)": [
        ""
      ],
      " Content view updated": [
        " Affichage de contenu mis à jour"
      ],
      " DEBs": [
        " DEBs"
      ],
      " Either select the latest content view or the content view version. Cannot set both.": [
        "Sélectionnez soit la dernière vue du contenu, soit la version de la vue du contenu. On ne peut pas régler les deux."
      ],
      " RPMs": [
        " RPMs"
      ],
      " The base path can be a web address or a filesystem location.": [
        " Le chemin de base peut être une adresse web ou un emplacement de système de fichiers."
      ],
      " The base path must be a web address pointing to the root RHUI content directory.": [
        " Le chemin de base doit être une adresse web pointant vers le répertoire racine du contenu de RHUI."
      ],
      " View task details ": [
        " Détails de la tâche "
      ],
      " ago": [
        " Il y a"
      ],
      " ago.": [
        " Il y a "
      ],
      " and": [
        " et"
      ],
      " are out of the environment path order. The recommended practice is to promote to the next environment in the path.": [
        " sont en dehors de l'ordonnancement du chemin de l'environnement. La pratique recommandée est de passer à l'environnement suivant dans le chemin."
      ],
      " content view is used in listed composite content views.": [
        "l’affichage du contenu est utilisé dans les affichages de contenus composites"
      ],
      " content view is used in listed content views. For more information, ": [
        " l’affichage du contenu est utilisé dans les affichages de contenu de composants listés. Pour plus d’informations, "
      ],
      " environment cannot be set to an environment already on its path": [
        "l'environnement ne peut pas être définit sur un environnement se trouvant déjà sur son chemin"
      ],
      " found.": [
        "trouvé(e)(s)."
      ],
      " is out of the environment path order. The recommended practice is to promote to the next environment in the path.": [
        " est en dehors de l'ordonnancement du chemin de l'environnement. La pratique recommandée est de passer à l'environnement suivant dans le chemin."
      ],
      " or any step on the left.": [
        " ou n'importe quelle étape sur la gauche."
      ],
      " to manage and promote content views, or select a different environment.": [
        " pour gérer et promouvoir les vues de contenu, ou sélectionnez un autre environnement."
      ],
      "${deleteFlow ? 'Deleting' : 'Removing'} version ${versionNameToRemove}": [
        "Version"
      ],
      "${option}": [
        "${option}"
      ],
      "${pluralize(akResponse.length, 'activation key')} will be moved to content view ${selectedCVNameForAK} in ": [
        "{pluralize(akResponse.length, 'activation key')} Les hôtes de contenu seront déplacés{selectedCVNameForAK} vers  "
      ],
      "${pluralize(hostResponse.length, 'host')} will be moved to content view ${selectedCVNameForHosts} in ": [
        "{pluralize(hostResponse.length, 'host')} Les hôtes de contenu seront déplacés{selectedCVNameForHosts} vers  "
      ],
      "${pluralize(versionCount, 'content view version')} in the environments below will be removed when content view is deleted": [
        "{pluralize(versionCount, 'content view version')}(versionCount, 'content view version')} présent dans l’environnement ci-dessous sera supprimé une fois le contenu supprimé"
      ],
      "${selectedContentType}": [
        "{selectedContentType}"
      ],
      "${selectedContentType} will appear here when created.": [
        "{selectedContentType} apparaîtra ici une fois que vous l’aurez créé."
      ],
      "%s %s has %s Hosts and %s Hostgroups that will need to be reassociated post deletion. Delete %s?": [
        "%s%s a %s Hôtes et %s Groupes d’hôtes qui devront être réassociés après la suppression. Supprimer %s ?"
      ],
      "%s Available": [
        "%s Disponible"
      ],
      "%s Errata": [
        "%s Errata"
      ],
      "%s Host": [
        "%shôte",
        "%shôtes",
        "%shôtes"
      ],
      "%s Used": [
        "%sUtilisé(e)"
      ],
      "%s ago": [
        "Il y a %s"
      ],
      "%s content type is not enabled.": [
        ""
      ],
      "%s guests": [
        "%s invités"
      ],
      "%s has already been deleted": [
        "%s a déjà été supprimé"
      ],
      "%s is not a valid package name": [
        "%s n'est pas un nom de package valide"
      ],
      "%s is not a valid path": [
        "%s n'est pas un chemin valide"
      ],
      "%s is required": [
        "%s est requis"
      ],
      "%s is unreachable. %s": [
        "%s est inaccessible. %s "
      ],
      "%s was not found!": [
        ""
      ],
      "%{errata} (%{total} other errata)": [
        "%{errata} (%{total} autres errata )"
      ],
      "%{errata} (%{total} other errata) install canceled": [
        "Installation de %{errata} (%{total} autres errata) annulée"
      ],
      "%{errata} (%{total} other errata) install failed": [
        "%{errata} (%{total} autres errata) échec de l'installation"
      ],
      "%{errata} (%{total} other errata) install timed out": [
        "Délai d'expiration de l'installation de %{errata} (%{total} autres errata)  dépassé"
      ],
      "%{errata} (%{total} other errata) installed": [
        "Installation d'errata %{errata} (%{total} autres errata)"
      ],
      "%{errata} erratum install canceled": [
        "Annulation de l’installation de l'erratum %{errata}"
      ],
      "%{errata} erratum install failed": [
        "Échec de l'installation d'erratum %{errata}"
      ],
      "%{errata} erratum install timed out": [
        "Délai d'expiration de l'installation d'erratum %{errata} dépassé"
      ],
      "%{errata} erratum installed": [
        "Erratum %{errata} installé"
      ],
      "%{expiring_subs} subscriptions in %{subject} are going to expire in less than %{days} days. Please renew them before they expire to guarantee your hosts will continue receiving content.": [
        "Les abonnements en %{expiring_subs} de %{subject}  vont expirer dans moins de %{days} jours. Veuillez les renouveler avant leur expiration pour garantir que vos hôtes continueront à recevoir du contenu."
      ],
      "%{group} (%{total} other package groups)": [
        "%{group} (%{total} groupes de packages)"
      ],
      "%{group} (%{total} other package groups) install canceled": [
        "%{group} (%{total} groupes de packages) installation annulée"
      ],
      "%{group} (%{total} other package groups) install failed": [
        "%{group} (%{total} autres groupes de packages) échec de l'installation"
      ],
      "%{group} (%{total} other package groups) install timed out": [
        "%{group} (%{total} autres groupes de packages) délai d'expiration de l'installation dépassé"
      ],
      "%{group} (%{total} other package groups) installed": [
        "%{group}installé (%{total} autres groupes de packages)"
      ],
      "%{group} (%{total} other package groups) remove canceled": [
        "Suppression de %{group} annulée (%{total} autres groupes de packages)"
      ],
      "%{group} (%{total} other package groups) remove failed": [
        "Échec de la suppression de %{group} (%{total} autres groupes de packages)"
      ],
      "%{group} (%{total} other package groups) remove timed out": [
        "Délai d'expiration de la suppression de %{group} dépassé %{total} autres groupes de packages)"
      ],
      "%{group} (%{total} other package groups) removed": [
        "%{group} supprimé (%{total} autres groupes de packages)"
      ],
      "%{group} (%{total} other package groups) update canceled": [
        "Mise à jour de %{group} annulée (%{total} autres groupes de packages)"
      ],
      "%{group} (%{total} other package groups) update failed": [
        "Échec de la mise à jour de %{group} (%{total} autres groupes de packages)"
      ],
      "%{group} (%{total} other package groups) update timed out": [
        "Délai d'expiration de la mise à jour de %{group} dépassé (%{total} autres groupes de packages)"
      ],
      "%{group} (%{total} other package groups) updated": [
        "%{group} mis à jour (%{total} autres groupes de packages)"
      ],
      "%{group} package group install canceled": [
        "%{group}Installation du groupe de packages annulée"
      ],
      "%{group} package group install failed": [
        "Échec de l'installation du groupe de packages %{group}"
      ],
      "%{group} package group install timed out": [
        "Délai d'expiration de l'installation du groupe de packages %{group}dépassé"
      ],
      "%{group} package group installed": [
        "Installation du groupe de packages %{group}"
      ],
      "%{group} package group remove canceled": [
        "Suppression du groupe de packages %{group} annulée"
      ],
      "%{group} package group remove failed": [
        "%{group} échec de la suppression du groupe de packages"
      ],
      "%{group} package group remove timed out": [
        "Délai d'expiration de la suppression du groupe de packages %{group} dépassé"
      ],
      "%{group} package group removed": [
        "Suppression de groupes de packages %{group}"
      ],
      "%{group} package group update canceled": [
        "Mise à jour du groupe de packages %{group} annulée"
      ],
      "%{group} package group update failed": [
        "Échec de la mise à jour du groupe de packages %{group}"
      ],
      "%{group} package group update timed out": [
        "Délai d'expiration de la mise à jour du groupe de packages %{group} dépassé"
      ],
      "%{group} package group updated": [
        "Mise à jour du groupe de packages %{group}"
      ],
      "%{label} failed": [
        ""
      ],
      "%{label} failed.": [
        ""
      ],
      "%{name} has no %{type} repositories with upstream URLs to add to the alternate content source.": [
        ""
      ],
      "%{package} (%{total} other packages)": [
        "%{package} ( %{total} autres packages )"
      ],
      "%{package} (%{total} other packages) install canceled": [
        "Installation de %{package}annulée (%{total} autres packages)"
      ],
      "%{package} (%{total} other packages) install failed": [
        "Échec de l'installation de %{package} (%{total} autres packages)"
      ],
      "%{package} (%{total} other packages) install timed out": [
        "Délai d'expiration de l'installation de %{package}dépassé (%{total} autres packages)"
      ],
      "%{package} (%{total} other packages) installed": [
        "%{package}(%{total} autres packages) installé"
      ],
      "%{package} (%{total} other packages) remove canceled": [
        "Suppression de %{package} annulée (%{total} autres packages)"
      ],
      "%{package} (%{total} other packages) remove failed": [
        "Échec de la suppression de %{package} (%{total} autres packages)"
      ],
      "%{package} (%{total} other packages) remove timed out": [
        "Délai d'expiration de la suppression de %{package} dépassé (%{total} autres packages)"
      ],
      "%{package} (%{total} other packages) removed": [
        "%{package} (%{total} autres package) supprimé"
      ],
      "%{package} (%{total} other packages) update canceled": [
        "Mise à jour de %{package}annulée (%{total} autres packages)"
      ],
      "%{package} (%{total} other packages) update failed": [
        "Échec de la mise à jour de %{package}( %{total} autres packages)"
      ],
      "%{package} (%{total} other packages) update timed out": [
        "Délai d'expiration de la mise à jour de %{package} dépassé (%{total} autres packages)"
      ],
      "%{package} (%{total} other packages) updated": [
        "%{package} (%{total} autres packages) mis à jour"
      ],
      "%{package} package install canceled": [
        "Installation du package %{package} annulée"
      ],
      "%{package} package install timed out": [
        "Délai d'expiration de l'installation du package %{package} dépassé"
      ],
      "%{package} package remove canceled": [
        "Suppression du package %{package} annulée"
      ],
      "%{package} package remove failed": [
        "Échec de la suppression du package %{package}"
      ],
      "%{package} package remove timed out": [
        "Délai d'expiration de la suppression du package %{package} dépassé"
      ],
      "%{package} package removed": [
        "%{package} package supprimé"
      ],
      "%{package} package update canceled": [
        "Mise à jour du package %{package}annulée"
      ],
      "%{package} package update failed": [
        "Échec de la mise à jour du package %{package}"
      ],
      "%{package} package update timed out": [
        "Délai d'expiration de la mise à jour du package %{package} dépassé"
      ],
      "%{package} package updated": [
        "Package %{package} mis à jour."
      ],
      "%{release}: %{number_of_hosts} hosts are approaching end of %{lifecycle} on %{end_date}. Please upgrade them before support expires. Check Report Host - Statuses for detail.": [
        ""
      ],
      "%{sla}": [
        "%{sla}"
      ],
      "%{subject}'s disk is %{percentage} full. Since this proxy is running Pulp, it needs disk space to publish content views. Please ensure the disk does not get full.": [
        "Le disque de %{subject} est à %{percentage} plein. Comme ce proxy exécute Pulp, il a besoin d'espace disque pour publier les vues du contenu. Veuillez vous assurer que le disque n'est pas plein."
      ],
      "%{unused_substitutions} cannot be specified for %{content_name} as that information is not substitutable in %{content_url} ": [
        "Le {unused_substitutions} ne peut pas être spécifié pour le % {content_name} car cette information n'est pas substituable en %{content_url} "
      ],
      "%{used} of %{total}": [
        "%{used} de %{total} "
      ],
      "%{value} can contain only lowercase letters, numbers, dashes and dots.": [
        ""
      ],
      "%{view_label} could not be promoted to %{environment_label} because the content view and the environment are not in the same organization!": [
        "%{view_label} n'a pas pu être promu en %{environment_label} parce que la vue du contenu et l'environnement ne sont pas dans la même organisation !"
      ],
      "'%{item}' does not exist in the backend system [ Candlepin ].  Either remove and re-enable the repository or try refreshing the manifest before synchronizing. ": [
        "'%{item}' n'existe pas dans le système backend [ Candlepin ].  Soit vous supprimez et réactivez le dépôt, soit vous essayez de rafraîchir le manifeste avant la synchronisation. "
      ],
      "'%{item}' does not exist in the backend system [ Candlepin ].  Either remove the invalid repository or try refreshing the manifest before promoting. ": [
        "'%{item}' n'existe pas dans le système backend [ Candlepin ].  Supprimez le dépôt invalide ou essayez de rafraîchir le manifeste avant de le promouvoir. "
      ],
      "'%{item}' does not exist in the backend system [ Candlepin ].  Remove and recreate the repository before synchronizing. ": [
        "'%{item}' n'existe pas dans le système backend [ Candlepin ].  Supprimez et recréez le référentiel avant de procéder à la synchronisation. "
      ],
      "'%{item}' does not exist in the backend system [ Candlepin ].  Remove the invalid repository before promoting. ": [
        "'%{item}' n'existe pas dans le système backend [ Candlepin ].  Supprimez le dépôt invalide avant la promotion. "
      ],
      "'%{item}' in this content view does not exist in the backend system [ Candlepin ].  Either remove the invalid repository or try refreshing the manifest before publishing again. ": [
        "'%{item}' dans cette vue de contenu n'existe pas dans le système backend [ Candlepin ].  Supprimez le dépôt invalide ou essayez de rafraîchir le manifeste avant de publier à nouveau. "
      ],
      "'%{item}' in this content view does not exist in the backend system [ Candlepin ].  Remove the invalid repository before publishing again. ": [
        "'%{item}' dans cette vue de contenu n'existe pas dans le système backend [ Candlepin ].  Supprimez le référentiel invalide avant de publier à nouveau. "
      ],
      "(Orphaned)": [
        "(Abandonné)"
      ],
      "(unset)": [
        "(non défini)"
      ],
      ", and": [
        ", et"
      ],
      ", must be unique to major and version id version.": [
        ", doit être unique à la version majeure et id de version."
      ],
      ": '%s' is a built-in environment": [
        ": « %s » est un environnement intégré"
      ],
      ":a_resource identifier": [
        ":a_resource identifier"
      ],
      "<b>PROMOTION</b> SUMMARY": [
        "<b>RÉSUMÉ DE LA PROMOTION </b>"
      ],
      "<b>SYNC</b> SUMMARY": [
        "<b>SYNC </b> RÉSUMÉ"
      ],
      "A CV version already exists with the same major and minor version (%{major}.%{minor})": [
        "Une version du CV existe déjà avec la même version majeure et mineure (%{major}.%{minor})"
      ],
      "A Pool and its Subscription cannot belong to different organizations.": [
        ""
      ],
      "A backend service [ %s ] is unreachable": [
        "Un service backend [ %s ] est injoignable"
      ],
      "A comma-separated list of refs to include during an ostree sync. The wildcards *, ? are recognized.": [
        ""
      ],
      "A comma-separated list of tags to exclude during an ostree sync. The wildcards *, ? are recognized. 'exclude_refs' is evaluated after 'include_refs'.": [
        ""
      ],
      "A large number of errata are unapplied in this content view, so only the first 100 are shown.": [
        "Un grand nombre d'errata n'est pas appliqué dans cet affichage de contenu. Seuls les 100 premiers sont affichés."
      ],
      "A large number of errata were synced for this repository, so only the first 100 are shown.": [
        "Un grand nombre d'errata on été synchronisés pour ce référentiel. Seuls les 100 premiers sont affichés."
      ],
      "A list of subscriptions expiring soon": [
        "Une liste des abonnements arrivant à échéance prochainement"
      ],
      "A new version of ": [
        "Une nouvelle version de "
      ],
      "A notification about failed content view promotion": [
        ""
      ],
      "A notification about failed content view publish": [
        ""
      ],
      "A notification about failed proxy sync": [
        ""
      ],
      "A notification about failed repository sync": [
        ""
      ],
      "A post-promotion summary of hosts with installable errata": [
        "Un sommaire des hôtes post-promotion avec errata installables"
      ],
      "A remote execution job is in progress": [
        "Un travail d'exécution à distance est en cours"
      ],
      "A remote execution job is in progress.": [
        "Un travail d'exécution à distance est en cours."
      ],
      "A service level for auto-healing process, e.g. SELF-SUPPORT": [
        "Un niveau de service pour le processus de auto-healing, ex : SELF-SUPPORT"
      ],
      "A smart proxy seems to have been refreshed without pulpcore being running. Please refresh the smart proxy after ensuring that pulpcore services are running.": [
        "Un proxy smart semble avoir été rafraîchi sans que pulpcore soit en cours d'exécution. Veuillez rafraîchir le smart proxy après vous être assuré que les services pulpcore sont en cours d'exécution."
      ],
      "A summary of available and applicable errata for your hosts": [
        "Un sommaire d'errata disponibles et applicables pour vos hôtes"
      ],
      "A summary of new errata after a repository is synchronized": [
        "Un sommaire de nouveaux errata après la synchronisation d'un référentiel"
      ],
      "ANY": [
        "TOUT"
      ],
      "About page": [
        "Page d'accueil"
      ],
      "Access to Red Hat Subscription Management is prohibited. If you would like to change this, please update the content setting 'Subscription connection enabled'.": [
        "L'accès à la gestion des abonnements Red Hat est interdit. Si vous souhaitez modifier cette interdiction, veuillez mettre à jour le paramètre de contenu \\\"Connexion aux abonnements activée\\\"."
      ],
      "Account Number": [
        "Numéro de compte"
      ],
      "Action": [
        "Action"
      ],
      "Action not allowed for the default smart proxy.": [
        "Action non autorisée pour le proxy smart par défaut."
      ],
      "Action unauthorized to be performed in this organization.": [
        "Action non autorisée à être exécutée dans cette organisation."
      ],
      "Activation Key information": [
        ""
      ],
      "Activation Key will no longer be available for use. This operation cannot be undone.": [
        ""
      ],
      "Activation Keys": [
        "Clés d'activation"
      ],
      "Activation key": [
        "Clé d'activation"
      ],
      "Activation key %s has more than one content view. Use #content_views instead.": [
        ""
      ],
      "Activation key %s has more than one lifecycle environment. Use #lifecycle_environments instead.": [
        ""
      ],
      "Activation key '%s' is associated to multiple environments and registering to multiple environments is not enabled.": [
        ""
      ],
      "Activation key ID": [
        "ID de clé d'activation"
      ],
      "Activation key deleted": [
        ""
      ],
      "Activation key details": [
        ""
      ],
      "Activation key details updated": [
        ""
      ],
      "Activation key for subscription-manager client, required for CentOS and Red Hat Enterprise Linux. For multiple keys use `activation_keys` param instead.": [
        "Clé d'activation pour le client subscription-manager, requise pour CentOS et Red Hat Enterprise Linux. Pour plusieurs clés, utilisez plutôt le paramètre `activation_keys`."
      ],
      "Activation key identifier": [
        ""
      ],
      "Activation key(s) to use during registration": [
        ""
      ],
      "Activation keys": [
        "Clés d'activation"
      ],
      "Activation keys can be managed {here}.": [
        ""
      ],
      "Activation keys for subscription-manager client, required for CentOS and Red Hat Enterprise Linux. Required only if host group has no activation keys or if you do not provide a host group.": [
        ""
      ],
      "Activation keys may be used during {system_registration}.": [
        ""
      ],
      "Activation keys: ": [
        "Clés d'activation : "
      ],
      "Active only": [
        "Actifs uniquement"
      ],
      "Add": [
        "Ajouter"
      ],
      "Add Bookmark": [
        "Ajouter Signet"
      ],
      "Add DEB rule": [
        "Ajouter une règle DEB"
      ],
      "Add RPM rule": [
        "Ajouter une règle RPM"
      ],
      "Add Subscriptions": [
        "Ajouter Abonnements"
      ],
      "Add a subscription to a host": [
        "Ajouter un abonnement à un hôte"
      ],
      "Add an alternate content source": [
        "Montrer une autre source de contenu"
      ],
      "Add components to the content view": [
        "Ajouter des éléments à l’affichage du contenu"
      ],
      "Add content": [
        ""
      ],
      "Add content view": [
        "Ajouter un affichage de contenu"
      ],
      "Add content views": [
        "Ajouter les affichages du contenu"
      ],
      "Add custom cron logic for sync plan": [
        "Ajouter une logique de cron personnalisée pour le plan de synchronisation"
      ],
      "Add errata": [
        "Ajouter errata"
      ],
      "Add filter rule": [
        "Ajouter une règle de filtre"
      ],
      "Add host to collections": [
        "Ajouter un hôte aux collections"
      ],
      "Add host to host collections": [
        "Ajouter un hôte aux collections d'hôtes"
      ],
      "Add host to the host collection": [
        "Ajouter l'hôte à la collection d'hôtes"
      ],
      "Add lifecycle environments to the smart proxy": [
        "Ajouter les environnements de cycle de vie au proxy smart"
      ],
      "Add new bookmark": [
        "Ajouter un nouveau signet"
      ],
      "Add one or more host collections to one or more hosts": [
        "Ajouter une ou plusieurs collections d'hôte à un ou plusieurs hôtes"
      ],
      "Add products to sync plan": [
        "Ajouter des produits au plan de sync"
      ],
      "Add repositories": [
        "Ajouter référentiels"
      ],
      "Add repositories with package groups to content view to select them here.": [
        ""
      ],
      "Add rule": [
        "Ajouter une règle"
      ],
      "Add source": [
        "Ajouter une source"
      ],
      "Add subscriptions": [
        ""
      ],
      "Add subscriptions consumed by a manifest from Red Hat Subscription Management": [
        "Ajouter les abonnements consommés par un manifeste de Red Hat Subscription Management"
      ],
      "Add subscriptions to one or more hosts": [
        "Ajouter des abonnements à un ou plusieurs hôtes"
      ],
      "Add subscriptions using the Add Subscriptions button.": [
        ""
      ],
      "Add to a host collection": [
        "Ajouter à une collection d'hôtes"
      ],
      "Added": [
        "Ajouté"
      ],
      "Added %s": [
        "%s Ajouté"
      ],
      "Added Content:": [
        "Contenu ajouté :"
      ],
      "Added component to content view": [
        "Composant ajouté à la vue du contenu."
      ],
      "Additional content": [
        "Contenu supplémentaire"
      ],
      "Affected Repositories": [
        "Référentiels affectés"
      ],
      "Affected hosts": [
        ""
      ],
      "Affected repositories": [
        "Référentiels affectés"
      ],
      "After configuring Foreman, configuration must also be updated on {hosts}. Choose one of the following options to update {hosts}:": [
        ""
      ],
      "After generating the incremental update, apply the changes to the specified hosts.  Only Errata are supported currently.": [
        "Après avoir effectué la mise à jour croissante, appliquer les modifications aux systèmes spécifiés. Seuls les errata sont actuellement pris en charge."
      ],
      "All": [
        "Tout"
      ],
      "All Media": [
        "Tous les médias"
      ],
      "All Repositories": [
        "Référentiels"
      ],
      "All available architectures for this repo are enabled.": [
        "Toutes les architectures disponibles pour cette prise en pension sont activées."
      ],
      "All errata applied": [
        "Toutes les errata sont applicables"
      ],
      "All errata up-to-date": [
        "Tous les errata sont à jour"
      ],
      "All subpaths must have a slash at the end and none at the front": [
        "Tous les sous-chemins doivent avoir une barre oblique à la fin et aucune au début."
      ],
      "All up to date": [
        "Tout est à jour"
      ],
      "All versions": [
        "Toutes les versions"
      ],
      "All versions will be removed from these environments": [
        "Toutes les versions seront supprimées de ces environnements"
      ],
      "Allow deleting repositories in published content views": [
        "Permettre la suppression des référentiels dans les vues de contenu publié"
      ],
      "Allow host registrations to bypass 'Host Profile Assume' as long as the host is in build mode.": [
        "Permettre aux enregistrements d'hôtes de contourner la \\\"Profile d’hôte Assume'\\\" tant que l'hôte est en mode build."
      ],
      "Allow hosts or activation keys to be associated with multiple content view environments": [
        ""
      ],
      "Allow hosts to re-register themselves only when they are in build mode": [
        "Autoriser les hôtes à se réenregistrer uniquement lorsqu'ils sont en mode \\\"build\\\""
      ],
      "Allow multiple content views": [
        ""
      ],
      "Allow new host registrations to assume registered profiles with matching hostname as long as the registering DMI UUID is not used by another host.": [
        "Autoriser les nouveaux enregistrements d'hôtes à assumer des profils enregistrés avec un nom d'hôte correspondant tant que l'UUID du DMI d'enregistrement n'est pas utilisé par un autre hôte."
      ],
      "Also include the latest upgradable package version for each host package": [
        "Inclure également la dernière version de package de mise à jour pour chaque package d’hôte."
      ],
      "Alter a host's host collections": [
        "Modifier les collections d'hôtes d'un hôte"
      ],
      "Alternate Content Source HTTP Proxy": [
        "Source de contenu alternatif Proxy HTTP"
      ],
      "Alternate Content Sources": [
        "Autres sources de contenu"
      ],
      "Alternate content source ${name} created": [
        "Source de contenu alternatif ${name} créée"
      ],
      "Alternate content source ID": [
        "ID de la source de contenu alternatif"
      ],
      "Alternate content source deleted": [
        "Source de contenu alternatif supprimée"
      ],
      "Alternate content source edited": [
        "ID de la source de contenu alternatif"
      ],
      "Alternate content sources define new locations to download content from at repository or smart proxy sync time.": [
        "Les sources de contenu alternatives définissent de nouveaux emplacements à partir desquels télécharger le contenu au moment de la synchronisation du référentiel ou du proxy smart."
      ],
      "Alternate content sources use the HTTP proxy of their assigned smart proxy for communication.": [
        "Les autres sources de contenu utilisent le proxy HTTP du proxy smart qui leur a été attribué pour communiquer."
      ],
      "Always Use Latest (currently %{version})": [
        "Toujours utiliser la version la plus récente (actuellement %{version})"
      ],
      "Always update to latest version": [
        "Toujours mettre à jour la dernière version"
      ],
      "Amount of workers in the pool to handle the execution of host-related tasks. When set to 0, the default queue will be used instead. Restart of the dynflowd/foreman-tasks service is required.": [
        "Nombre de workers dans le pool pour l'exécution des tâches liées à l'hôte. Si la valeur est 0, la file d'attente par défaut sera utilisée à la place. Il faut redémarrer le service dynflowd/foreman-tasks."
      ],
      "An alternate content source can be added by using the \\\\\\\"Add source\\\\\\\" button below.": [
        ""
      ],
      "An environment is missing a prior": [
        "Il manque à l'environnement un préalable"
      ],
      "An error occurred during the sync \\n%{error_message}": [
        "Une erreur s'est produite lors de la synchronisation\\n%{error_message}"
      ],
      "An error occurred during upload \\n%{error_message}": [
        "Une erreur s'est produite lors de la synchronisation %{error_message}"
      ],
      "An option to specify how many ostree commits to traverse.": [
        ""
      ],
      "Another component already includes content view with ID %s": [
        "Une autre composante comprend déjà une vue du contenu avec ID %s"
      ],
      "Ansible Collection": [
        "Collection Ansible"
      ],
      "Ansible Collections": [
        "Collections Ansible"
      ],
      "Ansible collection": [
        "Collection Ansible"
      ],
      "Ansible collections": [
        "Collections Ansible"
      ],
      "Applicability Batch Size": [
        "Applicabilité Taille du lot"
      ],
      "Applicable": [
        "Applicable"
      ],
      "Applicable Content Hosts": [
        "Hôtes de contenu applicables"
      ],
      "Applicable bugfix/enhancement errata": [
        ""
      ],
      "Applicable errata apply to at least one package installed on the host.": [
        "Les errata applicables s'appliquent à au moins un paquet installé sur l'hôte."
      ],
      "Applicable security errata": [
        ""
      ],
      "Application": [
        "Application"
      ],
      "Apply": [
        "Appliquer"
      ],
      "Apply errata": [
        ""
      ],
      "Apply erratum": [
        ""
      ],
      "Apply to all repositories in the CV": [
        "Appliquer à tous les référentiels dans le CV"
      ],
      "Apply to subset of repositories": [
        "Appliquer au sous-groupe de référentiels"
      ],
      "Apply via customized remote execution": [
        "Appliquer via exécution à distance personnalisée"
      ],
      "Apply via remote execution": [
        "Appliquer via exécution à distante"
      ],
      "Approaching end of maintenance support": [
        ""
      ],
      "Approaching end of maintenance support (%s)": [
        ""
      ],
      "Approaching end of support": [
        ""
      ],
      "Approaching end of support (%s)": [
        ""
      ],
      "Arch": [
        "Arch"
      ],
      "Architecture": [
        "Architecture"
      ],
      "Architecture of content in the repository": [
        "Architecture du contenu dans le référentiel"
      ],
      "Architecture restricted to {archRestricted}. If host architecture does not match, the repository will not be available on this host.": [
        "Architecture limitée à {archRestricted}. Si l'architecture de l'hôte ne correspond pas, le référentiel ne sera pas disponible sur cet hôte."
      ],
      "Architecture(s)": [
        "Architecture(s)"
      ],
      "Are you sure you want to delete %(entitlementCount)s subscription(s)? This action will remove the subscription(s) and refresh your manifest. All systems using these subscription(s) will lose them and also may lose access to updates and Errata.": [
        "Êtes-vous sûr de vouloir supprimer %(entitlementCount)s abonnement(s) ? Cette action supprimera le(s) abonnement(s) et rafraîchira votre manifeste. Tous les systèmes utilisant ces abonnements les perdront, ainsi que l'accès aux mises à jour et aux Errata."
      ],
      "Are you sure you want to delete the manifest?": [
        "Êtes-vous sûr de vouloir supprimer le manifeste ?"
      ],
      "Array of Content override parameters": [
        "Paramètres de remplacement de contenu"
      ],
      "Array of Content override parameters to be added in bulk": [
        "Tableau des paramètres de contournement du contenu à ajouter en masse"
      ],
      "Array of Pools to be updated. Only pools originating upstream are accepted.": [
        "Tableau des pools à mettre à jour. Seuls les pools provenant de l'amont sont acceptés."
      ],
      "Array of Trace IDs": [
        "Réseau de traces d'identification"
      ],
      "Array of components to add": [
        "Tableau des éléments à ajouter"
      ],
      "Array of content view component IDs to remove. Identifier of the component association": [
        "Tableau des ID des composants de la vue du contenu à supprimer. Identificateur de l'association de composants"
      ],
      "Array of content view environment ids associated with the activation key. Ignored if content_view_id and lifecycle_environment_id are specified.Requires allow_multiple_content_views setting to be on.": [
        ""
      ],
      "Array of content view environment ids to be associated with the activation key. Ignored if content_view_id and lifecycle_environment_id are specified. Requires allow_multiple_content_views setting to be on.": [
        ""
      ],
      "Array of content view environment ids to be associated with the host. Ignored if content_view_id and lifecycle_environment_id are specified. Requires allow_multiple_content_views setting to be on.": [
        ""
      ],
      "Array of host ids": [
        "Ensemble d'ids d'hôtes"
      ],
      "Array of local pool IDs. Only pools originating upstream are accepted.": [
        "Tableau d'identification des pools locaux. Seuls les pools provenant de l'amont sont acceptés."
      ],
      "Array of pools to add": [
        "Tableau des pools à ajouter"
      ],
      "Array of subscriptions to add": [
        "Ensemble d'abonnements à ajouter"
      ],
      "Array of subscriptions to remove": [
        "Ensemble d'abonnements à supprimer"
      ],
      "Array of uploads to import": [
        "Ensemble des téléchargements à importer"
      ],
      "Artifact Id and relative path are needed to create content": [
        "L'identifiant de l'artefact et le chemin relatif sont nécessaires pour créer le contenu"
      ],
      "Artifacts": [
        "Artifacts"
      ],
      "Assign system purpose attributes on one or more hosts": [
        "Attribuer des attributs de finalité du système sur un ou plusieurs hôtes"
      ],
      "Assign the %{count} host with no %{taxonomy_single} to %{taxonomy_name}": [
        "Affecter l'hôte {taxonomy_single} sans %{taxonomy_name} à %{taxonomy_name}",
        "Affecter tous les hôtes %{count} sans %{taxonomy_single}  à %{taxonomy_name}",
        "Affecter tous les hôtes %{count} sans %{taxonomy_single}  à %{taxonomy_name}"
      ],
      "Assign the environment and content view to one or more hosts": [
        "Assigner l'environnement et l'affichage de contenu d'un ou plusieurs systèmes hôtes"
      ],
      "Assign the release version to one or more hosts": [
        "Attribuer la version de diffusion à un ou plusieurs hôtes"
      ],
      "Assigning a host to multiple content view environments is not enabled. To enable, set the allow_multiple_content_views setting.": [
        ""
      ],
      "Assigning an activation key to multiple content view environments is not enabled. To enable, set the allow_multiple_content_views setting.": [
        ""
      ],
      "Associated location IDs": [
        "Identifiants de localisation associés"
      ],
      "Associated version": [
        "Version associée"
      ],
      "Associations": [
        "Associations"
      ],
      "At least one Content View Version must be specified": [
        "Au moins une version d'affichage de contenu doit être spécifiée"
      ],
      "At least one activation key must be provided": [
        "Au moins une clé d'activation doit être fournie"
      ],
      "At least one activation key must have a lifecycle environment and content view assigned to it": [
        "Au moins une clé d'activation doit avoir un environnement de cycle de vie et un affichage de contenu lui étant assignée."
      ],
      "At least one errata type option needs to be selected.": [
        ""
      ],
      "At least one of the selected items requires the host to reboot": [
        ""
      ],
      "At least one organization must exist.": [
        "Au moins une organisation doit exister."
      ],
      "Attach a subscription": [
        "Attacher Abonnement"
      ],
      "Attach subscriptions": [
        "Attacher abonnements"
      ],
      "Attach subscriptions to %s": [
        "Attacher abonnements à %s"
      ],
      "Attempted to destroy consumer %s from candlepin, but consumer does not exist in candlepin": [
        "Tentative de destruction du consommateur %s de candlepin, mais le consommateur n'existe pas dans candlepin"
      ],
      "Auth URL requires Auth token be set.": [
        "L'URL d'authentification exige que le jeton d'authentification soit défini."
      ],
      "Authentication type": [
        "Type d'authentification"
      ],
      "Author": [
        "Auteur"
      ],
      "Auto Publish - Triggered by '%s'": [
        "Auto Publish - Déclenché par '%s' "
      ],
      "Auto publish": [
        "Auto Publish"
      ],
      "Autopublish": [
        "Autopublication"
      ],
      "Available": [
        "Disponible"
      ],
      "Available Entitlements": [
        "Droits d'accès disponibles"
      ],
      "Available Repositories": [
        "référentiels disponibles"
      ],
      "Available image": [
        ""
      ],
      "Available image digest": [
        ""
      ],
      "Available schema versions": [
        ""
      ],
      "Back": [
        "Précédent"
      ],
      "Backend System Status": [
        "Statut du système backend"
      ],
      "Base URL": [
        "URL de base"
      ],
      "Base URL for finding alternate content": [
        "URL de base pour trouver le contenu alternatif"
      ],
      "Base URL of the flatpak registry index, ex: https://flatpaks.redhat.io/rhel/ , https://registry.fedoraproject.org/.": [
        ""
      ],
      "Base URL to perform repo discovery on": [
        "URL de base sur lequel effectuer la découverte de référentiel"
      ],
      "Basearch to disable": [
        "Basearch à désactiver"
      ],
      "Basearch to enable": [
        "Basearch à activer"
      ],
      "Basic authentication password": [
        "Mot de passe d'authentification de base"
      ],
      "Basic authentication username": [
        "Nom d'utilisateur pour l'authentification de base"
      ],
      "Batch size to sync repositories in.": [
        "Taille des lots pour synchroniser les référentiels."
      ],
      "Before continuing, ensure that all of the following prerequisites are met:": [
        ""
      ],
      "Before removing versions you must move activation keys to an environment where the associated version is not in use.": [
        "Avant de supprimer des versions, vous devez déplacer les clés d'activation vers un environnement où la version associée n'est pas utilisée."
      ],
      "Before removing versions you must move hosts to an environment where the associated version is not in use. ": [
        "Avant de supprimer des versions, vous devez déplacer les hôtes dans un environnement où la version associée n'est pas utilisée. "
      ],
      "Below are the repository sets currently available for this content host. For Red Hat subscriptions, additional content can be made available through the {rhrp}. Changing default settings requires subscription-manager 1.10 or newer to be installed on this host.": [
        "Vous trouverez ci-dessous les ensembles de contenu du référentiel actuellement disponibles pour cet hébergeur de contenu. Pour les abonnements à Red Hat, du contenu supplémentaire peut être mis à disposition par le biais de {rhrp}. Modifier les paramètres par défaut exigent subscription manager 1.10 ou plus récent sur cet hôte."
      ],
      "Beta": [
        "Bêta"
      ],
      "Bind an entitlement to an allocation": [
        "Lier un droit à une allocation"
      ],
      "Bind entitlements to an allocation": [
        "Lier les droits à une allocation"
      ],
      "Bookmark this search": [
        "Ajouter cette recherche aux favoris"
      ],
      "Bookmarks marked as public are available to all users": [
        "Les signets marqués comme étant publics sont disponibles à tous les utilisateurs"
      ],
      "Bootc rollback via Bootc interface": [
        ""
      ],
      "Bootc status via Bootc interface": [
        ""
      ],
      "Bootc switch via Bootc interface": [
        ""
      ],
      "Bootc upgrade via Bootc interface": [
        ""
      ],
      "Booted Container Images": [
        ""
      ],
      "Booted container images": [
        ""
      ],
      "Both": [
        "Les deux"
      ],
      "Both major and minor parameters have to be used to override a CV version": [
        "Des paramètres majeurs et mineurs doivent être utilisés pour remplacer une version CV"
      ],
      "Bug Fix": [
        "Correctif de bogue"
      ],
      "Bugfix": [
        "Correction de bogues"
      ],
      "Bugs": [
        "Bogues"
      ],
      "Bulk alternate content source delete has started.": [
        "La suppression en masse des sources de contenu alternatif a commencé."
      ],
      "Bulk alternate content source refresh has started.": [
        "Le rafraîchissement de la source de contenu alternatif en vrac a commencé."
      ],
      "Bulk generate applicability for host %s": [
        "La masse génère l'applicabilité pour les hôtes %s"
      ],
      "Bulk generate applicability for hosts": [
        "La masse génère l'applicabilité pour les hôtes"
      ],
      "Bulk remove versions from a content view and reassign systems and keys": [
        "Suppression en bloc des versions d'une vue de contenu et réaffectation des systèmes et des clés"
      ],
      "CDN Configuration": [
        "Configuration CDN"
      ],
      "CDN Configuration for Red Hat Content": [
        "Configuration CDN pour le contenu Red Hat"
      ],
      "CDN Configuration updated.": [
        "Configuration CDN mise à jour"
      ],
      "CDN configuration is set to Export Sync (disconnected). Repository enablement/disablement is not permitted on this page.": [
        "La configuration du CDN est réglée sur Export Sync (déconnecté). L'activation/désactivation du référentiel n'est pas autorisée sur cette page."
      ],
      "CDN configuration type. One of %s.": [
        "Type de configuration CDN. L'une des options suivantes : %s."
      ],
      "CDN loading error: %s not found": [
        "Erreur de chargement CDN : %s introuvable"
      ],
      "CDN loading error: access denied to %s": [
        "Erreur de chargement CDN : accès refusé à %s "
      ],
      "CDN loading error: access forbidden to %s": [
        "Erreur de chargement CDN : accès interdit à %s "
      ],
      "CVE identifier": [
        "Identifiant CVE"
      ],
      "CVEs": [
        "CVE"
      ],
      "Calculate Applicable Errata based on a particular Content View": [
        "Calculer les errata applicables selon un affichage de contenu particulier"
      ],
      "Calculate Applicable Errata based on a particular Environment": [
        "Calculer les errata applicables selon un environnement particulier"
      ],
      "Calculate content counts on smart proxies automatically": [
        ""
      ],
      "Can communicate with the Red Hat Portal for subscriptions.": [
        "Peut communiquer avec le portail Red Hat pour les abonnements."
      ],
      "Can only remove content from within the Default Content View": [
        "Peut uniquement supprimer les contenus à partir de l'Affichage de contenu par défaut"
      ],
      "Can't update the '%s' environment": [
        "Mise à jour de l'environnement  '%s' impossible"
      ],
      "Cancel": [
        "Annuler"
      ],
      "Cancel repository discovery": [
        "Annuler la découverte de référentiel"
      ],
      "Cancel running smart proxy synchronization": [
        "Annuler l'exécution de la synchronisation du proxy smart"
      ],
      "Canceled": [
        "Annulé"
      ],
      "Cancelled.": [
        "Annulé."
      ],
      "Candlepin": [
        "Candlepin"
      ],
      "Candlepin Event": [
        "Événement Candlepin"
      ],
      "Candlepin ID of pool to add": [
        "ID Candlepin du pool à ajouter"
      ],
      "Candlepin consumer %s has already been removed": [
        "Le consommateur Candlepin %s a déjà été supprimé"
      ],
      "Candlepin is not running properly": [
        "Candlepin ne fonctionne pas correctement"
      ],
      "Candlepin returned different consumer uuid than requested (%s), updating uuid in subscription_facet.": [
        ""
      ],
      "Cannot add %s repositories to a content view.": [
        "Impossible d'ajouter %s référentiels à un affichage de contenu."
      ],
      "Cannot add a repository from an Organization other than %s.": [
        "Impossible d'ajouter un référentiel à partir d'une organisation autre que %s."
      ],
      "Cannot add component versions to a non-composite content view": [
        "Impossible d'ajouter des versions de composants à un affichage de contenu non-composite"
      ],
      "Cannot add composite versions to a composite content view": [
        "Impossible d'ajouter des versions composites à un affichage de contenu composite"
      ],
      "Cannot add composite versions to another composite content view": [
        "Impossible d'ajouter des versions composites à un autre affichage de contenu composite"
      ],
      "Cannot add content view environments from a different organization": [
        ""
      ],
      "Cannot add default content view to composite content view": [
        "Impossible d'ajouter un affichage du contenu par défaut à la vue du contenu composite"
      ],
      "Cannot add disabled Red Hat product %s to sync plan!": [
        ""
      ],
      "Cannot add disabled products to sync plan!": [
        ""
      ],
      "Cannot add generated content view versions to composite content view": [
        "Impossible d'ajouter des versions de la vue de contenu générée à la vue de contenu composite"
      ],
      "Cannot add product %s because it is disabled.": [
        ""
      ],
      "Cannot add repositories to a composite content view": [
        "Impossible d'ajouter des référentiels à un affichage du contenu composite"
      ],
      "Cannot associate a Red Hat provider with a custom product": [
        ""
      ],
      "Cannot associate a component to a non composite content view": [
        "Impossible d'ajouter un composant à un affichage de contenu non-composite"
      ],
      "Cannot be disabled because it is part of a published content view": [
        ""
      ],
      "Cannot calculate name for custom repos": [
        "Impossible de calculer le nom pour les référentiels personnalisés"
      ],
      "Cannot clone into the Default Content View": [
        "Impossible de cloner dans un affichage de contenu par défaut"
      ],
      "Cannot delete '%{view}' due to associated %{dependent}: %{names}.": [
        "Ne peut pas supprimer '%{view}'  en raison de l'association %{dependent} :%{names}."
      ],
      "Cannot delete Red Hat product: %{product}": [
        "Ne peut pas supprimer le produit Red Hat : %{product}"
      ],
      "Cannot delete from %s, view does not exist there.": [
        "Impossible de supprimer à partir de %s, l'affichage n'y existe pas."
      ],
      "Cannot delete product with repositories published in a content view.  Product: %{product}, %{view_versions}": [
        "Impossible de supprimer un produit dont les référentiels sont publiés dans une vue de contenu.  Produit : %{product}, %{view_versions}"
      ],
      "Cannot delete product: %{product} with repositories that are the last affected repository in content view filters. Delete these repositories before deleting product.": [
        ""
      ],
      "Cannot delete provider with attached products": [
        "Impossible de supprimer le fournisseur avec les produits joints"
      ],
      "Cannot delete redhat product content": [
        "Ne peut pas supprimer le contenu d'un produit Red Hat"
      ],
      "Cannot delete the default Location for subscribed hosts. If you no longer want this Location, change the default Location for subscribed hosts under Administer > Settings, tab Content.": [
        "Impossible de supprimer l'emplacement par défaut pour les hôtes abonnés. Si vous ne voulez plus de cet emplacement, modifiez l'emplacement par défaut pour les hôtes abonnés sous Administration > Paramètres, onglet Contenu."
      ],
      "Cannot delete the last Location.": [
        "Impossible de supprimer le dernier emplacement"
      ],
      "Cannot delete version while it is in environment %s": [
        "Impossible de supprimer la version lorsqu'elle se trouve dans l'environnement %s"
      ],
      "Cannot delete version while it is in environments: %s": [
        "Impossible de supprimer la version lorsqu'elle se trouve dans les environnements : %s"
      ],
      "Cannot delete version while it is in use by composite content views: %s": [
        "Impossible de supprimer la version tant qu'elle est utilisée par des affichages de contenu composites : %s"
      ],
      "Cannot delete view while it exists in environments": [
        "Impossible de supprimer l'affichage pendant qu'il existe dans des environnements"
      ],
      "Cannot import a composite content view": [
        "Ne peut importer une vue de contenu composite"
      ],
      "Cannot import a custom subscription from a redhat product.": [
        "Impossible d'importer un abonnement personnalisé à partir d'un produit Red Hat."
      ],
      "Cannot incrementally export from a filtered and a non-filtered content view version. The exported content view version '%{content_view} %{current}'  cannot be incrementally updated from version '%{from}.'.  Please do a full export.": [
        ""
      ],
      "Cannot incrementally export from a incrementally exported version and a regular version or vice-versa.  The exported Content View Version '%{content_view} %{current}' cannot be incrementally exported from version '%{from}.' Please do a full export.": [
        ""
      ],
      "Cannot install errata: No errata found for search term '%s'": [
        ""
      ],
      "Cannot perform an incremental update on a Composite Content View Version (%{name} version version %{version}": [
        "Ne peut effectuer une mise à jour croissante sur une version d'affichage de contenu composite (%{name} version version %{version}"
      ],
      "Cannot perform an incremental update on a Generated Content View Version (%{name} version version %{version}": [
        "Ne peut effectuer une mise à jour croissante sur une version d'affichage de contenu générée (%{name} version version %{version}"
      ],
      "Cannot promote environment out of sequence. Use force to bypass restriction.": [
        "Impossible de promouvoir l'environnement hors séquence. Forcez le contournement de la restriction."
      ],
      "Cannot publish a composite with rpm filenames": [
        "Impossible de publier un composite avec des noms de fichiers rpm"
      ],
      "Cannot publish a link repository if multiple component clones are specified": [
        "Impossible de publier un référentiel de liens si plusieurs clones de composants sont spécifiés"
      ],
      "Cannot publish default content view": [
        "Impossible de publier l'affichage du contenu par défaut"
      ],
      "Cannot register a system to the '%s' environment": [
        "Impossible d'enregistrer le système sur l'environnement '%s'"
      ],
      "Cannot remove '%{view}' from environment '%{env}' due to associated %{dependent}: %{names}.": [
        "Ne peut pas supprimer '%{view}' de l'environnement '%{env}' en raison de  %{dependent}: %{names}."
      ],
      "Cannot remove content from a non-custom repository": [
        "Impossible de supprimer le contenu d'un référentiel non personnalisé."
      ],
      "Cannot remove content view from environment. Content view '%{view}' is not in lifecycle environment '%{env}'.": [
        "Impossible de supprimer l'affichage de contenu de l'environnement. L'affichage de contenu '%{view}' ne se trouve pas dans l'environnement de cycle de vie '%{env}'."
      ],
      "Cannot remove package(s): No installed packages found for search term '%s'.": [
        ""
      ],
      "Cannot set attribute %{attr} for content type %{type}": [
        "Impossible de définir l'attribut %{attr} pour le type de contenu %{type} "
      ],
      "Cannot set auto publish to a non-composite content view": [
        "Impossible de régler la publication automatique sur une vue de contenu non composite"
      ],
      "Cannot skip metadata check on non-yum/deb repositories.": [
        ""
      ],
      "Cannot specify components for non-composite views": [
        "Impossible d'indiquer des composants pour les affichages non-composite"
      ],
      "Cannot specify content for composite views": [
        "Impossible d'indiquer du contenu pour les affichages composite"
      ],
      "Cannot sync file:// repositories with the On Demand Download Policy": [
        "Impossible de synchroniser les référentiels file:// avec les politiques de téléchargement à la demande"
      ],
      "Cannot update properties of a container push repository": [
        ""
      ],
      "Cannot upgrade packages: No installed packages found for search term '%s'.": [
        ""
      ],
      "Cannot upload Ansible collections.": [
        "Impossible de télécharger les collections Ansible."
      ],
      "Cannot upload Container Image content.": [
        "Impossible de télécharger le contenu de l'image du conteneur."
      ],
      "Cannot upload container content via Hammer/API. Use podman push instead.": [
        ""
      ],
      "Capacity": [
        "Capacité"
      ],
      "Change Content Source": [
        "Changer la source du contenu"
      ],
      "Change content source": [
        "Changer la source du contenu"
      ],
      "Change content view environments": [
        ""
      ],
      "Change host content source": [
        "Changer la source du contenu de l'hôte"
      ],
      "Changing a host's content source will change the Smart Proxy from which the host gets its content.": [
        ""
      ],
      "Check audited changes and proceed only if content or filters have changed since last publish": [
        ""
      ],
      "Check for missing or corrupted artifacts, and attempt to redownload them.": [
        ""
      ],
      "Check if a connection can be made to Red Hat Subscription Management.": [
        "Vérifiez si une connexion peut être établie avec Red Hat Subscription Management."
      ],
      "Check services before actions": [
        "Vérifier les services avant les actions"
      ],
      "Checksum": [
        "Somme de vérification"
      ],
      "Checksum is a required parameter.": [
        "La somme de contrôle est un paramètre obligatoire."
      ],
      "Checksum of file to upload": [
        "Somme de contrôle du fichier à télécharger"
      ],
      "Checksum type cannot be set for yum repositories with on demand download policy.": [
        "Le type de checksum ne peut pas être défini pour les référentiels yum avec une politique de téléchargement à la demande."
      ],
      "Checksum used for published repository contents. Supported types: %s": [
        ""
      ],
      "Choose content credentials if required for this RHUI source.": [
        "Choisissez les informations d'identification du contenu si nécessaire pour cette source RHUI."
      ],
      "Clear any previous registration and run subscription-manager with --force.": [
        "Effacez tout enregistrement précédent et exécutez subscription-manager avec --force."
      ],
      "Clear filters": [
        "Effacer les filtres"
      ],
      "Clear search": [
        "Supprimer la recherche"
      ],
      "Click here to go to the tasks page for the task.": [
        "Cliquez ici pour aller à la page des tâches."
      ],
      "Click to see repositories available to add.": [
        ""
      ],
      "Click {update} below to save changes.": [
        "Cliquez sur {update} ci-dessous pour enregistrer les modifications."
      ],
      "Clone": [
        "Cloner"
      ],
      "Close": [
        "Fermer"
      ],
      "Collapse All": [
        "Réduire tout"
      ],
      "Comma-separated list of content view environment labels associated with the activation key, in the format of 'lifecycle_environment_label/content_view_label'. Ignored if content_view_environment_ids is specified, or if content_view_id and lifecycle_environment_id are specified. Requires allow_multiple_content_views setting to be on.": [
        ""
      ],
      "Comma-separated list of content view environment labels to be associated with the activation key, in the format of 'lifecycle_environment_label/content_view_label'. Ignored if content_view_environment_ids is specified, or if content_view_id and lifecycle_environment_id are specified. Requires allow_multiple_content_views setting to be on.": [
        ""
      ],
      "Comma-separated list of content view environment labels to be associated with the host, in the format of 'lifecycle_environment_label/content_view_label'. Ignored if content_view_environment_ids is specified, or if content_view_id and lifecycle_environment_id are specified. Requires allow_multiple_content_views setting to be on.": [
        ""
      ],
      "Comma-separated list of subpaths. All subpaths must have a slash at the end and none at the front.": [
        "Liste de sous-chemins séparés par des virgules. Tous les sous-chemins doivent avoir une barre oblique à la fin et aucune au début."
      ],
      "Comma-separated list of tags to exclude when syncing a container image repository. Default: any tag ending in \\\"-source\\\"": [
        "Liste de balises, séparées par des virgules, à exclure lors de la synchronisation d'un référentiel d'images de conteneurs. Défaut : toute balise se terminant par \\\"-source\\\"."
      ],
      "Comma-separated list of tags to sync for a container image repository": [
        "Liste de balises séparées par des virgules à synchroniser pour le référentiel d'images des conteneurs"
      ],
      "Compare": [
        "Comparez"
      ],
      "Completed pulp task protection days": [
        ""
      ],
      "Component": [
        "Composant"
      ],
      "Component Content View": [
        "Affichage du contenu des composants"
      ],
      "Component Version: '%{cvv}', Product: '%{product}', Repository: '%{repo}' ": [
        "Version du composant : '%{cvv}', Produit : '%{product}', Dépôt : '%{repo}' "
      ],
      "Components": [
        "Composants"
      ],
      "Composite": [
        "Composite"
      ],
      "Composite Content View": [
        "Affichage du contenu composite"
      ],
      "Composite Content View '%{subject}' failed auto-publish": [
        "L'affichage du contenu composite '%{subject}' a échoué à la publication automatique"
      ],
      "Composite content view": [
        "Affichage du contenu composite"
      ],
      "Composite content views": [
        "Affichages de contenus composites"
      ],
      "Compute resource IDs": [
        "IDs de ressource compute"
      ],
      "Configuration still must be updated on {hosts}": [
        ""
      ],
      "Configuration updated on Foreman": [
        ""
      ],
      "Confirm Deletion": [
        "Confirmer la suppression"
      ],
      "Confirm delete manifest": [
        "Confirmer la suppression du manifeste"
      ],
      "Consider changing the Lifecycle Environment's Registry Name Pattern to something more specific.": [
        "Envisagez de modifier le modèle de nom de registre de l’environnement de cycle de vie pour le rendre plus spécifique."
      ],
      "Consisting of multiple content views": [
        "Constitué de plusieurs vues de contenu"
      ],
      "Consists of content views": [
        "Consiste en affichages de contenu"
      ],
      "Consists of repositories": [
        "Consiste en référentiels"
      ],
      "Consumed": [
        "Consommé"
      ],
      "Container Image Manifest": [
        "Manifeste de l'image du conteneur"
      ],
      "Container Image Repositories are not protected at this time. They need to be published via http to be available to containers.": [
        "Les référentiels d’image de conteneur ne sont pas toujours protégés. Ils ont besoin d'être publiés via http pour être disponibles aux conteneurs."
      ],
      "Container Image Tag": [
        "Balise d'image de conteneur"
      ],
      "Container Image Tags": [
        "Balises d'images de conteneurs"
      ],
      "Container Image repo '%{repo}' is present in multiple component content views.": [
        "L'image du conteneur '%{repo}' est présente dans les vues de contenu à composants multiples."
      ],
      "Container Images": [
        "Images de conteneurs"
      ],
      "Container image tag": [
        "Balise d'image de conteneur"
      ],
      "Container image tags": [
        "Balises d'images de conteneurs"
      ],
      "Container manifest lists": [
        "Listes de manifestes d'images de conteneur"
      ],
      "Container manifests": [
        "Manifestes de containeurs"
      ],
      "Container tags": [
        "Balises de conteneur"
      ],
      "Content": [
        "Contenu"
      ],
      "Content Count": [
        "Nombre de contenus"
      ],
      "Content Credential ID": [
        "ID Identifiants de contenu"
      ],
      "Content Credential numeric identifier": [
        "identificateur numérique d’attestation de contenu"
      ],
      "Content Credential to use for SSL CA. Relevant only for 'upstream_server' type.": [
        "Identifiant de contenu à utiliser pour l'autorité de certification SSL. Pertinent uniquement pour le type \\\"upstream_server\\\"."
      ],
      "Content Credentials": [
        "Identifiants de contenu"
      ],
      "Content Details": [
        "Détails du contenu"
      ],
      "Content Download URL": [
        "URL de téléchargement du contenu"
      ],
      "Content Facet for host with id %s is non-existent. Skipping applicability calculation.": [
        "La facette de contenu pour l'hôte avec id %s est inexistante. Sauter le calcul de l'applicabilité."
      ],
      "Content Hosts": [
        "Hôtes du contenu"
      ],
      "Content Source": [
        "Source de contenu"
      ],
      "Content Sync": [
        "Sync Contenu"
      ],
      "Content Types": [
        "Types de contenu"
      ],
      "Content View": [
        "Vue du contenu"
      ],
      "Content View %{view}: Versions: %{versions}": [
        "Affichage de contenu %{view}: Versions: %{versions} "
      ],
      "Content View Details": [
        "Détails d'affichage du contenu"
      ],
      "Content View Filter id": [
        "Id du filtre d'affichage de contenu"
      ],
      "Content View Filter identifier. Use to filter by ID": [
        ""
      ],
      "Content View ID": [
        "ID d’affichage de contenu"
      ],
      "Content View Name": [
        "Nom de la vue de contenu"
      ],
      "Content View Version %{id} not in all specified environments %{envs}": [
        "La version d'affichage de contenu %{id} ne se trouve pas dans tous les environnements %{envs} indiqués"
      ],
      "Content View Version Ids to perform an incremental update on.  May contain composites as well as one or more components to update.": [
        "Les ID de version d'affichage de contenu sur lesquels effectuer une mise à jour croissante. Peut contenir des éléments composites ainsi qu'un ou plusieurs composants à mettre à jour."
      ],
      "Content View Version identifier": [
        "Identifiant de version d'affichage de contenu"
      ],
      "Content View Version not set": [
        "Version d'affichage de contenu non définie"
      ],
      "Content View Version specified in the metadata - '%{name}' already exists. If you wish to replace the existing version, delete %{name} and try again. ": [
        "Content View Version spécifiée dans les métadonnées - '%{name}' existe déjà. Si vous souhaitez remplacer la version existante, supprimez %{name} et réessayez. "
      ],
      "Content View Version: '%{cvv}', Product: '%{product}', Repository: '%{repo}' ": [
        "Content View Version : '%{cvv}', Product : '%{product}', Repository : '%{repo}' "
      ],
      "Content View id": [
        "ID de la vue de contenu"
      ],
      "Content View label not provided.": [
        "La balise Content View n'est pas fournie."
      ],
      "Content Views": [
        "Affichages du contenu"
      ],
      "Content cannot be imported into a Composite Content View. ": [
        "Le contenu ne peut pas être importé dans une vue de contenu composite. "
      ],
      "Content credential": [
        "Identifiants de contenu"
      ],
      "Content credentials": [
        "Identifiants de contenu"
      ],
      "Content facet for host %s has more than one content view. Use #content_views instead.": [
        ""
      ],
      "Content facet for host %s has more than one lifecycle environment. Use #lifecycle_environments instead.": [
        ""
      ],
      "Content files to upload. Can be a single file or array of files.": [
        "Fichiers de contenu à télécharger. Il peut s'agir d'un fichier unique ou d'un ensemble de fichiers."
      ],
      "Content host must be unregistered before performing this action.": [
        "L'hôte du contenu doit être dés-enregistré avant d'effectuer cette action."
      ],
      "Content hosts": [
        "Hôtes du contenu"
      ],
      "Content imported by %{user} into content view '%{name}'": [
        "Contenu importé par %{user} dans la vue du contenu '%{name}'."
      ],
      "Content may come from {contentSourceName} or any other Smart Proxy behind the load balancer.": [
        ""
      ],
      "Content not uploaded to pulp": [
        "Le contenu ne peut pas être téléchargé dans pulp"
      ],
      "Content override search parameters": [
        "Le contenu remplace les paramètres de recherche"
      ],
      "Content source": [
        "Source de contenu"
      ],
      "Content source ID": [
        "ID Source de contenu"
      ],
      "Content source was not set for host '%{host}'": [
        "La source de contenu n’a pas été définie pour l’hôte '%{host}'"
      ],
      "Content type": [
        "Type de contenu"
      ],
      "Content type %{content_type_string} does not belong to an enabled repo type.": [
        "Le type de contenu %{content_type_string} n'appartient pas à un type de repo activé."
      ],
      "Content type %{content_type} is incompatible with repositories of type %{repo_type}": [
        "Le type de contenu {content_type} est incompatible avec les référentiels de type %{repo_type}"
      ],
      "Content type does not support repo discovery": [
        ""
      ],
      "Content view": [
        "Affichage de contenu"
      ],
      "Content view ${name} created": [
        "Vue de contenu {name} créée"
      ],
      "Content view '%{content_view}' is not attached to the environment.": [
        ""
      ],
      "Content view '%{content_view}' is not attached to this capsule.": [
        ""
      ],
      "Content view '%{cv_name}' is a generated content view, which cannot be assigned to hosts or activation keys.": [
        ""
      ],
      "Content view '%{view}' is not in environment '%{env}'": [
        "L'affichage de contenu '%{view}' ne se trouve pas dans l'environnement '%{env}' "
      ],
      "Content view '%{view}' is not in lifecycle environment '%{env}'.": [
        "L'affichage de contenu '%{view}' ne se trouve pas dans l'environnement de cycle de vie '%{env}'."
      ],
      "Content view ID": [
        "ID d’affichage de contenu"
      ],
      "Content view and environment not set for registration.": [
        ""
      ],
      "Content view and lifecycle environment must be provided together": [
        ""
      ],
      "Content view does not need a publish since there are no audited changes since the last publish. Pass check_needs_publish parameter as false if you don't want to check if content view needs a publish.": [
        ""
      ],
      "Content view environment": [
        ""
      ],
      "Content view environments": [
        ""
      ],
      "Content view environments and activation key must all belong to the same organization": [
        ""
      ],
      "Content view environments must have both a content view and an environment": [
        ""
      ],
      "Content view has repository label '%s' which is not specified in repos_units parameter.": [
        "La vue du contenu a un label de référentiel '%s' qui n'est pas spécifié dans le paramètre repos_units."
      ],
      "Content view identifier": [
        "Identifiant d'affichage du contenu"
      ],
      "Content view label": [
        "Balise d'affichage du contenu"
      ],
      "Content view must be specified": [
        ""
      ],
      "Content view name": [
        "Nom de la vue de contenu"
      ],
      "Content view not provided in the metadata": [
        "Vue du contenu non fournie dans les métadonnées"
      ],
      "Content view numeric identifier": [
        "Identifiant numérique d'affichage du contenu"
      ],
      "Content view promote failure": [
        ""
      ],
      "Content view publish failure": [
        ""
      ],
      "Content view version export history identifier": [
        "Afficher l'historique des exportations pour une version d’affichage de contenu"
      ],
      "Content view version identifier": [
        "Identifiant de la version de l'affichage du contenu"
      ],
      "Content view version import history identifier": [
        "Identifiant de l'historique d'importation de la version d’affichage de contenu"
      ],
      "Content view version is empty": [
        ""
      ],
      "Content view version is empty or content counts are not up to date": [
        ""
      ],
      "Content views": [
        "Affichages de contenu"
      ],
      "Content will be synced from the alternate content source first, then the original source if the ACS is not reachable.": [
        "Le contenu sera synchronisé à partir de la source de contenu alternative d'abord, puis de la source originale si l'ACS n'est pas joignable."
      ],
      "Content_Host_Status": [
        "Content_Host_Status"
      ],
      "Contents of requirement yaml file to sync from URL": [
        "Contenu du fichier yaml requis à sync à partir de l'URL"
      ],
      "Context": [
        "Contexte"
      ],
      "Contract": [
        "Contrat"
      ],
      "Contract Number": [
        "Numéro de contrat"
      ],
      "Copied to clipboard": [
        "Copié dans le presse-papiers"
      ],
      "Copy": [
        "Copie"
      ],
      "Copy an activation key": [
        "Copier une clé d'activation|"
      ],
      "Copy content view": [
        "Copier l’affichage de contenu"
      ],
      "Copy to clipboard": [
        "Copier dans le presse-papiers"
      ],
      "Cores per socket": [
        "Cores par socket"
      ],
      "Cores: %s": [
        "Cores: %s"
      ],
      "Could not delete organization '%s'.": [
        "Suppression de l'organisation '%s' impossible."
      ],
      "Could not find %{content} with id '%{id}' in repository.": [
        "Impossible de trouver %{content} ayant pour id '%{id}'. dans le référentiel."
      ],
      "Could not find %{count} errata.  Only found: %{found}": [
        "Impossible de trouver errata %{count}. Résultat: %{found} uniquement."
      ],
      "Could not find %{name} resource with id %{id}. %{perms_message}": [
        "Impossible de trouver la ressource %%{name} avec l'identifiant %%{id}. %{perms_message}"
      ],
      "Could not find %{name} resources with ids %{ids}": [
        "Impossible de trouver la ressource %%{name} avec l'identifiant %%{ids}"
      ],
      "Could not find Environment with ids: %s": [
        "Impossible de trouver un environnement avec les ID : %s"
      ],
      "Could not find Lifecycle Environment with id '%{id}'.": [
        "Impossible de trouver un Environnement de cycle de vie avec l'ID '%{id}'."
      ],
      "Could not find a host with id %s": [
        "Impossible de trouver errata ayant pour id %s"
      ],
      "Could not find a smart proxy with pulp feature.": [
        "Impossible de trouver un proxy smart avec la fonction pulp."
      ],
      "Could not find all specified errata ids: %s": [
        "Impossible de trouver tous les ID d'errata indiqués : %s"
      ],
      "Could not find environments for promotion": [
        "N'a pas pu trouver d'environnements pour la promotion"
      ],
      "Could not locate Pulp distribution.": [
        ""
      ],
      "Could not locate local uploaded repository for content indexing.": [
        ""
      ],
      "Could not locate repository properties for content indexing.": [
        ""
      ],
      "Could not remove the lifecycle environment from the smart proxy": [
        "Impossible de supprimer l'environnement du cycle de vie du proxy smart"
      ],
      "Couldn't establish a connection to %s": [
        "N’a pas pu établir de connexion à %s"
      ],
      "Couldn't find %{content_type} with id '%{id}'": [
        "N'a pas pu trouver %{content_type} ayant pour id '%{id}'"
      ],
      "Couldn't find %{type} Filter with id %{id}": [
        "Impossible de trouver le Filtre %{type} avec l'ID %{id}"
      ],
      "Couldn't find ContentViewFilter with id=%s": [
        "Le filtre d'affichage du contenu avec l'ID =%s est introuvable"
      ],
      "Couldn't find Organization '%s'.": [
        "Organisation '%s' introuvable."
      ],
      "Couldn't find activation key '%s'": [
        "Clé d'activation '%s' introuvable"
      ],
      "Couldn't find activation key content view id '%s'": [
        "L'affichage de contenu de la clé d'activation avec l'id '%s' est introuvable"
      ],
      "Couldn't find activation key environment '%s'": [
        "L'environnement de la clé d'activation '%s' est introuvable"
      ],
      "Couldn't find consumer '%s'": [
        "Le consommateur '%s' est introuvable"
      ],
      "Couldn't find content host content view id '%s'": [
        "L'id de l'affichage du contenu de la clé d'activation '%s' est introuvable"
      ],
      "Couldn't find content host environment '%s'": [
        "L'environnement de l'hôte du contenu '%s' est introuvable"
      ],
      "Couldn't find content view environment with content view ID '%{cv}' and environment ID '%{env}'": [
        ""
      ],
      "Couldn't find content view version '%s'": [
        "Impossible de trouver la version d'affichage de contenu '%s'"
      ],
      "Couldn't find content view versions '%s'": [
        "Impossible de trouver les versions d'affichage de contenu '%s'"
      ],
      "Couldn't find content view with id: '%s'": [
        "Impossible de trouver l’id de contenu '%s'"
      ],
      "Couldn't find environment '%s'": [
        "Environnement '%s' introuvable"
      ],
      "Couldn't find errata ids '%s'": [
        "Les id d'errata '%s' sont introuvables"
      ],
      "Couldn't find host collection '%s'": [
        "La collection de l'hôte '%s' est introuvable"
      ],
      "Couldn't find host with host id '%s'": [
        "N'a pas pu trouver l'hôte avec l'id d'hôte '%s'"
      ],
      "Couldn't find organization '%s'": [
        "Organisation '%s' introuvable"
      ],
      "Couldn't find prior-environment '%s'": [
        "Le pré-environnement  '%s' est introuvable"
      ],
      "Couldn't find product with id '%s'": [
        "Le produit avec l’Id '%s' est introuvable"
      ],
      "Couldn't find products with id '%s'": [
        "Impossible de trouver des produits avec l'id '%s'."
      ],
      "Couldn't find repository '%s'": [
        "Référentiel '%s' introuvable"
      ],
      "Couldn't find smart proxies with id '%s'": [
        "Impossible de trouver les proxies smart avec l'id '%s'."
      ],
      "Couldn't find smart proxies with name '%s'": [
        "Impossible de trouver les proxies avec l'id '%s'."
      ],
      "Couldn't find specified content view and lifecycle environment.": [
        ""
      ],
      "Couldn't find subject of synchronization": [
        "Sujet de la synchronisation introuvable"
      ],
      "Create": [
        "Créer"
      ],
      "Create ACS": [
        "Créer ACS"
      ],
      "Create Alternate Content Source": [
        "Créer une autre source de contenu"
      ],
      "Create Container Push Repository Root": [
        ""
      ],
      "Create Export History": [
        "Créer un historique des exportations"
      ],
      "Create Import History": [
        "Créer un historique des importations"
      ],
      "Create Repositories": [
        "Créer des référentiels"
      ],
      "Create Syncable Export History": [
        "Créer un historique d'exportation synchronisable"
      ],
      "Create a Content Credential": [
        "Créer un identifiant de contenu"
      ],
      "Create a content view": [
        "Créer un affichage du contenu"
      ],
      "Create a custom product": [
        "Créer un produit personnalisé"
      ],
      "Create a custom repository": [
        "Créer un référentiel personnalisé"
      ],
      "Create a filter rule. The parameters included should be based upon the filter type.": [
        "Créer une règle de filtre. Les paramètres inclus doivent se baser sur le type de filtre."
      ],
      "Create a flatpak remote": [
        ""
      ],
      "Create a host collection": [
        "Créer une collection d'hôte"
      ],
      "Create a product": [
        "Créer un produit"
      ],
      "Create a sync plan": [
        "Créer un plan de sync"
      ],
      "Create an activation key": [
        "Créer une clé d'activation"
      ],
      "Create an alternate content source to download content from during repository syncing.  Note: alternate content sources are global and affect ALL sync actions on their smart proxies regardless of organization.": [
        "Créez une source de contenu alternative pour télécharger du contenu pendant la synchronisation du référentiel.  Remarque : les sources de contenu alternatives sont globales et affectent TOUTES les actions de synchronisation sur leurs proxys smart, quelle que soit l'organisation."
      ],
      "Create an environment": [
        "Créer un environnement"
      ],
      "Create an environment in an organization": [
        "Créer un environnement dans une organisation"
      ],
      "Create an upload request": [
        "Créer une requête de téléchargement"
      ],
      "Create content credentials with the generated SSL certificate and key.": [
        "Créez les informations d'identification du contenu avec le certificat et la clé SSL générés."
      ],
      "Create content view": [
        "Créer Affichage du contenu"
      ],
      "Create filter": [
        "Créer un filtre"
      ],
      "Create host collection": [
        "Créer Collection d'hôtes"
      ],
      "Create new activation key": [
        ""
      ],
      "Create organization": [
        "Créer une organisation"
      ],
      "Create package filter rule": [
        "Créer une règle de filtrage des paquets"
      ],
      "Create rule": [
        "Créer une règle"
      ],
      "Credentials": [
        "Identifiants"
      ],
      "Critical": [
        "Critique"
      ],
      "Cron expression is not valid!": [
        "L'expression cron n'est pas acceptée."
      ],
      "Current organization does not have a manifest imported.": [
        "L'organisation actuelle ne dispose pas d'un manifeste importé."
      ],
      "Current organization is not set.": [
        "L'organisation actuelle n'est pas déterminée."
      ],
      "Current organization not set.": [
        "Organisation actuelle non déterminée."
      ],
      "Custom": [
        "Personnalisé"
      ],
      "Custom CDN": [
        "CDN personnalisé"
      ],
      "Custom Content Repositories": [
        "Référentiels au contenu personnalisé"
      ],
      "Custom cron expression only needs to be set for interval value of custom cron": [
        "L'expression cron personnalisée ne doit être définie que pour la valeur de l'intervalle de cron personnalisé"
      ],
      "Custom repositories cannot be disabled.": [
        "Les référentiels personnalisés ne peuvent pas être désactivés."
      ],
      "Customize with Rex": [
        "Personnalisez avec Rex"
      ],
      "DEB name": [
        "Nom DEB"
      ],
      "DEB package updates": [
        "Mises à jour des paquets DEB"
      ],
      "Database connection": [
        "Connexion à la base de données"
      ],
      "Date": [
        "Date"
      ],
      "Date format is incorrect.": [
        "Le format de la date est incorrect."
      ],
      "Days Remaining": [
        "Jours restants"
      ],
      "Days from Now": [
        "Jours à compter d’aujourd’hui"
      ],
      "Deb": [
        "Deb"
      ],
      "Deb Package": [
        "Package Deb"
      ],
      "Deb Packages": [
        "Packages Deb"
      ],
      "Deb name": [
        "Nom Deb"
      ],
      "Deb package identifiers to filter content by": [
        "Identificateurs de packages Deb pour filtrer le contenu"
      ],
      "Deb packages": [
        "Packages Deb"
      ],
      "Debian packages": [
        ""
      ],
      "Debug Certificate": [
        "Déboguer Certificat"
      ],
      "Debug RPM": [
        "Déboguer RPM"
      ],
      "Default Custom Repository download policy": [
        "Politique de téléchargement par défaut du référentiel personnalisé"
      ],
      "Default HTTP Proxy": [
        "Proxy HTTP par défaut"
      ],
      "Default HTTP proxy for syncing content": [
        "Proxy HTTP par défaut pour la synchronisation du contenu"
      ],
      "Default Location where new subscribed hosts will put upon registration": [
        "Emplacement par défaut où les nouveaux hôtes abonnés se situeront après l’inscription"
      ],
      "Default PXEGrub template for new Operating Systems created from synced content": [
        "Modèle PXEGrub par défaut pour les nouveaux systèmes d'exploitation créés à partir de contenu synchronisé"
      ],
      "Default PXEGrub2 template for new Operating Systems created from synced content": [
        "Modèle PXEGrub2 par défaut pour les nouveaux systèmes d'exploitation créés à partir de contenu synchronisé"
      ],
      "Default PXELinux template for new Operating Systems created from synced content": [
        "Modèle PXELinux par défaut pour les nouveaux systèmes d'exploitation créés à partir de contenu synchronisé"
      ],
      "Default Red Hat Repository download policy": [
        "Politique de téléchargement par défaut du référentiel Red Hat"
      ],
      "Default Smart Proxy download policy": [
        "Politique de téléchargement par défaut du Proxy Smart"
      ],
      "Default System SLA": [
        "SLA du système par défaut"
      ],
      "Default content view versions cannot be promoted": [
        "Les versions de l'affichage du contenu par défaut ne peuvent pas être promues"
      ],
      "Default download policy for Smart Proxy syncs (either 'inherit', immediate', or 'on_demand')": [
        "Stratégie de téléchargement par défaut des syncs de Proxy Smart (soit 'immediate', 'on_demand')"
      ],
      "Default download policy for custom repositories (either 'immediate' or 'on_demand')": [
        "Stratégie de téléchargement par défaut des référentiels personnalisés (soit 'immediate', 'on_demand')"
      ],
      "Default download policy for enabled Red Hat repositories (either 'immediate' or 'on_demand')": [
        "Stratégie de téléchargement par défaut des référentiels Red Hat (soit 'immediate', 'on_demand')"
      ],
      "Default export format": [
        ""
      ],
      "Default export format for content-exports(either 'syncable' or 'importable')": [
        ""
      ],
      "Default finish template for new Operating Systems created from synced content": [
        "Modèle de finition par défaut pour les nouveaux systèmes d'exploitation créés à partir de contenu synchronisé"
      ],
      "Default iPXE template for new Operating Systems created from synced content": [
        "Modèle iPXE par défaut pour les nouveaux systèmes d'exploitation créés à partir de contenu synchronisé"
      ],
      "Default kexec template for new Operating Systems created from synced content": [
        "Modèle kexec par défaut pour les nouveaux systèmes d'exploitation créés à partir de contenu synchronisé"
      ],
      "Default location for subscribed hosts": [
        "Emplacement par défaut des hôtes souscrits"
      ],
      "Default partitioning table for new Operating Systems created from synced content": [
        "Tableau de partitionnement par défaut pour les nouveaux systèmes d'exploitation créés à partir de contenu synchronisé"
      ],
      "Default provisioning template for Operating Systems created from synced content": [
        "Modèle de provisionnement par défaut pour les systèmes d'exploitation créés à partir de contenu synchronisé"
      ],
      "Default provisioning template for new Atomic Operating Systems created from synced content": [
        "Modèle de provisionnement par défaut pour les nouveaux systèmes d'exploitation atomiques créés à partir de contenu synchronisé"
      ],
      "Default synced OS Atomic template": [
        "Modèle Atomic OS synchronisé par défaut"
      ],
      "Default synced OS PXEGrub template": [
        "Modèle PXEGrub pour OS synchronisé par défaut"
      ],
      "Default synced OS PXEGrub2 template": [
        "Modèle PXEGrub2 synchronisé par défaut"
      ],
      "Default synced OS PXELinux template": [
        "Modèle PXELinux synchronisé par défaut"
      ],
      "Default synced OS finish template": [
        "Modèle de fin d'OS synchronisé par défaut"
      ],
      "Default synced OS iPXE template": [
        "Modèle synchronisé par défaut de l'OS iPXE"
      ],
      "Default synced OS kexec template": [
        "Modèle de synchronisation par défaut de l'OS kexec"
      ],
      "Default synced OS partition table": [
        "Table de partition du système d'exploitation synchronisé par défaut"
      ],
      "Default synced OS provisioning template": [
        "Modèle de provisionnement par défaut du système d'exploitation synchronisé"
      ],
      "Default synced OS user-data": [
        "Données utilisateur du système d'exploitation synchronisé par défaut"
      ],
      "Default user data for new Operating Systems created from synced content": [
        "Données utilisateur par défaut pour les nouveaux systèmes d'exploitation créés à partir de contenu synchronisé"
      ],
      "Define RHUI repository paths with guided steps.": [
        "Définir les chemins du référentiel RHUI avec des étapes guidées."
      ],
      "Define repositories structured under a common web or filesystem path.": [
        "Définir des référentiels structurés sous un chemin web ou un chemin de système de fichiers commun."
      ],
      "Delete": [
        "Supprimer"
      ],
      "Delete Activation Key": [
        "Supprimer la clé d'activation"
      ],
      "Delete Host upon unregister": [
        "Supprimer l'hôte lors de la désinscription"
      ],
      "Delete Lifecycle Environment": [
        "Supprimer l'environnement de cycle de vie"
      ],
      "Delete Manifest": [
        "Supprimer le manifeste"
      ],
      "Delete Product": [
        "Supprimer le produit"
      ],
      "Delete Upstream Subscription": [
        "Supprimer l'abonnement en amont"
      ],
      "Delete Version": [
        "Supprimer la version"
      ],
      "Delete a content view": [
        "Supprimer un affichage de contenu"
      ],
      "Delete a filter rule": [
        "Supprimer une règle de filtre"
      ],
      "Delete a flatpak remote": [
        ""
      ],
      "Delete activation key?": [
        ""
      ],
      "Delete all subscriptions attached to activation keys.": [
        "Supprimez tous les abonnements attachés aux clés d'activation."
      ],
      "Delete all subscriptions that are attached to running hosts.": [
        "Supprimez tous les abonnements qui sont liés aux hôtes en cours d'exécution."
      ],
      "Delete an organization": [
        "Supprimer une organisation"
      ],
      "Delete an upload request": [
        "Supprimer une requête de téléchargement"
      ],
      "Delete content view": [
        "Supprimer l’affichage du contenu"
      ],
      "Delete content view filters that have this repository as the last associated repository. Defaults to true. If false, such filters will now apply to all repositories in the content view.": [
        ""
      ],
      "Delete manifest from Red Hat provider": [
        "Supprimer le fichier manifeste du fournisseur Red Hat"
      ],
      "Delete multiple filters from a content view": [
        "Supprimer plusieurs filtres d'affichage de contenu"
      ],
      "Delete version": [
        "Supprimer la version"
      ],
      "Delete versions": [
        "Supprimer les versions"
      ],
      "Deleted %{host_count} %{hosts}": [
        ""
      ],
      "Deleted consumer '%s'": [
        "L'utilisateur '%s' a été supprimé"
      ],
      "Deleted from ": [
        "Supprimé(s) de "
      ],
      "Deleted from %{environment}": [
        "Supprimé de %{environment}"
      ],
      "Deleting content view : ": [
        "Supprimer l’affichage de contenu :"
      ],
      "Deleting manifest in '%{subject}' failed.": [
        "La suppression du manifeste de '%{subject}' a échoué."
      ],
      "Deleting version {versionList}": [
        "Suppression de la version {versionList}"
      ],
      "Deleting versions: {versionList}": [
        "Suppression des versions : {versionList}"
      ],
      "Depth": [
        ""
      ],
      "Description": [
        "Description"
      ],
      "Description for the alternate content source": [
        "Description de la source de contenu alternatif"
      ],
      "Description for the content view": [
        "Description de l'affichage du contenu"
      ],
      "Description for the new published content view version": [
        "Description de la version d'affichage de contenu récemment publiée"
      ],
      "Description of the flatpak remote": [
        ""
      ],
      "Description of the repository": [
        "Description du référentiel"
      ],
      "Designate this Content View for importing from upstream servers only. Defaults to false": [
        "Désigne cette vue de contenu pour l'importation à partir de serveurs en amont uniquement. Valeur par défaut : false"
      ],
      "Desired quantity of the pool": [
        "Quantité souhaitée du pool"
      ],
      "Destination Server name": [
        "Nom du serveur de destination"
      ],
      "Destroy": [
        "Détruire"
      ],
      "Destroy Alternate Content Source": [
        "Détruire la source de contenu alternatif"
      ],
      "Destroy Content Host": [
        "Détruire l'hôte du contenu"
      ],
      "Destroy Content Host %s": [
        "Détruire l'hôte du contenu %s"
      ],
      "Destroy a Content Credential": [
        "Détruire un identifiant de contenu"
      ],
      "Destroy a custom repository": [
        "Détruire un référentiel personnalisé"
      ],
      "Destroy a host collection": [
        "Détruire une collection d'hôtes"
      ],
      "Destroy a product": [
        "Détruire un produit"
      ],
      "Destroy a sync plan": [
        "Détruire un plan de sync"
      ],
      "Destroy an activation key": [
        "Détruire une clé d'activation"
      ],
      "Destroy an alternate content source.": [
        "Détruire une autre source de contenu"
      ],
      "Destroy an environment": [
        "Détruire un environnement"
      ],
      "Destroy an environment in an organization": [
        "Détruire un environnement dans une organisation"
      ],
      "Destroy one or more alternate content sources": [
        "Détruire une ou plusieurs sources de contenu alternatives"
      ],
      "Destroy one or more hosts": [
        "Détruire un ou plusieurs hôtes"
      ],
      "Destroy one or more products": [
        "Détruire un ou plusieurs produits"
      ],
      "Destroy one or more repositories": [
        "Détruire un ou plusieurs référentiels"
      ],
      "Details": [
        "Détails"
      ],
      "Determining settings for ${truncate(name)}": [
        ""
      ],
      "Digest": [
        ""
      ],
      "Directly setting package lists on composite content views is not allowed. Please update the components, then re-publish the composite.": [
        "Il n'est pas permis de définir directement des listes de packages sur des vues de contenu composite. Veuillez mettre à jour les composants, puis republier le composite."
      ],
      "Directory containing the exported Content View Version": [
        "Répertoire contenant une version d’affichage de contenu"
      ],
      "Disable": [
        "Désactiver"
      ],
      "Disable Red Hat Insights.": [
        "Désactivez Red Hat Insights."
      ],
      "Disable Simple Content Access": [
        "Désactivez l'accès au contenu simple"
      ],
      "Disable a repository from the set": [
        "Désactiver un référentiel à partir de l'ensemble"
      ],
      "Disable module stream": [
        "Désactiver le flux de modules"
      ],
      "Disabled": [
        "Désactivé"
      ],
      "Disabling Simple Content Access failed for '%{subject}'.": [
        "La désactivation de l'accès au contenu simple a échoué pour '%{subject}'."
      ],
      "Discover Repositories": [
        "Découvrir des référentiels"
      ],
      "Distribute archived content view versions": [
        "Distribuer les versions d'affichage du contenu archivé"
      ],
      "Do not include this array of content views": [
        "N'inclut pas cet ensemble d'affichages de contenu"
      ],
      "Do not wait for the ImportUpload action to finish. Default: false": [
        "N'attendez pas la fin de l'action ImportUpload. Valeur par défaut : false"
      ],
      "Do not wait for the update action to finish. Default: true": [
        "N'attendez pas que l'action de mise à jour soit terminée. Valeur par défaut : true"
      ],
      "Domain IDs": [
        "ID de domaines"
      ],
      "Download Policy of the capsule, must be one of %s": [
        "Politique de téléchargement de la capsule, doit être un parmi %s"
      ],
      "Download a debug certificate": [
        "Télécharger un certificat de débogage"
      ],
      "Download rate limit": [
        "Limite du débit de téléchargement"
      ],
      "Due to a change in your organizations, this container name has become ambiguous (org name '%{org_label}'). If you wish to continue using this container name, destroy the organization in conflict with '%{o_name} (id %{o_id}). If you wish to keep both orgs, destroy '%{o_label}/%{prod_label}/%{root_repo_label}' and retry your push using the id format.": [
        ""
      ],
      "Due to a change in your products, this container name has become ambiguous (product name '%{prod_label}'). If you wish to continue using this container name, destroy the product in conflict with '%{prod_name}' (id %{prod_id}). If you wish to keep both products, destroy '%{org_label}/%{prod_dot_label}/%{root_repo_label}' and retry your push using the id format.": [
        ""
      ],
      "Duplicate artifact detected": [
        "Artifact en double détecté"
      ],
      "Duplicate repositories in content view versions": [
        ""
      ],
      "Duration": [
        "Durée"
      ],
      "ERRATA ADVISORY": [
        "AVIS ERRATA"
      ],
      "Edit": [
        "Modifier"
      ],
      "Edit RPM rule": [
        "Ajouter une règle RPM"
      ],
      "Edit URL and subpaths": [
        "Modifier l'URL et les sous-chemins"
      ],
      "Edit activation key": [
        ""
      ],
      "Edit content view assignment": [
        "Modifier l'affectation de la vue du contenu"
      ],
      "Edit content view environments": [
        ""
      ],
      "Edit credentials": [
        "Modifier les informations d'identification"
      ],
      "Edit details": [
        "Modifier les détails"
      ],
      "Edit filter rule": [
        "Modifier la règle de filtrage"
      ],
      "Edit package filter rule": [
        "Modifier la règle de filtrage des paquets"
      ],
      "Edit products": [
        "Modifier les produits"
      ],
      "Edit rule": [
        "Modifier la règle"
      ],
      "Edit smart proxies": [
        "Modifier les Smart Proxies"
      ],
      "Edit system purpose attributes": [
        "Modifier les attributs system purpose"
      ],
      "Editing Entitlements": [
        "Modification des droits d'accès"
      ],
      "Either both parameters 'content_view_id' and 'environment_id' should be specified or neither should be specified": [
        "Soit les deux paramètres 'content_view_id' et 'environment_id' doivent être indiqués à la fois, soit aucun d'entre deux ne doit être indiqué."
      ],
      "Either environments or versions must be specified.": [
        "La version ou l'environnement doit être spécifié"
      ],
      "Either organization ID or environment ID needs to be specified": [
        "L'ID de l'organisation ou de l'environnement doit être spécifié"
      ],
      "Either packages or groups must be provided": [
        "Les packages ou les groupes doivent être fournis"
      ],
      "Either set the content view with the latest flag or set the content view version": [
        "Définir la vue du contenu avec le dernier drapeau ou définir la version de la vue du contenu"
      ],
      "Either set the latest content view or the content view version. Cannot set both": [
        "Définissez soit la dernière vue du contenu, soit la version de la vue du contenu. Il n'est pas possible de définir les deux"
      ],
      "Empty content view versions": [
        "Versions de vue du contenu vides"
      ],
      "Enable": [
        "Activer"
      ],
      "Enable Red Hat repositories": [
        "Activer les référentiels Red Hat"
      ],
      "Enable Simple Content Access": [
        "Permettre un accès simple au contenu"
      ],
      "Enable Tracer": [
        "Activer Traceur"
      ],
      "Enable Traces": [
        "Activer Traces"
      ],
      "Enable a repository from the set": [
        "Activer un référentiel à partir de l'ensemble"
      ],
      "Enable repository sets": [
        "Activer les ensembles de référentiels"
      ],
      "Enable structured APT for deb content": [
        ""
      ],
      "Enable/Disable auto publish of composite view": [
        "Activer/désactiver la publication automatique de la vue composite"
      ],
      "Enabled": [
        "Activé"
      ],
      "Enabled Repositories": [
        "Référentiels activés"
      ],
      "Enabling Simple Content Access failed for '%{subject}'.": [
        "L'activation de l'accès au contenu simple a échoué pour '%{subject}'."
      ],
      "Enabling Tracer requires installing the katello-host-tools-tracer package on the host.": [
        ""
      ],
      "End Date": [
        "Date de Fin"
      ],
      "End date": [
        "Date de fin"
      ],
      "Ends": [
        "Se termine"
      ],
      "Enhancement": [
        "Amélioration"
      ],
      "Enter a name": [
        "Saisir un nom"
      ],
      "Enter a name for your source.": [
        "Entrez un nom pour votre source."
      ],
      "Enter a valid date: MM/DD/YYYY": [
        "Entrez une date valide : MM/JJ/AAAA"
      ],
      "Enter basic authentication information or choose content credentials if required for this source.": [
        "Saisissez les informations d'authentification de base ou choisissez les informations d'identification du contenu si nécessaire pour cette source."
      ],
      "Enter in the base path and any subpaths that should be searched for alternate content.": [
        "Saisissez le chemin de base et tous les sous-chemins qui doivent être recherchés pour le contenu alternatif."
      ],
      "Entitlements": [
        "Droits d’accès"
      ],
      "Environment": [
        "Environnement"
      ],
      "Environment ID": [
        ""
      ],
      "Environment ID and content view ID must be provided together": [
        ""
      ],
      "Environment IDs": [
        "IDs des environnements"
      ],
      "Environment cannot be in its own promotion path": [
        "L'environnement ne peut pas se trouver dans son propre chemin de promotion"
      ],
      "Environment identifier": [
        "Identifiant d'environnement"
      ],
      "Environment name": [
        ""
      ],
      "Environments": [
        "Environnements"
      ],
      "Epoch": [
        "Epoch"
      ],
      "Equal to": [
        "Egal à"
      ],
      "Errata": [
        "Errata"
      ],
      "Errata - by date range": [
        "Errata - par plage de dates"
      ],
      "Errata ID": [
        "ID d'errata"
      ],
      "Errata Install": [
        "Installation d'errata"
      ],
      "Errata Install scheduled by %s": [
        "Installation de l'errata planifiée par %s"
      ],
      "Errata and package information will be updated at the next host check-in or package action.": [
        ""
      ],
      "Errata and package information will be updated immediately.": [
        ""
      ],
      "Errata id of the erratum (RHSA-2012:108)": [
        "Id de l'erratum (RHSA-2012:108)"
      ],
      "Errata statuses not updated for deleted content facet with UUID %s": [
        ""
      ],
      "Errata to apply": [
        ""
      ],
      "Errata to exclusively include in the action": [
        "Errata à inclure exclusivement dans l'action"
      ],
      "Errata to explicitly exclude in the action. All other applicable errata will be included in the action, unless an included parameter is passed as well.": [
        "Errata à exclure explicitement dans l'action. Tous les autres errata applicables seront inclus dans l'action, à moins qu'un paramètre inclus ne soit également transmis."
      ],
      "Errata type": [
        "Type d'errata"
      ],
      "Erratum": [
        "Erratum"
      ],
      "Erratum Install Canceled": [
        "Annulation de l’installation de l'erratum"
      ],
      "Erratum Install Complete": [
        "Installation d'erratum terminée"
      ],
      "Erratum Install Failed": [
        "Échec de l'installation d'erratum"
      ],
      "Erratum Install Timed Out": [
        "Délai d'expiration de l'installation d'erratum dépassé"
      ],
      "Error": [
        "Erreur"
      ],
      "Error connecting to Pulp service": [
        "Erreur de connexion au service Pulp"
      ],
      "Error connecting. Got: %s": [
        "Error de connexion. %s"
      ],
      "Error loading content views": [
        "Erreur de chargement des vues de contenu"
      ],
      "Error refreshing status for %s: ": [
        "Erreur Statut de rafraîchissement pour %s : "
      ],
      "Error retrieving Pulp storage": [
        "Error de récupération du stockage Pulp"
      ],
      "Exceeds available quantity": [
        "Dépasse la quantité disponible"
      ],
      "Exclude": [
        "Exclure"
      ],
      "Exclude Refs": [
        ""
      ],
      "Exclude all RPMs not associated to any errata": [
        "Exclure tous les RPMs non associés à un errata."
      ],
      "Exclude all module streams not associated to any errata": [
        "Exclure tous les flux de modules non associés à un errata."
      ],
      "Exclude filter": [
        "Exclure filtre"
      ],
      "Excluded": [
        "Exclus"
      ],
      "Excluded errata": [
        "Exclure errata"
      ],
      "Excludes": [
        "Exclusions"
      ],
      "Exit": [
        "Sortie"
      ],
      "Expand All": [
        "Tout agrandir"
      ],
      "Expire soon days": [
        "Expiration prochaine en jours"
      ],
      "Expired ": [
        ""
      ],
      "Expires ": [
        ""
      ],
      "Export": [
        "Exporter"
      ],
      "Export CSV": [
        "Exporter CSV"
      ],
      "Export Library": [
        "Exporter Bibliothèque"
      ],
      "Export Repository": [
        "Référentiel d'exportation"
      ],
      "Export Sync": [
        "Synchronisation des exportations"
      ],
      "Export Types": [
        "Types d'exportation"
      ],
      "Export as CSV": [
        "Exporter en CSV"
      ],
      "Export failed: One or more repositories needs to be synced (with Immediate download policy.)": [
        ""
      ],
      "Export formats.Choose syncable if the exported content needs to be in a yum format. This option is only available for %{syncable_repos} repositories. Choose importable if the importing server uses the same version  and exported content needs to be one of %{importable_repos} repositories.": [
        ""
      ],
      "Export history identifier used for incremental export. If not provided the most recent export history will be used.": [
        "Identifiant de l'historique d'exportation utilisé pour l'exportation incrémentielle. S'il n'est pas fourni, l'historique d'exportation le plus récent sera utilisé."
      ],
      "Exported content view": [
        "Affichage de contenu exporté"
      ],
      "Exported version": [
        "Version exportée"
      ],
      "Extended support": [
        ""
      ],
      "Facts successfully updated.": [
        "Mise à jour des faits réussie."
      ],
      "Failed": [
        "Échec"
      ],
      "Failed to delete %{host}: %{errors}": [
        "N'a pas réussi à supprimer %{host}: %{errors}"
      ],
      "Failed to delete latest content view version of Content View '%{subject}'.": [
        "Échec de la suppression de la dernière version de la vue de contenu de la vue de contenu '%{subject}'."
      ],
      "Failed to find %{content} with id '%{id}'.": [
        "Impossible à trouver avec l'identifiant %{content} ayant pour id '%{id}'."
      ],
      "Fails if any of the repositories belonging to this organization are unexportable. False by default.": [
        "Échec si l'un des référentiels appartenant à cette organisation est non exportable. Faux par défaut."
      ],
      "Fails if any of the repositories belonging to this version are unexportable. False by default.": [
        "Échoue si l'un des référentiels appartenant à cette version est non exportable. Faux par défaut."
      ],
      "Fetch applicable errata for one or more hosts.": [
        "Collecter errata applicable pour un ou plusieurs systèmes hôtes."
      ],
      "Fetch available module streams for hosts.": [
        "Récupérez les flux de modules disponibles pour les hôtes."
      ],
      "Fetch installable errata for one or more hosts.": [
        "Récupérer les errata installables pour un ou plusieurs hôtes."
      ],
      "Fetch traces for one or more hosts": [
        "Rechercher traces pour un ou plusieurs hôtes"
      ],
      "Fetching content credentials": [
        "Récupération des informations d'identification du contenu"
      ],
      "Field to sort the results on": [
        "Champs dans lequel trier les résultats"
      ],
      "File": [
        "Fichier"
      ],
      "File contents": [
        "Contenus de fichier"
      ],
      "Filename": [
        "Nom du fichier"
      ],
      "Files": [
        "Fichiers"
      ],
      "Filter by Product": [
        "Filtrer par produit"
      ],
      "Filter by type": [
        "Filtrer par nom"
      ],
      "Filter composite versions whose publish was triggered by the specified component version": [
        "Filtrer les versions composites dont la publication a été déclenchée par la version du composant spécifié"
      ],
      "Filter content view versions that contain the file": [
        ""
      ],
      "Filter created": [
        "Filtre créé"
      ],
      "Filter deleted": [
        "Filtre supprimé"
      ],
      "Filter edited": [
        "Filtre modifié"
      ],
      "Filter only composite content views": [
        "Filtrer les affichages de contenu composites uniquement"
      ],
      "Filter out composite content views": [
        "Exclure les affichages de contenu composites du filtre"
      ],
      "Filter out default content views": [
        "Exclure les affichages de contenu par défaut du filtre"
      ],
      "Filter products by host id": [
        "Filtrer les produits par id d'hôte"
      ],
      "Filter products by name": [
        "Filtrer les produits par nom"
      ],
      "Filter products by organization": [
        "Filtrer les produits par organisation"
      ],
      "Filter products by subscription": [
        "Filtrer les produits par abonnement"
      ],
      "Filter products by sync plan id": [
        "Filtrer les produits par id de plan de sync"
      ],
      "Filter repositories by content unit type (erratum, docker_tag, etc.). Check the \\\"Indexed?\\\" types here: /katello/api/repositories/repository_types": [
        "Filtrez les dépôts par type d'unité de contenu (erratum, docker_tag, etc.). Vérifiez les types \\\"Indexé ?\\\" ici : /katello/api/repositories/repository_types"
      ],
      "Filter rule added": [
        "Règle de filtre ajoutée."
      ],
      "Filter rule edited": [
        "Règle de filtre modifiée."
      ],
      "Filter rule removed": [
        "Règle de filtre supprimée."
      ],
      "Filter rules added": [
        "Règles de filtre ajoutées"
      ],
      "Filter rules deleted": [
        "Règles de filtre supprimées."
      ],
      "Filter versions by environment": [
        "Filtrer les versions par environnement"
      ],
      "Filter versions by version number": [
        "Filtrer les versions par numéro de version"
      ],
      "Filter versions that are components in the specified composite version": [
        "Filtrer les versions composantes dans la version composite spécifiée."
      ],
      "Filters": [
        "Filtres"
      ],
      "Filters deleted": [
        "Filtres supprimés"
      ],
      "Filters were applied to this version.": [
        ""
      ],
      "Filters will be applied to this content view version.": [
        ""
      ],
      "Find the relative path for each RHUI repository and combine them in a comma-separated list.": [
        "Trouvez le chemin relatif de chaque référentiel RHUI et combinez-les dans une liste séparée par des virgules."
      ],
      "Finish": [
        "Terminé"
      ],
      "Finished": [
        "Terminé"
      ],
      "Flatpak Remotes": [
        ""
      ],
      "Flatpak remote numeric identifier": [
        ""
      ],
      "Flatpak remote repository numeric identifier": [
        ""
      ],
      "Force": [
        "Force"
      ],
      "Force a sync and validate the checksums of all content. Non-yum repositories (or those with \\\\\\n                                                     On Demand download policy) are skipped.": [
        "Forcer une sync et valider les sommes de contrôle de tous les contenus. Les référentiels non-yum (ou ceux avec \\\\\\n                                                     Politique de téléchargement à la demande) seront ignorés."
      ],
      "Force a sync and validate the checksums of all content. Only used with yum repositories.": [
        "Forcer une synchronisation et valider les sommes de contrôle de tous les contenus. Utilisé uniquement avec les référentiels yum."
      ],
      "Force content view promotion and bypass lifecycle environment restriction": [
        ""
      ],
      "Force delete the repository by removing it from all content view versions": [
        "Suppression forcée du référentiel en le supprimant de toutes les versions d’affichage de contenu"
      ],
      "Force metadata regeneration to proceed. Dangerous operation when version has repositories with the 'Complete Mirroring' mirroring policy": [
        ""
      ],
      "Force metadata regeneration to proceed. Dangerous when repositories use the 'Complete Mirroring' mirroring policy": [
        ""
      ],
      "Force promotion": [
        "Forcer promotion"
      ],
      "Force regenerate applicability.": [
        "Regénération forcée de l'applicabilité."
      ],
      "Force sync even if no upstream changes are detected. Non-yum repositories are skipped.": [
        "Sync forcée même si aucun changement en amont n'est détecté. Les référentiels non-yum seront ignorés."
      ],
      "Force sync even if no upstream changes are detected. Only used with yum or deb repositories.": [
        ""
      ],
      "Forces a republish of the specified repository, regenerating metadata and symlinks on the filesystem. Not allowed for repositories with the 'Complete Mirroring' mirroring policy.": [
        ""
      ],
      "Forces a republish of the version's repositories' metadata": [
        "Oblige à republier les métadonnées des référentiels de la version"
      ],
      "Full description": [
        "Description complète"
      ],
      "Full support": [
        ""
      ],
      "GPG Key URL": [
        "ID de la clé GPG"
      ],
      "Generate RHUI certificates for the desired repositories as necessary.": [
        "Générez les certificats RHUI pour les référentiels souhaités, si nécessaire."
      ],
      "Generate and Download": [
        "Générer et télécharger"
      ],
      "Generate errata status from directly-installable content": [
        ""
      ],
      "Generate host applicability": [
        "Générer l'applicabilité à l'hôte"
      ],
      "Generate repository applicability": [
        "Générer l'applicabilité du référentiel"
      ],
      "Generated": [
        "Généré"
      ],
      "Generated content views cannot be assigned to hosts or activation keys": [
        ""
      ],
      "Generated content views cannot be directly published. They can updated only via export.": [
        "Les vues de contenu générées ne peuvent pas être publiées directement. Elles ne peuvent être mises à jour uniquement via l'exportation."
      ],
      "Get all content available, not just that provided by subscriptions": [
        "Obtenir tout le contenu disponible, pas seulement celui fourni par les abonnements"
      ],
      "Get all content available, not just that provided by subscriptions.": [
        "Obtenir tout le contenu disponible, pas seulement celui fourni par les abonnements"
      ],
      "Get content and overrides for the host": [
        "Obtenir du contenu et des dérogations pour l'hôte"
      ],
      "Get current smart proxy synchronization status": [
        "Obtenir le statut de synchronisation du proxy"
      ],
      "Get info about a repository set": [
        "Obtenir des informations à propos d’un ensemble de référentiels"
      ],
      "Get list of available repositories for the repository set": [
        "Obtenir une liste de référentiels disponibles pour un ensemble de référentiels"
      ],
      "Get status of synchronisation for given repository": [
        "Obtenir le statut de synchronisation pour un référentiel donné"
      ],
      "Given a set of hosts and errata, lists the content view versions and environments that need updating.": [
        "Pour un ensemble d'hôtes et d'errata, liste les environnements et les versions d'affichage de contenu qui ont besoin d'être mis à jour."
      ],
      "Given criteria doesn't match any DEBs. Try changing your rule.": [
        "Le critère donné ne correspond à aucun DEB. Essayez de changer la règle."
      ],
      "Given criteria doesn't match any activation keys. Try changing your rule.": [
        "Le critère donné ne correspond à aucun RPM. Essayez de changer la règle."
      ],
      "Given criteria doesn't match any hosts. Try changing your rule.": [
        "Le critère donnée ne correspond à aucun hôte. Essayez de changer la règle."
      ],
      "Given criteria doesn't match any non-modular RPMs. Try changing your rule.": [
        ""
      ],
      "Go to job details": [
        "Détails du job"
      ],
      "Go to task page": [
        "Aller à la page des tâches"
      ],
      "Greater than": [
        "Plus grand que"
      ],
      "Guests of": [
        "Les invités de"
      ],
      "HTTP Proxies": [
        "Proxies HTTP"
      ],
      "HTTP Proxy identifier to associated": [
        "Proxy HTTP Identificateur du proxy associé"
      ],
      "HW properties": [
        "Propriétés HW"
      ],
      "Has to be > 0": [
        "Doit être > 0"
      ],
      "Hash containing the Id of the single lifecycle environment to be associated with the activation key.": [
        ""
      ],
      "Help": [
        ""
      ],
      "Helper": [
        "Aide"
      ],
      "Hide Reclaim Space Warning": [
        ""
      ],
      "Hide affected activation keys": [
        "Cacher les clés d'activation affectées"
      ],
      "Hide affected hosts": [
        "Cacher les hôtes affectés"
      ],
      "Hide description": [
        "Cacher la description"
      ],
      "History": [
        "Historique "
      ],
      "History will appear here when the content view is published or promoted.": [
        "L'historique apparaîtra ici lorsque l’affichage du contenu sera publiée ou promue."
      ],
      "Host": [
        "Hôte"
      ],
      "Host %s has not been registered with subscription-manager.": [
        "L’hôte %sn'est pas enregistré dans le subscription-manager."
      ],
      "Host %{hostname}: Cannot add content view environment to content facet. The host's content source '%{content_source}' does not sync lifecycle environment '%{lce}'.": [
        ""
      ],
      "Host %{name} cannot be assigned release version %{release_version}.": [
        "L'hôte %{nom} ne peut pas se voir attribuer la version %{release_version}."
      ],
      "Host '%{name}' does not belong to an organization": [
        "L'hôte '%{name}' n'appartient pas à une organisation"
      ],
      "Host Can Re-Register Only In Build": [
        "L'hôte peut se réenregistrer uniquement dans le Build"
      ],
      "Host Collection name": [
        "Nom de la collection d'hôtes"
      ],
      "Host Collections": [
        "Collections d'hôtes"
      ],
      "Host Duplicate DMI UUIDs": [
        "Duplicata des UUID des DMI de l'hôte"
      ],
      "Host Errata Advisory": [
        "Avis d'errata de l'hôte"
      ],
      "Host ID": [
        "ID Hôte"
      ],
      "Host Limit": [
        ""
      ],
      "Host Profile Assume": [
        "Profil d'hôte Assume"
      ],
      "Host Profile Can Change In Build": [
        "Le profil de l'hôte peut changer en mode ’build’"
      ],
      "Host Tasks Workers Pool Size": [
        "Taille du pool de workers Tâches Hôte"
      ],
      "Host collection": [
        "Collection d'hôtes"
      ],
      "Host collection '%{name}' exceeds maximum usage limit of '%{limit}'": [
        "La collection d'hôtes '%{name}' dépasse la limite d'utilisation de '%{limit} '"
      ],
      "Host collection is empty.": [
        "La collection d'hôtes est vide."
      ],
      "Host collections": [
        "Collections d'hôtes"
      ],
      "Host collections updated": [
        "Mise à jour des collections d'hôtes"
      ],
      "Host content and subscription details": [
        "Contenu de l'hôte et détails de l'abonnement"
      ],
      "Host content source will remain the same. Click Save below to update the host's content view environment.": [
        ""
      ],
      "Host content view and environment updated": [
        "Mise à jour de la vue du contenu de l'hôte et de l'environnement"
      ],
      "Host content view environment(s) updated": [
        ""
      ],
      "Host content view environments updating.": [
        ""
      ],
      "Host creation was skipped for %s because it shares a BIOS UUID with %s. To report this hypervisor, override its dmi.system.uuid fact or set 'candlepin.use_system_uuid_for_matching' to 'true' in the Candlepin configuration.": [
        "La création d'un hôte a été ignorée pour %scar il partage un BIOS UUID avec %s. Pour signaler cet hyperviseur, surchargez son dmi.system.uuid fact ou mettez \\\"candlepin.use_system_uuid_for_matching\\\" à \\\"true\\\" dans la configuration de Candlepin."
      ],
      "Host errata advisory": [
        "Avis d'errata de l'hôte"
      ],
      "Host group IDs": [
        "IDs des groupes"
      ],
      "Host has not been registered with subscription-manager": [
        "Cet hôte n'est pas enregistré dans le subscription-manager."
      ],
      "Host has not been registered with subscription-manager.": [
        "Cet hôte n'est pas enregistré dans subscription-manager."
      ],
      "Host id to list applicable deb packages for": [
        "Identifiant de l'hôte pour lister les packages applicables"
      ],
      "Host id to list applicable errata for": [
        "Identifiant de l'hôte pour énumérer les errata applicables pour"
      ],
      "Host id to list applicable packages for": [
        "Identifiant de l'hôte pour énumérer les packages applicables pour"
      ],
      "Host identifier": [
        ""
      ],
      "Host lifecycle support expiration notification": [
        ""
      ],
      "Host was not found by the subscription UUID: '%s', this can happen if the host is registered already, but not to this instance": [
        "L'hôte n'a pas été trouvé par l'UUID de l'abonnement : '%s', cela peut arriver si l'hôte est déjà enregistré, mais pas pour cette instance"
      ],
      "Host with ID %s already exists in the host collection.": [
        "L’hôte ayant pour ID %s existe déjà dans la collection d'hôtes."
      ],
      "Host with ID %s does not exist in the host collection.": [
        "L’hôte ayant pour ID %s n'existe pas dans la collection d'hôtes."
      ],
      "Host with ID %s not found.": [
        "Stratégie avec l'ID %s introuvable."
      ],
      "Hosts": [
        "Hôtes"
      ],
      "Hosts to update": [
        "Hôtes à mettre à jour"
      ],
      "Hosts with Installable Errata": [
        "Hôtes avec errata installables"
      ],
      "Hosts: ": [
        "Hôtes : "
      ],
      "How many days before a completed Pulp task is purged by Orphan Cleanup.": [
        ""
      ],
      "How many repositories should be synced concurrently on the capsule. A smaller number may lead to longer sync times. A larger number will increase dynflow load.": [
        "Combien de référentiels doivent être synchronisés simultanément sur la capsule.  Un nombre inférieur peut entraîner des temps de synchronisation plus longs.  Un nombre plus élevé augmentera la charge de dynflow."
      ],
      "How to order the sorted results (e.g. ASC for ascending)": [
        "Comment classer les résultats triés (ex :  ASC for pour croissant)"
      ],
      "ID of a HTTP Proxy": [
        "ID d'un proxy HTTP"
      ],
      "ID of a content view to show repositories in": [
        "ID d'un affichage de contenu dans lequel afficher les référentiels"
      ],
      "ID of a content view version to show repositories in": [
        "ID d'une version d'affichage de contenu sur laquelle afficher les référentiels"
      ],
      "ID of a product to list repository sets from": [
        "ID d'un produit à partir duquel répertorier les ensembles de référentiels"
      ],
      "ID of a product to show repositories of": [
        "ID d'un produit pour lequel afficher les référentiels"
      ],
      "ID of an environment to show repositories in": [
        "ID d'un environnement dans lequel afficher les référentiels"
      ],
      "ID of an organization to show repositories in": [
        "ID d'une organisation dans laquelle afficher les référentiels"
      ],
      "ID of flatpak remote to show repositories of": [
        ""
      ],
      "ID of the Organization": [
        "ID de l'organisation"
      ],
      "ID of the activation key": [
        "ID de la clé d'activation"
      ],
      "ID of the environment": [
        "ID de l'environnement"
      ],
      "ID of the host": [
        "ID de l'hôte"
      ],
      "ID of the host collection": [
        "ID de la collection d'hôtes"
      ],
      "ID of the organization": [
        "ID de l'organisation"
      ],
      "ID of the product containing the repository set": [
        "ID du produit contenant l'ensemble de référentiels"
      ],
      "ID of the repository set": [
        "ID de l'ensemble de référentiels"
      ],
      "ID of the repository set to disable": [
        "ID de l'ensemble de référentiels à désactiver"
      ],
      "ID of the repository set to enable": [
        "ID de l'ensemble de référentiels à activer"
      ],
      "ID of the repository within the set to disable": [
        "ID du référentiel dans l'ensemble à désactiver"
      ],
      "ID of the sync plan": [
        "ID du plan de sync"
      ],
      "IDs of products to copy repository information from into a Simplified Alternate Content Source. Products must include at least one repository of the chosen content type.": [
        "ID des produits dont il faut copier les informations de référentiel dans une source de contenu alternative simplifiée. Les produits doivent comprendre au moins un référentiel du type de contenu choisi."
      ],
      "Id of a deb package to find repositories that contain the deb": [
        "Id d'un package deb pour trouver les référentiels qui contiennent le deb"
      ],
      "Id of a file to find repositories that contain the file": [
        "Id d'un package pour trouver les référentiels qui contiennent le fichier"
      ],
      "Id of a rpm package to find repositories that contain the rpm": [
        "Id d'un package rpm pour trouver les référentiels qui contiennent le rpm"
      ],
      "Id of an ansible collection to find repositories that contain the ansible collection": [
        "Id d'une collection ansible pour trouver les référentiels qui contiennent la collection ansible"
      ],
      "Id of an erratum to find repositories that contain the erratum": [
        "id d'une erratum pour trouver les référentiels qui contiennent l'erratum"
      ],
      "Id of the HTTP proxy to use with alternate content sources": [
        "Id du proxy HTTP à utiliser avec les sources de contenu alternatives."
      ],
      "Id of the content host": [
        "ID de l'hôte du contenu"
      ],
      "Id of the content view to limit the content counting on": [
        ""
      ],
      "Id of the content view to limit the synchronization on": [
        "Id du contenu sur lequel limiter la synchronisation"
      ],
      "Id of the content view to limit verifying checksum on": [
        ""
      ],
      "Id of the environment to limit the content counting on": [
        ""
      ],
      "Id of the environment to limit the synchronization on": [
        "Id de l'environnement sur lequel limiter la synchronisation"
      ],
      "Id of the environment to limit verifying checksum on": [
        ""
      ],
      "Id of the host": [
        "Id de l'hôte"
      ],
      "Id of the host collection": [
        "ID de la collection d'hôtes"
      ],
      "Id of the lifecycle environment": [
        "Id de l'environnement du cycle de vie"
      ],
      "Id of the organization to get the status for": [
        "Id de l'organisation pour laquelle on veut obtenir le statut"
      ],
      "Id of the organization to limit environments on": [
        "Id de l'organisation sur lequel limiter les environnements"
      ],
      "Id of the repository to limit the content counting on": [
        ""
      ],
      "Id of the repository to limit the synchronization on": [
        "Id du référentiel sur lequel limiter la synchronisation"
      ],
      "Id of the repository to limit verifying checksum on": [
        ""
      ],
      "Id of the single content view to be associated with the activation key.": [
        ""
      ],
      "Id of the single content view to be associated with the host.": [
        ""
      ],
      "Id of the single lifecycle environment to be associated with the activation key.": [
        ""
      ],
      "Id of the single lifecycle environment to be associated with the host.": [
        ""
      ],
      "Id of the smart proxy": [
        "Id du proxy smart"
      ],
      "Id of the smart proxy from which the host consumes content.": [
        ""
      ],
      "Idenifier of the SSL CA Cert": [
        "Idenifier le Cert CA SSL"
      ],
      "Identifier of the GPG key": [
        "Identifiant de la clé GPG"
      ],
      "Identifier of the SSL Client Cert": [
        "Identifiant du Cert Client SSL"
      ],
      "Identifier of the SSL Client Key": [
        "Identifiant de la Clé Client SSL"
      ],
      "Identifier of the content credential containing the SSL CA Cert": [
        "Identifiant des attestations de contenu contenant le certificat Contenant SSL"
      ],
      "Identifier of the content credential containing the SSL Client Cert": [
        "Identifiant des attestations de contenu contenant le certificat Client SSl"
      ],
      "Identifier of the content credential containing the SSL Client Key": [
        "Identifiant des attestations de contenu contenant la clé Client SSL"
      ],
      "Identifiers for Lifecycle Environment": [
        "Identifiants de l’Environnement de cycle de vie"
      ],
      "Identifies whether the repository should be unavailable on a client with a non-matching OS version.\\nPass [] to make repo available for clients regardless of OS version. Maximum length 1; allowed tags are: %s": [
        ""
      ],
      "Ids of smart proxies to associate": [
        "Ids des proxies smart à associer"
      ],
      "If SSL should be verified for the upstream URL": [
        "Si SSL doit être vérifié pour l'URL amont"
      ],
      "If hosts fail to register because of duplicate DMI UUIDs, add their comma-separated values here. Subsequent registrations will generate a unique DMI UUID for the affected hosts.": [
        "Si les hôtes ne parviennent pas à s'enregistrer en raison de doublons d'UUID DMI, ajoutez ici leurs valeurs séparées par des virgules. Les enregistrements ultérieurs généreront un DMI UUID unique pour les hôtes concernés."
      ],
      "If product certificates should be used to authenticate to a custom CDN.": [
        ""
      ],
      "If set, newly created APT repos in Katello will use the same repo structure as the remote repos they are synchronized from. You may migrate existing APT repos to match the setting, by running 'foreman-rake katello:migrate_structure_content_for_deb'.": [
        ""
      ],
      "If specified, remove the first instance of a subscription with matching id and quantity": [
        "Si spécifié, supprimer la première instance d'un abonnement avec la quantité et l'id correspondants"
      ],
      "If the smart proxies' assigned HTTP proxies should be used": [
        "Si les proxys HTTP attribués aux proxys smart doivent être utilisés"
      ],
      "If this is enabled, a composite content view may not be published or promoted unless the component content view versions that it includes exist in the target environment.": [
        "Si activé, un affichage de contenu composite peut être publié ou promus, à moins que les versions d'affichage de contenu de composant qu'il inclut existent dans l’environnement cible."
      ],
      "If this is enabled, and register_hostname_fact is set and provided, registration will look for a new host by name only using that fact, and will skip all hostname matching": [
        "Si c’est le cas, et register_hostname_fact est défini et fourni, l'enregistrement cherchera un nouvel hôte par son nom uniquement en utilisant ce fact, et ignorera tous les noms d'hôte correspondants"
      ],
      "If this is enabled, content counts on smart proxies will be updated automatically after content sync.": [
        ""
      ],
      "If this is enabled, repositories can be deleted even when they belong to published content views. The deleted repository will be removed from all content view versions.": [
        "Si cette option est activée, les référentiels peuvent être supprimés même s'ils appartiennent à des vues de contenu publiées. Le référentiel supprimé sera retiré de toutes les versions de la vue de contenu."
      ],
      "If this is enabled, repositories of content view versions without environments (\\\"archived\\\") will be distributed at '/pulp/content/<organization>/content_views/<content view>/X.Y/...'.": [
        "Si cette option est activée, les dépôts de versions de vues de contenu sans environnement (\\\"archivées\\\") seront distribués dans '/pulp/content/<organization>/content_views/<content view>/X.Y/...'."
      ],
      "If this is enabled, the Smart Proxy page will suppress the warning message about reclaiming space.": [
        ""
      ],
      "If true, only errata that can be installed without an incremental update will affect the host's errata status. Also affects the Host Collections dashboard widget.": [
        ""
      ],
      "If true, only return repository sets that are associated with an active subscriptions": [
        "Si c’est le cas, ne renvoyez que les ensembles de référentiels associés à un abonnement actif"
      ],
      "If true, only return repository sets that have been enabled. Defaults to false": [
        "Si c’est le cas, ne renvoyez que les ensembles de référentiels qui ont été activés. La valeur par défaut est false"
      ],
      "If true, return custom repository sets along with redhat repos. Will be ignored if repository_type is supplied.": [
        ""
      ],
      "If true, when adding the specified errata or packages, any needed dependencies will be copied as well. Defaults to true": [
        "Si c’est le cas, toute dépendance nécessaire sera copiée lors de l'ajout des errata ou package spécifiés. Valeur par défaut true."
      ],
      "If true, will publish a new composite version using any specified content_view_version_id that has been promoted to a lifecycle environment": [
        "Si c’est le cas, une nouvelle version composite sera publiée à l'aide d'un content_view_version_id spécifié ayant été promu à un environnement de cycle de vie."
      ],
      "If you would prefer to move some of these hosts to different content views or environments then {clickHere} to manage these hosts individually.": [
        "Si vous préférez déplacer certains de ces hôtes vers des vues de contenu ou des environnements différents, alors {clickHere} pour gérer ces hôtes individuellement."
      ],
      "Ignorable content can be only set for Yum repositories.": [
        "Le contenu ignorable ne peut être défini que pour les référentiels Yum."
      ],
      "Ignore %s cannot be set in combination with the 'Complete Mirroring' mirroring policy.": [
        ""
      ],
      "Ignore errors": [
        "Ignorer les erreurs"
      ],
      "Ignore subscription manager errors": [
        "Ignorer les erreurs du gestionnaire d'abonnement"
      ],
      "Ignore subscription-manager errors for `subscription-manager register` command": [
        "Ignorer les erreurs du gestionnaire d'abonnements pour la commande `subscription-manager register`"
      ],
      "Ignore subscriptions that are unavailable to the specified host": [
        "Ignorer les abonnements qui ne sont pas disponibles pour un hôte spécifique"
      ],
      "Ignored hosts": [
        "Hôtes ignorés"
      ],
      "Image": [
        ""
      ],
      "Image digest": [
        ""
      ],
      "Image digests": [
        ""
      ],
      "Image mode": [
        ""
      ],
      "Image mode / package mode": [
        ""
      ],
      "Image mode details": [
        ""
      ],
      "Image name": [
        ""
      ],
      "Image-mode host": [
        ""
      ],
      "Immediate": [
        "Immédiat"
      ],
      "Import": [
        "Importation"
      ],
      "Import Content View Version": [
        "Supprimer la version de l'affichage du contenu"
      ],
      "Import Default Content View": [
        "Importer la vue du contenu par défaut"
      ],
      "Import Manifest": [
        "Importer le manifeste"
      ],
      "Import Repository": [
        "Importation du référentiel"
      ],
      "Import Types": [
        "Types d'importation"
      ],
      "Import a Manifest": [
        "Importer un manifeste"
      ],
      "Import a Manifest to Begin": [
        "Importer un manifeste pour commencer"
      ],
      "Import a content view version": [
        "Exporter une version d’affichage de contenu"
      ],
      "Import a content view version to the library": [
        "Importer une version d’affichage de contenu dans la bibliothèque"
      ],
      "Import a manifest using the Manifest tab above.": [
        ""
      ],
      "Import a repository": [
        "Importe un référentiel"
      ],
      "Import a subscription manifest to give hosts access to Red Hat content.": [
        ""
      ],
      "Import new manifest": [
        ""
      ],
      "Import only": [
        "Importation uniquement"
      ],
      "Import only Content Views cannot be directly publsihed. Content can only be updated by importing into the view.": [
        "Les affichages de contenu importés ne peuvent pas être publiés directement. Le contenu ne peut être mis à jour qu'en l'important dans la vue."
      ],
      "Import uploads into a repository": [
        "Importer les téléchargements dans un référentiel"
      ],
      "Import-only can not be changed after creation": [
        "Import-only ne peut pas être modifié après la création"
      ],
      "Import-only content views can not be published directly": [
        "Les vues de contenu à importer ne peuvent pas être publiées directement"
      ],
      "Import/Export": [
        "Import/Export"
      ],
      "Important": [
        "Important"
      ],
      "Importing manifest into '%{subject}' failed.": [
        "L'importation du manifeste dans '%{subject}' a échoué."
      ],
      "In Progress": [
        "En cours"
      ],
      "In progress": [
        "En cours"
      ],
      "Include": [
        "Inclure"
      ],
      "Include Refs": [
        ""
      ],
      "Include all RPMs not associated to any errata": [
        "Inclure tous les RPMs qui ne sont associés à aucun errata"
      ],
      "Include all module streams not associated to any errata": [
        "Inclure tous les flux de modules non associés à un errata."
      ],
      "Include content views generated by imports/exports. Defaults to false": [
        "Inclure les vues de contenu générées par les importations/exportations. Valeur par défaut : false"
      ],
      "Include filter": [
        "Inclure filtre"
      ],
      "Include manifests": [
        ""
      ],
      "Included": [
        "Inclus"
      ],
      "Included errata": [
        "Inclure errata"
      ],
      "Includes": [
        "Inclut"
      ],
      "Includes associated content view filter ids in response": [
        "Inclut les ids de filtre de visualisation de contenu associés dans la réponse"
      ],
      "Inclusion type": [
        "Type d’inclusion"
      ],
      "Incremental Update": [
        "Mise à jour croissante"
      ],
      "Incremental Update incomplete.": [
        "Mise à jour incrémentielle incomplète."
      ],
      "Incremental Update of %{content_view_count} Content View Version(s) ": [
        "Mise à jour incrémentielle de %{content_view_count}Version(s) d'affichage de contenu "
      ],
      "Incremental update": [
        "Mise à jour croissante"
      ],
      "Incremental update requires at least one content unit": [
        "La mise à jour progressive nécessite au moins une unité de contenu"
      ],
      "Incremental update specified for composite %{name} version %{version}, but no components updated.": [
        "Mise à jour croissante spécifiée pour le composite %{name} version %{version}, mais aucun composant mis à jour."
      ],
      "Informable Type must be one of the following [ %{list} ]": [
        "Le type Informable doit être l'un parmi [%{list} ]"
      ],
      "Inherit from Repository": [
        "Hérité du référentiel"
      ],
      "Initiate a sync of the products attached to the sync plan": [
        "Initier une synchronisation des produits attachés au plan de synchronisation"
      ],
      "Install": [
        "Installez"
      ],
      "Install errata using scoped search query": [
        "Installer les errata en utilisant une requête de recherche étendue"
      ],
      "Install errata via Katello interface": [
        "Installer les errata via l'interface Katello"
      ],
      "Install package group via Katello interface": [
        "Installer le groupe de packages via l'interface Katello"
      ],
      "Install package via Katello interface": [
        "Installer le package via l'interface Katello"
      ],
      "Install packages": [
        "Installer les packages"
      ],
      "Install packages via Katello interface": [
        "Installer le package via l'interface Katello"
      ],
      "Install via customized remote execution": [
        "Redémarrer via exécution à distance personnalisée"
      ],
      "Install via remote execution": [
        "Installation par exécution à distance"
      ],
      "Installable": [
        "Installable"
      ],
      "Installable bugfix/enhancement errata": [
        ""
      ],
      "Installable errata are applicable errata that are available in the host's content view and lifecycle environment.": [
        ""
      ],
      "Installable security errata": [
        ""
      ],
      "Installable updates": [
        "Mises à jour installables"
      ],
      "Installation status": [
        "État de l'installation"
      ],
      "Installed": [
        "Installé"
      ],
      "Installed Packages": [
        "Packages installés"
      ],
      "Installed module profiles will be removed. Additionally, all packages whose names are provided by specific modules will be removed. Packages required by other installed modules profiles and packages whose names are also provided by other modules are not removed.": [
        "Les profils des modules installés seront supprimés. De plus, tous les paquets dont les noms sont fournis par des modules spécifiques seront supprimés. Les paquets requis par les profils des autres modules installés et les paquets dont les noms sont également fournis par d'autres modules ne sont pas supprimés."
      ],
      "Installed products": [
        "Produits installés"
      ],
      "Installed profile": [
        "Profil installé"
      ],
      "Installed version": [
        "Version installée"
      ],
      "Installing Erratum...": [
        "Installation de l'erratum..."
      ],
      "Installing Package Group...": [
        "Installation du groupe de packages..."
      ],
      "Installing Package...": [
        "Installation du package..."
      ],
      "Instance-based": [
        "Basé sur l'instancea"
      ],
      "Interpret specified object to return only Host Collections that can be associated with specified object. The value 'host' is supported.": [
        "Interprète l'objet spécifié à retourner uniquement les Collections d'hôtes qui peuvent être associées à l'objet spécifié. La valeur 'hôte' est prise en charge."
      ],
      "Interpret specified object to return only Products that can be associated with specified object.  Only 'sync_plan' is supported.": [
        "Interprète l'objet spécifié à retourner uniquement les Collections d'hôtes qui peuvent être associées à l'objet spécifié. La valeur 'sync_plan' est prise en charge."
      ],
      "Interval cannot be nil": [
        "L'intervalle ne peut être nul"
      ],
      "Interval not set correctly": [
        "Intervalle mal défini"
      ],
      "Invalid association of the content view id. Content View must match the content view version being saved": [
        "Association non valable de l'identifiant de la vue du contenu. La vue du contenu doit correspondre à la version de la vue du contenu enregistrée"
      ],
      "Invalid content label: %s": [
        "Étiquette de contenu non valide : %s"
      ],
      "Invalid content type '%{content_type}' provided. Content types can be one of %{content_types}": [
        "Type de contenu invalide '%{content_type}' fourni. Les types de contenu doivent être l'un de %{content_types} "
      ],
      "Invalid date range. The erratum filter rule start date must come before the end date": [
        "Plage de dates invalide. La date du début de la règle du filtre de l'erratum doit se trouver avant la date de fin."
      ],
      "Invalid erratum filter rule specified, 'errata_id' cannot be specified in the same tuple as 'start_date', 'end_date' or 'types'": [
        "Règle de filtre de l'erratum non valide spécifiée, 'errata_id' ne peut être spécifié dans le même tuple que 'start_date', 'end_date' ou 'types'"
      ],
      "Invalid erratum filter rule specified, Must specify at least one of the following: 'errata_id', 'start_date', 'end_date', 'types', or 'allow_other_types'": [
        ""
      ],
      "Invalid erratum types %{invalid_types} provided. Erratum type can be any of %{valid_types}": [
        "Type d'erratum non valide {invalid_types} fourni. Le type d'erratum doit être l'un des %{valid_types}"
      ],
      "Invalid event_type %s": [
        "Type_événement_invalide %s"
      ],
      "Invalid export format provided. Format must be one of  %s ": [
        "Le format d'exportation fourni est invalide. Le format doit être l'un des suivants  %s "
      ],
      "Invalid filter rule specified, 'version' cannot be specified in the same tuple as 'min_version' or 'max_version'": [
        "Règle de filtre non valide spécifiée, 'version' ne peut être spécifiée dans le même tuple que 'min_version' ou 'max_version'"
      ],
      "Invalid format. Container name cannot be blank.": [
        ""
      ],
      "Invalid format. Container pushes should follow 'organization_label/product_label/name' OR 'id/organization_id/product_id/name' schema.": [
        ""
      ],
      "Invalid format. Organization id must be an integer without leading zeros.": [
        ""
      ],
      "Invalid format. Organization label cannot be blank.": [
        ""
      ],
      "Invalid format. Product id must be an integer without leading zeros.": [
        ""
      ],
      "Invalid format. Product label cannot be blank.": [
        ""
      ],
      "Invalid mirroring policy for repository type %{type}, only %{policies} are valid.": [
        "Politique de mise en miroir non valide pour le type de référentiel %%{type}, seul %%{policies} est valide."
      ],
      "Invalid parameters sent in the request for this operation. Please contact a system administrator.": [
        "Paramètres invalides envoyés dans la requête pour cette opération. Veuillez contacter un administrateur système."
      ],
      "Invalid parameters sent. You may have mistyped the address. If you continue having trouble with this, please contact an Administrator.": [
        "Paramètres envoyés incorrects. Vous avez peut-être mal saisi l'adresse. Si ce problème persiste, veuillez contacter un administrateur."
      ],
      "Invalid params provided - content_type must be one of %s": [
        "Params non valides fournis - content_type doit être un parmi %s"
      ],
      "Invalid params provided - date_type must be one of %s": [
        "Params non valides fournis - date_type doit être un parmi %s"
      ],
      "Invalid params provided - with_content must be one of %s": [
        "Params non valides fournis - with_content doit être un parmi %s"
      ],
      "Invalid path provided. Content can be only imported from file system. ": [
        "Le chemin fourni est invalide. Le contenu ne peut être importé que depuis un système de fichiers. "
      ],
      "Invalid release version: [%s]": [
        "Version du contenu non valide : [%s]"
      ],
      "Invalid repository in the metadata %{repo} error=%{error}": [
        "Référentiel non valide dans les métadonnées %%{repo} error=%{error}"
      ],
      "Invalid value specified for Container Image repositories.": [
        "Valeur non valable spécifiée pour les référentiels d'images de conteneurs."
      ],
      "Invalid value specified for ignorable content.": [
        "Valeur invalide spécifiée pour un contenu ignorable."
      ],
      "Invalid value specified for ignorable content. Permissible values %s": [
        "Valeur invalide spécifiée pour un contenu ignorable. Valeurs autorisées %s"
      ],
      "Issued": [
        "Publié"
      ],
      "Issued from": [
        "Délivré par"
      ],
      "It is only allowed for Non-Redhat Yum repositories.": [
        ""
      ],
      "Job '${description}' completed": [
        "Job '${description}' terminé"
      ],
      "Job '${description}' has started.": [
        "Le job ${description} a commencé."
      ],
      "Katello Bootc interface": [
        ""
      ],
      "Katello ID of local pool to update": [
        "Katello ID du pool local à mettre à jour"
      ],
      "Katello: Bootc Action": [
        ""
      ],
      "Katello: Bootc Rollback": [
        ""
      ],
      "Katello: Bootc Status": [
        ""
      ],
      "Katello: Bootc Switch": [
        ""
      ],
      "Katello: Bootc Upgrade": [
        ""
      ],
      "Katello: Configure host for new content source": [
        ""
      ],
      "Katello: Install Errata": [
        "Katello : Installer l'errata"
      ],
      "Katello: Install Package": [
        "Katello : Installer le package"
      ],
      "Katello: Install Package Group": [
        "Katello : Installation du groupe de packages"
      ],
      "Katello: Install errata by search query": [
        "Katello : Installer les errata par requête de recherche"
      ],
      "Katello: Install packages by search query": [
        "Katello : Installation de paquets par requête de recherche"
      ],
      "Katello: Module Stream Actions": [
        "Katello : Module Stream Actions"
      ],
      "Katello: Remove Package": [
        "Katello : Supprimer le package"
      ],
      "Katello: Remove Package Group": [
        "Katello : Supprimer le groupe de packages"
      ],
      "Katello: Remove Packages by search query": [
        "Katello : Supprimer les paquets par requête de recherche"
      ],
      "Katello: Resolve Traces": [
        "Katella : Résoudre les traces"
      ],
      "Katello: Service Restart": [
        "Katello : Redémarrage des services"
      ],
      "Katello: Update Package": [
        "Katello : Mettre à jour le package"
      ],
      "Katello: Update Package Group": [
        "Katello : Mise à jour du Groupe de packages"
      ],
      "Katello: Update Packages by search query": [
        "Katello : Mise à jour des paquets par requête de recherche"
      ],
      "Katello: Upload Profile": [
        ""
      ],
      "Keep latest packages": [
        ""
      ],
      "Key-value hash of subscription-manager facts, nesting uses a period delimiter (.)": [
        "Hachage de valeurs clés des facts du subscription-manager, l'imbrication utilise un délimiteur (.)"
      ],
      "Kickstart": [
        "Kickstart"
      ],
      "Kickstart repositories can only be assigned to hosts in the Red Hat family": [
        "Les référentiels Kickstart ne peuvent être attribués qu'aux hôtes de la famille Red Hat"
      ],
      "Kickstart repository ID": [
        "ID du référentiel Kickstart"
      ],
      "Kickstart repository was not set for host '%{host}'": [
        "Le référentiel Kickstart n'a pas été défini pour l'hôte '%{host}'"
      ],
      "Label": [
        "Balise"
      ],
      "Label of the content": [
        "Balise du contenu"
      ],
      "Label of the content view": [
        "Balise du contenu"
      ],
      "Label of the flatpak remote": [
        ""
      ],
      "Last check-in:": [
        "Dernière vérification :"
      ],
      "Last checkin": [
        "Dernière vérification"
      ],
      "Last published": [
        "Dernière publication"
      ],
      "Last refresh": [
        "Dernier rafraîchissement"
      ],
      "Last refresh :": [
        "Dernier rafraîchissement :"
      ],
      "Last seen": [
        ""
      ],
      "Last sync": [
        ""
      ],
      "Last task": [
        "Dernière tâche"
      ],
      "Latest (automatically updates)": [
        "Dernière (mise à jour automatique)"
      ],
      "Latest Errata": [
        "Dernier errata"
      ],
      "Latest version": [
        "Dernière version"
      ],
      "Learn more about adding subscription manifests in ": [
        ""
      ],
      "Legacy UI": [
        ""
      ],
      "Legacy content host UI": [
        "Interface utilisateur de l'hôte de contenu hérité"
      ],
      "Less than": [
        "Moins de"
      ],
      "Library": [
        "Bibliothèque"
      ],
      "Library lifecycle environments may not be deleted.": [
        "Les environnements de cycle de vie de la bibliothèque ne peuvent pas être supprimés."
      ],
      "Library repository id to restrict comparisons to": [
        "ID de référentiel de bibliothèque pour restreindre les comparaisons à"
      ],
      "Lifecycle": [
        "Cycle de vie"
      ],
      "Lifecycle Environment": [
        "Environnement de cycle de vie"
      ],
      "Lifecycle Environment %s has associated Activation Keys. Please change or remove the associated Activation Keys before trying to delete this lifecycle environment.": [
        "L'environnement de cycle de vie %s a associé les Clés d'Activation. Veuillez changer ou supprimer les clés d'activation avant de tenter de supprimer cet environnement de cycle de vie."
      ],
      "Lifecycle Environment %s has associated Hosts. Please unregister or move the associated Hosts before trying to delete this lifecycle environment.": [
        "L'environnement de cycle de vie %s a des hôtes associés. Veuillez changer ou supprimer les hôtes avant de tenter de supprimer cet environnement de cycle de vie."
      ],
      "Lifecycle Environment ID": [
        "ID Environnement de cycle de vie"
      ],
      "Lifecycle Environment Label": [
        "Balise d’environnement de cycle de vie"
      ],
      "Lifecycle Environments": [
        "Environnements de cycle de vie"
      ],
      "Lifecycle environment": [
        "Environnement de cycle de vie"
      ],
      "Lifecycle environment '%{environment}' is not attached to this capsule.": [
        "L'environnement de cycle de vie '%{environment}' n'est pas joint à cette capsule."
      ],
      "Lifecycle environment '%{env}' cannot be used with content view '%{view}'": [
        ""
      ],
      "Lifecycle environment ID": [
        "ID d’environnement de cycle de vie"
      ],
      "Lifecycle environment must be specified": [
        ""
      ],
      "Lifecycle environment was not attached to the smart proxy; therefore, no changes were made.": [
        "L'environnement de cycle de vie n'était pas attaché au proxy smart; de ce fait, aucun changement n'a été fait."
      ],
      "Lifecycle environment: {lce}": [
        "Environnement de cycle de vie : {lce}"
      ],
      "Lifecycle environments cannot be modifed on the default Smart proxy.  The content from all Lifecycle Environments will exist on this Smart proxy.": [
        "Les environnements du cycle de vie ne peuvent pas être modifiés sur le proxy smart par défaut.  Le contenu de tous les environnements de cycle de vie existera sur ce proxy smart."
      ],
      "Limit actions to content in the host's environment.": [
        ""
      ],
      "Limit content to Red Hat / custom": [
        ""
      ],
      "Limit content to enabled / disabled / overridden": [
        "Limiter le contenu à activé / désactivé / écrasé"
      ],
      "Limit content to just that available in the activation key's content view version": [
        "Limiter le contenu à celui qui est disponible dans la version de visualisation du contenu de la clé d'activation"
      ],
      "Limit content to just that available in the host's content view version": [
        "Limiter le contenu à celui qui est disponible dans la version de visualisation du contenu de l'hôte"
      ],
      "Limit content to just that available in the host's or activation key's content view version and lifecycle environment.": [
        "Limite le contenu à celui qui est disponible dans la version d'affichage du contenu de la clé d'activation ou dans l’hôte."
      ],
      "Limit the repository type. Available types endpoint: /katello/api/repositories/repository_types": [
        "Limite le type de référentiel. Point de terminaison des types disponibles : /katello/api/repositories/repository_types"
      ],
      "Limit to environment": [
        "Limiter à l'environnement"
      ],
      "Limits": [
        "Limites"
      ],
      "List %s": [
        "Liste %s"
      ],
      "List :resource": [
        "List :resource"
      ],
      "List :resource_id": [
        "List :resource_id"
      ],
      "List Content Credentials": [
        "Liste des identifiants de contenu"
      ],
      "List a host's subscriptions": [
        "Répertorier les abonnements d'un hôte"
      ],
      "List activation keys": [
        "Répertorier les clés d'activation"
      ],
      "List all :resource_id": [
        "Tout afficher : resource_id"
      ],
      "List all organizations": [
        "Répertorier toutes les organisations"
      ],
      "List all packages unique by name": [
        ""
      ],
      "List alternate content sources.": [
        "Lister les autres sources de contenu"
      ],
      "List an activation key's subscriptions": [
        "Répertorier les abonnements d'une clé d'activation"
      ],
      "List available releases in the organization": [
        "Liste des communiqués disponibles dans l'organisation"
      ],
      "List available subscriptions from Red Hat Subscription Management": [
        "Liste des abonnements disponibles auprès de Red Hat Subscription Management"
      ],
      "List booted bootc container images for hosts": [
        ""
      ],
      "List components attached to this content view": [
        "Liste des éléments attachés à cette vue de contenu"
      ],
      "List content counts for the smart proxy": [
        ""
      ],
      "List content view environments": [
        ""
      ],
      "List content view versions": [
        "Répertorier les versions d'affichage de contenu"
      ],
      "List content views": [
        "Répertorier les affichages de contenu"
      ],
      "List deb packages": [
        "Lister Packages Deb"
      ],
      "List deb packages installed on the host": [
        "Répertorier les packages deb installés sur l'hôte"
      ],
      "List environment paths": [
        "Répertorier les chemins d'environnement"
      ],
      "List environments in an organization": [
        "Répertorier les environnements dans une organisation"
      ],
      "List errata": [
        "Répertorier les erratas"
      ],
      "List errata available for the content host": [
        "Répertorier les erratas disponibles pour l'hôte de contenu"
      ],
      "List export histories": [
        "Liste des historiques d'exportation"
      ],
      "List filter rules": [
        "Répertorier les règles de filtre"
      ],
      "List flatpak remote repositories": [
        ""
      ],
      "List flatpak remote's repositories": [
        ""
      ],
      "List flatpak remotes": [
        ""
      ],
      "List host collections": [
        "Répertorier les collections d'hôtes"
      ],
      "List host collections in an activation key": [
        "Énumérer les collections d'hôtes dans une clé d'activation"
      ],
      "List host collections the activation key does not belong to": [
        "Répertorier les collections d'hôtes auxquels la clé d'activation n'appartient pas"
      ],
      "List host collections within an organization": [
        "Énumérer les collections d'hôtes dans une organisation"
      ],
      "List import histories": [
        "Liste des historiques d'importation"
      ],
      "List module streams available to the host": [
        "Liste des flux de modules disponibles pour l'hôte"
      ],
      "List of Errata ids": [
        "Énumérer les ID d'errata"
      ],
      "List of Products for sync plan": [
        "Liste de produits pour un plan de sync"
      ],
      "List of alternate content source IDs": [
        "Liste des ID de sources de contenu alternatif"
      ],
      "List of component content view version ids for composite views": [
        "Liste d'ids de version d'affichage de contenu de composant pour les affichages composites."
      ],
      "List of content units to ignore while syncing a yum repository. Must be subset of %s": [
        "Liste des unités de contenu à ignorer lors de la synchronisation d'un référentiel yum. Doit être un sous-ensemble de %s"
      ],
      "List of enabled repo urls for the repo (Only first is used.)": [
        "Liste d'url de référentiels activés pour le référentiel (seul le premier est utilisé)."
      ],
      "List of enabled repositories": [
        "Liste de référentiels activés"
      ],
      "List of errata ids to exclude and not run an action on, (ex: RHSA-2019:1168)": [
        "Liste d'id de systèmes à exclure et sur lesquels ne pas effectuer d'action, (ex: RHSA-2019:1168)"
      ],
      "List of errata ids to perform an action on, (ex: RHSA-2019:1168)": [
        "Liste d'id de systèmes sur lesquels effectuer une action, (ex: RHSA-2019:1168)"
      ],
      "List of host collection IDs to associate with activation key": [
        "Liste d'ID de collection d'hôtes à associer à la clé d'activation"
      ],
      "List of host collection IDs to disassociate from the activation key": [
        "Liste d'ID de collection d'hôtes à dissocier de la clé d'activation"
      ],
      "List of host collection ids": [
        "Liste d'ids de collection d'hôtes"
      ],
      "List of host collection ids to update": [
        "Liste des ids de collection d'hôtes à mettre à jour"
      ],
      "List of host id to list available module streams for": [
        "Liste des numéros d'identification des hôtes afin de répertorier les flux de modules disponibles pour"
      ],
      "List of host ids to exclude and not run an action on": [
        "Liste d'id d’hôtes à exclure et sur lesquels ne pas effectuer d'action"
      ],
      "List of host ids to perform an action on": [
        "Liste d'id d’hôtes sur lesquels effectuer une action"
      ],
      "List of host ids to replace the hosts in host collection": [
        "Liste d'ids d'hôtes de contenu pour remplacer les hôtes dans la collection d'hôtes"
      ],
      "List of hypervisor guest uuids": [
        "Liste des uuids invités de l'hyperviseur"
      ],
      "List of package group names (Deprecated)": [
        "Liste de noms de groupes de packages (dépréciée)"
      ],
      "List of package names": [
        "Liste de noms de packages"
      ],
      "List of product ids": [
        "Liste d'ids de produits"
      ],
      "List of product ids to add to the sync plan": [
        "Liste d'id de produits à ajouter au plan de sync"
      ],
      "List of product ids to remove from the sync plan": [
        "Liste d'ids de produits à supprimer du plan de sync"
      ],
      "List of products in an organization": [
        "Liste de produits dans une organisation"
      ],
      "List of products installed on the host": [
        "Liste des produits installés sur l'hôte"
      ],
      "List of repositories belonging to a product in an environment": [
        "Liste des référentiels appartenant à un produit dans un environnement"
      ],
      "List of repositories for a content view": [
        "Liste de référentiels pour un affichage de contenu"
      ],
      "List of repositories for a docker meta tag": [
        "Liste de référentiels pour une balise meta docker"
      ],
      "List of repositories for a product": [
        "Liste de tous les référentiels d'un produit"
      ],
      "List of repositories in an organization": [
        "Liste des référentiels d’une organisation"
      ],
      "List of repository ids": [
        "Liste d'ids de référentiel "
      ],
      "List of resources types that will be automatically associated": [
        "Lister les types de ressources qui seront associées automatiquement"
      ],
      "List of subscription products in a subscription": [
        "Liste de produits d'abonnement dans un abonnement"
      ],
      "List of subscription products in an activation key": [
        "Liste de produits d'abonnement dans une clé d'activation"
      ],
      "List of versions to exclude and not run an action on": [
        "Liste des versions à exclure et sur lesquelles ne pas exécuter d'action"
      ],
      "List of versions to perform an action on": [
        "Liste des versions sur lesquelles effectuer une action"
      ],
      "List organization subscriptions": [
        "Répertorier les abonnements d'organisation"
      ],
      "List packages": [
        "Répertorier tous les packages"
      ],
      "List packages installed on the host": [
        "Répertorier les packages installés sur l'hôte"
      ],
      "List products": [
        "Répertorier les produits"
      ],
      "List repositories in the environment": [
        "Liste des référentiels dans l'environnement"
      ],
      "List repository sets for a product.": [
        "Répertorier les ensembles de référentiels pour un produit"
      ],
      "List repository sets.": [
        "Répertorier les ensembles de référentiels"
      ],
      "List services that need restarting on the host": [
        "Liste des services qui doivent être redémarrés sur l'hôte"
      ],
      "List srpms": [
        "Liste des srpms"
      ],
      "List subscriptions": [
        "Liste des abonnements"
      ],
      "List sync plans": [
        "Répertorier les plans de sync"
      ],
      "List the lifecycle environments attached to the smart proxy": [
        "Répertorier les environnements de cycle de vie attachés au proxy smart"
      ],
      "List the lifecycle environments not attached to the smart proxy": [
        "Répertorier les environnements de cycle de vie non attachés au proxy smart"
      ],
      "Load balancer": [
        ""
      ],
      "Loading": [
        "Chargement..."
      ],
      "Loading versions": [
        "Versions de chargement"
      ],
      "Loading...": [
        "Chargement..."
      ],
      "Low": [
        "Faible"
      ],
      "Maintenance support": [
        ""
      ],
      "Make copy of a content view": [
        "Faire une copie d'un affichage de contenu"
      ],
      "Make copy of a host collection": [
        "Faire une copie d'une collection d'hôte"
      ],
      "Make sure all the component content views are published before publishing/promoting the composite content view. This restriction is optional and can be modified in the Administrator -> Settings -> Content page using the restrict_composite_view flag.": [
        "Assurez-vous que tous les affichages de contenu composant sont publiées avant de publier/promouvoir un affichage de contenu composite. Cette restriction est facultative et peut être modifiée dans la page Administrateur -> Paramètres -> Contenu en utilisant le drapeau restrict_composite_view."
      ],
      "Manage Manifest": [
        "Gérer le manifeste"
      ],
      "Manage content": [
        ""
      ],
      "Manage errata": [
        ""
      ],
      "Manage packages": [
        ""
      ],
      "Manifest": [
        "Manifeste"
      ],
      "Manifest History": [
        "L'historique du manifeste"
      ],
      "Manifest deleted": [
        "Manifeste supprimé"
      ],
      "Manifest does not have a valid subscription": [
        ""
      ],
      "Manifest expired": [
        ""
      ],
      "Manifest expiring soon": [
        ""
      ],
      "Manifest imported": [
        "Manifeste importé"
      ],
      "Manifest in '%{subject}' deleted.": [
        "Manifeste de '%{sujet}' supprimé."
      ],
      "Manifest in '%{subject}' failed to refresh.": [
        "Le manifeste de '%{subject}' n'a pas été actualisé."
      ],
      "Manifest in '%{subject}' imported.": [
        "Manifeste de '%{subject}' importé"
      ],
      "Manifest in '%{subject}' refreshed.": [
        "Manifeste de '%{subject}' rafraîchi"
      ],
      "Manifest in organization %{subject} has an identity certificate that will expire in %{days_remaining} days, on %{manifest_expire_date}. To extend the expiration date, please refresh your manifest.": [
        ""
      ],
      "Manifest refresh timeout": [
        "Échec de l'actualisation du manifeste"
      ],
      "Manifest refreshed": [
        "Manifeste rafraîchi"
      ],
      "Manual": [
        "Manuelle"
      ],
      "Manual authentication": [
        "Authentification manuelle"
      ],
      "Mark Content Host Statuses as Unknown for %s": [
        "Marquer les statuts des hôtes de contenu comme inconnus pour %s"
      ],
      "Matching RPMs based on your created filter rule. Remember, RPM filters don't apply to modular RPMs.": [
        ""
      ],
      "Matching content": [
        "Contenu correspondant"
      ],
      "Max %(maxQuantity)s": [
        "Max %(maxQuantity)s"
      ],
      "Max Hosts (%{limit}) reached for activation key '%{name}'": [
        "Hôtes Maximum (%{limit}) atteint pour la clé d'activation '%{name}'."
      ],
      "Maximum download rate when syncing a repository (requests per second). Use 0 for no limit.": [
        "Taux de téléchargement maximal lors de la synchronisation d'un référentiel (demandes par seconde). Utilisez 0 pour ne pas avoir de limite."
      ],
      "Maximum number of content hosts exceeded for host collection(s): %s": [
        "Nombre maximum d'hôtes de contenu dépassé pour la ou les collection(s) d'hôtes : %s"
      ],
      "Maximum number of hosts in the host collection": [
        "Nombre maximum d'hôtes de contenu dans la collection d'hôtes"
      ],
      "Maximum version": [
        "Version maximum"
      ],
      "May not add a type or date range rule to a filter that has existing rules.": [
        "Ne doit pas ajouter un type ou une règle de plage de dates à un filtre possédant des règles existantes."
      ],
      "May not add an id rule to a filter that has an existing type or date range rule.": [
        "Ne doit pas ajouter une règle d'id à un filtre qui possède un type existant ou une règle de plage de date."
      ],
      "Media Selection": [
        "Sélection des médias"
      ],
      "Medium IDs": [
        "ID Medium"
      ],
      "Message": [
        "Message"
      ],
      "Messaging connection": [
        "Connexion à la messagerie"
      ],
      "Metadata republishing is risky on 'Complete Mirroring' repositories. Change the mirroring policy and try again.\\nAlternatively, use the 'force' parameter to regenerate metadata locally. On the next sync, the upstream repository's metadata will overwrite local metadata for 'Complete Mirroring' repositories.": [
        ""
      ],
      "Metadata taken from the upstream export history for this Content View Version": [
        "Métadonnées tirées de l'historique des exportations en amont pour cette version de la vue du contenu"
      ],
      "Minimum version": [
        "Version minimum"
      ],
      "Mirror Remote Repository": [
        ""
      ],
      "Mirror a flatpak remote repository": [
        ""
      ],
      "Missing activation key!": [
        "Clé d'activation manquante !"
      ],
      "Missing arguments %{substitutions} for %{content_url}": [
        "Arguments manquants %{substitutions} pour %{content_url} "
      ],
      "Model": [
        "Modéliser"
      ],
      "Moderate": [
        "Modéré"
      ],
      "Modify via remote execution": [
        ""
      ],
      "Modular": [
        "Modulaire"
      ],
      "Module Stream": [
        "Flux de modules"
      ],
      "Module Stream Details": [
        "Détails du flux de modules"
      ],
      "Module Streams": [
        "Flux de module"
      ],
      "Module stream": [
        "Flux de modules"
      ],
      "Module streams": [
        "Flux de module"
      ],
      "Module streams will appear here after enabling Red Hat repositories or creating custom products.": [
        "Les flux de modules apparaîtront ici après avoir activé les référentiels Red Hat ou créé des produits personnalisés."
      ],
      "Multi Content View Environment": [
        ""
      ],
      "Multi-entitlement": [
        "Droits d’accès multiples"
      ],
      "N/A": [
        "Sans objet"
      ],
      "NA": [
        "N/A"
      ],
      "NOTE: Content view version '%{content_view} %{current}' does not have any exportable repositories. At least one repository with any of the following types is required to be able to export: '%{exportable_types}'.": [
        ""
      ],
      "NOTE: Unable to export repository '%{repository}' because it does not have an exportable content type.": [
        "NOTE : Impossible d'exporter le référentiel '%{repository}' car il n'a pas de type de contenu exportable."
      ],
      "NOTE: Unable to export repository '%{repository}' because it does not have an syncably exportable content type.": [
        ""
      ],
      "NOTE: Unable to fully export '%{organization}' organization's library because it contains repositories without the 'immediate' download policy. Update the download policy and sync affected repositories to include them in the export. \\n %{repos}": [
        "REMARQUE : Impossible d'exporter complètement la bibliothèque de l'organisation '%%{organization}' car elle contient des référentiels sans la politique de téléchargement \\\"immédiate\\\". Mettez à jour la politique de téléchargement et synchronisez les référentiels concernés pour les inclure dans l'exportation\\n %%{repos}"
      ],
      "NOTE: Unable to fully export Content View Version '%{content_view} %{current}' it contains repositories with un-exportable content types. \\n %{repos}": [
        "REMARQUE : Impossible d'exporter complètement la version de la vue du contenu '%{content_view} %{current}' car elle contient des référentiels avec des types de contenu non exportables. \\n %{repos}"
      ],
      "NOTE: Unable to fully export Content View Version '%{content_view} %{current}' it contains repositories without the 'immediate' download policy. Update the download policy and sync affected repositories. Once synced republish the content view and export the generated version. \\n %{repos}": [
        "REMARQUE : Impossible d'exporter complètement la version de la vue du contenu '%{content_view} %%{current}' car elle contient des référentiels sans la politique de téléchargement 'immediate'. Mettez à jour la politique de téléchargement et synchronisez les référentiels concernés. Une fois synchronisé, republiez la vue du contenu et exportez la version générée\\n %%{repos}"
      ],
      "NOTE: Unable to fully export repository '%{repository}' because it does not have the 'immediate' download policy. Update the download policy and sync the affected repository to include them in the export.": [
        "NOTE : Impossible d'exporter complètement le dépôt '%{repository}' car il n'a pas la politique de téléchargement 'immédiate'. Mettez à jour la politique de téléchargement et synchronisez le référentiel concerné pour l'inclure dans l'exportation."
      ],
      "Name": [
        "Nom"
      ],
      "Name and label of default content view should not be changed": [
        "Le nom et le libellé de la vue de contenu par défaut ne doivent pas être modifiés."
      ],
      "Name is a required parameter.": [
        "Le nom est un paramètre obligatoire."
      ],
      "Name of new activation key": [
        "Nom de la nouvelle clé d'activation"
      ],
      "Name of the Content Credential": [
        "Nom des identifiants du contenu"
      ],
      "Name of the alternate content source": [
        "Nom de la source de contenu alternatif"
      ],
      "Name of the content view": [
        "Nom de l'affichage du contenu"
      ],
      "Name of the flatpak remote": [
        ""
      ],
      "Name of the flatpak remote repository": [
        ""
      ],
      "Name of the host": [
        "Nom de l'hôte"
      ],
      "Name of the repository": [
        "Nom du référentiel"
      ],
      "Name of the upstream docker repository": [
        "Nom du référentiel docker en amont"
      ],
      "Name source": [
        "Source du nom"
      ],
      "Names of smart proxies to associate": [
        "Noms des proxies smart à associer"
      ],
      "Needs to only be set for docker tags": [
        "Ne doit être réglé que pour les balises docker"
      ],
      "Needs to only be set for file repositories or docker tags": [
        "Ne doit être défini que pour les référentiels de fichiers ou les balises docker"
      ],
      "Nest": [
        "Imbriquer"
      ],
      "Network Sync": [
        "Synchronisation du réseau"
      ],
      "Never": [
        "Jamais"
      ],
      "Never Synced": [
        "Jamais sync"
      ],
      "New Errata": [
        "Nouveaux errata"
      ],
      "New content view name": [
        "Nouveau nom de la vue de contenu"
      ],
      "New host collection name": [
        "Nouveau nom de la collection d'hôte"
      ],
      "New name cannot be blank": [
        "Le nouveau nom ne peut être vide."
      ],
      "New name for the content view": [
        "Nouveau nom de l'affichage du contenu"
      ],
      "New version is available: Version ${latestVersion}": [
        "Une version plus récente est disponible : Version {latestVersion}"
      ],
      "Newly published": [
        "Dernière publication"
      ],
      "Newly published version will be the same as the previous version.": [
        ""
      ],
      "No": [
        "Non"
      ],
      "No Activation Keys selected": [
        "Aucune clé d'activation n'est affectée."
      ],
      "No Activation keys to select": [
        "Aucune clé d'activation n'est affectée."
      ],
      "No Content View": [
        "Aucun affichage de contenu"
      ],
      "No Content found": [
        "Aucun affichage de contenu trouvé"
      ],
      "No Red Hat products currently exist, please import a manifest %(anchorBegin)s here %(anchorEnd)s to receive Red Hat content. No repository sets available.": [
        "Aucun produit Red Hat n'existe actuellement, veuillez importer un manifeste %(anchorBegin)s ici %(anchorEnd)s pour recevoir le contenu Red Hat. Aucun ensemble de référentiel n'est disponible."
      ],
      "No Service Level Preference": [
        "Aucune préférence de niveau de service"
      ],
      "No URL found for a container registry. Please check the configuration.": [
        "Aucune URL trouvée pour un registre de conteneurs. Veuillez vérifier la configuration."
      ],
      "No Version of Content View %{component} already exists as a component of the composite Content View %{composite} version %{version}": [
        "Aucune version d'affichage de contenu %{component} existe en tant que composant de l'affichage de contenu composite %{composite} version %{version}"
      ],
      "No action is needed because there are no applicable errata for this host.": [
        "Aucune action n'est nécessaire car il n'y a pas d'errata applicable pour cet hôte."
      ],
      "No action required": [
        "Aucune action requise"
      ],
      "No applicable errata": [
        "Aucun errata applicable"
      ],
      "No applications to restart": [
        "Aucune application à redémarrer"
      ],
      "No artifacts to show": [
        "Pas d'artefacts à montrer"
      ],
      "No available component content view updates": [
        ""
      ],
      "No available debs found for search term '%s'. Check the host's content view environments and already-installed debs.": [
        ""
      ],
      "No available packages found for search term '%s'.": [
        ""
      ],
      "No available repository or filter updates": [
        ""
      ],
      "No content": [
        "Aucun contenu"
      ],
      "No content added.": [
        "Aucun affichage de contenu ajouté."
      ],
      "No content ids provided": [
        "Aucuns ids de contenu ne sont fournis"
      ],
      "No content in selected versions.": [
        "Aucun contenu dans les versions sélectionnées."
      ],
      "No content view environments": [
        ""
      ],
      "No content view environments found with ids: %{ids}": [
        ""
      ],
      "No content view environments found with names: %{names}": [
        ""
      ],
      "No content view history events found.": [
        "Aucun historique d'affichage de contenu n'a été trouvé."
      ],
      "No content views available": [
        "Il n'existe pas d’affichages de contenu disponible"
      ],
      "No content views available for the selected environment": [
        "Aucune vue du contenu n'est disponible pour l'environnement sélectionné"
      ],
      "No content views to add yet": [
        ""
      ],
      "No content views yet": [
        ""
      ],
      "No content_view_version_ids provided": [
        "Aucun content_view_version_ids fourni"
      ],
      "No description": [
        "Aucune description"
      ],
      "No description provided": [
        "Aucune description fournie"
      ],
      "No docker manifests to delete after ignoring manifests with tags or manifest lists": [
        ""
      ],
      "No enabled repositories match your search criteria.": [
        "Aucun référentiel activé ne correspond à vos critères de recherche."
      ],
      "No environments": [
        "Aucun environnement"
      ],
      "No errata filter rules yet": [
        ""
      ],
      "No errata found.": [
        ""
      ],
      "No errata matching given search query": [
        ""
      ],
      "No errata to add yet": [
        ""
      ],
      "No errors": [
        "Aucune erreur"
      ],
      "No existing export history was found to perform an incremental export. A full export must be performed": [
        "Aucun historique d'exportation existant n'a été trouvé pour effectuer une exportation incrémentielle. Une exportation complète doit être effectuée"
      ],
      "No file uploaded": [
        "Aucun fichier téléchargé"
      ],
      "No filters yet": [
        ""
      ],
      "No history yet": [
        ""
      ],
      "No host collections": [
        "Aucune collection d'hôtes"
      ],
      "No host collections found.": [
        "Aucune collection d'hôtes trouvée"
      ],
      "No host collections yet": [
        "Pas encore de collections d'hôtes"
      ],
      "No hosts found": [
        ""
      ],
      "No hosts registered with subscription-manager found in selection.": [
        "Aucun hôte enregistré avec le gestionnaire d'abonnement n'a été trouvé dans la sélection."
      ],
      "No hosts were specified": [
        ""
      ],
      "No installed debs found for search term '%s'": [
        ""
      ],
      "No installed packages and/or enabled repositories have been reported by %s.": [
        "Aucun package installé et/ou référentiel activé n'a été signalé par %s."
      ],
      "No items have been specified.": [
        "Aucun objet n'a été spécifié."
      ],
      "No manifest file uploaded": [
        "Aucun fichier manifeste téléchargé"
      ],
      "No manifest found. Import a manifest with the appropriate subscriptions before importing content.": [
        "Aucun manifeste trouvé. Importez un manifeste avec les abonnements appropriés avant d'importer le contenu."
      ],
      "No manifest imported": [
        ""
      ],
      "No matching ": [
        "Aucun résultat"
      ],
      "No matching ${name} found.": [
        "Aucun résultat ${name} correspondant."
      ],
      "No matching ${selectedContentType} found": [
        "Aucun résultat {selectedContentType} correspondant."
      ],
      "No matching DEB found.": [
        "Aucun DEB correspondant n’a été trouvé."
      ],
      "No matching activation keys found.": [
        "Aucune clé d’activation n’a été trouvée."
      ],
      "No matching alternate content sources found": [
        "Aucune source de contenu alternatif correspondante trouvée"
      ],
      "No matching content views found": [
        "Aucun contenu correspondant n'a été trouvé"
      ],
      "No matching errata found": [
        "Aucune errata correspondante n’a été trouvée"
      ],
      "No matching filter rules found.": [
        "Aucun filtre correspondant n'a été trouvé"
      ],
      "No matching filters found": [
        "Aucun filtre correspondant n'a été trouvé"
      ],
      "No matching history record found": [
        "Aucune fiche d'historique correspondante trouvée"
      ],
      "No matching host collections found": [
        "Aucune collection d'hôtes correspondante n'a été trouvée"
      ],
      "No matching hosts found.": [
        "Aucun hôte correspondant n’a été trouvé."
      ],
      "No matching non-modular RPM found.": [
        ""
      ],
      "No matching packages found": [
        "Aucun paquet correspondant n'a été trouvé."
      ],
      "No matching repositories found": [
        "Aucun référentiel correspondant n'a été trouvé"
      ],
      "No matching repository sets found": [
        "Aucun ensemble de référentiels correspondant n'a été trouvé"
      ],
      "No matching traces found": [
        "Aucune règle de traces n'a été trouvée."
      ],
      "No matching version found": [
        "Aucune version correspondante trouvée"
      ],
      "No module stream filter rules yet": [
        ""
      ],
      "No module streams to add yet.": [
        ""
      ],
      "No new packages installed": [
        "Aucun nouveau package installé"
      ],
      "No package groups yet": [
        ""
      ],
      "No packages": [
        "Aucun package"
      ],
      "No packages available to install": [
        "Aucun paquet disponible pour l'installation"
      ],
      "No packages available to install on this host. Please check the host's content view and lifecycle environment.": [
        ""
      ],
      "No packages removed": [
        "Aucun package supprimé"
      ],
      "No packages updated": [
        "Aucun package mis à jour"
      ],
      "No pool IDs were provided.": [
        "Aucun ID de Pool n'a été fourni."
      ],
      "No pools available": [
        "Aucun Pool disponible"
      ],
      "No pools were provided.": [
        "Aucun Pool fourni."
      ],
      "No processes require restarting": [
        "Aucun processus ne doit être relancé"
      ],
      "No products are enabled.": [
        "Aucun produit n'est activé."
      ],
      "No profiles to show": [
        "Aucun profil à montrer"
      ],
      "No pulp workers running.": [
        "Aucun worker Pulp en cours d'exécution."
      ],
      "No pulpcore content apps are running at %s.": [
        "Aucune app de contenu pulpcore n’exécute dans %s."
      ],
      "No pulpcore workers are running at %s.": [
        "Aucun pulpcore n’exécute dans %s."
      ],
      "No recently synced products": [
        "Aucun produit synchronisé récemment"
      ],
      "No recurring logic tied to the sync plan.": [
        "Pas de logique récurrente liée au plan de synchronisation."
      ],
      "No repositories added yet": [
        ""
      ],
      "No repositories available to add": [
        ""
      ],
      "No repositories available.": [
        "Aucun référentiel n'est disponible."
      ],
      "No repositories enabled.": [
        "Aucun référentiel activé"
      ],
      "No repositories selected.": [
        "Aucun référentiel sélectionné."
      ],
      "No repositories to show": [
        "Aucun dépôt à montrer"
      ],
      "No repository sets match your search criteria.": [
        "Aucun ensemble de référentiels ne correspond à vos critères de recherche."
      ],
      "No repository sets to show.": [
        "Aucun ensemble de référentiels à afficher."
      ],
      "No rules yet": [
        ""
      ],
      "No services defined, is this class extended?": [
        "Aucuns services définis, est-ce une classe étendue ?"
      ],
      "No start time currently available.": [
        "Aucune date de début disponible actuellement"
      ],
      "No subscriptions match your search criteria.": [
        "Aucun abonnement ne correspond à vos critères dae recherche."
      ],
      "No syncable repositories found for selected products and options.": [
        "Aucun référentiel synchronisable n'a été trouvé pour les produits et options sélectionnés."
      ],
      "No upgradable packages found for search term '%s'.": [
        ""
      ],
      "No upgradable packages found.": [
        ""
      ],
      "No uploads param specified. An array of uploads to import is required.": [
        "Aucun paramètre de téléchargement n'est spécifié. Un tableau des téléchargements à importer est nécessaire."
      ],
      "No versions yet": [
        ""
      ],
      "Non-security errata applicable": [
        "Errata non-sécurité applicable"
      ],
      "Non-security errata installable": [
        "Errata non-sécurité installable"
      ],
      "Non-system event": [
        "Événement non système"
      ],
      "None": [
        "Aucun(e)"
      ],
      "None provided": [
        "Aucun n'est prévu"
      ],
      "Not a number": [
        "Pas un numéro"
      ],
      "Not added": [
        "Non ajouté"
      ],
      "Not all necessary pulp workers running at %s.": [
        "Tous les workers pulp nécessaires ne fonctionnent pas à %s."
      ],
      "Not installed": [
        "Non installé"
      ],
      "Not running": [
        "Non en cours"
      ],
      "Not yet published": [
        "Pas encore publié"
      ],
      "Note: Deleting a subscription manifest is STRONGLY discouraged.": [
        ""
      ],
      "Note: Deleting a subscription manifest is STRONGLY discouraged. Deleting a manifest will:": [
        "Remarque : la suppression d'un manifeste d'abonnement est VIVEMENT déconseillée. La suppression d'un manifeste entraînera :"
      ],
      "Note: The number in parentheses reflects all applicable errata from the Library environment that are unavailable to the host. You will need to promote this content to the relevant content view in order to make it available.": [
        "Remarque : le nombre indiqué entre parenthèses reflète tous les errata applicables de l'environnement de la bibliothèque et indisponibles à l'hôte. Vous devez promouvoir ce contenu vers l'affichage de contenu approprié afin de le rendre disponible."
      ],
      "Nothing selected": [
        "Rien n'a été sélectionné"
      ],
      "Number of CPU(s)": [
        "Nombre de processeurs"
      ],
      "Number of host applicability calculations to process per task.": [
        "Nombre de calculs d'applicabilité de l'hôte à traiter par tâche."
      ],
      "Number of results per page to return": [
        "Nombre de résultats par page à renvoyer"
      ],
      "Number of results per page to return.": [
        "Nombre de résultats par page à renvoyer"
      ],
      "Number to Allocate": [
        "Numéro à attribuer"
      ],
      "OS": [
        ""
      ],
      "OS restricted to {osRestricted}. If host OS does not match, the repository will not be available on this host.": [
        "OS restreint à {osRestricted}. Si l'OS de l'hôte ne correspond pas, le référentiel ne sera pas disponible sur cet hôte."
      ],
      "OSTree Branch": [
        "Branche OSTree"
      ],
      "OSTree Ref": [
        "Ref OSTree"
      ],
      "OSTree Refs": [
        "Refs OSTree"
      ],
      "OSTree ref": [
        "ref OSTree"
      ],
      "OSTree refs": [
        "refs OSTree"
      ],
      "Object to show subscriptions available for, either 'host' or 'activation_key'": [
        "Objets qui montre les abonnements disponibles for, soit 'hôte' ou 'activation_key'"
      ],
      "On Demand": [
        "Sur demande"
      ],
      "On the RHUA Instance, check the available repositories.": [
        "Sur l'Instance RHUA, vérifiez les référentiels disponibles."
      ],
      "On-disk location for pulp 3 exported repositories": [
        "Emplacement-disque des référentiels Pulp3 exportés"
      ],
      "Once the prerequisites are met, select a provider to install katello-host-tools-tracer": [
        ""
      ],
      "One of parameters [ %s ] required but not specified.": [
        "L'un des paramètres [ %s ] est requis, mais il n'est pas spécifié."
      ],
      "One of yum or docker": [
        "Un de yum ou de docker"
      ],
      "One or more hosts not found": [
        "Un ou plusieurs hôtes non trouvés"
      ],
      "One or more ids (%{ids}) were not found for %{assoc}.  You may not have permissions to see them.": [
        "Un ou plusieurs ids (%{ids}) n'ont pas été trouvés pour %{assoc}.  Vous n'avez peut-être pas les autorisations nécessaires pour les voir."
      ],
      "One or more processes require restarting": [
        "Un ou plusieurs processus doivent être relancés"
      ],
      "Only On Demand repositories may have space reclaimed.": [
        "Seuls les référentiels Sur demande peuvent récupérer de l’espace."
      ],
      "Only On Demand smart proxies may have space reclaimed.": [
        "Seuls les proxy smart peuvent récupérer de l’espace."
      ],
      "Only one Red Hat provider permitted for an Organization": [
        "Seul un fournisseur Red Hat autorisé pour une organisation"
      ],
      "Only repositories not published in a content view can be disabled. Published repositories must be deleted from the repository details page.": [
        ""
      ],
      "Only returns id and quantity fields": [
        "Ne renvoie que les champs d'identification et de quantité"
      ],
      "Operators": [
        "Opérateurs"
      ],
      "Organization": [
        "Organisation"
      ],
      "Organization %s is being deleted.": [
        "L'organisation %s a été supprimée"
      ],
      "Organization ID": [
        "ID de l’organisation"
      ],
      "Organization ID is required": [
        "L'identification de l'organisation est requise"
      ],
      "Organization Information not provided.": [
        "Informations sur l'organisation non fournies."
      ],
      "Organization cannot be blank.": [
        "L'organisation ne peut pas être vide."
      ],
      "Organization id": [
        "ID de l’organisation"
      ],
      "Organization id not found: '%s'": [
        ""
      ],
      "Organization identifier": [
        "Identifiant de l'organisation"
      ],
      "Organization label": [
        "Balise de l'organisation"
      ],
      "Organization label '%s' is ambiguous. Try using an id-based container name.": [
        ""
      ],
      "Organization not found": [
        "Organisation non trouvée"
      ],
      "Organization not found: '%s'": [
        ""
      ],
      "Organization required": [
        "Organisation requise"
      ],
      "Orphaned Content Protection Time": [
        "Temps de protection du contenu orphelin"
      ],
      "Orphaned content facets for deleted hosts exist for the content view and environment. Please run rake task : katello:clean_orphaned_facets and try again!": [
        ""
      ],
      "Other": [
        "Autre"
      ],
      "Other Content Types": [
        "Autres types de contenu"
      ],
      "Overridden": [
        "Remplacé"
      ],
      "Override content for activation_key": [
        "Annuler le contenu pour la clé d'activation"
      ],
      "Override key or name. Note if name is not provided the default name will be 'enabled'": [
        "Annulez la clé ou le nom. Notez que si le nom n'est pas fourni, le nom par défaut sera \\\"activé\\\""
      ],
      "Override parameter key or name. Note if name is not provided the default name will be 'enabled'": [
        "Remplacez la clé ou le nom du paramètre. Notez que si le nom n'est pas fourni, le nom par défaut sera \\\"activé\\\""
      ],
      "Override the major version number": [
        "Remplacer le numéro de la version principale"
      ],
      "Override the minor version number": [
        "Remplacer le numéro de la version mineure"
      ],
      "Override to a boolean value or 'default'": [
        "Remplacer par une valeur booléenne ou par \\\"défaut\\\""
      ],
      "Override to disabled": [
        "Remplacer par «Désactiver»"
      ],
      "Override to enabled": [
        "Remplacer par «Activer»"
      ],
      "Override value. Provide a boolean value if name is 'enabled'": [
        "Valeur d'annulation. Fournir une valeur booléenne si le nom est \\\"activé\\\""
      ],
      "Package": [
        "Package"
      ],
      "Package Group": [
        "Groupe de packages"
      ],
      "Package Group Install": [
        "Installation de groupes de packages"
      ],
      "Package Group Install Canceled": [
        "Installation du groupe de packages annulée"
      ],
      "Package Group Install Complete": [
        "Installation du groupe de packages terminée"
      ],
      "Package Group Install Failed": [
        "Échec de l'installation du groupe de packages"
      ],
      "Package Group Install Timed Out": [
        "Délai d'expiration de l'installation du groupe de packages dépassé"
      ],
      "Package Group Install scheduled by %s": [
        "Installation du groupe de packages planifiée par %s"
      ],
      "Package Group Remove": [
        "Suppression de groupes de packages"
      ],
      "Package Group Remove Canceled": [
        "Suppression du groupe de packages annulée"
      ],
      "Package Group Remove Complete": [
        "Suppression du groupe de packages terminée"
      ],
      "Package Group Remove Failed": [
        "Échec de la suppression du groupe de packages"
      ],
      "Package Group Remove Timed Out": [
        "Délai d'expiration de la suppression du groupe de packages dépassé"
      ],
      "Package Group Remove scheduled by %s": [
        "Suppression du groupe de packages planifiée par %s"
      ],
      "Package Group Update": [
        "Mise à jour de groupe de packages"
      ],
      "Package Group Update scheduled by %s": [
        "Mise à jour du groupe de packages planifiée par %s"
      ],
      "Package Groups": [
        "Groupes de packages"
      ],
      "Package Install": [
        "Installation de packages"
      ],
      "Package Install Canceled": [
        "Installation du package annulée"
      ],
      "Package Install Complete": [
        "Installation du package terminée"
      ],
      "Package Install Failed": [
        "Échec de l'installation du package"
      ],
      "Package Install Timed Out": [
        "Délai d'expiration de l'installation du package dépassé"
      ],
      "Package Install scheduled by %s": [
        "Installation du package planifiée par %s"
      ],
      "Package Remove": [
        "Suppression de packages"
      ],
      "Package Remove Canceled": [
        "Suppression du package annulée"
      ],
      "Package Remove Complete": [
        "Suppression du package terminée"
      ],
      "Package Remove Failed": [
        "Échec de la suppression du package"
      ],
      "Package Remove Timed Out": [
        "Délai d'expiration de la suppression du package dépassé"
      ],
      "Package Remove scheduled by %s": [
        "Suppression du package planifiée par %s"
      ],
      "Package Type": [
        "Type de package"
      ],
      "Package Types": [
        "Types de paquets"
      ],
      "Package Update": [
        "Mise à jour de packages"
      ],
      "Package Update Canceled": [
        "Mise à jour du package annulée"
      ],
      "Package Update Complete": [
        "Mise à jour du package terminée"
      ],
      "Package Update Failed": [
        "Échec de la mise à jour du package"
      ],
      "Package Update Timed Out": [
        "Délai d'expiration de la mise à jour du package dépassé"
      ],
      "Package Update scheduled by %s": [
        "Mise à jour du package planifiée par %s"
      ],
      "Package group update canceled": [
        "Mise à jour du groupe de packages annulée"
      ],
      "Package group update complete": [
        "Mise à jour du groupe de package terminée"
      ],
      "Package group update failed": [
        "Échec de la mise à jour du groupe de packages"
      ],
      "Package group update timed out": [
        "Délai d'expiration de la mise à jour du groupe de packages dépassé"
      ],
      "Package groups": [
        "Groupes de packages"
      ],
      "Package identifiers to filter content by": [
        "Identificateurs de packages pour filtrer le contenu par"
      ],
      "Package install failed: \\\"%{package}\\\"": [
        "Échec de l'installation du package: \\\"%{package}\\\" "
      ],
      "Package installation: \\\"%{package}\\\" ": [
        "Installation de packages: \\\"%{package}\\\" "
      ],
      "Package mode": [
        ""
      ],
      "Package types to sync for Python content, separated by comma. Leave empty to get every package type. Package types are: bdist_dmg,bdist_dumb,bdist_egg,bdist_msi,bdist_rpm,bdist_wheel,bdist_wininst,sdist.": [
        ""
      ],
      "Packages": [
        "Packages"
      ],
      "Packages must be provided": [
        "Des packages doivent être fournis"
      ],
      "Packages to be removed": [
        ""
      ],
      "Packages to be updated": [
        ""
      ],
      "Packages to install": [
        ""
      ],
      "Packages will appear here when available.": [
        "Les packages apparaîtront ici une fois disponibles."
      ],
      "Page number, starting at 1": [
        "Numéro de la page, commençant par 1"
      ],
      "Partition template IDs": [
        "ID des modèles de partitionnement"
      ],
      "Password": [
        "Mot de passe"
      ],
      "Password for authentication. Relevant only for 'upstream_server' type.": [
        "Mot de passe pour l'authentification. N'est pertinent que pour le type 'upstream_server'."
      ],
      "Password of the upstream repository user used for authentication": [
        "Mot de passe de l'utilisateur du référentiel en amont utilisé pour l'authentification"
      ],
      "Password to access URL": [
        "Mot de passe pour accéder à l'URL"
      ],
      "Path": [
        "Chemin"
      ],
      "Path suffixes for finding alternate content": [
        "Suffixes de chemin pour trouver un contenu alternatif"
      ],
      "Paused": [
        "Suspendue"
      ],
      "Pending tasks detected in repositories of this content view. Please wait for the tasks: ": [
        ""
      ],
      "Perform a module stream action via Katello interface": [
        "Effectuer une action de flux de module via l'interface Katello"
      ],
      "Perform an Incremental Update on one or more Content View Versions": [
        "Effectuer une mise à jour croissante sur une ou plusieurs versions d'affichage de contenu."
      ],
      "Performs a full-export of a content view version.": [
        "Effectue une exportation complète d'une version de vue de contenu."
      ],
      "Performs a full-export of the repositories in library.": [
        "Effectue une exportation complète des référentiels dans la bibliothèque."
      ],
      "Performs a full-export of the repository in library.": [
        "Effectue une exportation complète des référentiels dans la bibliothèque."
      ],
      "Performs a incremental-export of the repository in library.": [
        "Effectue une exportation incrémentale du référentiel dans la bibliothèque."
      ],
      "Performs an incremental-export of a content view version.": [
        "Effectue une exportation incrémentielle d'une version de vue du contenu."
      ],
      "Performs an incremental-export of the repositories in library.": [
        "Effectue une exportation incrémentale des référentiels de la bibliothèque."
      ],
      "Permission Denied. User '%{user}' does not have permissions to access organization '%{org}'.": [
        "Permission refusée. L'utilisateur '%{user}' ne possède pas les permissions pour accéder à l'organisation '%{org}'."
      ],
      "Physical": [
        "Physique"
      ],
      "Plan numeric identifier": [
        "Identifiant numérique du plan"
      ],
      "Please add some repositories.": [
        "Veuillez ajouter quelques référentiels."
      ],
      "Please create some content views.": [
        ""
      ],
      "Please enter a positive number above zero": [
        "Veuillez entrer un nombre positif au-dessus de zéro"
      ],
      "Please enter digits only": [
        "Veuillez saisir uniquement des chiffres"
      ],
      "Please limit number to 10 digits": [
        "Veuillez limiter le nombre à 10 chiffres"
      ],
      "Please select a content source before assigning a kickstart repository": [
        "Veuillez sélectionner une source de contenu avant d'attribuer un référentiel kickstart"
      ],
      "Please select a lifecycle environment and a content view to move these activation keys.": [
        "Veuillez sélectionner un environnement de cycle de vie et une vue de contenu pour déplacer ces clés d'activation."
      ],
      "Please select a lifecycle environment and a content view to move this activation key.": [
        "Veuillez sélectionner un environnement de cycle de vie et une vue de contenu pour déplacer cette clé d'activation."
      ],
      "Please select a lifecycle environment and content view to view activation keys.": [
        ""
      ],
      "Please select an architecture before assigning a kickstart repository": [
        "Veuillez sélectionner une architecture avant d'attribuer un référentiel kickstart"
      ],
      "Please select an operating system before assigning a kickstart repository": [
        "Veuillez sélectionner un système d'exploitation avant d'attribuer un référentiel kickstart"
      ],
      "Please select one from the list below and you will be redirected.": [
        "Veuillez en choisir un dans la liste ci-dessous et vous serez redirigé."
      ],
      "Please wait while the task starts..": [
        "Veuillez patienter pour le démarrage des tâches ...."
      ],
      "Please wait...": [
        "Veuillez patienter..."
      ],
      "Policy to set for mirroring content.  Must be one of %s.": [
        "Politique à définir pour le contenu de mise en miroir . Doit être un parmi %s."
      ],
      "Possible values: %s": [
        ""
      ],
      "Prefer registered through Smart Proxy for remote execution": [
        ""
      ],
      "Prefer using a Smart Proxy to which a host is registered when using remote execution": [
        ""
      ],
      "Prevent from further updates": [
        "Empêcher toute mise à jour ultérieure"
      ],
      "Prior Content View Version specified in the metadata - '%{name}' does not exist. Please import the metadata for '%{name}' before importing '%{current}' ": [
        "La version antérieure de la vue du contenu spécifiée dans les métadonnées - '%{name}' n'existe pas. Veuillez importer les métadonnées de '%{name}' avant d'importer '%{current}' "
      ],
      "Problem searching": [
        "Recherche de problèmes"
      ],
      "Problem searching errata": [
        "Problème de recherche d'errata"
      ],
      "Problem searching host collections": [
        "Problème de recherche dans les collections d'hôtes"
      ],
      "Problem searching module streams": [
        "Problème de recherche de flux de modules"
      ],
      "Problem searching packages": [
        "Problème de recherche de paquets"
      ],
      "Problem searching repository sets": [
        "Problème de recherche dans les ensembles de référentiels"
      ],
      "Problem searching traces": [
        "Problème de recherche de traces"
      ],
      "Product": [
        "Produit"
      ],
      "Product Content": [
        "Contenu du produit"
      ],
      "Product Create": [
        "Créer Produit"
      ],
      "Product Host Count": [
        ""
      ],
      "Product ID": [
        "ID Produit"
      ],
      "Product ID to mirror the remote repository to": [
        ""
      ],
      "Product and Repositories": [
        "Produit et référentiels"
      ],
      "Product architecture": [
        "Architecture du produit"
      ],
      "Product description": [
        "Description de produit"
      ],
      "Product id as listed from a host's installed products, \\\\\\n        this is not the same product id as the products api returns": [
        "L'identifiant du produit tel qu'il figure dans la liste des produits installés sur l'hôte, \\\\\\n        il ne s'agit pas du même numéro d'identification que celui des produits renvoyés par l'api"
      ],
      "Product id not found: '%s'": [
        ""
      ],
      "Product label": [
        ""
      ],
      "Product label '%s' is ambiguous. Try using an id-based container name.": [
        ""
      ],
      "Product name": [
        "Nom du produit"
      ],
      "Product name as listed from a host's installed products": [
        "Nom du produit tel qu'il figure dans la liste des produits installés sur l'hôte"
      ],
      "Product not found: '%s'": [
        ""
      ],
      "Product the repository belongs to": [
        "Produit auquel le référentiel appartient"
      ],
      "Product version": [
        "Version du produit"
      ],
      "Product with ID %s not found in Candlepin. Skipping content import for it.": [
        "Produit avec ID %s non trouvé dans Candlepin. Sauter l'importation de contenu pour ce produit."
      ],
      "Product: '%{product}', Repository: '%{repository}'": [
        "* Produit: '%%{product}', Repo: '%%{repository}'"
      ],
      "Product: '%{product}', Repository: '%{repo}' ": [
        "Produit: '%%{product}', Repo: '%%{repo}' "
      ],
      "Products": [
        "Produits"
      ],
      "Products updated.": [
        "Produits mis à jour."
      ],
      "Profiles": [
        "Profils"
      ],
      "Promote": [
        "Promouvoir"
      ],
      "Promote a content view version": [
        "Promouvoir une version de vue de contenu"
      ],
      "Promote errata": [
        "Promouvoir les errata"
      ],
      "Promote version ${versionNameToPromote}": [
        "Promouvoir la version {versionNameToPromote}"
      ],
      "Promoted to ": [
        "Promu à "
      ],
      "Promoted to %{environment}": [
        "Promu à %{environment}"
      ],
      "Promotion Summary": [
        "Résumé de la promotion"
      ],
      "Promotion Summary for %{content_view}": [
        "Résumé de la promotion pour {content_view}"
      ],
      "Promotion to Environment": [
        "Promotion à Environnement"
      ],
      "Provide the required information and click {update} below to save changes.": [
        "Fournissez les informations requises et cliquez sur {update} ci-dessous pour enregistrer les modifications."
      ],
      "Provided Products": [
        "Produits fournis"
      ],
      "Provided pool with id %s has no upstream entitlement": [
        "Un pool avec l’identification %s n'a pas de droit d’accès en amont"
      ],
      "Provisioning template IDs": [
        "IDs des modèles d'attribution"
      ],
      "Proxies": [
        "Proxies"
      ],
      "Proxy sync failure": [
        ""
      ],
      "Public": [
        "Public"
      ],
      "Public key block in DER encoding or certificate content": [
        "Bloc de clé publique dans le codage DER ou le contenu du certificat"
      ],
      "Publish": [
        "Publier"
      ],
      "Publish Lifecycle Environment Container Repositories": [
        ""
      ],
      "Publish a content view": [
        "Publier une vue de contenu"
      ],
      "Publish new version": [
        "Publier nouvelle version"
      ],
      "Publish new version - ": [
        "Nouvelle version publiée -"
      ],
      "Published date": [
        "Date de publication"
      ],
      "Published new version": [
        "Nouvelle version publiée"
      ],
      "Publishing ${truncate(name)}": [
        ""
      ],
      "Publishing content view": [
        "Publier un affichage de contenu"
      ],
      "Pulp": [
        "Pulp"
      ],
      "Pulp 3 export destination filepath": [
        "Chemin de fichier de destination d'exportation Pulp3"
      ],
      "Pulp 3 is not enabled on Smart proxy!": [
        "Pulp 3 n'est pas activé sur Smart proxy !"
      ],
      "Pulp bulk load size": [
        "Taille de la charge Pulp"
      ],
      "Pulp database connection issue at %s.": [
        "Problème de connexion de la base de données Pulp à %s."
      ],
      "Pulp database connection issue.": [
        "Problème de connexion de la base de données Pulp."
      ],
      "Pulp disk space notification": [
        "Notification de l'espace disque Pulp"
      ],
      "Pulp does not appear to be running at %s.": [
        "Pulp ne semble pas exécuter à %s."
      ],
      "Pulp does not appear to be running.": [
        "Pulp ne semble pas exécuter."
      ],
      "Pulp message bus connection issue at %s.": [
        "Problème de connexion de bus de message Pulp à %s."
      ],
      "Pulp message bus connection issue.": [
        "Problème de connexion de bus de message Pulp."
      ],
      "Pulp node": [
        "Nœud Pulp"
      ],
      "Pulp redis connection issue at %s.": [
        "Problème de la connexion redis Pulp à %s."
      ],
      "Pulp server version": [
        "Version de serveur Pulp"
      ],
      "Pulp storage": [
        "Stockage Pulp"
      ],
      "Pulp task error": [
        "Erreur de tâche pulp"
      ],
      "Python Package": [
        "Package Python"
      ],
      "Python Packages": [
        "Packages Python"
      ],
      "Python package": [
        "Package Python"
      ],
      "Python packages": [
        "Packages Python"
      ],
      "Python packages to exclude from the upstream URL, names separated by newline. You may also specify versions, for example: django~=2.0.": [
        "Packages Python à exclure depuis l'URL amont, noms séparés par une nouvelle ligne. Vous pouvez également spécifier des versions, par exemple : django~=2.0. "
      ],
      "Python packages to include from the upstream URL, names separated by newline. You may also specify versions, for example: django~=2.0. Leave empty to include every package.": [
        "Package Python à inclure depuis l'URL amont, noms séparés par une nouvelle ligne. Vous pouvez également spécifier des versions, par exemple : django~=2.0. Laissez vide pour inclure tous les packages."
      ],
      "Quantity": [
        "Quantité"
      ],
      "Quantity must not be above ${pool.available}": [
        "La quantité ne doit pas être supérieure à ${pool.available}"
      ],
      "Quantity of entitlements to bind": [
        "Quantité de droits d’accès à rattacher"
      ],
      "Quantity of specified subscription to remove": [
        "Quantité de souscriptions spécifiées à retirer"
      ],
      "Quantity of this subscription to add": [
        "Nombre de ces abonnements à ajouter."
      ],
      "Quantity of this subscriptions to add": [
        "Quantité de cet abonnement à ajouter"
      ],
      "Quantity to Allocate": [
        "Quantité à allouer"
      ],
      "RAM": [
        "RAM"
      ],
      "RAM: %s GB": [
        "RAM: %s GB"
      ],
      "RH Repos": [
        "RH Repos"
      ],
      "RHEL Lifecycle status": [
        ""
      ],
      "RHEL lifecycle": [
        ""
      ],
      "RHUI": [
        "RHUI"
      ],
      "RPM": [
        "RPM"
      ],
      "RPM Package Groups": [
        "RPM Groupes de packages"
      ],
      "RPM Packages": [
        "RPM Packages"
      ],
      "RPM name": [
        "Nom du RPM"
      ],
      "RPM package groups": [
        "Groupes de paquets RPM"
      ],
      "RPM package updates": [
        "Mises à jour des paquets RPM"
      ],
      "RPM packages": [
        "Packages RPM"
      ],
      "RPMs": [
        "RPMs"
      ],
      "Range": [
        "Gamme"
      ],
      "Realm IDs": [
        "ID des domaines"
      ],
      "Reassign affected activation key": [
        "Réassigner les clés d'activation concernées"
      ],
      "Reassign affected activation keys": [
        "Réassigner les clés d'activation concernées"
      ],
      "Reassign affected host": [
        "Réassigner les hôtes affectés"
      ],
      "Reassign affected hosts": [
        "Réassigner les hôtes affectés"
      ],
      "Reboot host": [
        ""
      ],
      "Reboot required": [
        "Redémarrage nécessaire"
      ],
      "Reclaim Space": [
        "Récupération d’espace"
      ],
      "Reclaim space from On Demand repositories": [
        "Récupérer l’espace en provenance des référentiels Sur demande"
      ],
      "Reclaim space from all On Demand repositories on a smart proxy": [
        "Récupérer l’espace de tous les référentiels Sur demande sur un proxy smart"
      ],
      "Reclaim space from an On Demand repository": [
        "Récupérer l’espace en provenance d’un référentiel Sur demande"
      ],
      "Recommended Repositories": [
        "Référentiels recommandés"
      ],
      "Red Hat": [
        ""
      ],
      "Red Hat CDN": [
        "Red Hat CDN"
      ],
      "Red Hat CDN URL": [
        "Red Hat CDN URL"
      ],
      "Red Hat Repositories": [
        "Référentiels Red Hat"
      ],
      "Red Hat Repositories page": [
        "Page Référentiels Red Hat"
      ],
      "Red Hat content will be consumed from an {type}.": [
        "Le contenu de Red Hat sera utilisé à partir de {type}."
      ],
      "Red Hat content will be consumed from the {type}.": [
        "Le contenu de Red Hat sera utilisé sur le site {type}."
      ],
      "Red Hat content will be consumed from {type}.": [
        "Le contenu de Red Hat sera utilisé à partir de {type}."
      ],
      "Red Hat content will be enabled and consumed via the {type} process.": [
        "Le contenu de Red Hat sera activé et utilisé via le processus {type}."
      ],
      "Red Hat products cannot be manipulated.": [
        "Les produits Red Hat ne peuvent pas être manipulés."
      ],
      "Red Hat provider can not be deleted": [
        "Le fournisseur Red Hat ne peut pas être supprimé"
      ],
      "Red Hat repositories cannot be manipulated.": [
        "Les référentiels Red Hat ne peuvent pas être manipulés"
      ],
      "Refresh": [
        "Réactualiser"
      ],
      "Refresh Alternate Content Source": [
        "Réactualisation de la source de contenu alternatif"
      ],
      "Refresh Content Host Statuses for %s": [
        "Rafraîchir les statuts d’hôtes de contenu pour %s"
      ],
      "Refresh Manifest": [
        "Actualiser le fichier manifeste"
      ],
      "Refresh all alternate content sources": [
        ""
      ],
      "Refresh alternate content sources": [
        "Réactualiser les sources de contenu alternatives"
      ],
      "Refresh an alternate content source. Refreshing, like repository syncing, is required before using an alternate content source.": [
        "Rafraîchir une source de contenu alternative. L'actualisation, comme la synchronisation du référentiel, est nécessaire avant d'utiliser une autre source de contenu."
      ],
      "Refresh applicability": [
        ""
      ],
      "Refresh counts": [
        ""
      ],
      "Refresh errata applicability": [
        ""
      ],
      "Refresh package applicability": [
        ""
      ],
      "Refresh previously imported manifest for Red Hat provider": [
        "Actualiser le fichier manifeste importé précédemment pour le fournisseur de Red Hat"
      ],
      "Refresh source": [
        "Source de rafraîchissement"
      ],
      "Refresh_Content_Host_Status": [
        "Refresh_Content_Host_Status"
      ],
      "Register a host with subscription and information": [
        "Inscrire un hôte avec abonnement et informations"
      ],
      "Register host '%s' before attaching subscriptions": [
        "Enregistrer les hôtes '%s' avant de joindre les abonnements"
      ],
      "Registered": [
        "Enregistré"
      ],
      "Registered at": [
        ""
      ],
      "Registered by": [
        "Enregistré par"
      ],
      "Registered on": [
        "Enregistré le"
      ],
      "Registered to": [
        ""
      ],
      "Registering to multiple environments is not enabled.": [
        ""
      ],
      "Registration details": [
        "Détails de l'inscription"
      ],
      "Registry name pattern results in duplicate container image names for these repositories: %s.": [
        "Le modèle de nom de registre donne des noms d'images de conteneurs en double pour ces référentiels : %s."
      ],
      "Registry name pattern results in invalid container image name of member repository '%{name}'": [
        "Le modèle de nom de registre donne un nom d'image de conteneur non valide du référentiel membre '%{name}'"
      ],
      "Registry name pattern will result in invalid container image name of member repositories": [
        "Le modèle de nom de registre entraînera l'invalidation du nom de l'image de conteneur des référentiels membres"
      ],
      "Related composite content views": [
        "Affichages du contenu composite associé"
      ],
      "Related composite content views: ": [
        "Affichages du contenu composite associé :"
      ],
      "Related content views": [
        "Vues du contenu associées"
      ],
      "Related content views will appear here when created.": [
        "Les affichages de contenu associés apparaîtront ici une fois créés."
      ],
      "Related content views: ": [
        "Vues de contenu associées : "
      ],
      "Release": [
        "Sortie"
      ],
      "Release version": [
        "Version de sortie"
      ],
      "Release version for this Host to use (7Server, 7.1, etc)": [
        "Version à utiliser par cet hôte (7Server, 7.1, etc.)"
      ],
      "Release version of the content host": [
        "Version de l'hôte de contenu"
      ],
      "Releasever to disable": [
        "Releasever à désactiver"
      ],
      "Releasever to enable": [
        "Releasever à activer"
      ],
      "Reload data": [
        "Recharger les données"
      ],
      "Remote execution is enabled.": [
        ""
      ],
      "Remote execution job '${description}' failed.": [
        "La tâche d'exécution à distance '${description}' a échoué."
      ],
      "Remove": [
        "Supprimer"
      ],
      "Remove Content": [
        "Supprimer le contenu"
      ],
      "Remove Version": [
        "Supprimer la version"
      ],
      "Remove Versions and Associations": [
        "Supprimer les versions et les associations"
      ],
      "Remove a content view from an environment": [
        "Supprimer un affichage de contenu à partir de l'environnement"
      ],
      "Remove any `katello-ca-consumer` rpms before registration and run subscription-manager with `--force` argument.": [
        "Supprimez tout rpms `katello-ca-consumer` avant l'enregistrement et lancez subscription-manager avec l'argument `--force`."
      ],
      "Remove components from the content view": [
        "Supprimer des éléments de la vue du contenu"
      ],
      "Remove content view version": [
        "Supprimer la version de l'affichage du contenu"
      ],
      "Remove from Environment": [
        "Supprimer les environnements"
      ],
      "Remove from environment": [
        "Supprimer de l’environnement"
      ],
      "Remove from environments": [
        "Supprimer des environnements"
      ],
      "Remove host from collections": [
        "Retirer l'hôte des collections"
      ],
      "Remove host from host collections": [
        "Supprimer un hôte des collections d'hôtes"
      ],
      "Remove hosts from the host collection": [
        "Supprimer les hôtes de la collection d'hôtes"
      ],
      "Remove lifecycle environments from the smart proxy": [
        "Supprimer les environnements de cycle de vie du proxy smart"
      ],
      "Remove module stream": [
        "Supprimer un flux de modules"
      ],
      "Remove one or more host collections from one or more hosts": [
        "Supprimer une ou plusieurs collections d'hôtes d'un ou plusieurs hôtes"
      ],
      "Remove one or more subscriptions from an upstream manifest": [
        "Supprimer un ou plusieurs abonnements d'un manifeste amont"
      ],
      "Remove package group via Katello interface": [
        "Supprimer un groupe de packages via l'interface Katello"
      ],
      "Remove package via Katello interface": [
        "Supprimer le package via l'interface Katello"
      ],
      "Remove packages": [
        ""
      ],
      "Remove packages via Katello interface": [
        "Supprimer le package via l'interface Katello"
      ],
      "Remove products from sync plan": [
        "Supprimer les produits du plan de sync"
      ],
      "Remove subscriptions": [
        "Supprimer les abonnements"
      ],
      "Remove subscriptions from %s": [
        "Supprimer les abonnements de %s"
      ],
      "Remove subscriptions from a host": [
        ""
      ],
      "Remove subscriptions from one or more hosts": [
        "Supprimer les abonnements d'un ou plusieurs hôtes"
      ],
      "Remove versions and/or environments from a content view and reassign systems and keys": [
        "Supprimer les versions et/ou les environnements de l'affichage de contenu et assigner les systèmes et les clés à nouveau"
      ],
      "Remove versions from environments": [
        "Supprimer les versions des environnements"
      ],
      "Removed component from content view": [
        "Composant supprimé de l'affichage du contenu"
      ],
      "Removed components from content view": [
        "Composants supprimés de l'affichage du contenu"
      ],
      "Removing Package Group...": [
        "Suppression du groupe de packages..."
      ],
      "Removing Package...": [
        "Suppression du package..."
      ],
      "Removing product %{prod_name} with ID %{prod_id} from ACS %{acs_name} with ID %{acs_id}": [
        "Retrait du produit %{prod_name} avec ID %{prod_id} de l'ACS %{acs_name} avec ID %.{acs_id}"
      ],
      "Removing this version from all environments will not delete the version. Version will still be available for later promotion.": [
        "Supprimer cette version de tous les environnement n’aura pas pour effet de supprimer la version. La version sera toujours disponible pour une promotion ultérieure."
      ],
      "Replace content source on the target machine": [
        ""
      ],
      "Repo ID": [
        ""
      ],
      "Repo Type": [
        "Type de référentiel"
      ],
      "Repo label": [
        ""
      ],
      "Repositories": [
        "Référentiels"
      ],
      "Repositories are not available for enablement while CDN configuration is set to Air-gapped (disconnected).": [
        "Les référentiels ne sont pas disponibles pour l'activation lorsque la configuration du CDN est définie sur Air-gapped (déconnecté)."
      ],
      "Repositories common to the selected content view versions will merge, resulting in a composite content view that is a union of all content from each of the content view versions.": [
        ""
      ],
      "Repositories from published Content Views are not allowed.": [
        "Les référentiels des affichages de contenu publiés ne sont pas autorisés."
      ],
      "Repository": [
        "Référentiel"
      ],
      "Repository %s cannot be deleted since it has already been included in a published Content View. Use repository details page to delete": [
        ""
      ],
      "Repository %s cannot be deleted since it is the last affected repository in a filter. Use repository details page to delete.": [
        ""
      ],
      "Repository %{label} failed to synchronize": [
        ""
      ],
      "Repository '%(repoName)s' has been disabled.": [
        "Le référentiel '%(repoName)s' a été désactivé"
      ],
      "Repository '%(repoName)s' has been enabled.": [
        "Le référentiel '%(repoName)s' a été activé."
      ],
      "Repository ID": [
        ""
      ],
      "Repository Id associated with the kickstart repo used for provisioning": [
        "Identifiant de référentiel associé au référentiel de démarrage kickstart utilisée pour le provisionnement"
      ],
      "Repository cannot be deleted since it has already been included in a published Content View. Please delete all Content View versions containing this repository before attempting to delete it or use --remove-from-content-view-versions flag to automatically remove the repository from all published versions.": [
        ""
      ],
      "Repository cannot be disabled since it has already been promoted.": [
        "Le référentiel ne peut pas être désactivé car il a déjà été promu."
      ],
      "Repository has already been cloned to %{cv_name} in environment %{to_env}": [
        "Le référentiel a déjà été cloné sur %{cv_name} dans l'environnement %{to_env} "
      ],
      "Repository id": [
        "Id de référentiel"
      ],
      "Repository identifier": [
        "Identifiant de référentiel"
      ],
      "Repository label '%s' is not associated with content view.": [
        "Le label de référentiel '%s' n'est pas associé à la vue du contenu."
      ],
      "Repository name": [
        ""
      ],
      "Repository name '%{container_name}' already exists in this product using a different naming scheme. Please retry your request with the %{root_repo_container_push_name} format or destroy and recreate the repository using your preferred schema.": [
        ""
      ],
      "Repository not found": [
        "Référentiel introuvable"
      ],
      "Repository path": [
        "Chemin d’accès du référentiel"
      ],
      "Repository set disabled": [
        "Ensemble de référentiels désactivé."
      ],
      "Repository set enabled": [
        "Ensemble de référentiels activé"
      ],
      "Repository set name to search on": [
        "Nom de l'ensemble du référentiel avec lequel effectuer la recherche"
      ],
      "Repository set reset to default": [
        "Ensemble de référentiels redéfinis à leur valeur par défaut"
      ],
      "Repository sets": [
        "Ensembles de référentiels"
      ],
      "Repository sets are not available for custom products.": [
        "Les ensembles de référentiels ne sont pas disponibles pour les produits personnalisés.."
      ],
      "Repository sets disabled": [
        "Ensembles de référentiels désactivés"
      ],
      "Repository sets enabled": [
        "Ensembles de référentiels activés"
      ],
      "Repository sets reset to default": [
        "Ensembles de référentiels redéfinis à leur valeur par défaut"
      ],
      "Repository sets will appear here after enabling Red Hat repositories or creating custom products.": [
        "Les ensembles de référentiels apparaîtront ici après avoir activé les référentiels Red Hat ou créé des produits personnalisés."
      ],
      "Repository sets will appear here when the host's content view and environment has available content.": [
        ""
      ],
      "Repository sync failure": [
        ""
      ],
      "Repository type": [
        ""
      ],
      "Republish Repositories of %{name} %{version}": [
        "Republier les référentiels de %{name}%{version} "
      ],
      "Republish Version Repositories": [
        "Publier de nouveau les référentiels de version"
      ],
      "Republish repository metadata": [
        ""
      ],
      "Requested access to '%s' is denied": [
        ""
      ],
      "Require you to upload the subscription-manifest and re-attach subscriptions to hosts and activation keys.": [
        "Nécessite que vous chargiez le subscription-manifest et que vous ré-attachiez les abonnements aux hôtes et aux clés d'activation."
      ],
      "Requirements is not valid yaml.": [
        "Les exigences ne sont pas valides pour yalm."
      ],
      "Requirements yaml should be a key-value pair structure.": [
        "Les exigences de yaml doivent avoir une structure de paire clé-valeur."
      ],
      "Requirements yaml should have a 'collections' key": [
        "Les exigences de yaml doivent avoir une clé 'collections'."
      ],
      "Requires Virt-Who": [
        "Nécessite Virt-Who"
      ],
      "Reset": [
        "Restauration"
      ],
      "Reset filters": [
        "Réinitialiser les filtres"
      ],
      "Reset module stream": [
        "Réinitialisation du flux de modules"
      ],
      "Reset to default": [
        "Réinitialiser"
      ],
      "Reset to the default state": [
        "Remise à l'état par défaut"
      ],
      "Resolve traces": [
        "Résoudre les traces"
      ],
      "Resolve traces for one or more hosts": [
        "Résoudre traces pour un ou plusieurs hôtes"
      ],
      "Resolve traces via Katello interface": [
        "Résoudre les traces via l'interface Katello"
      ],
      "Resource": [
        "Ressource"
      ],
      "Restart Services via Katello interface": [
        "Redémarrage des services via l'interface Katello"
      ],
      "Restart app": [
        "Redémarrer app"
      ],
      "Restart via customized remote execution": [
        "Redémarrer via exécution à distance personnalisée"
      ],
      "Restart via remote execution": [
        "Redémarrer via exécution à distante"
      ],
      "Restrict composite content view promotion": [
        "Restreindre la promotion de l’affichage de contenu composite"
      ],
      "Result": [
        "Résultat"
      ],
      "Retrieve a single errata for a host": [
        "Extraire un seul errata de l'hôte"
      ],
      "Return Red Hat (non-custom) products only": [
        "Retourne uniquement les produits Red Hat (non-personnalisés)"
      ],
      "Return a list of installed packages distinct by name": [
        ""
      ],
      "Return content that can be added to the specified object.  The values 'content_view_version' and 'content_view_filter are supported.": [
        "Retourne le contenu qui peut être ajouté à l'objet spécifié.  Les valeurs \\\"content_view_version\\\" et \\\"content_view_filter\\\" sont supportées."
      ],
      "Return custom products only": [
        "Retourner uniquement les produits personnalisés"
      ],
      "Return deb packages that are applicable to one or more hosts (defaults to true if host_id is specified)": [
        "Renvoie les packages deb qui sont applicables à un ou plusieurs hôtes (par défaut, true si host_id est spécifié)"
      ],
      "Return deb packages that are upgradable on one or more hosts": [
        "Renvoie les packages qui sont évolutifs sur un ou plusieurs hôtes"
      ],
      "Return deb packages that can be added to the specified object.  Only the value 'content_view_version' is supported.": [
        "Renvoie les packages qui peuvent être ajoutés à l'objet spécifié. Seule la valeur \\\"content_view_version\\\" est prise en charge."
      ],
      "Return enabled products only": [
        "Retourner uniquement les produits activés"
      ],
      "Return errata that are applicable to one or more hosts (defaults to true if host_id is specified)": [
        "Retourne les errata qui sont applicables à un ou plusieurs hôtes (par défaut, true si host_id est spécifié)"
      ],
      "Return errata that are applicable to this host. Defaults to false)": [
        "Renvoie les errata qui sont applicables à cet hôte. La valeur par défaut est false)"
      ],
      "Return errata that are upgradable on one or more hosts": [
        "Retourner les errata qui sont évolutifs sur un ou plusieurs hôtes"
      ],
      "Return errata that can be added to the specified object.  The values 'content_view_version' and 'content_view_filter are supported.": [
        "Retourne les errata qui peuvent être ajoutés à l'objet spécifié.  Les valeurs \\\"content_view_version\\\" et \\\"content_view_filter\\\" sont supportées."
      ],
      "Return name and stream information only)": [
        "Renvoyer le nom et les informations sur le flux uniquement)"
      ],
      "Return only errata of a particular severity (None, Low, Moderate, Important, Critical)": [
        "Retourner uniquement les errata d'une gravité particulière (Aucune, Faible, Modérée, Importante, Critique)"
      ],
      "Return only errata of a particular type (security, bugfix, enhancement)": [
        "Renvoie uniquement les errata d'un type particulier (sécurité, correction de bogues, amélioration)."
      ],
      "Return only packages of a particular status (upgradable or up-to-date)": [
        "Renvoyer uniquement les packages comportant un statut particulier (upgradable ou up-to-date)"
      ],
      "Return only subscriptions which can be attached to the upstream allocation": [
        "Ne restituer que les abonnements qui peuvent être rattachés à l'allocation en amont"
      ],
      "Return only the latest version of each package": [
        "Ne renvoyer que la dernière version de chaque package"
      ],
      "Return only the upstream pools which map to the given Katello pool IDs": [
        "Ne renvoyer que les pools en amont qui correspondent aux identifiants de pool Katello donnés"
      ],
      "Return packages that are applicable to one or more hosts (defaults to true if host_id is specified)": [
        "Retourne les packages qui sont applicables à un ou plusieurs hôtes (par défaut, true si host_id est spécifié)"
      ],
      "Return packages that are upgradable on one or more hosts": [
        "Renvoyer les packages qui sont évolutifs sur un ou plusieurs hôtes"
      ],
      "Return packages that can be added to the specified object.  Only the value 'content_view_version' is supported.": [
        "Retourner les packages qui peuvent être ajoutés à l'objet spécifié.  Seule la valeur \\\"content_view_version\\\" est prise en charge."
      ],
      "Return same, different or all results": [
        "Renvoyer les mêmes résultats, des résultats différents ou tous les résultats"
      ],
      "Return subscriptions that match installed products of the specified host": [
        "Retourne des abonnements qui correspondent aux produits installés d'un hôte donné"
      ],
      "Return subscriptions which do not overlap with a currently-attached subscription": [
        "Retourne les abonnements qui ne se superposent pas avec l'abonnement actuellement attaché."
      ],
      "Return the content of a Content Credential, used directly by yum": [
        "Renvoie le contenu des identifiants de contenu, utilisé directement par yum"
      ],
      "Return the content of a repo gpg key, used directly by yum": [
        "Renvoyer le contenu d'une clé gpg de référentiel, utilisé directement par yum"
      ],
      "Return the enabled content types": [
        "Renvoie les types de contenu activés"
      ],
      "Returns content that can be both added and is currently added to the object. The value 'content_view_filter' is supported": [
        "Renvoie le contenu qui peut être ajouté et qui est actuellement ajouté à l'objet. La valeur 'content_view_filter' est prise en charge"
      ],
      "Review": [
        ""
      ],
      "Review affected environment": [
        "Examen de l'environnement affecté"
      ],
      "Review affected environments": [
        "Examiner les environnements affectés"
      ],
      "Review and optionally exclude hosts from your selection.": [
        ""
      ],
      "Review and then click {submitBtnText}.": [
        ""
      ],
      "Review details": [
        "Détails de la revue"
      ],
      "Review hosts": [
        ""
      ],
      "Review the information below and click ": [
        "Consultez les informations ci-dessous et cliquez dessus "
      ],
      "Review your currently selected changes for ": [
        "Revoir vos changements actuellement sélectionnés pour"
      ],
      "Role": [
        "Rôle"
      ],
      "Role of host": [
        "Rôle de l'hôte"
      ],
      "Roles": [
        "Rôles"
      ],
      "Rollback image": [
        ""
      ],
      "Rollback image digest": [
        ""
      ],
      "Rules to be added": [
        "Règles à ajouter"
      ],
      "Run Sync Plan:": [
        "Exécuter Plan Sync :"
      ],
      "Run job invocation": [
        ""
      ],
      "Running": [
        "Exécution en cours"
      ],
      "Running image": [
        ""
      ],
      "Running image digest": [
        ""
      ],
      "SKU": [
        "SKU"
      ],
      "SLA": [
        "SLA"
      ],
      "SRPM details": [
        "Détails SRPM"
      ],
      "SSL CA Content Credential": [
        "Identifiants de contenu CA SSL"
      ],
      "SSL CA certificate": [
        "Certificat SSL CA"
      ],
      "SSL client certificate": [
        "Certificat client SSL"
      ],
      "SSL client key": [
        "Clé du client SSL"
      ],
      "SUBSCRIPTIONS EXPIRING SOON": [
        "ABONNEMENTS EXPIRANT BIENTÔT"
      ],
      "Save": [
        "Enregistrer"
      ],
      "Saving alternate content source...": [
        "Mise à jour de la source de contenu alternatif..."
      ],
      "Scan a flatpak remote": [
        ""
      ],
      "Schema version 1": [
        ""
      ],
      "Schema version 2": [
        ""
      ],
      "Search": [
        "Recherche"
      ],
      "Search Query": [
        "Requête de recherche"
      ],
      "Search available Debian packages": [
        ""
      ],
      "Search available packages": [
        "Rechercher les paquets disponibles"
      ],
      "Search host collections": [
        "Recherche de collections d'hôtes"
      ],
      "Search pattern (defaults to '*')": [
        "Modèle de recherche (par défaut : '*')"
      ],
      "Search string": [
        "Rechercher une chaîne"
      ],
      "Search string for erratum to perform an action on": [
        "Rechercher une chaîne pour qu’erratum puisse effectuer une action dessus"
      ],
      "Search string for host to perform an action on": [
        "Rechercher une chaîne pour que l’hôte puisse effectuer une action dessus"
      ],
      "Search string for hosts to perform an action on": [
        "Rechercher une chaîne pour que les hôtes puissent effectuer une action dessus"
      ],
      "Search string for versions to perform an action on": [
        "Chaîne de recherche des versions sur lesquelles effectuer une action"
      ],
      "Security": [
        "Sécurité"
      ],
      "Security errata applicable": [
        "Errata de sécurité applicable"
      ],
      "Security errata installable": [
        "Errata de sécurité installable"
      ],
      "Select": [
        "Sélectionner"
      ],
      "Select ...": [
        "Sélectionner ..."
      ],
      "Select All": [
        "Tout sélectionner"
      ],
      "Select Content View": [
        "Sélectionner l'affichage de contenu"
      ],
      "Select None": [
        "Ne rien sélectionner"
      ],
      "Select Organization": [
        "Choisir une organisation"
      ],
      "Select Value": [
        "Sélectionnez une valeur"
      ],
      "Select a CA certificate": [
        "Sélectionnez un certificat CA"
      ],
      "Select a client certificate": [
        "Sélectionnez un certificat client"
      ],
      "Select a client key": [
        "Sélectionnez une clé client"
      ],
      "Select a content source first": [
        ""
      ],
      "Select a content view": [
        "Sélectionner un affichage de contenu"
      ],
      "Select a lifecycle environment and a content view to move these hosts.": [
        "Sélectionnez un environnement de cycle de vie et une vue de contenu pour déplacer ces hôtes."
      ],
      "Select a lifecycle environment and a content view to move this host.": [
        "Sélectionnez un environnement de cycle de vie et une vue de contenu pour déplacer cet hôte."
      ],
      "Select a lifecycle environment first": [
        ""
      ],
      "Select a lifecycle environment from the available promotion paths to promote new version.": [
        "Sélectionnez un environnement de cycle de vie parmi les chemins de promotion disponibles pour promouvoir la nouvelle version."
      ],
      "Select a provider to install katello-host-tools-tracer": [
        "Sélectionner un fournisseur pour installer katello-host-tools-tracer"
      ],
      "Select a source": [
        ""
      ],
      "Select action": [
        ""
      ],
      "Select all": [
        "Tout sélectionner"
      ],
      "Select all rows": [
        "Sélectionnez toutes les lignes"
      ],
      "Select an Organization": [
        "Sélectionner une organisation"
      ],
      "Select an environment": [
        "Sélectionnez un environnement"
      ],
      "Select an option": [
        "Sélectionnez une option"
      ],
      "Select an organization": [
        "Sélectionner une organisation"
      ],
      "Select at least one erratum.": [
        ""
      ],
      "Select at least one package.": [
        ""
      ],
      "Select attributes for ${akDetails.name}": [
        ""
      ],
      "Select available version of ${truncate(cvName)} to use": [
        ""
      ],
      "Select available version of content views to use": [
        "Sélectionnez la version disponible des vues de contenu à utiliser"
      ],
      "Select content view": [
        "Sélectionner l'affichage de contenu"
      ],
      "Select environment": [
        "Choisir l'environnement"
      ],
      "Select errata": [
        ""
      ],
      "Select errata to apply on the selected hosts. Some errata may already be applied on some hosts.": [
        ""
      ],
      "Select host collection(s) to associate with host {hostName}.": [
        "Sélectionnez la ou les collections d'hôtes à associer à l'hôte {hostName}."
      ],
      "Select host collection(s) to remove from host {hostName}.": [
        "Sélectionnez la ou les collections d'hôtes à supprimer de l'hôte {hostName}."
      ],
      "Select hosts to assign to %s": [
        "Sélectionner les hôtes à assigner à %s"
      ],
      "Select lifecycle environment": [
        "Sélectionner un environnement de cycle de vie"
      ],
      "Select none": [
        "Ne rien sélectionner"
      ],
      "Select one": [
        "Sélectionnez-en un"
      ],
      "Select packages to install on the selected hosts. Some packages may already be installed on some hosts.": [
        ""
      ],
      "Select packages to install to the host {hostName}.": [
        "Sélectionnez les paquets à installer sur l'hôte {hostName}."
      ],
      "Select packages to remove on the selected hosts.": [
        ""
      ],
      "Select packages to upgrade to the latest version. Packages may have different versions on different hosts.": [
        ""
      ],
      "Select page": [
        "Sélectionner page"
      ],
      "Select products": [
        "Sélectionnez les produits"
      ],
      "Select products to associate to this source.": [
        "Sélectionnez les produits à associer à cette source."
      ],
      "Select row": [
        "Sélectionner une ligne"
      ],
      "Select smart proxies to be used with this source.": [
        "Sélectionnez les proxies smart à utiliser avec cette source."
      ],
      "Select smart proxy": [
        "Sélectionner les Smart Proxies"
      ],
      "Select source type": [
        "Sélectionner le type de source"
      ],
      "Select system purpose attributes for activation key {name}.": [
        ""
      ],
      "Select system purpose attributes for host {name}.": [
        ""
      ],
      "Select the installation media that will be used to provision this host. Choose 'Synced Content' for Synced Kickstart Repositories or 'All Media' for other media.": [
        "Sélectionnez le support d'installation qui sera utilisé pour fournir cet hôte. Choisissez \\\"Contenu synchronisé\\\" pour les référentiels de démarrage synchronisés ou \\\"Tous les médias\\\" pour les autres médias."
      ],
      "Selected environment ": [
        "Environnement sélectionné"
      ],
      "Selected environments ": [
        "Environnements sélectionnés"
      ],
      "Selected errata will be applied on {hostCount} hosts": [
        ""
      ],
      "Selected packages will be {submitAction} on {hostCount} hosts": [
        ""
      ],
      "Sending a list of included IDs is not allowed when all items are being selected.": [
        "L'envoi d'une liste d'identifiants inclus n'est pas autorisé lorsque tous les éléments sont sélectionnés."
      ],
      "Service Level %s": [
        "Niveau de service %s"
      ],
      "Service Level (SLA)": [
        "Niveau de service (SLA)"
      ],
      "Service level of host": [
        "Niveau de service (SLA) de l’hôte"
      ],
      "Service level to be used for autoheal": [
        "Niveau de service à utiliser pour la vérification automatique autoheal"
      ],
      "Set content overrides for the host": [
        "Définir les priorités de contenu pour l'hôte"
      ],
      "Set content overrides to one or more hosts": [
        "Définir des priorités de contenu pour un ou plusieurs hôtes"
      ],
      "Set this HTTP proxy as the default content HTTP proxy": [
        ""
      ],
      "Set true to override to enabled; Set false to override to disabled.'": [
        "Définissez true pour passer en mode activé ; définissez false pour passer en mode désactivé."
      ],
      "Set true to remove an override and reset it to 'default'": [
        "Régler sur true pour supprimer une dérogation et la remettre sur \\\"default\\\""
      ],
      "Sets the system purpose usage": [
        "Définir l'utilisation de l'objectif du système"
      ],
      "Sets whether the Host will autoheal subscriptions upon checkin": [
        "Permet de déterminer si l'hôte doit procéder à la vérification automatique des abonnements lors de l'enregistrement"
      ],
      "Setting 'default_location_subscribed_hosts' is not set to a valid location.": [
        "Le paramètre \\\"default_location_subscribed_hosts\\\" n'est pas défini sur un emplacement valide."
      ],
      "Severity": [
        "Sévérité"
      ],
      "Severity must be one of: %s": [
        "Une sévérité doit être choisie parmi %s."
      ],
      "Show %s": [
        "Afficher %s"
      ],
      "Show :a_resource": [
        "Afficher : a_resource"
      ],
      "Show a Content Credential": [
        "Montrer un identifiant de contenu"
      ],
      "Show a content view": [
        "Afficher un affichage de contenu"
      ],
      "Show a content view component": [
        "Afficher un composant d'affichage de contenu"
      ],
      "Show a content view's history": [
        "Afficher un historique d'affichage de contenu"
      ],
      "Show a flatpak remote": [
        ""
      ],
      "Show a flatpak remote repository": [
        ""
      ],
      "Show a host collection": [
        "Afficher une collection d'hôte"
      ],
      "Show a product": [
        "Afficher un produit"
      ],
      "Show a repository": [
        "Afficher un référentiel"
      ],
      "Show a subscription": [
        "Afficher un abonnement"
      ],
      "Show a sync plan": [
        "Afficher un plan sync"
      ],
      "Show affected activation keys": [
        "Afficher les clés d'activation concernées"
      ],
      "Show affected hosts": [
        "Afficher les hôtes affectés"
      ],
      "Show all": [
        "Tout afficher"
      ],
      "Show all repository sets": [
        ""
      ],
      "Show an activation key": [
        "Afficher une clé d'activation"
      ],
      "Show an alternate content source.": [
        "Afficher une autre source de contenu"
      ],
      "Show an environment": [
        "Afficher un environnement"
      ],
      "Show content available for an activation key": [
        "Afficher le contenu disponible pour une clé d'activation"
      ],
      "Show content view version": [
        "Afficher la version de l'affichage de contenu"
      ],
      "Show filter rule info": [
        "Afficher les informations de règle de filtre"
      ],
      "Show full description": [
        "Afficher Description complète"
      ],
      "Show hosts associated to an activation key": [
        ""
      ],
      "Show organization": [
        "Afficher l'organisation"
      ],
      "Show release versions available for an activation key": [
        "Afficher les versions disponibles pour une clé d'activation"
      ],
      "Show releases available for the content host": [
        "Afficher les versions disponibles pour l'hôte de contenu"
      ],
      "Show repositories": [
        ""
      ],
      "Show repositories enabled on the host that are known to Katello": [
        "Afficher les référentiels activés sur l'hôte qui sont connus de Katello."
      ],
      "Show the available repository types": [
        "Affiche les types de référentiels disponibles"
      ],
      "Show whether each lifecycle environment is associated with the given Smart Proxy id.": [
        ""
      ],
      "Shows status of Katello system and it's subcomponents": [
        "Afficher le statut du système Katello et ses sous-composants"
      ],
      "Shows version information": [
        "Afficher les informations de la version"
      ],
      "Simple Content Access has been disabled for '%{subject}'.": [
        "L'accès au contenu simple a été désactivé pour '%{subject}'."
      ],
      "Simple Content Access has been enabled for '%{subject}'.": [
        "L'accès au contenu simple a été activé pour '%{subject}'."
      ],
      "Simple Content Access is the only supported content access mode": [
        ""
      ],
      "Simplified": [
        "Simplifié"
      ],
      "Single content view consisting of e.g. repositories": [
        "Vue de contenu unique composée de référentiels par ex."
      ],
      "Size of file to upload": [
        "Taille du fichier à télécharger"
      ],
      "Skip metadata check on each repository on the smart proxy": [
        "Sauter la vérification des métadonnées de chaque référentiel sur le proxy smart"
      ],
      "Skipped pulp_auth check after failed pulp check": [
        "Vérification pulp_auth ignorée après échec de la vérification Pulp"
      ],
      "Smart proxies": [
        "Smart Proxies"
      ],
      "Smart proxy ID": [
        ""
      ],
      "Smart proxy IDs": [
        "IDs des smart proxies"
      ],
      "Smart proxy content count refresh has started in the background": [
        ""
      ],
      "Smart proxy content source not found!": [
        "La source de contenu du smart proxy n'a pas été trouvée !"
      ],
      "Smart proxy name": [
        ""
      ],
      "Sockets": [
        "Sockets"
      ],
      "Sockets: %s": [
        "Sockets: %s"
      ],
      "Solution": [
        "Solution"
      ],
      "Solve RPM dependencies by default on Content View publish, defaults to false": [
        "Résoudre les dépendances RPM par défaut sur Content View publish, les valeurs par défaut sont false"
      ],
      "Solve dependencies": [
        "Résoudre les dépendances"
      ],
      "Some environments are disabled because they are not associated with the host's content source.": [
        ""
      ],
      "Some environments are disabled because they are not associated with the selected content source.": [
        ""
      ],
      "Some hosts are not registered as content hosts and will be ignored.": [
        "Les hôtes suivants ne sont pas enregistrés comme hôtes de contenu, ils seront donc ignorés :"
      ],
      "Some of your inputs contain errors. Please update them and save your changes again.": [
        "Certaines de vos entrées contiennent des erreurs. Veuillez les mettre à jour et enregistrer à nouveau vos modifications."
      ],
      "Some services are not properly started. See the About page for more information.": [
        "Certains services ne sont pas correctement démarrés. Consultez la page d’accueil pour plus d'informations."
      ],
      "Something went wrong while adding a bookmark: ${getBookmarkErrorMsgs(error.response)}": [
        "Un problème est survenu lors de l'ajout du signet : {getBookmarkErrorMsgs(error.response)} (error.response)}"
      ],
      "Something went wrong while adding a filter rule! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de l'ajout d’une règle de filtre ! {getResponseErrorMsgs(error.response)} (error.response)}"
      ],
      "Something went wrong while adding component! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de l'ajout du composant ! {getResponseErrorMsgs(error.response)} (error.response)}"
      ],
      "Something went wrong while adding filter rules! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de l'ajout des règles de filtres! {getResponseErrorMsgs(error.response)} (error.response)}"
      ],
      "Something went wrong while creating the filter! ${getResponseErrorMsgs(error.response)}": [
        "Quelque chose s'est mal passé lors de la création du filtre !{getResponseErrorMsgs(error.response)} (error.response)}"
      ],
      "Something went wrong while deleting alternate content sources: ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la suppression des sources de contenu alternatives : ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while deleting filter rules! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la suppression des règles de filtres ! {getResponseErrorMsgs(error.response)}(error.response)}"
      ],
      "Something went wrong while deleting filters! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la suppression des versions ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while deleting this filter! ${getResponseErrorMsgs(error.response)}": [
        "Quelque chose s'est mal passé lors de la suppression de ce filtre ! {getResponseErrorMsgs(error.response)}(error.response)}"
      ],
      "Something went wrong while deleting versions ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la suppression des versions ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while editing a filter rule! ${getResponseErrorMsgs(error.response)}": [
        "Quelque chose s'est mal passé lors de la modification de ce filtre ! {getResponseErrorMsgs(error.response)}(error.response)}"
      ],
      "Something went wrong while editing the filter! ${getResponseErrorMsgs(error.response)}": [
        "Quelque chose s'est mal passé lors de la création du filtre !{getResponseErrorMsgs(error.response)} (error.response)}"
      ],
      "Something went wrong while editing version details. ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la modification des détails de la version ! {getResponseErrorMsgs(error.response)}(error.response)}"
      ],
      "Something went wrong while fetching ${lowerCase(pluralLabel)}! ${getResponseErrorMsgs(error.response)}": [
        "Une erreur s'est produite lors de la sélection des hôtes - {lowerCase(pluralLabel)}"
      ],
      "Something went wrong while fetching files! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de l’extraction des filtres ! {getResponseErrorMsgs(error.response)}(error.response)}"
      ],
      "Something went wrong while fetching rpm packages! ${getResponseErrorMsgs(error.response)}": [
        "Une erreur est survenue lors de l’extraction des packages rpm {getResponseErrorMsgs(error.response)}(error.response)}"
      ],
      "Something went wrong while getting container manifest lists! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while getting container tags! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de l’obtention des balises docker ! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while getting deb packages! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de l’extraction des packages deb ! {getResponseErrorMsgs(error.response)}(error.response)}"
      ],
      "Something went wrong while getting errata! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de l’apparition des errata ! {getResponseErrorMsgs(error.response)}(error.response)}"
      ],
      "Something went wrong while getting module streams! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de l’obtention des flux de modules ! {getResponseErrorMsgs(error.response)}(error.response)}"
      ],
      "Something went wrong while getting repositories! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de l’extraction des référentiels ! {getResponseErrorMsgs(error.response)}(error.response)}"
      ],
      "Something went wrong while getting the data. See the logs for more information": [
        "Un problème est survenu lors de l'obtention des données. Voir les journaux pour plus d'informations"
      ],
      "Something went wrong while getting version details. ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de l’affichage des détails de la version ! {getResponseErrorMsgs(error.response)}(error.response)}"
      ],
      "Something went wrong while loading the Smart Proxy. See the logs for more information": [
        "Un problème est survenu lors du chargement du Smart Proxy. Voir les logs pour plus d'informations"
      ],
      "Something went wrong while loading the content views. See the logs for more information": [
        "Un problème est survenu lors du chargement des vues de contenu. Voir les journaux pour plus d'informations"
      ],
      "Something went wrong while refreshing alternate content sources: ": [
        "Un problème est survenu lors du rafraîchissement des sources de contenu alternatives : "
      ],
      "Something went wrong while refreshing content counts: ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while removing a filter rule! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la suppression d’une règle de filtre ! {getResponseErrorMsgs(error.response)} (error.response)}"
      ],
      "Something went wrong while removing component! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la suppression du composant ! {getResponseErrorMsgs(error.response)} (error.response)}"
      ],
      "Something went wrong while retrieving package groups! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération des groupes de référentiel ! {getResponseErrorMsgs(error.response)}(error.response)}"
      ],
      "Something went wrong while retrieving the activation keys! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération des clés d’activation ! {getResponseErrorMsgs(error.response)}(error.response)}"
      ],
      "Something went wrong while retrieving the container tags! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération des étiquettes de conteneur ! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the content view components! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération de l’historique de l’affichage du contenu ! {getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the content view filter rules! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération du filtre d'affichage du contenu ! {getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the content view filter! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération du filtre d'affichage du contenu ! {getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the content view filters! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération des filtres d'affichage du contenu ! {getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the content view history! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération de l’historique de l’affichage du contenu ! {getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the content view versions! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération de l’historique de l’affichage du contenu ! {getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the content! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération du contenu ! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the deb packages! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération des paquets deb ! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the errata! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération de l'errata ! {getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the files! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération des fichiers ! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the hosts! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération des hôtes ! {getResponseErrorMsgs(error.response)}(error.response)}"
      ],
      "Something went wrong while retrieving the module streams! ${getResponseErrorMsgs(error.response)}": [
        "Quelque chose s'est mal passé lors de la récupération des flux du module ! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the package groups! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération des groupes de paquets ! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the packages! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération des paquets ! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the repositories! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération des référentiels ! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the repository types! ${getResponseErrorMsgs(error.response)}": [
        "Un problème est survenu lors de la récupération des types de référentiel ! {getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while updating the content source. See the logs for more information": [
        "Un problème est survenu lors de la mise à jour de la source de contenu. Voir les journaux pour plus d'informations"
      ],
      "Something went wrong! Please check server logs!": [
        "Une erreur est survenue ! Veuillez vérifier la journalisation du serveur !"
      ],
      "Sort field and order, eg. 'id DESC'": [
        "Modifier champ et sens de tri, ex: 'id DESC'"
      ],
      "Source RPM": [
        "RPM source"
      ],
      "Source RPMs": [
        "RPM source"
      ],
      "Source type": [
        "Type de source"
      ],
      "Specify an export chunk size less than 1_000_000 GB": [
        "Spécifiez une taille de bloc d'exportation inférieure à 1_000_000 Go"
      ],
      "Specify the list of units in each repo": [
        "Préciser la liste des unités de chaque référentiel"
      ],
      "Split the exported content into archives no greater than the specified size in gigabytes.": [
        "Divisez le contenu exporté en archives ne dépassant pas la taille spécifiée en giga-octets."
      ],
      "Stacking ID": [
        "Empilage des ID"
      ],
      "Staged image": [
        ""
      ],
      "Staged image digest": [
        ""
      ],
      "Start Date": [
        "Date de départ"
      ],
      "Start Date and Time can't be blank": [
        "La date de lancement et l'heure ne peuvent pas être vides"
      ],
      "Start Time": [
        "Date de lancement"
      ],
      "Start date": [
        "Date de départ"
      ],
      "Starts": [
        "Démarrage"
      ],
      "State": [
        "État"
      ],
      "Status": [
        "Statut"
      ],
      "Status must be one of: %s": [
        "La valeur doit être choisie parmi %s."
      ],
      "Storage": [
        "Stockage"
      ],
      "Stream": [
        "Flux"
      ],
      "Streamed": [
        "Streaming"
      ],
      "Streams based on the host based on the installation status": [
        "Flux basés sur l'hôte en fonction de l'état de l'installation"
      ],
      "Streams based on the host based on their status": [
        "Les flux basés sur l'hôte en fonction de leur statut"
      ],
      "Submit": [
        "Envoyer"
      ],
      "Subnet IDs": [
        "IDs des sous-réseaux"
      ],
      "Subpaths": [
        "Sous-chemins"
      ],
      "Subscription": [
        "Abonnement"
      ],
      "Subscription Details": [
        "Détails de l’abonnement"
      ],
      "Subscription ID": [
        "ID d'abonnement"
      ],
      "Subscription Info": [
        "Info de l'abonnement"
      ],
      "Subscription Manifest": [
        "Manifeste d'abonnement"
      ],
      "Subscription Manifest expiration date check": [
        ""
      ],
      "Subscription Manifest validity check": [
        "Contrôle de la validité du manifeste abonnement"
      ],
      "Subscription Name": [
        "Nom de l’abonnement"
      ],
      "Subscription Pool id": [
        "ID Pool Abonnement"
      ],
      "Subscription Pool uuid": [
        "Uuid de pool d'abonnement"
      ],
      "Subscription UUID": [
        "UUID de l’abonnement"
      ],
      "Subscription connection enabled": [
        "Connexion de l'abonnement activée"
      ],
      "Subscription expiration notification": [
        "Avis d'expiration de l'abonnement"
      ],
      "Subscription id is nil.": [
        "Id d'abonnement nul."
      ],
      "Subscription identifier": [
        "Identifiant d'abonnement"
      ],
      "Subscription manager name registration fact": [
        "Fait concernant l'enregistrement du nom du gestionnaire d'abonnement"
      ],
      "Subscription manager name registration fact strict matching": [
        "Gestionnaire d'abonnement - enregistrement du nom - correspondance stricte"
      ],
      "Subscription manifest file": [
        "Fichier manifeste d'abonnement"
      ],
      "Subscription not found": [
        "Abonnement non trouvé"
      ],
      "Subscription was not persisted - %{error_message}": [
        "L'abonnement n'a pas été maintenu - %{error_message}"
      ],
      "Subscriptions": [
        "Abonnements"
      ],
      "Subscriptions expiring soon": [
        "Abonnements expirant sous peu"
      ],
      "Subscriptions have been saved and are being updated. ": [
        "Les abonnements ont été enregistrés et sont en cours d'actualisation. "
      ],
      "Subscriptions service": [
        "Service d'abonnements"
      ],
      "Substitution Mismatch. Unable to update for content: (%{content}). From [%{content_url}] To [%{new_url}].": [
        "Discordance de substitution. Impossible de mettre à jour le contenu : (%{content}). De [%{content_url} ] à [{new_url}]."
      ],
      "Success": [
        "Réussi"
      ],
      "Successfully added %s Host(s).": [
        "%s Hôte(s) ajoutés."
      ],
      "Successfully added %{count} content host(s) to host collection %{host_collection}.": [
        "%{count} hôte(s) de contenu a/ont été ajouté(s) à la collection d'hôtes %{host_collection}."
      ],
      "Successfully changed sync plan for %s product(s)": [
        "Le plan de sync de %s produit(s) a été modifié avec succès"
      ],
      "Successfully initiated removal of %s product(s)": [
        "La suppression de %s produit(s) a été initiée avec succès"
      ],
      "Successfully refreshed.": [
        "Actualisation réussie."
      ],
      "Successfully removed %s Host(s).": [
        "%s Hôte(s) supprimés."
      ],
      "Successfully removed %{count} content host(s) from host collection %{host_collection}.": [
        "%{count}hôte(s) de contenu a/ont été supprimé(s) de la collection d'hôtes %{host_collection}."
      ],
      "Successfully synced capsule.": [
        "La capsule a été synchronisée avec succès."
      ],
      "Successfully synchronized.": [
        "Synchronisation réussie."
      ],
      "Summary": [
        "Résumé"
      ],
      "Support Type": [
        "Type de pris en charge"
      ],
      "Support ended": [
        ""
      ],
      "Supported Content Types": [
        "Types de contenu pris en charge"
      ],
      "Sync Canceled": [
        "Sync Annulée"
      ],
      "Sync Connect Timeout": [
        "Sync Connect Timeout"
      ],
      "Sync Content View on Smart Proxy(ies)": [
        "Sync de la vue du contenu sur le(s) proxy(s) smart"
      ],
      "Sync Incomplete": [
        "Sync incomplète"
      ],
      "Sync Overview": [
        "Vue d'ensemble de la sync"
      ],
      "Sync Plan": [
        "Plan de Sync"
      ],
      "Sync Plan: ": [
        "Plan de Sync : "
      ],
      "Sync Plans": [
        "Plans de sync"
      ],
      "Sync Repository on Smart Proxy(ies)": [
        "Sync Référentiel sur le(s) proxy(s) smart"
      ],
      "Sync Smart Proxies after content view promotion": [
        "Sync Proxies Smart après la promotion de l’affichage de contenu"
      ],
      "Sync Sock Connect Timeout": [
        "Sync Sock Connect Timeout"
      ],
      "Sync Sock Read Timeout": [
        "Sync Sock Read Timeout"
      ],
      "Sync Status": [
        "Sync Statut"
      ],
      "Sync Summary": [
        "Sync Résumé"
      ],
      "Sync Summary for %s": [
        "Sync Résumé pour %s"
      ],
      "Sync Total Timeout": [
        "Sync Total Timeout"
      ],
      "Sync a repository": [
        "Synchroniser un référentiel"
      ],
      "Sync all repositories for a product": [
        "Synchroniser tous les référentiels d'un produit"
      ],
      "Sync complete.": [
        "Sync Terminée."
      ],
      "Sync errata": [
        "Sync errata"
      ],
      "Sync one or more products": [
        "Sync un ou plusieurs produits"
      ],
      "Sync plan identifier to attach": [
        "Sync les identifiants de plan à attacher"
      ],
      "Sync smart proxy content directly from upstream repositories by selecting the desired products.": [
        "Synchronisez le contenu du proxy smart directement à partir des référentiels en amont en sélectionnant les produits souhaités."
      ],
      "Sync state": [
        "État de synchronisation"
      ],
      "Synced": [
        ""
      ],
      "Synced ": [
        "Synchronisé "
      ],
      "Synced Content": [
        "Contenu synchronisé"
      ],
      "Synchronize": [
        "Synchroniser"
      ],
      "Synchronize Now": [
        "Sync Maintenant"
      ],
      "Synchronize repository": [
        "Synchroniser les référentiels"
      ],
      "Synchronize smart proxy": [
        "Synchroniser le smart proxy"
      ],
      "Synchronize the content to the smart proxy": [
        "Synchroniser le contenu du proxy smart"
      ],
      "Synchronize: Skip Metadata Check": [
        "Synchroniser : Sauter la vérification des métadonnées"
      ],
      "Synchronize: Validate Content": [
        "Synchroniser : Valider le contenu"
      ],
      "Syncing Complete.": [
        "Sync complète."
      ],
      "Synopsis": [
        "Synopsis"
      ],
      "System Purpose": [
        "Objectif system"
      ],
      "System Status": [
        "Statut du système"
      ],
      "System purpose": [
        "Objectif system"
      ],
      "System purpose attributes updated": [
        "Mise à jour des attributs system purpose"
      ],
      "System purpose enables you to set the system's intended use on your network and improves reporting accuracy in the Subscriptions service of the Red Hat Hybrid Cloud Console.": [
        ""
      ],
      "Tag name": [
        "Nom de la balise"
      ],
      "Tags": [
        "Balises"
      ],
      "Task": [
        "Tâche"
      ],
      "Task ${task.humanized.action} completed with a result of ${task.result}. ${task.errors ? getErrors(task) : ''}": [
        "La tâche ${task.humanized.action} s'est achevée avec un résultat de ${task.result}.{task.errors ? getErrors(task) : ''}"
      ],
      "Task ${task.humanized.action} has started.": [
        "La tâche ${task.humanized.action} a commencé."
      ],
      "Task ID": [
        ""
      ],
      "Task canceled": [
        "Tâche annulée"
      ],
      "Task detail": [
        "Détails de la tâche"
      ],
      "Task details": [
        ""
      ],
      "Task result": [
        ""
      ],
      "Task state": [
        ""
      ],
      "Temporary": [
        "Temporaire"
      ],
      "The '%s' environment cannot contain a changeset!": [
        "L'environnement '%s' ne doit pas contenir de changeset !"
      ],
      "The Alternate Content Source type": [
        "Le type de source de contenu alternatif"
      ],
      "The Foreman Client repository is available in the host's content view environment(s). ": [
        ""
      ],
      "The Foreman Client repository is enabled. ": [
        ""
      ],
      "The Foreman Client repository is synced. ": [
        ""
      ],
      "The Foreman Client repository set is enabled for the host. ": [
        ""
      ],
      "The URL to receive a session token from, e.g. used with Automation Hub.": [
        "L'URL à partir de laquelle recevoir un jeton de session, par exemple utilisé avec Automation Hub."
      ],
      "The action requested on this composite view cannot be performed until all of the component content view versions have been promoted to the target environment: %{env}.  This restriction is optional and can be modified in the Administrator -> Settings -> Content page using the restrict_composite_view flag.": [
        "Impossible d’effectuer l’action demandée sur cette vue composite tant que toutes les versions d’affichage du contenu du composant ont été promues à l’environnement cible : %{env}. Cette restriction est facultative et peut être modifiée dans la page Administrateur-> Paramètres de configuration, en utilisant la balise restrict_composite_view."
      ],
      "The actual file contents": [
        "Le contenu du fichier"
      ],
      "The amount of latest versions of a package to keep on sync, includes pre-releases if synced. Default 0 keeps all versions.": [
        ""
      ],
      "The content type for the Alternate Content Source": [
        "Le type de contenu de la source de contenu alternatif"
      ],
      "The current organization cannot be deleted. Please switch to a different organization before deleting.": [
        "L'organisation actuelle ne peut pas être supprimée. Veuillez basculer sur une différente organisation avant d'effectuer la suppression."
      ],
      "The default content view cannot be edited, published, or deleted.": [
        "L'affichage de contenu par défaut ne peut pas être modifié, publié ou supprimé."
      ],
      "The default content view cannot be promoted": [
        "L'affichage de contenu par défaut ne peut pas être promu"
      ],
      "The description for the content view version": [
        "Description de la version d'affichage du contenu"
      ],
      "The description for the content view version promotion": [
        "Description de la promotion de la version d'affichage de contenu"
      ],
      "The description for the new generated Content View Versions": [
        "Description pour les nouvelles Versions d'affichage de contenu générées"
      ],
      "The email notification will include subscriptions expiring in this number of days or fewer.": [
        "La notification par courriel comprendra les abonnements qui expirent dans ce nombre de jours ou avant."
      ],
      "The erratum filter rule end date is in an invalid format or type.": [
        "La date de fin de la règle du filtre de l'erratum est un type ou un format non valide."
      ],
      "The erratum filter rule start date is in an invalid format or type.": [
        "La date de début de la règle du filtre de l'erratum est un type ou un format non valide."
      ],
      "The erratum type must be an array. Invalid value provided": [
        "Le type d'erratum doit être une matrice. Valeur non valide fournie"
      ],
      "The field to sort the data by. Defaults to the created date.": [
        "Le champ permettant de trier les données. Par défaut, la date de création."
      ],
      "The following hosts have errata that apply to them: ": [
        "Les hôtes suivants contiennent des errata à appliquer :"
      ],
      "The following repositories provided in the import metadata have an incorrect content type or provider type. Make sure the export and import repositories are of the same type before importing\\n %{repos}": [
        "Les référentiels suivants fournis dans les métadonnées d'importation ont un type de contenu ou un type de fournisseur incorrect. Assurez-vous que les référentiels d'exportation et d'importation sont du même type avant de procéder à l'importation de\\n %{repos}"
      ],
      "The id of the content source": [
        "L'identifiant de la source de contenu"
      ],
      "The id of the content view": [
        "L'identifiant de la vue du contenu"
      ],
      "The id of the host to alter": [
        "L'id de l'hôte à modifier"
      ],
      "The id of the lifecycle environment": [
        "Id de l'environnement du cycle de vie"
      ],
      "The ids of the hosts to alter. Hosts not managed by Katello are ignored": [
        "Les identifiants des hôtes à modifier. Les hôtes non gérés par Katello sont ignorés."
      ],
      "The list of environments to promote the specified Content View Version to (replacing the older version)": [
        "La liste des environnements vers lesquels promouvoir la version d'affichage de contenu spécifiée (en remplacement de l'ancienne version)."
      ],
      "The manifest doesn't exist on console.redhat.com. Please create and import a new manifest.": [
        "Le manifeste n'existe pas sur console.redhat.com. Veuillez créer et importer un nouveau manifeste."
      ],
      "The manifest imported within Organization %{subject} is no longer valid. Please import a new manifest.": [
        "Le manifeste importé au sein de l’ Organisation %{subject} n'est plus valable. Veuillez importer un nouveau manifeste."
      ],
      "The maximum number of second that Pulp can take to do a single sync operation, e.g., download a single metadata file.": [
        "Le nombre maximum de secondes que Pulp peut prendre pour effectuer une seule opération de synchronisation, par exemple, télécharger un seul fichier de métadonnées."
      ],
      "The maximum number of seconds for Pulp to connect to a peer for a new connection not given from a pool.": [
        "Le nombre maximum de secondes pour que Pulp se connecte à un pair pour une nouvelle connexion non donnée à partir d'un pool."
      ],
      "The maximum number of seconds for Pulp to establish a new connection or for waiting for a free connection from a pool if pool connection limits are exceeded.": [
        "Le nombre maximum de secondes pour que Pulp établisse une nouvelle connexion ou pour attendre une connexion libre d'un pool si les limites de connexion du pool sont dépassées."
      ],
      "The maximum number of seconds that Pulp can take to download a file, not counting connection time.": [
        "Le nombre maximum de secondes que Pulp peut prendre pour télécharger un fichier, sans compter le temps de connexion."
      ],
      "The maximum number of versions of each package to keep.": [
        "Le nombre maximum de versions de chaque package à conserver."
      ],
      "The number of days remaining in a subscription before you will be reminded about renewing it. Also used for manifest expiration warnings.": [
        ""
      ],
      "The number of items fetched from a single paged Pulp API call.": [
        "Le nombre d'éléments récupérés à partir d'un seul appel à l'API Pulp."
      ],
      "The offset in the file where the content starts": [
        "L'offset dans le fichier où le contenu commence"
      ],
      "The order to sort the results in. ['asc', 'desc'] Defaults to 'desc'.": [
        "L'ordre de tri des résultats. ['asc', 'desc'] La valeur par défaut est \\\"desc\\\"."
      ],
      "The organization's manifest does not contain the subscriptions required to enable the following repositories.\\n %{repos}": [
        "Le manifeste de l'organisation ne contient pas les abonnements nécessaires pour activer les référentiels suivants.\\n %%{repos}"
      ],
      "The page you are attempting to access requires selecting a specific organization.": [
        "La page à laquelle vous tentez d'accéder nécessite la sélection d'une organisation spécifique."
      ],
      "The path %{real_path} does not seem to be a valid repository. If you think this is an error, please try refreshing your manifest.": [
        "Le chemin %{real_path} ne semble pas être un référentiel valide. Si vous pensez qu'il s'agit d'une erreur, veuillez essayer de rafraîchir votre manifeste."
      ],
      "The promotion of %{content_view} to %{environment} has completed.  %{count} errata are available to your hosts.": [
        "La promotion du %{content_view} à %{environment} a terminé. %{count} errata sont à la disposition de vos hôtes."
      ],
      "The promotion of %{content_view} to <b>%{environment}</b> has completed.  %{count} needed errata are installable on your hosts.": [
        "La promotion de {content_view} à <b> %{environment}</b> est terminée. Les %{count}errata nécessaires sont installables sur vos hôtes."
      ],
      "The repository is already enabled": [
        "Le référentiel est déjà activé"
      ],
      "The repository's publication is missing. Please run a 'complete sync' on %s.": [
        "La publication du référentiel est manquante. Veuillez lancer une \\\"synchronisation complète\\\" sur %s."
      ],
      "The request did not contain any repository information.": [
        "La demande ne contenait aucune information sur le référentiel d'archives."
      ],
      "The requested resource does not belong to the specified Organization": [
        "La ressource demandée n'appartient pas à l'organisation spécifiée"
      ],
      "The requested resource does not belong to the specified organization": [
        "La ressource demandée n'appartient pas à l'organisation spécifiée"
      ],
      "The requested traces were not found for this host": [
        "Les traces demandées n'ont pas été trouvées pour cet hôte"
      ],
      "The selected kickstart repository is not part of the assigned content view, lifecycle environment, content source, operating system, and architecture": [
        "Le référentiel kickstart sélectionné ne fait pas partie de la vue de contenu assignée, de l’environnement de cycle de vie, de la source de contenu, du système d'exploitation ou de l'architecture"
      ],
      "The selected lifecycle environment contains no activation keys": [
        ""
      ],
      "The selected/Inherited Content View is not available for this Lifecycle Environment": [
        "L’affichage de contenu sélectionné/hérité n’est pas disponible pour cet environnement de cycle de vie"
      ],
      "The specified organization is in Simple Content Access mode. Attaching subscriptions is disabled": [
        "L'organisation spécifiée est en mode d'accès au contenu simple. L'ajout d'abonnements est désactivé"
      ],
      "The subscription cannot be found upstream": [
        "L'abonnement ne peut être trouvé en amont"
      ],
      "The subscription is no longer available": [
        "L'abonnement n'est plus disponible"
      ],
      "The synchronization of \\\"%s\\\" has completed.  Below is a summary of new errata.": [
        "La synchronisation de \\\"%s\\\" est terminée. Veuillez voir ci-dessous un sommaire des nouveaux errata."
      ],
      "The token key to use for authentication.": [
        "La clé de jeton à utiliser pour l'authentification."
      ],
      "The type of content to remove (srpm, docker_manifest, etc.). Check removable types here: /katello/api/repositories/repository_types": [
        "Le type de contenu à supprimer (srpm, docker_manifest, etc.). Vérifiez les types de suppression ici : /katello/api/repositories/repository_types"
      ],
      "The type of content to upload (srpm, file, etc.). Check uploadable types here: /katello/api/repositories/repository_types": [
        "Le type de contenu à télécharger (srpm, fichier, etc.). Vérifiez les types téléchargeables ici : /katello/api/repositories/repository_types"
      ],
      "The value will be available in templates as @host.params['kt_activation_keys']": [
        ""
      ],
      "There are no Manifests to display": [
        "Il n'y a aucun manifeste à afficher"
      ],
      "There are no Subscriptions to display": [
        "Il n'y a pas d'Abonnements à afficher"
      ],
      "There are no errata that need to be applied to registered content hosts.": [
        "Aucun errata n'a besoin d'être appliqué aux hôtes de contenu enregistrés."
      ],
      "There are no host collections available to add.": [
        "Il n'y a pas de collections d'hôtes disponibles à ajouter."
      ],
      "There are no products or repositories enabled. Try enabling via %{custom} or %{redhat}.": [
        "Aucun produit ou référentiel n'est activé. Essayez d'activer via %{custom} ou %{redhat} "
      ],
      "There are {numberOfActivationKeys} activation keys that need to be reassigned.": [
        "Il y a {numberOfActivationKeys} clés d'activation qui doivent être réaffectées."
      ],
      "There are {numberOfHosts} hosts that need to be reassigned.": [
        "Il y a {numberOfHosts} hôtes qui ont besoin d'être réassignés."
      ],
      "There either were no environments nor versions specified or there were invalid environments/versions specified. Please check environment_ids and content_view_version_ids parameters.": [
        "Aucun environnement ou version n'a été spécifié ou les environnements ou versions spécifiés étaient non valides. Veuillez vérifier les paramètres environment_ids et content_view_version_ids."
      ],
      "There is no downloaded content to clean.": [
        "Il n'y a pas de contenu téléchargé à nettoyer."
      ],
      "There is no manifest history to display.": [
        ""
      ],
      "There is no such HTTP proxy": [
        "Il n'existe pas de proxy HTTP de ce type"
      ],
      "There is nothing to see here": [
        "Il n'y a rien à voir ici"
      ],
      "There is {numberOfActivationKeys} activation key that needs to be reassigned.": [
        "Il y a {numberOfActivationKeys} clé d'activation qui doit être réaffectée."
      ],
      "There is {numberOfHosts} host that needs to be reassigned.": [
        "Il y a {numberOfHosts} hôte qui doit être réaffecté."
      ],
      "There was a problem retrieving Activation Key data from the server.": [
        "Il y a eu un problème pour récupérer les données de la clé d'activation sur le serveur."
      ],
      "There was an error retrieving data from the server. Check your connection and try again.": [
        "Une erreur est survenue lors de l’extraction des données du serveur. Veuillez vérifier la connexion et essayer à nouveau."
      ],
      "There was an issue with the backend service %s: ": [
        "Il y avait un problème avec le service de backend %s : "
      ],
      "There's no running synchronization for this smart proxy.": [
        "Il n'y a pas de synchronisation en cours pour ce proxy smart."
      ],
      "This Content View must be set to Import-only before performing an import": [
        "Cette vue de contenu doit être réglée sur Import-only avant d'effectuer une importation"
      ],
      "This Host is not currently registered with subscription-manager.": [
        "Cet hôte n'est pas actuellement enregistré auprès de subscription-manager."
      ],
      "This Organization's subscription manifest has expired. Please import a new manifest.": [
        "Le manifeste de souscription de cette organisation a expiré. Veuillez importer un nouveau manifeste."
      ],
      "This action doesn't support package groups": [
        "Cette action de prend pas en charge les groupes de packages"
      ],
      "This action should only be taken for debugging purposes.": [
        ""
      ],
      "This action should only be taken in extreme circumstances or for debugging purposes.": [
        "Cette action doit être prise uniquement dans des circonstances extrêmes ou à des fins de débogage."
      ],
      "This activation key is associated to one or more Hosts/Hostgroups. Search and unassociate Hosts/Hostgroups using params.kt_activation_keys ~ \\\"%{name}\\\" before deleting.": [
        "Cette clé d'activation est associée à un ou plusieurs Hôtes/Groupes d'Hôtes. Recherchez et dissociez les Hôtes/Groupes d’hôtes en utilisant params.kt_activation_keys ~ \\\"%{name}\\\" avant de les supprimer."
      ],
      "This certificate allows a user to view the repositories in any environment from a browser.": [
        "Ce certificat permet à l'utilisateur d'afficher les référentiels dans n'importe quel environnement à partir d'un navigateur."
      ],
      "This content view does not have any versions associated.": [
        "Cet affichage de contenu n’a aucune version associée."
      ],
      "This content view version doesn't have a history.": [
        "Cette version de la vue du contenu n'a pas d'historique."
      ],
      "This content view version is used in one or more multi-environment hosts. The version will simply be removed from the multi-environment hosts. The content view and lifecycle environment you select here will only apply to single-environment hosts. See hammer activation-key --help for more details.": [
        ""
      ],
      "This content view will be automatically updated to the latest version.": [
        "Cet affichage de contenu sera automatiquement mis à jour à la dernière version."
      ],
      "This content view will be deleted. Changes will be effective after clicking Delete.": [
        "Cet affichage de contenu va être supprimé. Les changements seront applicables une fois que vous aurez saisi la touche Supprimer."
      ],
      "This endpoint is deprecated and will be removed in an upcoming release. Simple Content Access is the only supported content access mode.": [
        ""
      ],
      "This endpoint is primarily designed for UI interactions and uploading content into the repository. For API-based uploads, please use the 'content_uploads' endpoint instead.": [
        ""
      ],
      "This environment is used in one or more multi-environment activation keys. The environment will simply be removed from the multi-environment keys. The content view and lifecycle environment you select here will only apply to single-environment activation keys. See hammer activation-key --help for more details.": [
        ""
      ],
      "This erratum is not installable because it is not in this host's content view and lifecycle environment.": [
        "Cet erratum n’est pas installable car il ne fait pas partie de ce affichage de contenu ou environnement de cycle de vie de cet hôte."
      ],
      "This host does not have any Module streams.": [
        "Cet hôte n'a pas de flux de modules."
      ],
      "This host does not have any packages.": [
        "Cet hôte n’a pas d’errata installable."
      ],
      "This host has errata that are applicable, but not installable. Adjust your filters and try again.": [
        ""
      ],
      "This host is associated with multiple content view environments. If you assign a lifecycle environment and content view here, the host will be removed from the other environments.": [
        ""
      ],
      "This host's organization is in Simple Content Access mode. Attaching subscriptions is disabled.": [
        "L'organisation de cet hôte est en mode d'accès simple au contenu. L'ajout d'abonnements est désactivé."
      ],
      "This host's organization is in Simple Content Access mode. Auto-attach is disabled": [
        "L'organisation de cet hôte est en mode d'accès simple au contenu. L'auto-attachement est désactivé"
      ],
      "This is disabled because a manifest task is in progress": [
        "Cette fonction est désactivée parce qu'une tâche manifeste est en cours"
      ],
      "This is disabled because a manifest-related task is in progress.": [
        "Cette fonction est désactivée car une tâche liée au manifeste est en cours."
      ],
      "This is disabled because no connection could be made to the upstream Manifest.": [
        "Cette fonction est désactivée car aucune connexion n'a pu être établie avec le manifeste en amont."
      ],
      "This is disabled because no manifest exists": [
        "Il est désactivé parce qu'il n'existe pas de manifeste"
      ],
      "This is disabled because no manifest has been uploaded.": [
        "Cette option est désactivée car aucun manifeste n'a été téléchargé."
      ],
      "This is disabled because no subscriptions are selected.": [
        "Cette option est désactivée car aucun abonnement n'est sélectionné."
      ],
      "This is not a linked repository": [
        "Il ne s'agit pas d'un référentiel associé"
      ],
      "This page shows the subscriptions available from this organization's subscription manifest. {br} Learn more about your overall subscription usage with the {subscriptionsService}.": [
        ""
      ],
      "This repository has pending tasks in associated content views. Please wait for the tasks: ": [
        ""
      ],
      "This repository is not suggested. Please see additional %(anchorBegin)sdocumentation%(anchorEnd)s prior to use.": [
        "Ce référentiel n'est pas suggéré. Veuillez consulter la %(anchorBegin)sdocumentation%(anchorEnd)s supplémentaire avant l'utilisation."
      ],
      "This request may only be performed on a Smart proxy that has the Pulpcore feature with mirror=true.": [
        "Cette demande ne peut avoir lieu que sur un proxy smart qui a la fonctionnalité Pulpcore avec mirror=true.."
      ],
      "This service is available for unauthenticated users": [
        "Ce service est disponible pour les utilisateurs non authentifiés"
      ],
      "This service is only available for authenticated users": [
        "Ce service est disponible pour les utilisateurs authentifiés uniquement"
      ],
      "This shows repositories that are used in a typical setup.": [
        "Il s'agit de référentiels utilisés dans une configuration typique."
      ],
      "This subscription is not relevant to the current organization.": [
        "Cet abonnement n'est pas pertinent pour l'organisation actuelle."
      ],
      "This version has not been promoted to any environments.": [
        "Cette version n’est pas promue à aucun environnement."
      ],
      "This version is not promoted to any environments.": [
        "Cette version n’est pas promue à aucun environnement."
      ],
      "This version will be removed from:": [
        "Cette version sera retirée de :"
      ],
      "This will create a copy of {cv}, including details, repositories, and filters. Generated data such as history, tasks and versions will not be copied.": [
        "Cela créera une copie de {cv}, y compris les détails, les référentiels et les filtres. Les données générées telles que l'historique, les tâches et les versions ne seront pas copiées."
      ],
      "This will update the content view environments for {hosts}.": [
        ""
      ],
      "Time in minutes before content that is not contained within a repository and has not been accessed is considered orphaned.": [
        ""
      ],
      "Time to expire yum metadata in seconds. Only relevant for custom yum repositories.": [
        ""
      ],
      "Timeout when refreshing a manifest (in seconds)": [
        "Délai d'attente pour le rafraîchissement d'un manifeste (en secondes)"
      ],
      "Timestamp": [
        "Horodatage"
      ],
      "Title": [
        "Titre"
      ],
      "To change content view environments, a specific organization must be selected from the organization context.": [
        ""
      ],
      "To enable the synced content option, this host must use a content source, content view, and lifecycle environment which contain synced kickstart repositories for the selected architecture and operating system.": [
        ""
      ],
      "To enable them, add the environment to the content source, or select a different content source.": [
        ""
      ],
      "To enable them, add the environment to the host's content source, or ": [
        ""
      ],
      "To finish the process of changing the content source, run the following script manually on {hosts}.": [
        ""
      ],
      "To get started, add a filter rule to this filter": [
        ""
      ],
      "To get started, add this host to a host collection.": [
        "Pour commencer, ajoutez cet hôte à une collection d'hôtes."
      ],
      "To include or exclude specific content from the content view, create a filter. Without filters, the content view includes everything from the added repositories.": [
        ""
      ],
      "To manage host packages, a specific organization must be selected from the organization context.": [
        ""
      ],
      "To manage packages, select an action.": [
        ""
      ],
      "Token/password for the flatpak remote": [
        ""
      ],
      "Total steps: ": [
        "Total des étapes : "
      ],
      "Tracer": [
        "Traceur"
      ],
      "Tracer helps administrators identify applications that need to be restarted after a system is patched.": [
        "Tracer aide les administrateurs à identifier les applications qui doivent être redémarrées après qu'un système a été corrigé."
      ],
      "Tracer profile uploaded successfully": [
        "Le profil du traceur a été téléchargé avec succès"
      ],
      "Traces": [
        "Traces"
      ],
      "Traces are being enabled": [
        "Les traces sont activées"
      ],
      "Traces are not enabled": [
        "Traces non activées"
      ],
      "Traces help administrators identify applications that need to be restarted after a system is patched.": [
        "Les traces aident les administrateurs à identifier les applications qui doivent être redémarrées après qu'un système ait été corrigé."
      ],
      "Traces may be enabled by a user with the appropriate permissions.": [
        "Les traces peuvent être activées par un utilisateur disposant des autorisations appropriées."
      ],
      "Traces may be listed here after {pkgLink}.": [
        "Les traces peuvent être énumérées ici après {pkgLink}."
      ],
      "Traces not available": [
        "Traces non disponibles"
      ],
      "Traces that require logout cannot be restarted remotely": [
        "Traces nécessitant une déconnexion ne peut pas être redémarré à distance"
      ],
      "Traces will be shown here to a user with the appropriate permissions.": [
        "Les traces seront montrées ici à un utilisateur ayant les permissions appropriées."
      ],
      "Traffic for all alternate content sources associated with this smart proxy will go through the chosen HTTP proxy.": [
        "Le trafic de toutes les sources de contenu alternatif associées à ce proxy smart passera par le proxy HTTP choisi."
      ],
      "Trigger an auto-attach of subscriptions": [
        "Déclenche Abonnements auto-attach"
      ],
      "Trigger an auto-attach of subscriptions on one or more hosts": [
        "Déclenche Abonnements auto-attach sur un ou plusieurs hôtes"
      ],
      "Try changing your search criteria.": [
        "Essayez de modifier vos critères de recherche."
      ],
      "Try changing your search query.": [
        "Essayez de modifier vos paramètres de recherche."
      ],
      "Try changing your search settings.": [
        "Essayez de modifier vos paramètres de recherche."
      ],
      "Trying to cancel the synchronization...": [
        "Tentative d'annulation de la synchronisation..."
      ],
      "Type": [
        "Type"
      ],
      "Type must be one of: %s": [
        "Une valeur doit être choisie parmi %s."
      ],
      "Type of content": [
        "Type de contenu"
      ],
      "Type of content: \\\"cert\\\", \\\"gpg_key\\\"": [
        "Type de contenu : \\\"cert\\\", \\\"gpg_key\\\""
      ],
      "Type of repository. Available types endpoint: /katello/api/repositories/repository_types": [
        "Type de référentiel. Point de terminaison des types disponibles : /katello/api/repositories/repository_types"
      ],
      "URL": [
        "URL"
      ],
      "URL and paths": [
        "URL et chemins d'accès"
      ],
      "URL and subpaths": [
        "URL et sous-chemins"
      ],
      "URL needs to have a trailing /": [
        "L'URL doit comporter un / à la fin"
      ],
      "URL of a PyPI content source such as https://pypi.org.": [
        "URL d’une source de contenu PyPI telle que https://pypi.org."
      ],
      "URL of an OSTree repository.": [
        "URL d’un référentiel OSTree"
      ],
      "UUID": [
        "UUID"
      ],
      "UUID of the consumer": [
        "UUID du consommateur"
      ],
      "UUID of the content host": [
        "UUID de l'hôte de contenu"
      ],
      "UUID of the system": [
        "UUID du système"
      ],
      "UUID to use for registered host, random uuid is generated if not provided": [
        "UUID à utiliser pour l'hôte enregistré, un uuid aléatoire est généré s'il n'est pas fourni"
      ],
      "UUIDs of the virtual guests from the host's hypervisor": [
        "UUID des invités virtuels de l'hyperviseur de l'hôte"
      ],
      "Unable to connect": [
        "Impossible de se connecter"
      ],
      "Unable to connect. Got: %s": [
        "Impossible de se connecter. Obtenu: %s"
      ],
      "Unable to create ContentViewEnvironment. Check the logs for more information.": [
        ""
      ],
      "Unable to delete any alternate content source. You either do not have the permission to delete, or none of the alternate content sources exist.": [
        "Impossible de supprimer une source de contenu alternative. Soit vous n'avez pas l'autorisation de supprimer, soit aucune des sources de contenu alternatives n'existe."
      ],
      "Unable to detect pulp storage": [
        "Impossible de détecter la stockage Pulp"
      ],
      "Unable to detect puppet path": [
        "Impossible de détecter le chemin d’accès Pulp"
      ],
      "Unable to find product '%s' in organization '%s'": [
        "Impossible de trouver le produit '%s' dans l’organisation '%s'"
      ],
      "Unable to get users": [
        "Impossible d'obtenir des utilisateurs"
      ],
      "Unable to import in to Content View specified in the metadata - '%{name}'. The 'import_only' attribute for the content view is set to false. To mark this Content View as importable, have your system administrator run the following command on the server. ": [
        "Impossible d'importer dans la vue du contenu spécifiée dans les métadonnées - '%{name}'. L'attribut 'import_only' de la vue de contenu est défini sur false. Pour marquer cette vue de contenu comme importable, demandez à votre administrateur système d'exécuter la commande suivante sur le serveur. "
      ],
      "Unable to incrementally export. Do a Full Export on the library content before updating from the latest increment.": [
        "Impossible d'exporter de manière incrémentielle. Effectuez une exportation complète du contenu de la bibliothèque avant d'effectuer la mise à jour à partir du dernier incrément."
      ],
      "Unable to incrementally export. Do a Full Export on the repository content.": [
        "Impossible d'exporter de manière incrémentielle. Faites une exportation complète du contenu du référentiel."
      ],
      "Unable to reassign activation_keys. Please check activation_key_content_view_id and activation_key_environment_id.": [
        "Impossible de réassigner des activation_keys. Veuillez vérifier activation_key_content_view_id et activation_key_environment_id."
      ],
      "Unable to reassign activation_keys. Please provide key_content_view_id and key_environment_id.": [
        "Impossible de réassigner des activation_keys. Veuillez fournir key_content_view_id et key_environment_id."
      ],
      "Unable to reassign content hosts. Please provide system_content_view_id and system_environment_id.": [
        "Impossible de réassigner les hôtes de contenu. Veuillez fournir system_content_view_id et system_environment_id."
      ],
      "Unable to reassign systems. Please check system_content_view_id and system_environment_id.": [
        "Impossible de réassigner des systèmes. Veuillez vérifier system_content_view_id et system_environment_id."
      ],
      "Unable to refresh any alternate content source. You either do not have the permission to refresh, or no alternate content sources exist.": [
        ""
      ],
      "Unable to refresh any alternate content source. You either do not have the permission to refresh, or none of the alternate content sources exist.": [
        "Impossible d'actualiser une source de contenu alternative. Soit vous n'avez pas l'autorisation d'actualiser, soit aucune des sources de contenu alternatives n'existe."
      ],
      "Unable to send errata e-mail notification: %{error}": [
        "Impossible d'envoyer une notification par courrier électronique errata : %{error}"
      ],
      "Unable to sync repo. This repository does not have a feed url.": [
        "Impossible de sync le référentiel. Ce référentiel ne possède pas d'url de flux."
      ],
      "Unable to sync repo. This repository is not a library instance repository.": [
        ""
      ],
      "Unable to synchronize any repository. You either do not have the permission to synchronize or the selected repositories do not have a feed url.": [
        "Impossible de synchroniser un référentiel. Vous ne possédez pas de permission pour synchroniser ou les référentiels sélectionnés ne contiennent pas un url de flux."
      ],
      "Unable to update the repository list": [
        "Impossible de mettre à jour la liste des référentiels"
      ],
      "Unable to update the user-repository mapping": [
        "Impossible de mettre à jour le mapping utilisateur-référentiel"
      ],
      "Unapplied Errata": [
        "Errata non appliqués"
      ],
      "Unattach a subscription": [
        "Détacher un abonnement"
      ],
      "Unfiltered params array: %s.": [
        "Tableau des paramètres non filtrés : %s."
      ],
      "Uninstall and reset": [
        "Désinstaller et réinitialiser"
      ],
      "Unknown": [
        "Inconnu"
      ],
      "Unknown Action": [
        "Action inconnue"
      ],
      "Unknown errata status": [
        "Statut d'errata inconnu"
      ],
      "Unknown traces status": [
        "Statut des traces inconnues"
      ],
      "Unlimited": [
        "Illimité"
      ],
      "Unregister host %s before assigning an organization": [
        "Désenregistrer l’hôte %s avant d'assigner une organisation"
      ],
      "Unregister the host as a subscription consumer": [
        "Désenregistrer l'hôte en tant que consommateur d'abonnement"
      ],
      "Unspecified": [
        "Non spécifié"
      ],
      "Unsupported CDN resource": [
        "Ressource CDN non prise en charge"
      ],
      "Unsupported event type %{type}. Supported: %{types}": [
        "Type d'événement non pris en charge %{type}. Pris en charge : %{types}"
      ],
      "Up-to date": [
        "Mis à jour"
      ],
      "Update": [
        "Mise à jour"
      ],
      "Update Alternate Content Source": [
        "Mise à jour de la source de contenu alternatif"
      ],
      "Update CDN Configuration": [
        "Mise à jour de la configuration CDN"
      ],
      "Update Content Counts": [
        ""
      ],
      "Update Content Overrides": [
        "Mettre à jour les substitutions de contenu"
      ],
      "Update Content Overrides to %s": [
        "Mettre à jour les substitutions de contenu à %s"
      ],
      "Update Upstream Subscription": [
        "Mise à jour de l'abonnement en amont"
      ],
      "Update a Content Credential": [
        "Mettre à jour un identifiant de contenu"
      ],
      "Update a component associated with the content view": [
        "Mettre à jour un composant associé à l'affichage de contenu"
      ],
      "Update a content view": [
        "Mettre à jour un affichage de contenu"
      ],
      "Update a content view version": [
        "Promouvoir une version d’affichage de contenu"
      ],
      "Update a filter rule. The parameters included should be based upon the filter type.": [
        "Mettre à jour une règle de filtre. Les paramètres inclus doivent se baser sur le type de filtre."
      ],
      "Update a flatpak remote": [
        ""
      ],
      "Update a host collection": [
        "Mettre à jour une collection d'hôte"
      ],
      "Update a repository": [
        "Mettre à jour un référentiel"
      ],
      "Update a sync plan": [
        "Mettre à jour un plan de sync"
      ],
      "Update an activation key": [
        "Mettre à jour une clé d'activation"
      ],
      "Update an alternate content source.": [
        "Mettre à jour une autre source de contenu"
      ],
      "Update an environment": [
        "Mettre à jour un environnement"
      ],
      "Update an environment in an organization": [
        "Mettre à jour un environnement dans une organisation"
      ],
      "Update content counts for the smart proxy": [
        ""
      ],
      "Update content view environments for host": [
        ""
      ],
      "Update content view environments for host %s": [
        ""
      ],
      "Update hosts manually": [
        ""
      ],
      "Update installed packages, enabled repos, module inventory": [
        "Mise à jour des packages installés, activation des repos, inventaire des modules"
      ],
      "Update organization": [
        "Mettre à jour l'organisation"
      ],
      "Update package group via Katello interface": [
        "Mise à jour du groupe de packages via l'interface Katello"
      ],
      "Update package via Katello interface": [
        "Mise à jour du package via l'interface Katello"
      ],
      "Update packages via Katello interface": [
        "Mise à jour du package via l'interface Katello"
      ],
      "Update release version for host": [
        "Mettre à jour la version de publication pour l'hôte"
      ],
      "Update release version for host %s": [
        "Mettre à jour la version de publication pour l'hôte %s"
      ],
      "Update services requiring restart": [
        "Mise à jour des services nécessitant un redémarrage"
      ],
      "Update the CDN configuration": [
        "Mise à jour de la configuration CDN"
      ],
      "Update the HTTP proxy configuration on the repositories of one or more products.": [
        "Mettre à jour la configuration du proxy HTTP sur les référentiels d'un ou plusieurs produits."
      ],
      "Update the content source for specified hosts and generate the reconfiguration script": [
        "Mettre à jour la source de contenu pour les hôtes spécifiés et générer le script de reconfiguration"
      ],
      "Update the host immediately via remote execution": [
        ""
      ],
      "Update the information about enabled repositories": [
        "Mettre à jour les informations sur les référentiels activés"
      ],
      "Update the quantity of one or more subscriptions on an upstream allocation": [
        "Mettre à jour la quantité d'un ou plusieurs abonnements sur une allocation en amont"
      ],
      "Update version": [
        "Mise à jour de la version"
      ],
      "Updated": [
        "Mis à jour"
      ],
      "Updated component details": [
        "Mise à jour des détails des composants"
      ],
      "Updated from": [
        "Mis à jour à partir de"
      ],
      "Updates": [
        "Mises à jour"
      ],
      "Updates a product": [
        "Met à jour un produit"
      ],
      "Updates available: Component content view versions have been updated.": [
        ""
      ],
      "Updates available: Repositories and/or filters have changed.": [
        ""
      ],
      "Updating Package...": [
        "Mise à jour de packages..."
      ],
      "Updating System Purpose for host": [
        "Mise à jour Objectif système pour l'hôte"
      ],
      "Updating System Purpose for host %s": [
        "Mise à jour Objectif système pour l'hôte %s"
      ],
      "Updating package group...": [
        "Mise à jour du groupe de packages..."
      ],
      "Updating repository authentication configuration": [
        "Mise à jour de la configuration d'authentification du référentiel"
      ],
      "Upgradable": [
        "Pouvant être mis à niveau"
      ],
      "Upgradable to": [
        "Pouvant être mis à niveau à"
      ],
      "Upgrade": [
        "Mettre à niveau"
      ],
      "Upgrade all packages": [
        ""
      ],
      "Upgrade packages": [
        ""
      ],
      "Upgrade via customized remote execution": [
        "Mettre à niveau via exécution à distance personnalisée"
      ],
      "Upgrade via remote execution": [
        "Mettre à niveau via exécution à distante"
      ],
      "Upload Content Credential contents": [
        "Télécharger les identifiants de contenu"
      ],
      "Upload a chunk of the file's content": [
        "Télécharger une partie du contenu du fichier"
      ],
      "Upload a subscription manifest": [
        "Télécharger un fichier manifeste d'abonnement"
      ],
      "Upload into": [
        "Téléverser vers"
      ],
      "Upload package / repos profile": [
        ""
      ],
      "Upload request id": [
        "Télécharger l'id de requête"
      ],
      "Upstream Candlepin": [
        "Chandelle en amont"
      ],
      "Upstream Content View Label, default: Default_Organization_View. Relevant only for 'upstream_server' type.": [
        "Balise de la vue du contenu en amont, par défaut : Default_Organization_View. Pertinent uniquement pour le type 'upstream_server'."
      ],
      "Upstream Lifecycle Environment, default: Library. Relevant only for 'upstream_server' type.": [
        "Environnement du cycle de vie en amont, par défaut : Library. Pertinent uniquement pour le type 'upstream_server'."
      ],
      "Upstream Name cannot be blank when Repository URL is provided.": [
        "Le nom en amont ne peut pas être vide lorsque l'URL du référentiel est fournie."
      ],
      "Upstream authentication token string for yum repositories.": [
        ""
      ],
      "Upstream foreman server to sync CDN content from. Relevant only for 'upstream_server' type.": [
        "Serveur foreman en amont pour synchroniser le contenu CDN. Pertinent uniquement pour le type 'upstream_server'."
      ],
      "Upstream identity certificate not available": [
        "Le certificat d'identité en amont est indisponible"
      ],
      "Upstream organization %s does not provide this content path": [
        "L’organisation en amont %s ne fournit pas de chemin de contenu"
      ],
      "Upstream organization %{org_label} does not have a content view with the label %{cv_label}": [
        "L’organisation en amont %{org_label} ne possède pas d’affichage de contenu avec le libellé %{cv_label}"
      ],
      "Upstream organization %{org_label} does not have a lifecycle environment with the label %{lce_label}": [
        "L’organisation en amont %{org_label} ne possède pas d’environnement de cycle de vie avec le libellé %{lce_label}"
      ],
      "Upstream organization to sync CDN content from. Relevant only for 'upstream_server' type.": [
        "Organisation en amont pour synchroniser le contenu du CDN. Pertinent uniquement pour le type 'upstream_server'."
      ],
      "Upstream password requires upstream username be set.": [
        "Le mot de passe en amont exige que le nom d'utilisateur en amont soit défini."
      ],
      "Upstream username and password may only be set on custom repositories.": [
        "Le nom d'utilisateur et le mot de passe en amont ne peuvent être définis que sur des référentiels personnalisés."
      ],
      "Upstream username and upstream password cannot be blank for ULN repositories": [
        "Le nom d'utilisateur et le mot de passe en amont ne peuvent être vides pour les ULN personnalisés."
      ],
      "Upstream username requires upstream password be set.": [
        "Le nom d'utilisateur en amont exige que le mot de passe en amont soit défini."
      ],
      "Usage": [
        "Utilisation"
      ],
      "Usage Type": [
        "Type d'utilisation"
      ],
      "Usage of host": [
        "Utilisation de l'hôte"
      ],
      "Usage type": [
        "Type d'utilisation"
      ],
      "Use HTTP Proxies": [
        "Utiliser des proxy HTTP"
      ],
      "Use HTTP proxies": [
        "Utiliser des proxies HTTP"
      ],
      "Used to determine download concurrency of the repository in pulp3. Use value less than 20. Defaults to 10": [
        "Utilisé pour déterminer la simultanéité de téléchargement du référentiel dans la pulp3. Valeur d'utilisation inférieure à 20. Valeur par défaut de 10"
      ],
      "User": [
        "Utilisateur"
      ],
      "User '%s' did not specify an organization ID and does not have a default organization.": [
        "L'utilisateur '%s' n'a pas spécifié un ID d'organisation et ne possède pas d'organisation par défaut."
      ],
      "User '%{user}' does not belong to Organization '%{organization}'.": [
        "L'utilisateur  '%{user}' n'appartient pas à l'organisation '%{organization}'."
      ],
      "User IDs": [
        "ID des utilisateurs"
      ],
      "User must be logged in.": [
        "L'utilisateur doit être connecté"
      ],
      "Username": [
        "Nom d'utilisateur"
      ],
      "Username for authentication. Relevant only for 'upstream_server' type.": [
        "Nom d'utilisateur pour l'authentification. Pertinent uniquement pour le type 'upstream_server'."
      ],
      "Username for the flatpak remote": [
        ""
      ],
      "Username of the upstream repository user used for authentication": [
        "Nom d'utilisateur de l'utilisateur du référentiel en amont utilisé pour l'authentification"
      ],
      "Username to access URL": [
        "Nom d'utilisateur pour accéder à l'URL"
      ],
      "Username, Password, Organization Label, and SSL CA Content Credential must be provided together.": [
        "Le nom d'utilisateur, le mot de passe, le label de l'organisation et le justificatif de contenu de l'autorité de certification SSL doivent être fournis ensemble"
      ],
      "Username, Password, Upstream Organization Label, and SSL CA Credential are required when using an upstream Foreman server.": [
        "Le nom d'utilisateur, le mot de passe, le label de l'organisation en amont et l'accréditation de l'autorité de certification SSL sont requis lorsque vous utilisez un serveur Foreman en amont."
      ],
      "Validate host/lifecycle environment/content source coherence": [
        ""
      ],
      "Validate that a host's assigned lifecycle environment is synced by the smart proxy from which the host will get its content. Applies only to API requests; does not affect web UI checks": [
        ""
      ],
      "Value must either be a boolean or 'default' for 'enabled'": [
        "La valeur doit être soit un booléen, soit la valeur par défaut de \\\"enabled\\\""
      ],
      "Verify SSL": [
        "Vérifier SSL"
      ],
      "Verify checksum for content on smart proxy": [
        ""
      ],
      "Verify checksum for one or more products": [
        "Vérifier la somme de contrôle pour un ou plusieurs produits"
      ],
      "Verify checksum of repositories in %{name} %{version}": [
        ""
      ],
      "Verify checksum of repository contents": [
        "Vérifier la somme de contrôle des contenus de référentiel"
      ],
      "Verify checksum of repository contents in the content view version": [
        ""
      ],
      "Verify checksum of version repositories": [
        ""
      ],
      "Version": [
        "Version"
      ],
      "Version ": [
        "Version "
      ],
      "Version ${item.version}": [
        "Version"
      ],
      "Version ${version.version}": [
        "Version"
      ],
      "Version ${versionNameToRemove} will be deleted from all environments. It will no longer be available for promotion.": [
        "Version {versionNameToRemove} sera supprimée de tous les environnements. Ne seront plus disponibles pour la promotion."
      ],
      "Version ${versionNameToRemove} will be deleted from the listed environments. It will no longer be available for promotion.": [
        "Version {versionNameToRemove} sera supprimée des environnement listés. Ne seront plus disponibles pour la promotion."
      ],
      "Version ${versionOne}": [
        "Version ${versionOne}"
      ],
      "Version ${versionTwo}": [
        "Version ${versionTwo}"
      ],
      "Version details updated.": [
        "Détails de la version mis à jour."
      ],
      "Versions": [
        "Versions"
      ],
      "Versions ": [
        "Versions "
      ],
      "Versions to compare": [
        "Versions à comparer"
      ],
      "Versions to exclusively include in the action": [
        "Versions à inclure exclusivement dans l'action"
      ],
      "Versions to explicitly exclude in the action. All other versions will be included in the action, unless an included parameter is passed as well.": [
        "Versions à exclure explicitement dans l'action. Tous les autres versions applicables seront incluses dans l'action, à moins qu'un paramètre inclus ne soit également transmis."
      ],
      "Versions will appear here when the content view is published.": [
        "Les versions apparaîtront ici lorsque la vue du contenu sera publiée."
      ],
      "View %{view} has not been promoted to %{env}": [
        "L'affichage %{view} n’a pas été promu à %{env} "
      ],
      "View Filters": [
        ""
      ],
      "View Subscription Usage": [
        "Afficher l'utilisation de l'abonnement"
      ],
      "View a report of the affected hosts": [
        "Voir un rapport sur les hôtes concernés"
      ],
      "View applicable errata": [
        ""
      ],
      "View by": [
        "Afficher par"
      ],
      "View content views": [
        ""
      ],
      "View documentation": [
        ""
      ],
      "View matching content": [
        "Afficher le contenu correspondant"
      ],
      "View sync status": [
        ""
      ],
      "View tasks ": [
        "Voir les tâches "
      ],
      "View the Content Views page": [
        "Afficher la page Vues du contenu"
      ],
      "View the job": [
        "Voir le job"
      ],
      "Virtual": [
        "Virtuel"
      ],
      "Virtual guests": [
        "Invités virtuels"
      ],
      "Virtual host": [
        "Hôte virtuel"
      ],
      "WARNING: Simple Content Access will be required for all organizations in Katello 4.12.": [
        ""
      ],
      "Waiting to start.": [
        "Attente de démarrage."
      ],
      "Warning": [
        "Avertissement"
      ],
      "When \\\"Releases/Distributions\\\" is set, \\\"Upstream URL\\\" must also be set!": [
        "Lorsque \\\"Releases/Distribution\\\" est défini, \\\"Upstream URL\\\" doit également être défini !"
      ],
      "When \\\"Upstream URL\\\" is set, \\\"Releases/Distributions\\\" must also be set!": [
        "Lorsque \\\"Upstream URL\\\" est défini, \\\"Releases/Distributions\\\" doit également être défini !"
      ],
      "When registering a host via subscription-manager, force use the specified fact (in the form of 'fact.fact')": [
        "Lors de l'enregistrement d'un hôte via le gestionnaire d'abonnement, il faut forcer l'utilisation du fact spécifié (sous la forme de \\\"fact.fact\\\")"
      ],
      "When set to 'True' repository types that are creatable will be returned": [
        "Si défini sur 'Vrai', les types de référentiels qui peuvent être créés seront retournés"
      ],
      "When unregistering a host via subscription-manager, also delete the host record. Managed resources linked to host such as virtual machines and DNS records may also be deleted.": [
        "Lorsque vous dés-enregistrez un hôte via le gestionnaire d'abonnement, supprimez également l'enregistrement de l'hôte. Les ressources gérées liées à l'hôte, telles que les machines virtuelles et les enregistrements DNS, peuvent également être supprimés."
      ],
      "Whether or not the host collection may have unlimited hosts": [
        "Que la collection d'hôte possède des hôtes illimités ou non."
      ],
      "Whether or not to auto sync the Smart Proxies after a content view promotion.": [
        "La synchronisation automatique ou non des proxys smart après une promotion d’affichage de contenu."
      ],
      "Whether or not to check the status of backend services such as pulp and candlepin prior to performing some actions.": [
        "Indique si on doit ou non vérifier le statut des services de backend comme Pulp et Candlepin avant d'effectuer certaines actions."
      ],
      "Whether or not to regenerate the repository on disk. Default: true": [
        "La régénération ou non du référentiel sur disque. Valeur par défaut : true"
      ],
      "Whether or not to return filters applied to the content view version": [
        ""
      ],
      "Whether or not to show all results": [
        "Afficher tous les résultats ou pas"
      ],
      "Whether or not to sync an external capsule after upload. Default: true": [
        "Synchronisation ou non d'une capsule externe après le téléchargement. Valeur par défaut : true"
      ],
      "Whether to include available content attribute in results": [
        "Définit si on doit inclure l'attribut de contenu disponible dans les résultats"
      ],
      "Workers": [
        "Workers"
      ],
      "Wrong content type submitted.": [
        "Le type de contenu soumis est erroné."
      ],
      "Yay empty state": [
        "état vide"
      ],
      "Yes": [
        "Oui"
      ],
      "You are not allowed to promote to Environments %s": [
        "Vous n'êtes pas autorisé à promouvoir vers les environnements %s"
      ],
      "You are not allowed to publish Content View %s": [
        "Vous n'êtes pas autorisé à publier l'affichage de contenu %s"
      ],
      "You can check sync status for repositories only in the library lifecycle environment.'": [
        "Vous ne pouvez vérifier le statut de synchronisation pour les référentiels que dans l'environnement de cycle de vie de la bibliothèque."
      ],
      "You cannot have more than %{max_hosts} host(s) associated with host collection '%{host_collection}'.": [
        "\\\"Vous ne pouvez pas posséder plus de{max_hosts} hôte(s) associés à la collection d'hôte '%{host_collection} '."
      ],
      "You cannot set an organization's parent. This feature is disabled.": [
        "Vous ne pouvez pas définir un parent d'organisation . Cette fonctionnalité est désactivée."
      ],
      "You cannot set an organization's parent_id. This feature is disabled.": [
        "Vous ne pouvez pas définir un id de parent d'organisation . Cette fonctionnalité est désactivée."
      ],
      "You currently don't have any ${selectedContentType}.": [
        "Vous n'avez actuellement aucun {selectedContentType}."
      ],
      "You currently don't have any alternate content sources.": [
        "Vous n'avez pas actuellement de sources de contenu alternatives."
      ],
      "You currently don't have any related content views.": [
        ""
      ],
      "You currently don't have any repositories associated with this content.": [
        "Vous n'avez actuellement aucun référentiel associé à ce contenu."
      ],
      "You currently don't have any repositories to add to this filter.": [
        "Vous n'avez actuellement aucun référentiel à ajouter à ce filtre."
      ],
      "You currently have no content views to display": [
        ""
      ],
      "You do not have permissions to delete %s": [
        "Vous ne disposez pas des droits nécessaires pour supprimer %s"
      ],
      "You have not set a default organization on the user %s.": [
        "Vous n'avez pas défini d'organisation par défaut pour l'utilisateur %s ."
      ],
      "You have subscriptions expiring within %s days": [
        "Vous avez des abonnements qui expirent dans %s jours"
      ],
      "You have unsaved changes. Do you want to exit without saving your changes?": [
        "Vous avez des modifications non sauvegardées. Voulez-vous sortir sans sauvegarder vos modifications ?"
      ],
      "You must select at least one host.": [
        ""
      ],
      "You were not allowed to add %s": [
        "Vous n'êtes pas autorisé à ajouter %s"
      ],
      "You were not allowed to change sync plan for %s": [
        "Vous n'êtes pas autorisé à modifier le plan de sync pour %s"
      ],
      "You were not allowed to delete %s": [
        "Vous n'êtes pas autorisé à supprimer %s"
      ],
      "You were not allowed to sync %s": [
        "Vous n'êtes pas autorisé à sync %s"
      ],
      "You're making changes to %(entitlementCount)s entitlement(s)": [
        "Vous apportez des modifications à %(entitlementCount)s droits d’accès."
      ],
      "Your manifest expired on {expirationDate}. To continue using Red Hat content, import a new manifest.": [
        ""
      ],
      "Your manifest has expired. To continue using Red Hat content, import a new manifest.": [
        ""
      ],
      "Your manifest will expire in {daysMessage}. To extend the expiration date, refresh your manifest. Or, if your Foreman is disconnected, import a new manifest.": [
        ""
      ],
      "Your search query was invalid. Please revise it and try again. The full error has been sent to the application logs.": [
        "Votre requête de recherche n'était pas valide. Veuillez la réviser et réessayer. L'erreur complète a été envoyée aux journaux des applications."
      ],
      "Your search returned no matching ": [
        "Votre recherche n’a pas été féconde"
      ],
      "Your search returned no matching ${name}.": [
        "Votre recherche n'a donné aucun résultat correspondant à ${name}."
      ],
      "Your search returned no matching DEBs.": [
        "Votre recherche n’a renvoyé aucun DEB."
      ],
      "Your search returned no matching Module streams.": [
        "Votre recherche n'a donné aucun flux de modules correspondant."
      ],
      "Your search returned no matching activation keys.": [
        "Votre recherche a donné zéro clé d'activation."
      ],
      "Your search returned no matching hosts.": [
        "Votre recherche n’a renvoyé aucun hôte."
      ],
      "Your search returned no matching non-modular RPMs.": [
        ""
      ],
      "Yum": [
        "Yum"
      ],
      "a content unit": [
        "une unité de contenu"
      ],
      "a custom CDN URL": [
        "une URL CDN personnalisée"
      ],
      "a deb package": [
        "Package Deb"
      ],
      "a docker manifest": [
        "un manifeste de docker"
      ],
      "a docker manifest list": [
        "une liste de manifestes de dockers"
      ],
      "a docker tag": [
        "une balise Docker"
      ],
      "a file": [
        "un fichier"
      ],
      "a module stream": [
        "un flux de module"
      ],
      "a package": [
        "un package"
      ],
      "a package group": [
        "un groupe de package"
      ],
      "actions not found": [
        "actions non trouvées"
      ],
      "activation key": [
        ""
      ],
      "activation key identifier": [
        "identifiant de la clé d'activation"
      ],
      "activation key name to filter by": [
        "Nom de la clé d'activation avec lequel filtrer"
      ],
      "activation keys": [
        "clés d'activation"
      ],
      "add all module streams without errata to the included/excluded list. (module stream filter only)": [
        "ajouter tous les flux de modules sans errata à la liste incluse/exclue. (filtre de package uniquement)."
      ],
      "add all packages without errata to the included/excluded list. (package filter only)": [
        "ajouter tous les packages sans errata à la liste incluse/exclue. (filtre de package uniquement)."
      ],
      "all environments": [
        "Tous les environnements"
      ],
      "all packages": [
        "tous les packages"
      ],
      "all packages update": [
        "mise à jour de tous les packages"
      ],
      "all packages update failed": [
        "échec de la mise à jour de tous les packages"
      ],
      "allow unauthenticed pull of container images": [
        "permettre l’extraction non authentifiée d'images de conteneurs"
      ],
      "already belongs to the content view": [
        "appartient déjà à la vue du contenu"
      ],
      "already taken": [
        "déjà pris"
      ],
      "an ansible collection": [
        "une collection accessible"
      ],
      "an erratum": [
        "un erratum"
      ],
      "an organization": [
        "une organisation"
      ],
      "are only allowed for Yum repositories.": [
        "ne sont autorisés que pour les référentiels Yum."
      ],
      "attempted to sync a non-library repository.": [
        ""
      ],
      "attempted to sync without a feed URL": [
        "a tenté de sync sans URL de flux"
      ],
      "auto attach subscriptions upon registration": [
        "joindre automatiquement les abonnements lors de l'enregistrement"
      ],
      "base url to perform repo discovery on": [
        "url de base sur lequel effectuer la découverte de référentiel  "
      ],
      "bug fix": [
        ""
      ],
      "bug fixes": [
        ""
      ],
      "bulk add filter rules": [
        "bulk - ajouter règles de filtre"
      ],
      "bulk delete filter rules": [
        "bulk - supprimer règles de filtrage"
      ],
      "can the activation key have unlimited hosts": [
        "La clé d'activation peut-elle avoir des hôtes de contenu illimités ?"
      ],
      "can't be blank": [
        "ne peut pas être vide"
      ],
      "cannot add filter to generated content views": [
        "Impossible d'ajouter un filtre aux vues de contenu généré"
      ],
      "cannot add filter to import-only view": [
        "impossible d'ajouter un filtre à la vue d'importation seulement"
      ],
      "cannot be a binary file.": [
        "ne peut pas être un fichier binaire."
      ],
      "cannot be blank": [
        "ne peut pas être vide"
      ],
      "cannot be blank when Repository URL is provided.": [
        "ne peut pas être vide lorsque l'URL du référentiel est fournie."
      ],
      "cannot be changed.": [
        "ne peut pas être changé."
      ],
      "cannot be deleted if it has been promoted.": [
        "ne peut pas être désactivé si il a déjà été promu."
      ],
      "cannot be less than one": [
        "ne peut pas être inférieur à un"
      ],
      "cannot be lower than current usage count (%s)": [
        "ne peut pas être inférieur au nombre actuel d'utilisations (%s)"
      ],
      "cannot be nil": [
        "ne peut pas être nul"
      ],
      "cannot be set because unlimited hosts is set": [
        "ne peut pas être fixé parce que le nombre d'hôtes est illimité"
      ],
      "cannot be set for repositories without 'Additive' mirroring policy.": [
        ""
      ],
      "cannot contain characters other than ascii alpha numerals, '_', '-'. ": [
        "ne peut pas contenir de caractères autres que des alphanumériques ASCII, '_' ou '-'. "
      ],
      "cannot contain commas": [
        "ne peut pas contenir de virgules"
      ],
      "cannot contain filters if composite view": [
        "ne peut pas contenir de filtres si l'affichage composite"
      ],
      "cannot contain filters whose repositories do not belong to this content view": [
        "ne peut pas contenir de filtres dont les référentiels n'appartiennent pas à cet affichage de contenu"
      ],
      "cannot contain more than %s characters": [
        "ne peut pas contenir plus de %s caractères"
      ],
      "change the host's content source.": [
        ""
      ],
      "checking %s task status": [
        "vérification de l'état de la tâche %s "
      ],
      "checking Pulp task status": [
        "vérification du statut de tâche Pulp"
      ],
      "click here": [
        "cliquez ici"
      ],
      "composite content view identifier": [
        "Identifiant d'affichage du contenu composite"
      ],
      "composite content view numeric identifier": [
        "Identifiant numérique d'affichage du contenu composite"
      ],
      "content release version": [
        "version du contenu de version"
      ],
      "content type ('deb', 'docker_manifest', 'file', 'ostree_ref', 'rpm', 'srpm')": [
        "content type ('deb', 'docker_manifest', 'file', 'ostree_ref', 'rpm', 'srpm')"
      ],
      "content type ('deb', 'file', 'ostree_ref', 'rpm', 'srpm')": [
        ""
      ],
      "content view component ID. Identifier of the component association": [
        "ID du composant de visualisation du contenu. Identificateur de l'association de composants"
      ],
      "content view filter identifier": [
        "Identifiant du filtre de l'affichage de contenu"
      ],
      "content view filter rule identifier": [
        "Identifiant de règle de filtrage d’affichage de contenu"
      ],
      "content view identifier": [
        "identifiant d'affichage du contenu"
      ],
      "content view identifier of the component who's latest version is desired": [
        "l'identifiant de la vue du contenu du composant dont la dernière version est souhaitée"
      ],
      "content view node publish": [
        "publication de nœud d'affichage de contenu"
      ],
      "content view numeric identifier": [
        "identifiant numérique d'affichage du contenu"
      ],
      "content view publish": [
        "publication d'affichage de contenu"
      ],
      "content view refresh": [
        "actualisation d'affichage de contenu"
      ],
      "content view to reassign orphaned activation keys to": [
        "affichage de contenu auquel réassigner des clés d'activation orphelines"
      ],
      "content view to reassign orphaned systems to": [
        "affichage de contenu auquel réassigner des systèmes orphelins"
      ],
      "content view version identifier": [
        "identifiant de version d'affichage de contenu"
      ],
      "content view version identifiers to be deleted": [
        "identifiants de la version de l'affichage du contenu à supprimer"
      ],
      "content view versions to compare": [
        "versions d'affichage de contenu à comparer"
      ],
      "create a custom product": [
        ""
      ],
      "create a filter for a content view": [
        "créer un filtre pour un affichage de contenu"
      ],
      "day": [
        ""
      ],
      "days": [
        ""
      ],
      "deb, package, package group, or docker tag names": [
        "deb, packages, groupes de packages ou noms de balises docker"
      ],
      "deb_ids is not an array": [
        "package_ids n'est pas sous forme de table"
      ],
      "deb_names_for_job_template: Action must be one of %s": [
        ""
      ],
      "delete a filter": [
        "supprimer un filtre"
      ],
      "delete the content view with all the versions and environments": [
        "supprimer l’affichage de contenu avec toutes ses versions et environnements "
      ],
      "description": [
        "description"
      ],
      "description of the environment": [
        "description de l'environnement"
      ],
      "description of the filter": [
        "description du filtre"
      ],
      "description of the repository": [
        "description du référentiel"
      ],
      "disk": [
        "disque"
      ],
      "download policy for deb, docker, file and yum repos (either 'immediate' or 'on_demand')": [
        ""
      ],
      "enables or disables synchronization": [
        "active ou désactive la synchronisation"
      ],
      "enhancement": [
        ""
      ],
      "enhancements": [
        ""
      ],
      "environment identifier": [
        "identifiant d'environnement"
      ],
      "environment numeric identifier": [
        "identifiant numérique d'environnement"
      ],
      "environment numeric identifiers to be removed": [
        "identifiants numériques d'environnement à supprimer"
      ],
      "environment to reassign orphaned activation keys to": [
        "environnement auquel réassigner des clés d'activation orphelines"
      ],
      "environment to reassign orphaned systems to": [
        "environnement auquel réassigner des systèmes orphelins"
      ],
      "environments": [
        "environnements"
      ],
      "errata_id of the content view filter rule": [
        "errata_id de la règle de filtrage de la vue du contenu"
      ],
      "errata_ids is a required parameter": [
        "errata_ids est un paramètre obligatoire"
      ],
      "erratum: IDs or a select all object": [
        "erratum : ID ou objet tout sélectionner"
      ],
      "erratum: allow types not matching a valid errata type": [
        ""
      ],
      "erratum: end date (YYYY-MM-DD)": [
        "erratum : date de fin (AAAA-MM-JJ)"
      ],
      "erratum: id": [
        "erratum : id"
      ],
      "erratum: search using the 'Issued On' or 'Updated On' column of the errata. Values are 'issued'/'updated'": [
        "erratum: recherche utilisant la colonne 'Émis le' ou 'Mis à jour le' de l'errata. Les valeurs sont 'émis'/'mis à jour'"
      ],
      "erratum: start date (YYYY-MM-DD)": [
        "erratum : date de début (AAAA-MM-JJ)"
      ],
      "erratum: types (enhancement, bugfix, security)": [
        "erratum : types (améliorations, corrections de bogues, sécurité)"
      ],
      "filter by interval": [
        "filtrer par intervalle"
      ],
      "filter by name": [
        "filtrer par nom"
      ],
      "filter by sync date": [
        "filtrer par date de sync"
      ],
      "filter content view filters by name": [
        "Filtrer les filtres d'affichage de contenu par nom"
      ],
      "filter identifier": [
        "identifiant de filtre"
      ],
      "filter identifiers": [
        "identifiants de filtre"
      ],
      "filter only environments containing this label": [
        "filtrer uniquement les environnements contenant ce libellé"
      ],
      "filter only environments containing this name": [
        "filtrer uniquement les environnements contenant ce nom"
      ],
      "for repository '%{name}' is not unique and cannot be created in '%{env}'. Its Container Repository Name (%{container_name}) conflicts with an existing repository.  Consider changing the Lifecycle Environment's Registry Name Pattern to something more specific.": [
        "car le référentiel \\\"%{name}\\\" n'est pas unique et ne peut pas être créé dans %{env}. Son nom de référentiel de conteneurs (%{container_name}) est en conflit avec un référentiel existant.  Envisagez de modifier le modèle de nom de registre de l'environnement du cycle de vie pour qu'il soit plus spécifique."
      ],
      "force content view promotion and bypass lifecycle environment restriction": [
        "forcer la promotion de la vue de contenu et contourner la restriction de l'environnement de cycle de vie"
      ],
      "foreman-tasks service not running or is not ready yet": [
        "le service foreman-tasks service n'est pas en cours d'exécution ou n'est pas encore prêt"
      ],
      "has already been taken": [
        "a déjà été pris"
      ],
      "has already been taken for a product in this organization.": [
        "a déjà été pris comme produit dans cette organisation."
      ],
      "has already been taken for this product.": [
        "a déjà été pris pour ce produit."
      ],
      "here": [
        ""
      ],
      "host": [
        ""
      ],
      "host collection name to filter by": [
        "nom de la collection d'hôte avec lequel filtrer"
      ],
      "hosts": [
        "hôtes"
      ],
      "how often synchronization should run": [
        "la fréquence à laquelle la synchronisation doit s'exécuter"
      ],
      "id of a host": [
        "id d'un hôte"
      ],
      "id of host": [
        "id de l'hôte"
      ],
      "id of the gpg key that will be assigned to the new repository": [
        "id de la clé gpg qui sera assignée au nouveau référentiel"
      ],
      "identifier of the version of the component content view": [
        "l'identifiant de la version de l’affichage du contenu du composant"
      ],
      "ids to filter content by": [
        "ID par lesquels filtrer le contenu"
      ],
      "if true, Katello will verify the upstream url's SSL certifcates are signed by a trusted CA": [
        "si c'est le cas, Katello vérifiera que les certificats SSL de l'url en amont sont signés par une AC de confiance"
      ],
      "initiating %s task": [
        "initier la tâche %s "
      ],
      "initiating Pulp task": [
        "initialisation d'une tâche Pulp"
      ],
      "installed": [
        ""
      ],
      "installing errata...": [
        "installation de l'errata..."
      ],
      "installing erratum...": [
        "installation de l'erratum..."
      ],
      "installing or updating packages": [
        "l'installation ou la mise à jour de paquets"
      ],
      "installing package group...": [
        "installation du groupe de packages..."
      ],
      "installing package groups...": [
        "installation des groupes de packages..."
      ],
      "installing package...": [
        "installation du package..."
      ],
      "installing packages...": [
        "installation des packages..."
      ],
      "interpret specified object to return only Repositories that can be associated with specified object.  Only 'content_view' & 'content_view_version' are supported.": [
        "Interprète l'objet spécifié pour qu’il ne retourne que les référentiels qui peuvent être associés à l'objet spécifié. La valeur 'content_view' est prise en charge."
      ],
      "invalid container image name": [
        "nom de l'image du conteneur non valide"
      ],
      "invalid: Repositories can only require one OS version.": [
        "invalide : les référentiels ne peuvent exiger qu'une seule version du système d'exploitation."
      ],
      "invalid: The content source must sync the lifecycle environment assigned to the host. See the logs for more information.": [
        ""
      ],
      "is already attached to the capsule": [
        "est déjà attaché à la capsule"
      ],
      "is invalid": [
        "est invalide"
      ],
      "is not a valid type. Must be one of the following: %s": [
        "n'est pas un type valide. Doit être l'un des suivants : %s"
      ],
      "is not allowed for ACS. Must be one of the following: %s": [
        "n'est pas autorisé pour l'ACS. Doit être l'un des éléments suivants : %s"
      ],
      "is not enabled. must be one of the following: %s": [
        "n’est pas activé. Doit correspondre à un parmi :%s"
      ],
      "is only allowed for Yum repositories.": [
        "ne sont autorisés que pour les référentiels Yum."
      ],
      "label of the environment": [
        "Balise de l'environnement"
      ],
      "label of the repository": [
        "libellé du référentiel"
      ],
      "limit to only repositories with this download policy": [
        "limiter aux dépôts ayant cette politique de téléchargement"
      ],
      "list filters": [
        "répertorier les filtres"
      ],
      "list of repository ids": [
        "liste d'ids de référentiel "
      ],
      "list of rpm filename strings to include in published version": [
        "liste des chaînes de noms de fichiers rpm à inclure dans la version publiée"
      ],
      "max_hosts must be given a value if this host collection is not unlimited.": [
        "max_hosts doit recevoir une valeur si cette collection d'hôtes n'est pas illimitée."
      ],
      "maximum number of registered content hosts": [
        "nombre maximum d'hôtes de contenu enregistrés"
      ],
      "may not be less than the number of hosts associated with the host collection.": [
        "ne peut pas être inférieur au nombre d'hôtes de associés à la collection d'hôtes"
      ],
      "module stream ids": [
        "Ids des flux de modules"
      ],
      "module streams not found": [
        "modules de flux non trouvés"
      ],
      "multi-environment activation key": [
        ""
      ],
      "multi-environment activation keys": [
        ""
      ],
      "multi-environment host": [
        ""
      ],
      "multi-environment hosts": [
        ""
      ],
      "must be %{gpg_key} or %{cert}": [
        "doit être %{gpg_key} ou %{cert}"
      ],
      "must be a positive integer value.": [
        "doit être une valeur entière positive."
      ],
      "must be one of the following: %s": [
        "doit être une des valeurs suivantes : %s"
      ],
      "must be one of: %s": [
        "doit être une des valeurs suivantes : %s"
      ],
      "must be true or false": [
        ""
      ],
      "must be unique within one organization": [
        "doit être unique dans une organisation"
      ],
      "must contain '%s'": [
        "doit contenir '%s'"
      ],
      "must contain GPG Key": [
        "doit contenir une clé GPG"
      ],
      "must contain at least %s character": [
        "doit contenir au moins %s caractère(s)"
      ],
      "must contain valid  Public GPG Key": [
        "doit contenir une clé GPG publique valide"
      ],
      "must contain valid Public GPG Key": [
        "doit contenir une clé GPG publique valide"
      ],
      "must not be a negative value.": [
        "ne doit pas correspondre à une valeur négative."
      ],
      "must not contain leading or trailing white spaces.": [
        "ne doit pas contenir d'espace comme premier ou dernier caractère."
      ],
      "name": [
        "nom"
      ],
      "name of organization": [
        "nom de d'organisation"
      ],
      "name of the content view filter rule": [
        "nom de la règle de filtrage d'affichage du contenu"
      ],
      "name of the environment": [
        "nom de l'environnement"
      ],
      "name of the filter": [
        "nom du filtre"
      ],
      "name of the organization": [
        "nom de l'organisation"
      ],
      "name of the repository": [
        "nom du référentiel"
      ],
      "name of the subscription": [
        "nom de l'abonnement"
      ],
      "new name for the filter": [
        "nouveau nom du filtre"
      ],
      "new name to be given to the environment": [
        "nouveau nom à donner à l'environnement"
      ],
      "no": [
        "non"
      ],
      "no global default": [
        "pas de défaut global"
      ],
      "obtain manifest history for subscriptions": [
        "obtenir l'historique du fichier manifeste pour les abonnements"
      ],
      "of environment must be unique within one organization": [
        "de l'environnement doit être unique dans l'organisation"
      ],
      "only show the repositories readable by this user with this username": [
        "afficher uniquement les dépôts lisibles par cet utilisateur avec ce nom d'utilisateur"
      ],
      "organization ID": [
        "ID d’organisation"
      ],
      "organization identifier": [
        "identifiant de l'organisation"
      ],
      "package group: uuid": [
        "Mise à jour de groupes de packages"
      ],
      "package, package group, or docker tag names": [
        "packages, groupes de packages ou balises docker"
      ],
      "package, package group, or docker tag: name": [
        "package, groupe de packages ou balise docker : nom"
      ],
      "package: architecture": [
        "package: architecture"
      ],
      "package: maximum version": [
        "package : version maximum"
      ],
      "package: minimum version": [
        "package : version minimum"
      ],
      "package: version": [
        "package : version"
      ],
      "package_ids is not an array": [
        "package_ids n'est pas une table"
      ],
      "package_names_for_job_template: Action must be one of %s": [
        "package_names_for_job_template : l'action doit être l'une des suivantes %s"
      ],
      "params 'show_all_for' and 'available_for' must be used independently": [
        "les paramètres \\\"show_all_for\\\" et \\\"available_for\\\" doivent être utilisés indépendamment"
      ],
      "pattern for container image names": [
        "modèle pour les noms d'images de conteneurs"
      ],
      "perform an incremental import": [
        "effectuer une importation progressive"
      ],
      "policies for HTTP proxy for content sync": [
        "politiques pour le proxy HTTP pour la synchronisation du contenu"
      ],
      "policy for HTTP proxy for content sync": [
        "politique pour le proxy HTTP pour la sync du contenu"
      ],
      "prior environment can only have one child": [
        "l'environnement précédent ne peut avoir qu'un seul enfant"
      ],
      "product numeric identifier": [
        "identifiant numérique du produit"
      ],
      "register_hostname_fact set for %s, but no fact found, or was localhost.": [
        "register_hostname_fact est réglé sur %s, mais aucun fact n'a été trouvé, ou était localhost."
      ],
      "removing package group...": [
        "suppression du groupe de packages..."
      ],
      "removing package groups...": [
        "suppression des groupes de packages..."
      ],
      "removing package...": [
        "suppression du package..."
      ],
      "removing packages...": [
        "suppression des packages..."
      ],
      "repo label": [
        "libélé de référentiel"
      ],
      "repository ID": [
        "ID référentiel"
      ],
      "repository id": [
        "ID du référentiel"
      ],
      "repository identifier": [
        "identifiant de référentiel"
      ],
      "repository source url": [
        "url de la source du référentiel"
      ],
      "root-node of collection contained in responses (default: 'results')": [
        "nœud racine de collection contenu dans les réponses (défaut : 'results')"
      ],
      "root-node of single-resource responses (optional)": [
        "nœud racine de réponses à ressource unique (facultatif)"
      ],
      "rule identifier": [
        "identifiant de règle"
      ],
      "security advisories": [
        ""
      ],
      "security advisory": [
        ""
      ],
      "selected host": [
        ""
      ],
      "selected hosts": [
        ""
      ],
      "service level": [
        "niveau de service"
      ],
      "set true if you want to see only library environments": [
        "définir comme vrai si vous souhaitez voir les environnements de bibliothèque uniquement"
      ],
      "sha256": [
        "sha256"
      ],
      "show archived repositories": [
        "afficher les référentiels d'archives"
      ],
      "show filter info": [
        "afficher les informations de filtre"
      ],
      "show repositories in Library and the default content view": [
        "afficher les référentiels dans la Bibliothèque et l'affichage de contenu par défaut"
      ],
      "some executors are not responding, check %{status_url}": [
        "certains exécuteurs ne répondent pas, vérifier %{status_url}"
      ],
      "specifies if content should be included or excluded, default: inclusion=false": [
        "indique si le contenu doit être inclus ou exclu, par défaut : inclusion=false"
      ],
      "start datetime of synchronization": [
        "date de lancement de la synchronisation"
      ],
      "subscriptions not specified": [
        "abonnements non spécifiés"
      ],
      "sync plan description": [
        "description du plan de sync"
      ],
      "sync plan name": [
        "nom du plan de sync"
      ],
      "sync plan numeric identifier": [
        "identifiant numérique du plan de sync"
      ],
      "system registration": [
        ""
      ],
      "the documentation.": [
        ""
      ],
      "the following attributes can not be updated for the Red Hat provider: [ %s ]": [
        "les attributs suivants ne peuvent pas être mis à jour pour le fournisseur Red Hat : [ %s ]"
      ],
      "the host": [
        ""
      ],
      "the hosts": [
        ""
      ],
      "to": [
        "à"
      ],
      "true if the latest version of the component's content view is desired": [
        "vrai si la dernière version de la vue du contenu du composant est souhaitée"
      ],
      "true if the latest version of the components content view is desired": [
        "vrai si la dernière version de la vue du contenu des composants est souhaitée"
      ],
      "true if this repository can be published via HTTP": [
        "vrai si ce référentiel peut être publié via HTTP"
      ],
      "type of filter (e.g. deb, rpm, package_group, erratum, erratum_id, erratum_date, docker, modulemd)": [
        "type de filtre (e.g. deb, rpm, package_group, erratum, erratum_id, erratum_date, docker, modulemd)"
      ],
      "types of filters": [
        "types de filtres"
      ],
      "unknown permission for %s": [
        "permission inconnue pour %s"
      ],
      "unlimited": [
        "illimité"
      ],
      "update a filter": [
        "mise à jour d'un filtre"
      ],
      "updated": [
        ""
      ],
      "updating package group...": [
        "mise à jour du groupe de packages..."
      ],
      "updating package groups...": [
        "mise à jour des groupes de packages..."
      ],
      "updating package...": [
        "mise à jour du package..."
      ],
      "updating packages...": [
        "mise à jour des packages..."
      ],
      "upstream Foreman server": [
        "serveur Foreman en amont"
      ],
      "url not defined.": [
        "url non définie."
      ],
      "via customized remote execution": [
        "via exécution à distance personnalisée"
      ],
      "via remote execution": [
        "via Exécution à distante"
      ],
      "view content view tabs.": [
        "voir onglets d’affichage de contenu"
      ],
      "waiting for %s to finish the task": [
        "en attendant que %s termine la tâche"
      ],
      "waiting for Pulp to finish the task %s": [
        "attend que Pulp termine la tâche %s"
      ],
      "waiting for Pulp to start the task %s": [
        "attend que Pulp démarre la tâche %s"
      ],
      "whitespace-separated list of architectures to be synced from deb-archive": [
        "liste d'architectures séparées par des espaces blancs à synchroniser avec deb-archive"
      ],
      "whitespace-separated list of releases to be synced from deb-archive": [
        "liste des versions à synchroniser avec deb-archive, séparée par des espaces"
      ],
      "whitespace-separated list of repo components to be synced from deb-archive": [
        "liste des composants du dépôt à synchroniser à partir de deb-archive, séparée par des espaces"
      ],
      "with": [
        "avec"
      ],
      "yes": [
        "oui"
      ],
      "{0} items selected": [
        "{0} éléments sélectionnés"
      ],
      "{enableRedHatRepos} or {createACustomProduct}.": [
        ""
      ],
      "{numberOfActivationKeys} activation key will be assigned to content view {cvName} in": [
        "{numberOfActivationKeys} la clé d'activation sera attribuée à la vue du contenu {cvName} dans"
      ],
      "{numberOfActivationKeys} activation keys will be assigned to content view {cvName} in": [
        "{numberOfActivationKeys} Les clés d'activation seront attribuées à la vue de contenu {cvName} dans"
      ],
      "{numberOfHosts} host will be assigned to content view {cvName} in": [
        "{numberOfHosts} L'hôte sera affecté à la vue du contenu {cvName} en"
      ],
      "{numberOfHosts} hosts will be assigned to content view {cvName} in": [
        "{numberOfHosts} Les hôtes seront assignés à la vue du contenu {cvName} en"
      ],
      "{versionOrVersions} {versionList} will be deleted and will no longer be available for promotion.": [
        "{versionOrVersions} {versionList} sera supprimée et ne sera plus disponible pour la promotion."
      ],
      "{versionOrVersions} {versionList} will be removed from the following environments:": [
        "{versionOrVersions} {versionList} sera supprimé des environnements suivants :"
      ],
      "{versionOrVersions} {versionList} will be removed from the listed environment and will no longer be available for promotion.": [
        "{versionOrVersions} {versionList} sera retiré de l'environnement répertorié et ne sera plus disponible pour la promotion."
      ],
      "{versionOrVersions} {versionList} will be removed from the listed environments and will no longer be available for promotion.": [
        "{versionOrVersions} {versionList} sera retiré des environnements répertoriés et ne sera plus disponible pour la promotion."
      ],
      "{versionOrVersions} {versionList} will be removed from the {envLabel} environment.": [
        "{versionOrVersions} {versionList} sera supprimé de l'environnement {envLabel}."
      ]
    }
  }
};
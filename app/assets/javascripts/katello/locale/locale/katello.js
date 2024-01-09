 locales['katello'] = locales['katello'] || {}; locales['katello']['locale'] = {
  "domain": "katello",
  "locale_data": {
    "katello": {
      "": {
        "Project-Id-Version": "",
        "Last-Translator": "Baptiste Agasse <baptiste.agasse@gmail.com>, 2023",
        "Language-Team": "French (https://app.transifex.com/foreman/teams/114/fr/)",
        "Content-Type": "text/plain; charset=UTF-8",
        "Content-Transfer-Encoding": "8bit",
        "Language": "fr",
        "Plural-Forms": "nplurals=3; plural=(n == 0 || n == 1) ? 0 : n != 0 && n % 1000000 == 0 ? 1 : 2;",
        "lang": "locale",
        "domain": "katello",
        "plural_forms": "nplurals=3; plural=(n == 0 || n == 1) ? 0 : n != 0 && n % 1000000 == 0 ? 1 : 2;"
      },
      "-- select an interval --": [
        "-- sélectionner un intervalle --"
      ],
      "(future)": [
        "(future)"
      ],
      "{{ 'Add Selected' | translate }}": [
        "{{ 'Add Selected' | translate }}"
      ],
      "{{ contentCredential.name }}": [
        "{{ contentCredential.name }}"
      ],
      "{{ deb.hosts_applicable_count }} Host(s)": [
        "{{ deb.hosts_applicable_count }} Hôte(s)"
      ],
      "{{ deb.hosts_applicable_count || 0 }} Applicable,": [
        "{{ deb.hosts_applicable_count || 0 }} Applicable,"
      ],
      "{{ deb.hosts_available_count }} Host(s)": [
        "{{ deb.hosts_available_count }} Hôte(s)"
      ],
      "{{ deb.hosts_available_count || 0 }} Upgradable": [
        "{{ deb.hosts_available_count || 0 }} Mise à jour"
      ],
      "{{ errata.hosts_applicable_count || 0 }} Applicable,": [
        "{{ errata.hosts_applicable_count || 0 }} Applicable,"
      ],
      "{{ errata.hosts_available_count || 0 }} Installable": [
        "{{ errata.hosts_available_count || 0 }} Installable"
      ],
      "{{ errata.title }}": [
        "{{ errata.title }}"
      ],
      "{{ file.name }}": [
        "{{ file.name }}"
      ],
      "{{ host.name }}": [
        "{{ host.name }}"
      ],
      "{{ host.rhel_lifecycle_status_label }}": [
        "{{ host.rhel_lifecycle_status_label }}"
      ],
      "{{ host.subscription_facet_attributes.user.login }}": [
        "{{ host.subscription_facet_attributes.user.login }}"
      ],
      "{{ installedDebCount }} Host(s)": [
        "{{ installedDebCount }} Hôte(s)"
      ],
      "{{ installedPackageCount }} Host(s)": [
        "{{ installedPackageCount }} Hôte(s)"
      ],
      "{{ package.hosts_applicable_count }} Host(s)": [
        "{{ package.hosts_applicable_count }} Hôte(s)"
      ],
      "{{ package.hosts_applicable_count || 0 }} Applicable,": [
        "{{ package.hosts_applicable_count || 0 }} Applicable,"
      ],
      "{{ package.hosts_available_count }} Host(s)": [
        "{{ package.hosts_available_count }} Hôte(s)"
      ],
      "{{ package.hosts_available_count || 0 }} Upgradable": [
        "{{ package.hosts_available_count || 0 }} pouvant être mis à niveau"
      ],
      "{{ package.human_readable_size }} ({{ package.size }} Bytes)": [
        "{{ package.human_readable_size }} ( {{ package.size }} Octets )"
      ],
      "{{ product.active_task_count }}": [
        "{{ product.active_task_count }}"
      ],
      "{{ product.name }}": [
        "{{ product.name }}"
      ],
      "{{ repo.last_sync_words }} ago": [
        "Il y a {{ repo.last_sync_words }}"
      ],
      "{{ repository.content_counts.ansible_collection || 0 }} Ansible Collections": [
        "{{ repository.content_counts.ansible_collection || 0 }} Collections Ansible"
      ],
      "{{ repository.content_counts.deb || 0 }} deb Packages": [
        "{{ repository.content_counts.deb || 0 }} deb Packages"
      ],
      "{{ repository.content_counts.docker_manifest || 0 }} Container Image Manifests": [
        "{{ repository.content_counts.docker_manifest || 0 }} Manifeste de l'image du conteneur"
      ],
      "{{ repository.content_counts.docker_manifest_list || 0 }} Container Image Manifest Lists": [
        "{{ repository.content_counts.docker_manifest_list || 0 }} Listes des manifestes d'images du conteneur"
      ],
      "{{ repository.content_counts.docker_tag || 0 }} Container Image Tags": [
        "{{ repository.content_counts.docker_tag || 0 }} Étiquettes d'images de conteneurs"
      ],
      "{{ repository.content_counts.erratum || 0 }} Errata": [
        "{{ repository.content_counts.erratum || 0 }} Errata"
      ],
      "{{ repository.content_counts.file || 0 }} Files": [
        "{{ repository.content_counts.file || 0 }} Fichiers"
      ],
      "{{ repository.content_counts.rpm || 0 }} Packages": [
        "{{ repository.content_counts.rpm || 0 }} Packages"
      ],
      "{{ repository.content_counts.srpm }} Source RPMs": [
        "{{ repository.content_counts.srpm }} RPM source"
      ],
      "{{ repository.last_sync_words }} ago": [
        "Il y a {{ repository.last_sync_words }}"
      ],
      "{{ repository.name }}": [
        "{{ repository.name }}"
      ],
      "{{ type.display }}": [
        "{{ type.display }}"
      ],
      "{{header}}": [
        "{{header}}"
      ],
      "{{option.description}}": [
        "{{option.description}}"
      ],
      "{{urlDescription}}": [
        "{{urlDescription}}"
      ],
      "* These marked Content View Versions are from Composite Content Views.  Their components needing updating are listed underneath.": [
        "* Ces versions marquées d’affichages de contenu sont issues des affichages de contenus composites.  Leurs composants nécessitant une mise à jour sont énumérés ci-dessous."
      ],
      "/foreman_tasks/tasks/%taskId": [
        "/foreman_tasks/tasks/%taskId"
      ],
      "/job_invocations": [
        "/job_invocations"
      ],
      "%(consumed)s out of %(quantity)s": [
        "%(consumed)s sur %(quantity)s"
      ],
      "%count environment(s) can be synchronized: %envs": [
        "Les environnements %count peuvent être synchronisés : %envs"
      ],
      "<a href=\\\"/foreman_tasks/tasks/{{repository.last_sync.id}}\\\">{{ repository.last_sync.result | capitalize}}</a>": [
        "<a href=\\\"/foreman_tasks/tasks/{{repository.last_sync.id}}\\\">{{ repository.last_sync.result | capitalize}}</a>"
      ],
      "<b>Additive:</b> new content available during sync will be added to the repository, and no content will be removed.": [
        "<b>Additions :</b> le nouveau contenu disponible lors de la sync sera ajouté au référentiel, et aucun contenu ne sera supprimé."
      ],
      "<b>Description</b>": [
        "<b>Description</b>"
      ],
      "<b>Issued</b>": [
        "<b>publié sur</b>"
      ],
      "<b>Mirror Complete</b>: a sync behaves exactly like \\\"Mirror Content Only\\\", but also mirrors metadata as well.  This is the fastest method, and preserves repository signatures, but is only supported by yum and not by all upstream repositories.": [
        "<b>Mirrorisation terminée</b>: une synchronisation se comporte exactement comme \\\"Mirror Content Only\\\", mais fait également le miroir des métadonnées.  C'est la méthode la plus rapide, et qui préserve les signatures du référentiel, mais elle n'est supportée que par yum et pas par tous les référentiels en amont."
      ],
      "<b>Mirror Content Only</b>: any new content available during sync will be added to the repository and any content removed from the upstream repository will be removed from the local repository.": [
        "<b>Contenu de mirrorisation uniquement</b>: tout nouveau contenu disponible pendant la sync sera ajouté au référentiel et tout contenu supprimé du référentiel amont sera supprimé du référentiel local."
      ],
      "<b>Module Streams</b>": [
        "<b>Flux de modules</b>"
      ],
      "<b>Packages</b>": [
        "<b>Paquets</b>"
      ],
      "<b>Reboot Suggested</b>": [
        "<b>Redémarrage suggéré</b>"
      ],
      "<b>Solution</b>": [
        "<b>Solution</b>"
      ],
      "<b>Title</b>": [
        "<b>Titre</b>"
      ],
      "<b>Type</b>": [
        "<b>Type</b>"
      ],
      "<b>Updated</b>": [
        "<b>Mis à jour</b>"
      ],
      "<i class=\\\"fa fa-warning inline-icon\\\"></i>\\n  This Host is not currently registered with subscription-manager. Use the <a href=\\\"/hosts/register\\\">Register Host</a> workflow to complete registration.": [
        "<i class=\\\"fa fa-warning inline-icon\\\"></i>\\n  Cet hôte n'est pas actuellement enregistré dans subscription-manager. Cliquer sur <a href=\\\"/hosts/register\\\">Enregistrer Hôte</a> pour compléter l’enregistrement."
      ],
      "1 Content Host": [
        "1 Hôte du contenu",
        "{{ host.subscription_facet_attributes.virtual_guests.length }} Hôtes du contenu",
        "{{ host.subscription_facet_attributes.virtual_guests.length }} Hôtes du contenu"
      ],
      "1 repository sync has errors.": [
        "1 La synchronisation du référentiel comporte des erreurs.",
        "{{ product.sync_summary.error || product.sync_summary.warning }} les synchronisations des référentiels comportent des erreurs.",
        "{{ product.sync_summary.error || product.sync_summary.warning }} les synchronisations des référentiels comportent des erreurs."
      ],
      "1 repository sync in progress.": [
        "1 synchronisation du référentiel en cours.",
        "{{ product.sync_summary.pending}} synchronisation des référentiels en cours..",
        "{{ product.sync_summary.pending}} synchronisation des référentiels en cours.."
      ],
      "1 successfully synced repository.": [
        "1 référentiel synchronisé avec succès.",
        "{{ product.sync_summary.success}} des référentiels synchronisés avec succès.",
        "{{ product.sync_summary.success}} des référentiels synchronisés avec succès."
      ],
      "A comma-separated list of container image tags to exclude when syncing. Source images are excluded by default because they are often large and unwanted.": [
        "Une liste de balises d'images de conteneurs, séparées par des virgules, à exclure lors de la synchronisation. Les images sources sont exclues par défaut car elles sont souvent volumineuses et indésirables."
      ],
      "A comma-separated list of container image tags to include when syncing.": [
        "Une liste de balises d'images de conteneurs, séparées par des virgules, à inclure lors de la synchronisation."
      ],
      "A sync has been initiated in the background, <a href=\\\"/foreman_tasks/tasks/{{ task.id }}\\\">click for more details</a>": [
        "Une synchronisation a été lancée en arrière-plan, <a href=\\\"/foreman_tasks/tasks/{{ task.id }}\\\">cliquez pour plus de détails</a>"
      ],
      "Account": [
        "Compte"
      ],
      "Action Type": [
        "Type d'action"
      ],
      "Actions": [
        "Actions"
      ],
      "Activation Key": [
        "Clé d'activation",
        "Clés d'activation",
        "Clés d'activation"
      ],
      "Activation Key Content": [
        "Contenu Clé d'activation"
      ],
      "Activation Key removed.": [
        "Clé d'activation supprimée"
      ],
      "Activation Key updated": [
        "Clé d'activation mise à jour"
      ],
      "Activation Key:": [
        "Clé d'activation :"
      ],
      "Activation Keys": [
        "Clés d'activation"
      ],
      "Active Tasks": [
        "Tâches actives"
      ],
      "Add": [
        "Ajouter"
      ],
      "Add Content Hosts to:": [
        "Ajouter des hôtes de contenu à :"
      ],
      "Add Host Collections": [
        ""
      ],
      "Add hosts to the host collection to see available actions.": [
        "Ajoutez des hôtes à la collection d'hôtes pour voir les actions disponibles."
      ],
      "Add New Environment": [
        "Ajouter un nouvel environnement"
      ],
      "Add ons": [
        "Add ons"
      ],
      "Add ons:": [
        "Add ons :"
      ],
      "Add Products": [
        "Ajouter des produits"
      ],
      "Add Selected": [
        "Ajouter les éléments sélectionnés"
      ],
      "Add Subscriptions": [
        "Ajouter Abonnements"
      ],
      "Add Subscriptions for Activation Key:": [
        "Ajouter les abonnements pour la clé d'activation :"
      ],
      "Add Subscriptions for Content Host:": [
        "Ajouter des abonnements pour l'hôte de contenu :"
      ],
      "Add To": [
        "Ajouter à"
      ],
      "Added %x host collections to activation key \\\"%y\\\".": [
        "Énumérer les collections d'hôtes %x dans une clé d'activation \\\"%y\\\"."
      ],
      "Added %x host collections to content host \\\"%y\\\".": [
        "Ajout %x collections hôtes à l'hôte de contenu \\\"%y\\\"."
      ],
      "Added %x products to sync plan \\\"%y\\\".": [
        "Ajouter %x produits au plan de synchronisation \\\"%y\\\"."
      ],
      "Adding Lifecycle Environment to the end of \\\"{{ priorEnvironment.name }}\\\"": [
        "Ajouter l'environnement sur le cycle de vie à la fin de \\\"{{ priorEnvironment.name }}\\\""
      ],
      "Additive": [
        "Addition"
      ],
      "Advanced Sync": [
        "Sync Avancée"
      ],
      "Advisory": [
        "Avis"
      ],
      "Affected Hosts": [
        "Hôtes affectés"
      ],
      "All": [
        "Tout"
      ],
      "All Content Views": [
        "Affichages de contenu"
      ],
      "All Lifecycle Environments": [
        "Environnements de cycle de vie"
      ],
      "All Repositories": [
        "Référentiels"
      ],
      "Alternate Content Sources": [
        "Autres sources de contenu"
      ],
      "Alternate Content Sources for": [
        "Autres sources de contenu pour"
      ],
      "An error occured: %s": [
        "Une erreur s'est produite : %s"
      ],
      "An error occurred initiating the sync:": [
        "Une erreur s'est produite en initiant la synchronisation :"
      ],
      "An error occurred removing the Activation Key:": [
        "Une erreur s'est produite lors de la suppression de la clé d'activation :"
      ],
      "An error occurred removing the content hosts.": [
        "Une erreur s'est produite lors de la suppression des hôtes de contenu."
      ],
      "An error occurred removing the environment:": [
        "Une erreur s'est produite en supprimant l'environnement :"
      ],
      "An error occurred removing the Host Collection:": [
        "Une erreur s'est produite lors de la suppression de la collection d'hôtes :"
      ],
      "An error occurred removing the subscriptions.": [
        "Une erreur s'est produite lors de la suppression des abonnements."
      ],
      "An error occurred saving the Activation Key:": [
        "Une erreur s'est produite lors de la sauvegarde de la clé d'activation :"
      ],
      "An error occurred saving the Content Host:": [
        "Une erreur s'est produite lors de la sauvegarde de l'hôte de contenu :"
      ],
      "An error occurred saving the Environment:": [
        "Une erreur s'est produite en sauvegardant l'environnement :"
      ],
      "An error occurred saving the Host Collection:": [
        "Une erreur s'est produite lors de la sauvegarde de la collection de l’hôte :"
      ],
      "An error occurred saving the Product:": [
        "Une erreur s'est produite lors de la sauvegarde du produit :"
      ],
      "An error occurred saving the Repository:": [
        "Une erreur s'est produite lors de la sauvegarde du référentiel :"
      ],
      "An error occurred saving the Sync Plan:": [
        "Une erreur s'est produite lors de la sauvegarde du plan de synchronisation :"
      ],
      "An error occurred trying to auto-attach subscriptions.  Please check your log for further information.": [
        "Une erreur s'est produite en essayant de joindre automatiquement les abonnements.  Veuillez consulter votre journal pour plus d'informations."
      ],
      "An error occurred updating the sync plan:": [
        "Une erreur s'est produite lors de la mise à jour du plan de synchronisation :"
      ],
      "An error occurred while creating the Content Credential:": [
        "Une erreur s'est produite lors de la création des Identifiants de contenu :"
      ],
      "An error occurred while creating the Product: %s": [
        "Une erreur s'est produite lors de la création du produit : %s"
      ],
      "An error occurred:": [
        "Une erreur s'est produite :"
      ],
      "Ansible Collection Authorization": [
        "Autorisation de la collection Ansible"
      ],
      "Ansible Collections": [
        "Collections Ansible"
      ],
      "Applicable": [
        "Applicable"
      ],
      "Applicable Content Hosts": [
        "Hôtes de contenu applicables"
      ],
      "Applicable Deb Packages": [
        "Paquets Deb applicables"
      ],
      "Applicable Errata": [
        "Errata applicables"
      ],
      "Applicable Packages": [
        "Packages applicables"
      ],
      "Applicable To": [
        "Applicable à"
      ],
      "Applicable to Host": [
        "Applicable à l'hôte"
      ],
      "Application": [
        "Application"
      ],
      "Apply": [
        "Appliquer"
      ],
      "Apply {{ errata.errata_id }}": [
        "Appliquer {{ errata.errata_id }}"
      ],
      "Apply {{ errata.errata_id }} to {{ contentHostIds.length  }} Content Host(s)?": [
        "Appliquer {{ errata.errata_id }} à {{ contentHostIds.length  }} hôte(s) de contenu ?"
      ],
      "Apply {{ errata.errata_id }} to all Content Host(s)?": [
        "Appliquer {{ errata.errata_id }} à tous les hôtes de contenu ?"
      ],
      "Apply {{ errataIds.length }} Errata to {{ contentHostIds.length }} Content Host(s)?": [
        "Appliquer {{ errataIds.length }} errata aux {{ contentHostIds.length }} hôtes de contenu ?"
      ],
      "Apply {{ errataIds.length }} Errata to all Content Host(s)?": [
        "Appliquer {{ errataIds.length }} errata à tous les hôtes de contenu ?"
      ],
      "Apply Errata": [
        "Appliquer les errata"
      ],
      "Apply Errata to Content Host \\\"{{host.name}}\\\"?": [
        "Appliquer les errata à l'hôte de contenu \\\"{{host.name}}\\\"?"
      ],
      "Apply Errata to Content Hosts": [
        "Appliquer les errata aux hôtes de contenu"
      ],
      "Apply Errata to Content Hosts immediately after publishing.": [
        "Appliquez les errata aux hôtes de contenu immédiatement après leur publication."
      ],
      "Apply Selected": [
        "Appliquer la sélection"
      ],
      "Apply to Content Hosts": [
        "Appliquer aux Hôtes de contenu"
      ],
      "Apply to Hosts": [
        "Appliquer aux hôtes"
      ],
      "Applying": [
        "Application"
      ],
      "Apt Actions": [
        "Actions Apt"
      ],
      "Arch": [
        "Arch"
      ],
      "Architecture": [
        "Architecture"
      ],
      "Architectures": [
        "Architectures"
      ],
      "Are you sure you want to add the {{ table.numSelected }} content host(s) selected to the host collection(s) chosen?": [
        "Êtes-vous sûr de vouloir ajouter le(s) hôte(s) de contenu {{ table.numSelected }} sélectionné(s) à la (aux) collection(s) d'hôtes choisie(s) ?"
      ],
      "Are you sure you want to add the sync plan to the selected products(s)?": [
        "Êtes-vous sûr de vouloir ajouter le plan de synchronisation aux produits sélectionnés ?"
      ],
      "Are you sure you want to apply Errata to content host \\\"{{ host.name }}\\\"?": [
        "Êtes-vous sûr de vouloir appliquer les Errata à l'hôte de contenu \\\"{{ host.name }}\\\" ?"
      ],
      "Are you sure you want to apply the {{ table.numSelected }} selected errata to the content hosts chosen?": [
        "Êtes-vous sûr de vouloir appliquer les errata sélectionnés {{ table.numSelected }} aux hôtes de contenu choisis ?"
      ],
      "Are you sure you want to assign the {{ table.numSelected }} content host(s) selected to {{ selected.contentView.name }} in {{ selected.environment.name }}?": [
        "Êtes-vous sûr de vouloir attribuer le(s) hôte(s) de contenu sélectionné(s) {{ table.numSelected }} à {{ selected.contentView.name }} dans {{ selected.environment.name }} ?"
      ],
      "Are you sure you want to delete the {{ table.numSelected }} host(s) selected?": [
        "Êtes-vous sûr de vouloir supprimer le(s) hôte(s) {{ table.numSelected }} sélectionnés ?"
      ],
      "Are you sure you want to disable the {{ table.numSelected }} repository set(s) chosen?": [
        "Êtes-vous sûr de vouloir désactiver le(s) ensemble(s) de référentiels {{ table.numSelected }} choisi(s) ?"
      ],
      "Are you sure you want to enable the {{ table.numSelected }} repository set(s) chosen?": [
        "Êtes-vous sûr de vouloir activer le(s) ensemble(s) de référentiels {{ table.numSelected }} choisi(s) ?"
      ],
      "Are you sure you want to install {{ content.content }} on the {{ getSelectedSystemIds().length }} system(s) selected?": [
        "Êtes-vous sûr de vouloir installer sur le(s){{ content.content }} sur les {{ getSelectedSystemIds().length }} système(s) sélectionné(s) ?"
      ],
      "Are you sure you want to remove {{ content.content }} from the {{ getSelectedSystemIds().length }} system(s) selected?": [
        "Êtes-vous sûr de vouloir supprimer {{ content.content }} de(s) {{ getSelectedSystemIds().length }} système(s) sélectionné(s) ?"
      ],
      "Are you sure you want to remove Activation Key \\\"{{ activationKey.name }}\\\"?": [
        "Êtes-vous sûr de vouloir retirer la clé d'activation \\\"{{ activationKey.name }}\\\" ?"
      ],
      "Are you sure you want to remove Content Credential {{ contentCredential.name }}?": [
        "Êtes-vous sûr de vouloir retirer votre Identifiant de contenu {{ contentCredential.name }}?"
      ],
      "Are you sure you want to remove environment {{ environment.name }}?": [
        "Êtes-vous certain de vouloir supprimer l’environnement {{ environment.name }} ?"
      ],
      "Are you sure you want to remove Host Collection \\\"{{ hostCollection.name }}\\\"?": [
        "Êtes-vous sûr de vouloir supprimer la collection d'hôtes \\\"{{ hostCollection.name }}\\\" ?"
      ],
      "Are you sure you want to remove product \\\"{{ product.name }}\\\"?": [
        "Etes-vous certain de vouloir supprimer le produit \\\"{{ product.name }}\\\" ?"
      ],
      "Are you sure you want to remove repository {{ repositoryWrapper.repository.name }} from all content views?": [
        "Êtes-vous sûr de vouloir supprimer le référentiel {{ repositoryWrapper.repository.name }} de toutes les vues de contenu ?"
      ],
      "Are you sure you want to remove Sync Plan \\\"{{ syncPlan.name }}\\\"?": [
        "Etes-vous certain de vouloir supprimer le Plan Sync \\\"{{ syncPlan.name }}\\\" ?"
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} content unit?": [
        "Êtes-vous sûr de vouloir supprimer l’unité de contenu \\\"{{ table.getSelected()[0].name }}\\\" ?",
        "Êtes-vous sûr de vouloir supprimer les {{ table.numSelected }} unités de contenu sélectionnées ?",
        "Êtes-vous sûr de vouloir supprimer les {{ table.numSelected }} unités de contenu sélectionnées ?"
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} file?": [
        "Etes-vous certain de vouloir supprimer le fichier {{ table.getSelected()[0].name }} ?",
        "Êtes-vous sûr de vouloir supprimer les {{ table.numSelected }} fichiers sélectionnés ?",
        "Êtes-vous sûr de vouloir supprimer les {{ table.numSelected }} fichiers sélectionnés ?"
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} package?": [
        "Êtes-vous sûr de vouloir retirer le package {{ table.getSelected()[0].name }}?",
        "Êtes-vous sûr de vouloir supprimer les {{ table.numSelected }}packages sélectionnés ?",
        "Êtes-vous sûr de vouloir supprimer les {{ table.numSelected }}packages sélectionnés ?"
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} product?": [
        "Êtes-vous sûr de vouloir retirer le produit {{ table.getSelected()[0].name }} ?",
        "Etes-vous certain de vouloir supprimer les {{ table.getSelected().length }} produits ?",
        "Etes-vous certain de vouloir supprimer les {{ table.getSelected().length }} produits ?"
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} repository?": [
        "",
        "",
        ""
      ],
      "Are you sure you want to remove the {{ table.numSelected }} Container Image manifest selected?": [
        "Êtes-vous sûr de vouloir supprimer le manifeste de l'image du conteneur {{ table.numSelected }} sélectionné ?",
        "Êtes-vous sûr de vouloir supprimer les manifestes d'images de conteneurs {{ table.numSelected }} sélectionnés ?",
        "Êtes-vous sûr de vouloir supprimer les manifestes d'images de conteneurs {{ table.numSelected }} sélectionnés ?"
      ],
      "Are you sure you want to remove the {{ table.numSelected }} content host(s) selected from the host collection(s) chosen?": [
        "Êtes-vous sûr de vouloir supprimer le(s) hôte(s) de contenu {{ table.numSelected }} sélectionné(s) dans la (les) collection(s) d'hôtes choisie(s) ?"
      ],
      "Are you sure you want to remove the sync plan from the selected product(s)?": [
        "Êtes-vous sûr de vouloir supprimer le plan de synchronisation du ou des produits sélectionnés ?"
      ],
      "Are you sure you want to reset to default the {{ table.numSelected }} repository set(s) chosen?": [
        "Êtes-vous sûr de vouloir remettre par défaut le(s) ensemble(s) de référentiels {{ table.numSelected }} choisi(s) ?"
      ],
      "Are you sure you want to restart services on content host \\\"{{ host.name }}\\\"?": [
        "Êtes-vous sûr de vouloir redémarrer les services sur l'hôte de contenu \\\"{{ host.name }}\\\" ?"
      ],
      "Are you sure you want to restart the services on the selected content hosts?": [
        "Êtes-vous sûr de vouloir redémarrer les services sur les hôtes de contenu sélectionnés ?"
      ],
      "Are you sure you want to set the HTTP Proxy to the selected products(s)?": [
        "Êtes-vous sûr de vouloir configurer le proxy HTTP pour le(s) produit(s) sélectionné(s) ?"
      ],
      "Are you sure you want to set the Release Version the {{ table.numSelected }} content host(s) selected to {{ selected.release }}?. This action will affect only those Content Hosts that belong to the appropriate Content View and Lifecycle Environment containining that release version.": [
        "Êtes-vous sûr de vouloir régler la version de sortie du ou des hôtes de contenu {{ table.numSelected }} sélectionnés sur {{ selected.release }} ? Cette action n'affectera que les hôtes de contenu qui appartiennent à la vue de contenu et à l'environnement de cycle de vie appropriés contenant cette version de publication."
      ],
      "Are you sure you want to update {{ content.content }} on the {{ getSelectedSystemIds().length }} system(s) selected?": [
        "Êtes-vous sûr de vouloir faire une mise à jour de {{ content.content }} parmi le(s) {{ getSelectedSystemIds().length }} système(s) sélectionné(s) ?"
      ],
      "Are you sure you want to update all packages on the {{ getSelectedSystemIds().length }} system(s) selected?": [
        "Êtes-vous sûr de vouloir mettre à jour tous les packages sur le(s) système(s) {{ getSelectedSystemIds().length }} sélectionné(s) ?"
      ],
      "Assign": [
        "Attribuer"
      ],
      "Assign Lifecycle Environment and Content View": [
        "Attribuer la vue Environnement et contenu du cycle de vie"
      ],
      "Assign Release Version": [
        "Attribuer une version sortie"
      ],
      "Assign System Purpose": [
        "Attribuer un objectif système"
      ],
      "Associations": [
        "Associations"
      ],
      "At least one Errata needs to be selected to Apply.": [
        "Au moins un erratum doit être sélectionné pour pouvoir appliquer."
      ],
      "Attached": [
        "Attaché"
      ],
      "Auth Token": [
        "Jeton d'authentification"
      ],
      "Auth URL": [
        "URL d'authentification"
      ],
      "Author": [
        "Auteur"
      ],
      "Auto-Attach": [
        "Auto-Attach"
      ],
      "Auto-attach available subscriptions to all selected hosts.": [
        "Attacher automatiquement les abonnements disponibles à tous les hôtes sélectionnés."
      ],
      "Auto-Attach Details": [
        "Détails Auto-Attach"
      ],
      "Auto-attach uses all available subscriptions, not a selected subset.": [
        "L'attachement automatique utilise tous les abonnements disponibles, et non pas juste un sous-ensemble sélectionné."
      ],
      "Automatic": [
        "Automatique"
      ],
      "Available Module Streams": [
        "Flux de modules disponibles"
      ],
      "Available Schema Versions": [
        "Versions de schémas disponibles"
      ],
      "Back To Errata List": [
        "Retour à la liste des errata"
      ],
      "Backend Identifier": [
        "Identifiant du back-end"
      ],
      "Basic Information": [
        "Informations de base"
      ],
      "Below are the repository content sets currently available for this content host through its subscriptions. For Red Hat subscriptions, additional content can be made available through the": [
        "Vous trouverez ci-dessous les ensembles de contenu du référentiel actuellement disponibles pour cet hébergeur de contenu par le biais de ses abonnements. Pour les abonnements à Red Hat, du contenu supplémentaire peut être mis à disposition par le biais de la"
      ],
      "Below are the Repository Sets currently available for this activation key through its subscriptions. For Red Hat subscriptions, additional content can be made available through the": [
        "Vous trouverez ci-dessous les ensembles de référentiels actuellement disponibles pour cette clé d'activation par le biais de ses abonnements. Pour les abonnements Red Hat, du contenu supplémentaire peut être mis à disposition par le biais du"
      ],
      "BIOS UUID": [
        "BIOS UUID"
      ],
      "Bootable": [
        "Amorçable"
      ],
      "Bug Fix": [
        "Correctif de bogue"
      ],
      "Bug Fix Advisory": [
        "Avis de correction de bogue"
      ],
      "Build Host": [
        "Hôte de création"
      ],
      "Build Information": [
        "Informations de création"
      ],
      "Build Time": [
        "Temps de Création"
      ],
      "Bulk Task": [
        ""
      ],
      "Cancel": [
        "Annuler"
      ],
      "Cannot clean Repository without the proper permissions.": [
        "Impossible de nettoyer le référentiel sans les autorisations appropriées."
      ],
      "Cannot clean Repository, a sync is already in progress.": [
        "Impossible de nettoyer le référentiel, une synchronisation est déjà en cours."
      ],
      "Cannot Remove": [
        "Suppression impossible"
      ],
      "Cannot republish Repository without the proper permissions.": [
        "Ne peut pas republier le référentiel sans les autorisations nécessaires."
      ],
      "Cannot republish Repository, a sync is already in progress.": [
        "Impossible de republier le référentiel, une synchronisation est déjà en cours."
      ],
      "Cannot sync Repository without a URL.": [
        "Impossible de synchroniser le référentiel sans URL."
      ],
      "Cannot sync Repository without the proper permissions.": [
        "Impossible de synchroniser le référentiel sans les autorisations appropriées."
      ],
      "Cannot sync Repository, a sync is already in progress.": [
        "Impossible de synchroniser le référentiel, une synchronisation est déjà en cours."
      ],
      "Capacity": [
        "Capacité"
      ],
      "Certificate": [
        "Certificat"
      ],
      "Change assigned Lifecycle Environment or Content View": [
        "Changer l'environnement ou la vue du contenu du cycle de vie attribué"
      ],
      "Change Host Collections": [
        "Répertorier les collections d'hôtes"
      ],
      "Change Lifecycle Environment": [
        "Supprimer l'environnement de cycle de vie"
      ],
      "Changing default settings for content hosts that register with this activation key requires subscription-manager version 1.10 or newer to be installed on that host.": [
        "Pour modifier les paramètres par défaut des hôtes de contenu qui s'enregistrent avec cette clé d'activation, il faut que la version 1.10 ou une version plus récente du gestionnaire d'abonnement soit installée sur cet hôte."
      ],
      "Changing default settings requires subscription-manager version 1.10 or newer to be installed on this host.": [
        "La modification des paramètres par défaut nécessite l'installation sur cet hôte de la version 1.10 ou d'une version plus récente du gestionnaire d'abonnement."
      ],
      "Changing download policy to \\\"On Demand\\\" will also clear the checksum type if set. The repository will use the upstream checksum type to verify downloads.": [
        "La modification de la politique de téléchargement en \\\"A la demande\\\" effacera également le type de somme de contrôle si défini. Le référentiel utilisera le type de somme de contrôle en amont pour vérifier les téléchargements."
      ],
      "Changing the Content View will not affect the Content Host until its next checkin.\\n                To update the Content Host immediately run the following command:": [
        "La modification de la vue du contenu n'affectera pas l'hôte du contenu jusqu'à son prochain contrôle.\\n                Pour mettre à jour l'hôte de contenu, exécutez immédiatement la commande suivante :"
      ],
      "Changing the Content View will not affect the Content Hosts until their next checkin.\\n        To update the Content Hosts immediately run the following command:": [
        "La modification de la vue du contenu n'affectera pas les hôtes de contenu jusqu'à leur prochaine vérification.\\n        Pour mettre à jour les hôtes de contenu, exécutez immédiatement la commande suivante :"
      ],
      "Checksum": [
        "Somme de contrôle"
      ],
      "Checksum Type": [
        "Type de somme de contrôle"
      ],
      "Choose one of the registry options to discover containers. To examine a private registry choose \\\"Custom\\\" and provide the url for the private registry.": [
        "Choisissez l'une des options du registre pour découvrir les conteneurs. Pour examiner un registre privé, choisissez \\\"Custom\\\" et indiquez l'adresse du registre privé."
      ],
      "Click here to check the status of the task.": [
        "Cliquez ici pour vérifier l'état d'avancement de la tâche."
      ],
      "Click here to select Errata for an Incremental Update.": [
        "Cliquez ici pour sélectionner les errata pour une mise à jour progressive."
      ],
      "Click to monitor task progress.": [
        "Cliquez pour suivre l'avancement de la tâche."
      ],
      "Click to view task": [
        "Cliquez pour voir la tâche"
      ],
      "Close": [
        "Fermer"
      ],
      "Collection Name": [
        "Nom de la collection"
      ],
      "Complete Mirroring": [
        "Terminer Mirrorisation"
      ],
      "Complete Sync": [
        "Terminer Sync"
      ],
      "Completed {{ repository.last_sync_words }} ago": [
        "Terminé il y a {{ repository.last_sync_words }}"
      ],
      "Completely deletes the host including VM and disks, and removes all reporting, provisioning, and configuration information.": [
        "Supprime complètement l'hôte, y compris la VM et les disques, et supprime toutes les informations de rapport, de provisionnement et de configuration."
      ],
      "Components": [
        "Composants"
      ],
      "Components:": [
        "Composants :"
      ],
      "Composite View": [
        "Affichage composite"
      ],
      "Confirm": [
        "Confirmer"
      ],
      "Confirm services restart": [
        "Confirmer le redémarrage des services"
      ],
      "Container Image Manifest": [
        "Manifeste de l'image du conteneur"
      ],
      "Container Image Manifest Lists": [
        "Listes de manifestes d'images de conteneur"
      ],
      "Container Image Manifests": [
        "Manifeste d'image de conteneur"
      ],
      "Container Image metadata generation has been initiated in the background.  Click\\n      <a ng-href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        "La génération des métadonnées de l'image du conteneur a été lancée en arrière-plan.  Cliquez sur\\n      <a ng-href=\\\"{{ taskUrl() }}\\\"> Ici</a>  pour suivre les progrès."
      ],
      "Container Image Registry": [
        "Registre d'images de conteneur"
      ],
      "Container Image Tags": [
        "Balises d'images de conteneurs"
      ],
      "Content": [
        "Contenu"
      ],
      "Content Counts": [
        "Nombre de contenus"
      ],
      "Content Credential": [
        "Identifiants de contenu"
      ],
      "Content Credential %s has been created.": [
        "L’identifiant de contenu %s a été créée."
      ],
      "Content Credential Contents": [
        "Contenus d’identifiants de contenu"
      ],
      "Content Credential successfully uploaded": [
        "Les identifiants de contenu ont été téléchargés"
      ],
      "Content credential updated": [
        "Identifiants de contenu mises à jour"
      ],
      "Content Credentials": [
        "Identifiants de contenu"
      ],
      "Content Host": [
        "Hôte de contenu"
      ],
      "Content Host Bulk Content": [
        "Contenu en vrac Hôte de contenu"
      ],
      "Content Host Bulk Subscriptions": [
        "Ensemble des abonnements Hôte de contenu"
      ],
      "Content Host Content": [
        "Contenu Hôte de contenu"
      ],
      "Content Host Counts": [
        "Nombre Hôte de contenu"
      ],
      "Content Host Limit": [
        "Limite Hôte de contenu"
      ],
      "Content Host Module Stream Management": [
        "Gestion des flux de modules Hôte de contenu"
      ],
      "Content Host Properties": [
        "Propriétés Hôte de contenu"
      ],
      "Content Host Registration": [
        "Enregistrement Hôte de contenu"
      ],
      "Content Host Status": [
        "Statut Hôte de contenu"
      ],
      "Content Host Traces Management": [
        "Gestion des traces Hôte de contenu"
      ],
      "Content Host:": [
        "Hôte du contenu :"
      ],
      "Content Hosts": [
        "Hôtes du contenu"
      ],
      "Content Hosts for Activation Key:": [
        "Annuler le contenu pour la clé d'activation :"
      ],
      "Content Hosts for:": [
        "Hôtes du contenu pour :"
      ],
      "Content Only": [
        "Contenu uniquement"
      ],
      "Content synced depends on the specifity of the URL and/or the optional requirements.yaml specified below <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'ansible_collection'\\\" uib-popover-html=\\\"collectionURLPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Upstream URL\\\">\\n        </a>": [
        "Le contenu synchronisé dépend de la spécificité de l'URL et/ou des exigences facultatives .yaml spécifiées ci-dessous <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'ansible_collection'\\\" uib-popover-html=\\\"collectionURLPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Upstream URL\\\">\\n        </a>"
      ],
      "Content Type": [
        "Type de contenu"
      ],
      "Content View": [
        "Vue du contenu"
      ],
      "Content View Version": [
        "Version d'affichage de contenu"
      ],
      "Content View:": [
        "Affichage de contenu :"
      ],
      "Content Views": [
        "Affichages du contenu"
      ],
      "Content Views <div>{{ library.counts.content_views || 0 }}</div>": [
        "Affichages de contenu <div>{{ library.counts.content_views || 0 }}</div>"
      ],
      "Content Views for Deb:": [
        "Affichages de contenu pour Deb :"
      ],
      "Content Views for File:": [
        "Affichages de contenu pour le dossier :"
      ],
      "Content Views that contain this Deb": [
        "Affichage de contenu qui contiennent cette Deb"
      ],
      "Content Views that contain this File": [
        "Affichage de contenu qui contiennent ce fichier"
      ],
      "Context": [
        "Contexte"
      ],
      "Contract": [
        "Contrat"
      ],
      "Copy Activation Key": [
        "Copier Clé d’activation"
      ],
      "Copy Host Collection": [
        "Nom de la collection d'hôtes"
      ],
      "Cores per Socket": [
        "Cores par socket"
      ],
      "Create": [
        "Créer"
      ],
      "Create a copy of {{ activationKey.name }}": [
        "Créer une copie de {{ activationKey.name }}"
      ],
      "Create a copy of {{ hostCollection.name }}": [
        "Créer une copie de {{ hostCollection.name }}"
      ],
      "Create Activation Key": [
        "Créer une clé d'activation"
      ],
      "Create Content Credential": [
        "Créer identifiant de contenu"
      ],
      "Create Copy": [
        "Créer une copie"
      ],
      "Create Discovered Repositories": [
        "Créer référentiels de découvertes"
      ],
      "Create Environment Path": [
        "Créer Chemin d’environnement"
      ],
      "Create Host Collection": [
        "Créer Collection d'hôtes"
      ],
      "Create Product": [
        "Créer un produit"
      ],
      "Create Repositories": [
        "Créer des référentiels"
      ],
      "Create Selected": [
        "Créer sélectionné"
      ],
      "Create Status": [
        "Créer un statut"
      ],
      "Create Sync Plan": [
        "Créer Plan Sync"
      ],
      "Creating repository...": [
        "Création d'un référentiel..."
      ],
      "Critical": [
        "Critique"
      ],
      "Cron Logic": [
        "Cron Logic"
      ],
      "ctrl-click or shift-click to select multiple Add ons": [
        "ctrl-clic ou shift-clic pour sélectionner plusieurs modules d'extension"
      ],
      "Current Lifecycle Environment (%e/%cv)": [
        "Environnement de cycle de vie antérieur (%e/%cv )"
      ],
      "Current Subscriptions for Activation Key:": [
        "Abonnements actuels pour la clé d'activation :"
      ],
      "Custom": [
        "Personnalisé"
      ],
      "custom cron": [
        "cron personnalisé"
      ],
      "Custom Cron": [
        "Cron personnalisé"
      ],
      "Custom Cron : {{ product.sync_plan.cron_expression }}": [
        "Custom Cron : {{ product.sync_plan.cron_expression }}"
      ],
      "Customize": [
        "Personnaliser"
      ],
      "CVEs": [
        "CVE"
      ],
      "daily": [
        "quotidiennement"
      ],
      "Daily at {{ product.sync_plan.sync_date | date:'mediumTime' }} (Server Time)": [
        "Tous les jours à {{ product.sync_plan.sync_date | date:'mediumTime' }} (heure du serveur)"
      ],
      "Date": [
        "Date"
      ],
      "deb metadata generation has been initiated in the background.  Click <a href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        "la génération des métadonnées deb a été lancée en arrière-plan.  Cliquez <a href=\\\"{{ taskUrl() }}\\\">ici</a> pour suivre les progrès."
      ],
      "Deb Package Actions": [
        ""
      ],
      "deb Package Updates": [
        "deb Mises à jour de paquets"
      ],
      "deb Packages": [
        "deb paquets"
      ],
      "Deb Packages": [
        "Paquets Deb"
      ],
      "Deb Packages <div>{{ library.counts.debs || 0 }}</div>": [
        "Paquets Deb <div>{{ library.counts.debs || 0 }}</div>"
      ],
      "Deb Packages for:": [
        "Paquets Deb pour :"
      ],
      "Deb Repositories": [
        "Référentiels deb"
      ],
      "Deb Repositories <div>{{ library.counts.deb_repositories || 0 }}</div>": [
        "Référentiels Deb <div>{{ library.counts.deb_repositories || 0 }}</div>"
      ],
      "Deb:": [
        "Deb:"
      ],
      "Debs": [
        "Debs"
      ],
      "Default": [
        "Par défaut"
      ],
      "Default Status": [
        "Statut par défaut"
      ],
      "Delete": [
        "Supprimer"
      ],
      "Delete {{ table.numSelected  }} Hosts?": [
        "Supprimer {{ table.numSelected  }}hôtes ?"
      ],
      "Delete filters": [
        "Supprimer les filtres"
      ],
      "Delete Hosts": [
        "Supprimer ces hôtes"
      ],
      "Delta RPM": [
        "Delta RPM"
      ],
      "Dependencies": [
        "Dépendances"
      ],
      "Description": [
        "Description"
      ],
      "Details": [
        "Détails"
      ],
      "Details for Activation Key:": [
        "Détails pour la clé d'activation :"
      ],
      "Details for Container Image Tag:": [
        "Détails pour les noms d'images de conteneurs :"
      ],
      "Details for Product:": [
        "Détails pour le produit :"
      ],
      "Details for Repository:": [
        "Détails pour le référentiel :"
      ],
      "Determines whether to require login to pull container images in this lifecycle environment.": [
        "Détermine s'il est nécessaire de se connecter pour extraire des images de conteneurs dans cet environnement de cycle de vie."
      ],
      "Digest": [
        "Digest"
      ],
      "Disable": [
        "Désactiver"
      ],
      "Disabled": [
        "Désactivé"
      ],
      "Disabled (overridden)": [
        "Désactivé (remplacé)"
      ],
      "Discover": [
        "Découvrir"
      ],
      "Discover Repositories": [
        "Découvrir des référentiels"
      ],
      "Discovered Repository": [
        "Référentiel des découvertes"
      ],
      "Discovery failed. Error: %s": [
        "La détection a échoué. Erreur : %s"
      ],
      "Distribution": [
        "Distribution"
      ],
      "Distribution Information": [
        "Informations sur la distribution"
      ],
      "Do not require a subscription entitlement certificate for accessing this repository.": [
        "Nul besoin de certificat de droit d'abonnement pour accéder à ce référentiel."
      ],
      "Docker": [
        "Docker"
      ],
      "Docker metadata generation has been initiated in the background.  Click\\n            <a ng-href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        "La génération de métadonnées Docker a été lancée en arrière-plan.  Cliquez sur\\n            <a ng-href=\\\"{{ taskUrl() }}\\\">Ici</a>  pour suivre les progrès."
      ],
      "Docker Repositories <div>{{ library.counts.docker_repositories || 0 }}</div>": [
        "Référentiels Docker <div>{{ library.counts.docker_repositories || 0 }} </div>"
      ],
      "Docker Tags": [
        "Balises Docker"
      ],
      "Done": [
        "Fait"
      ],
      "Download Policy": [
        "Télécharger la politique"
      ],
      "Enable": [
        "Activer"
      ],
      "Enable Traces": [
        "Activer Traces"
      ],
      "Enabled": [
        "Activé"
      ],
      "Enabled (overridden)": [
        "Activé (remplacé)"
      ],
      "Enhancement": [
        "Amélioration"
      ],
      "Enter Package Group Name(s)...": [
        "Nom de groupe(s) de packages..."
      ],
      "Enter Package Name(s)...": [
        "Entrez le(s) nom(s) de packages..."
      ],
      "Environment": [
        "Environnement"
      ],
      "Environment saved": [
        "Environnement sauvegardé"
      ],
      "Environment will also be removed from the following published content views!": [
        "L'environnement sera également supprimé des vues de contenu publiées suivantes !"
      ],
      "Environments": [
        "Environnements"
      ],
      "Environments List": [
        "Liste des environnements"
      ],
      "Errata": [
        "Errata"
      ],
      "Errata <div>{{ library.counts.errata.total || 0 }}</div>": [
        "Errata <div>{{ library.counts.errata.total || 0 }}</div>"
      ],
      "Errata are automatically Applicable if they are Installable": [
        "Les errata sont automatiquement applicables si installables"
      ],
      "Errata Details": [
        "Infos Errata"
      ],
      "Errata for:": [
        "Errata pour :"
      ],
      "Errata ID": [
        "ID des errata"
      ],
      "Errata Installation": [
        "Installation des errata"
      ],
      "Errata Task List": [
        "Liste des tâches des errata"
      ],
      "Errata Tasks": [
        "Tâches des errata"
      ],
      "Errata:": [
        "Errata:"
      ],
      "Error during upload:": [
        "Erreur lors du téléchargement :"
      ],
      "Error saving the Sync Plan:": [
        "Erreur de sauvegarde du plan de synchronisation :"
      ],
      "Event": [
        "Événement"
      ],
      "Exclude Tags": [
        "Exclure les balises"
      ],
      "Existing Product": [
        "Produit existant"
      ],
      "Expires": [
        "Expire"
      ],
      "Export": [
        "Exporter"
      ],
      "Family": [
        "Famille"
      ],
      "File Information": [
        "Information Fichier"
      ],
      "File removal been initiated in the background.  Click <a href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        "La suppression des fichiers a été initiée en arrière-plan.  Cliquez <a href=\\\"{{ taskUrl() }}\\\">ici</a>  pour suivre l'évolution de la situation."
      ],
      "File too large.": [
        "Fichier trop volumineux."
      ],
      "File too large. Please use the CLI instead.": [
        "Fichier trop volumineux. Veuillez utiliser le CLI à la place."
      ],
      "File:": [
        "Fichier :"
      ],
      "Filename": [
        "Nom du fichier"
      ],
      "Files": [
        "Fichiers"
      ],
      "Files in package {{ package.nvrea }}": [
        "Fichiers dans le package {{ package.nvrea }}"
      ],
      "Filter": [
        "Filtre"
      ],
      "Filter by Environment": [
        "Filtrer par environnement"
      ],
      "Filter by Status:": [
        "Filtrer par état :"
      ],
      "Filter...": [
        "Filtrer..."
      ],
      "Filters": [
        "Filtres"
      ],
      "Finished At": [
        "Terminé à"
      ],
      "For older operating systems such as Red Hat Enterprise Linux 5 or CentOS 5 it is recommended to use sha1.": [
        "Pour les anciens systèmes d'exploitation tels que Red Hat Enterprise Linux 5 ou CentOS 5, il est recommandé d'utiliser le sha1."
      ],
      "For On Demand synchronization, only the metadata is downloaded during sync and packages are fetched and stored on the filesystem when clients request them.\\n          On Demand is not recommended for custom repositories unless the upstream repository maintains older versions of packages within the repository.\\n          The Immediate option will download all metadata and packages immediately during the sync.": [
        "Pour la synchronisation à la demande, seules les métadonnées sont téléchargées pendant la synchronisation et les paquets sont récupérés et stockés sur le système de fichiers lorsque les clients les demandent.\\n          La synchronisation à la demande n'est pas recommandée pour les référentiels personnalisés, sauf si le référentiel en amont maintient des versions plus anciennes des paquets dans le référentiel.\\n          L'option Immédiate permet de télécharger toutes les métadonnées et tous les paquets immédiatement pendant la synchronisation."
      ],
      "Global Default": [
        "Par Défaut Global"
      ],
      "Global Default (None)": [
        "Pas de Par Défaut Global"
      ],
      "GPG Key": [
        "Clé GPG"
      ],
      "Group": [
        "Groupe"
      ],
      "Group Install (Deprecated)": [
        "Installation de groupe (déprécié)"
      ],
      "Group package actions are being deprecated, and will be removed in a future version.": [
        "Les actions de groupe de paquets sont dépréciées et seront supprimées dans une prochaine version."
      ],
      "Group Remove (Deprecated)": [
        "Suppression de groupe (déprécié)"
      ],
      "Guests of": [
        "Les invités de"
      ],
      "Helper": [
        "Assistant"
      ],
      "Host %s has been deleted.": [
        "L’hôte %s a été supprimé."
      ],
      "Host %s has been unregistered.": [
        "L'hôte %s a été dés-enregistré."
      ],
      "Host Collection Management": [
        "Gestion de la collection d'hôtes"
      ],
      "Host Collection Membership": [
        "Abonnement à la collection d'hôtes"
      ],
      "Host Collection Membership Management": [
        "Gestion Abonnement à la collection d'hôtes"
      ],
      "Host Collection removed.": [
        "Collection d'hôtes supprimée."
      ],
      "Host Collection updated": [
        "Collection d'hôtes mise à jour"
      ],
      "Host Collection:": [
        "Collection d'hôtes :"
      ],
      "Host Collections": [
        "Collections d'hôtes"
      ],
      "Host Collections for:": [
        "Collections d'hôtes pour :"
      ],
      "Host Count": [
        "Nombre d'hôtes"
      ],
      "Host Group": [
        "Groupe d'hôtes"
      ],
      "Host Limit": [
        "Limite d'hôtes"
      ],
      "Hostname": [
        "Nom d'hôte"
      ],
      "Hosts": [
        "Hôtes"
      ],
      "hourly": [
        "toutes les heures"
      ],
      "Hourly at {{ product.sync_plan.sync_date | date:'m' }} minutes and {{ product.sync_plan.sync_date | date:'s' }} seconds": [
        "Toutes les heures {{ product.sync_plan.sync_date | date:'m' }} minutes et {{ product.sync_plan.sync_date | date:'s' }} secondes"
      ],
      "HTTP Proxy": [
        "HTTP Proxy"
      ],
      "HTTP Proxy Management": [
        "Gestion du proxy HTTP"
      ],
      "HTTP Proxy Policy": [
        "Politique de proxy HTTP"
      ],
      "HTTP Proxy Policy:": [
        "Politique de proxy HTTP :"
      ],
      "HTTP Proxy:": [
        "HTTP Proxy:"
      ],
      "HttpProxyPolicy": [
        "HttpProxyPolicy"
      ],
      "Id": [
        "Id"
      ],
      "Ignore SRPMs": [
        "Ignorer les SRPM"
      ],
      "Ignore treeinfo": [
        ""
      ],
      "Image": [
        "Image"
      ],
      "Immediate": [
        "Immédiat"
      ],
      "Important": [
        "Important"
      ],
      "In order to browse this repository you must <a ng-href=\\\"/organizations/{{ organization }}/edit\\\">download the certificate</a>\\n            or ask your admin for a certificate.": [
        "Pour pouvoir consulter ce répertoire, vous devez <a ng-href=\\\"/organizations/{{ organization }}/edit\\\">télécharger le certificat</a> \\n            ou demandez un certificat à votre administrateur.."
      ],
      "Include Tags": [
        "Inclure les balises"
      ],
      "Independent Packages": [
        "Packages indépendants"
      ],
      "Install": [
        "Installer"
      ],
      "Install Selected": [
        "Installer Sélectionné"
      ],
      "Install the pre-built bootstrap RPM:": [
        "Installez le RPM du bootstrap préinstallé :"
      ],
      "Installable": [
        "Installable"
      ],
      "Installable Errata": [
        "Hôtes avec errata installables"
      ],
      "Installable Updates": [
        "Mises à jour installables"
      ],
      "Installed": [
        "Installé"
      ],
      "Installed Deb Packages": [
        "Packages deb installés"
      ],
      "Installed On": [
        "Installé le"
      ],
      "Installed Package": [
        "Paquet installé"
      ],
      "Installed Packages": [
        "Paquets installés"
      ],
      "Installed Products": [
        "Produits installés"
      ],
      "Installed Profile": [
        "Profil installé"
      ],
      "Interfaces": [
        "Interfaces"
      ],
      "Interval": [
        "Intervalle"
      ],
      "IPv4 Address": [
        "Adresse IPv4"
      ],
      "IPv6 Address": [
        "Adresse IPv6"
      ],
      "Issued": [
        "Publié"
      ],
      "Katello Tracer": [
        "Katello Tracer"
      ],
      "Label": [
        "Balise"
      ],
      "Last Checkin": [
        "Dernière vérification"
      ],
      "Last Published": [
        "Dernière publication"
      ],
      "Last Puppet Report": [
        "Dernier rapport Puppet"
      ],
      "Last reclaim space failed:": [
        "La dernière récupération d'espace a échoué :"
      ],
      "Last Sync": [
        "Dernière Sync"
      ],
      "Last sync failed:": [
        "La dernière synchronisation a échoué :"
      ],
      "Last synced": [
        "Dernière synchronisation"
      ],
      "Last Updated On": [
        "Dernière mise à jour le"
      ],
      "Library": [
        "Bibliothèque"
      ],
      "Library Repositories": [
        "Référentiels de bibliothèques"
      ],
      "Library Repositories that contain this Deb.": [
        "Les référentiels des bibliothèques qui contiennent cette Deb."
      ],
      "Library Repositories that contain this File.": [
        "Les référentiels des bibliothèques qui contiennent ce fichier."
      ],
      "Library Synced Content": [
        "Contenu de bibliothèque synchronisé"
      ],
      "License": [
        "Licence"
      ],
      "Lifecycle Environment": [
        "Environnement de cycle de vie"
      ],
      "Lifecycle Environment Paths": [
        "Chemins d’accès d’environnement de cycle de vie"
      ],
      "Lifecycle Environment:": [
        "Environnement de cycle de vie :"
      ],
      "Lifecycle Environments": [
        "Environnements de cycle de vie"
      ],
      "Limit": [
        "Limite"
      ],
      "Limit Repository Sets to only those available in this Activation Key's Lifecycle  Environment": [
        ""
      ],
      "Limit Repository Sets to only those available in this Host's Lifecycle Environment": [
        "Limiter les ensembles de référentiel aux seuls éléments disponibles dans l'environnement du cycle de vie de cet hôte"
      ],
      "Limit to environment": [
        "Limiter à l'environnement"
      ],
      "Limit to Environment": [
        "Limiter à l'Environnement"
      ],
      "Limit to Lifecycle Environment": [
        "Limiter à l’environnement Cycle de vie"
      ],
      "Limit:": [
        "Limite :"
      ],
      "List": [
        "Liste"
      ],
      "List Host Collections": [
        "Lister les collections d'hôtes"
      ],
      "List Hosts": [
        "Lister les hôtes"
      ],
      "List Products": [
        "Lister les produits"
      ],
      "List Subscriptions": [
        "Lister les abonnements"
      ],
      "List/Remove": [
        "Liste/Enlever"
      ],
      "Loading...": [
        "Chargement..."
      ],
      "Loading...\\\"": [
        "Chargement..."
      ],
      "Make filters apply to all repositories in the content view": [
        ""
      ],
      "Manage Ansible Collections for Repository:": [
        "Gérer les collections accessibles pour le référentiel :"
      ],
      "Manage Container Image Manifests for Repository:": [
        "Gérer les manifestes d'images de conteneurs pour le référentiel :"
      ],
      "Manage Content for Repository:": [
        "Gérer le contenu du référentiel :"
      ],
      "Manage deb Packages for Repository:": [
        "Gérer les paquets deb pour le référentiel :"
      ],
      "Manage Errata": [
        "Gérer les errata"
      ],
      "Manage Files for Repository:": [
        "Gérer les fichiers pour le référentiel :"
      ],
      "Manage Host Traces": [
        "Gérer les traces d’hôte"
      ],
      "Manage HTTP Proxy": [
        "Gérer le proxy HTTP"
      ],
      "Manage Module Streams": [
        "Indexer les flux de module"
      ],
      "Manage Module Streams for Repository:": [
        "Gérer les flux de modules pour le référentiel :"
      ],
      "Manage Packages": [
        "Gérer les paquets"
      ],
      "Manage Packages for Repository:": [
        "Gérer les paquets pour le référentiel :"
      ],
      "Manage Repository Sets": [
        "Gérer les ensembles de référentiels"
      ],
      "Manage Subscriptions": [
        "Gérer les abonnements"
      ],
      "Manage Sync Plan": [
        "Gérer le plan de synchronisation"
      ],
      "Manage System Purpose": [
        "Gérer Objectif system"
      ],
      "Manifest Lists": [
        "Listes de manifestes"
      ],
      "Manifest Type": [
        "Types de manifestes"
      ],
      "Metadata Expiration (Seconds)": [
        "Expiration des métadonnées (secondes)"
      ],
      "Mirroring Policy": [
        "Politique de mise en miroir"
      ],
      "Model": [
        "Modéliser"
      ],
      "Moderate": [
        "Modéré"
      ],
      "Modular": [
        "Modulaire"
      ],
      "Module Stream Management": [
        "Gestion des flux de modules"
      ],
      "Module Stream metadata generation has been initiated in the background.  Click\\n      <a ng-href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        "La génération des métadonnées du flux de module a été lancée en arrière-plan.  Cliquez ici </a> pour suivre les progrès."
      ],
      "Module Stream Packages": [
        "Paquets de flux de modules"
      ],
      "Module Streams": [
        "Flux de module"
      ],
      "Module Streams <div>{{ library.counts.module_streams || 0 }}</div>": [
        "Flux de module <div>{{ library.counts.module_streams || 0 }}</div>"
      ],
      "Module Streams for:": [
        "Flux de module pour :"
      ],
      "More Details": [
        "Plus de détails"
      ],
      "N/A": [
        "Sans objet"
      ],
      "Name": [
        "Nom"
      ],
      "Name of the upstream repository you want to sync. Example: 'quay/busybox' or 'fedora/ssh'.": [
        "Nom du référentiel en amont que vous souhaitez synchroniser. Exemple : \\\"quay/busybox\\\" ou \\\"fedora/ssh\\\"."
      ],
      "Networking": [
        "Networking"
      ],
      "Never": [
        "Jamais"
      ],
      "Never checked in": [
        "Jamais enregistré dans"
      ],
      "Never registered": [
        "Jamais enregistré"
      ],
      "Never synced": [
        "Jamais synchronisé"
      ],
      "New Activation Key": [
        "Nouvelles clé d'activation"
      ],
      "New Content Credential": [
        ""
      ],
      "New Environment": [
        "Nouvel environnement"
      ],
      "New Host Collection": [
        ""
      ],
      "New Name:": [
        "Nouveau nom :"
      ],
      "New Product": [
        "Nouveau produit"
      ],
      "New Repository": [
        "Nouveau référentiel"
      ],
      "New Sync Plan": [
        "Nouveau plan de synchronisation"
      ],
      "New sync plan successfully created.": [
        "Nouveau plan de synchronisation créé."
      ],
      "Next": [
        "Suivant"
      ],
      "Next Sync": [
        "Prochaine synchronisation"
      ],
      "No": [
        "Non"
      ],
      "No alternate release version choices are available. The available releases are based upon what is available in \\\"{{ host.content_facet_attributes.content_view.name }}\\\", the selected <a href=\\\"/content_views\\\">content view</a> this content host is attached to for the given <a href=\\\"/lifecycle_environments\\\">lifecycle environment</a>, \\\"{{ host.content_facet_attributes.lifecycle_environment.name }}\\\".": [
        "Il n'y a pas d'autres choix de versions de diffusion. Les versions disponibles sont basées sur ce qui est disponible dans \\\"{{ host.content_facet_attributes.content_view.name }}\\\", <a href=\\\"/content_views\\\"> l’affichage de contenu </a> sélectionné auquel ce contenu est attaché pour un <a href=\\\"/lifecycle_environments\\\">environnement de cycle de vie</a>, \\\"{{ host.content_facet_attributes.lifecycle_environment.name }}\\\"."
      ],
      "No Content Hosts match this Erratum.": [
        "Aucun hôte de contenu ne correspond à cet Erratum."
      ],
      "No Content Views contain this Deb": [
        "Aucun affichage de contenu ne contient cette Deb"
      ],
      "No Content Views contain this File": [
        "Ce fichier ne contient pas d’affichages de contenu"
      ],
      "No content views exist for {{selected.environment.name}}": [
        "Il n'existe pas d’affichages de contenu pour {{selected.environment.name}}"
      ],
      "No discovered repositories.": [
        "Aucun référentiel découvert."
      ],
      "No enabled Repository Sets provided through subscriptions.": [
        "Aucun ensemble de référentiel activé n'est fourni par les abonnements."
      ],
      "No Host Collections match your search.": [
        "Aucune collection d'hôtes ne correspond à votre recherche."
      ],
      "No Host Collections to show, you can add Host Collections after selecting 'Host Collections' under 'Hosts' in main menu.": [
        "Aucune collection d'hôtes à afficher, vous pouvez ajouter des collections d'hôtes après avoir sélectionné \\\"Collections d'hôtes\\\" sous \\\"Hôtes\\\" dans le menu principal."
      ],
      "No Host Collections to show, you can add Host Collections after selecting the 'Add' tab.": [
        "Aucune collection d'hôtes à afficher, vous pouvez ajouter des collections d'hôtes après avoir sélectionné l'onglet \\\"Ajouter\\\"."
      ],
      "No HTTP Proxies found": [
        "Aucun Proxy HTTP trouvé"
      ],
      "No HTTP Proxy": [
        "Aucun proxy HTTP"
      ],
      "No matching results.": [
        "Aucun résultat correspondant."
      ],
      "No Packages to show": [
        "Aucun paquet mis à afficher"
      ],
      "No products are available to add to this Sync Plan.": [
        "Aucun produit n'est disponible pour ajouter à ce plan de synchronisation."
      ],
      "No products have been added to this Sync Plan.": [
        "Aucun produit n'a été ajouté à ce plan de synchronisation."
      ],
      "No releases exist in the Library.": [
        "Il n'existe pas de version dans la bibliothèque."
      ],
      "No Repositories contain this Deb": [
        "Aucun référentiel ne contient ce Deb"
      ],
      "No Repositories contain this Erratum.": [
        "Aucun référentiel ne contient cet Erratum."
      ],
      "No Repositories contain this File": [
        "Aucun référentiel ne contient ce fichier"
      ],
      "No Repositories contain this Package.": [
        "Aucun référentiel ne contient ce paquet."
      ],
      "No repository sets provided through subscriptions.": [
        "Aucun ensemble de référentiels n'est fourni par le biais d'abonnements."
      ],
      "No restriction": [
        "Aucune restriction"
      ],
      "No sync information available.": [
        "Aucune information de synchronisation disponible."
      ],
      "No tasks exist for this resource.": [
        "Il n'existe aucune tâche pour cette ressource."
      ],
      "None": [
        "Aucun(e)"
      ],
      "Not Applicable": [
        "Non applicable"
      ],
      "Not started": [
        "Non démarré"
      ],
      "Not Synced": [
        "Pas synchronisé"
      ],
      "Number of CPUs": [
        "Nombre de processeurs"
      ],
      "Number of Repositories": [
        "Nombre de référentiels"
      ],
      "On Demand": [
        "Sur demande"
      ],
      "One or more of the selected Errata are not Installable via your published Content View versions running on the selected hosts.  The new Content View Versions (specified below)\\n      will be created which will make this Errata Installable in the host's Environment.  This new version will replace the current version in your host's Lifecycle\\n      Environment.  To install these errata immediately on hosts after publishing check the box below.": [
        "Un ou plusieurs des errata sélectionnés ne sont pas installables via les versions de Content View que vous avez publiées et qui fonctionnent sur les hôtes sélectionnés.  Les nouvelles versions de Content View (spécifiées ci-dessous)\\n      sera créé, ce qui rendra ces errata installable dans l'environnement de l'hôte.  Cette nouvelle version remplacera la version actuelle dans le cycle de vie de votre hôte\\n      Environnement.  Pour installer ces errata immédiatement sur les hôtes après leur publication, cochez la case ci-dessous."
      ],
      "One or more packages are not showing up in the local repository even though they exist in the upstream repository.": [
        "Un ou plusieurs paquets n'apparaissent pas dans le référentiel local alors qu'ils existent dans le référentiel en amont."
      ],
      "Only show content hosts where the errata is currently installable in the host's Lifecycle Environment.": [
        "N'affichez que les hôtes de contenu où les errata sont actuellement installables dans l'environnement du cycle de vie de l'hôte."
      ],
      "Only show Errata that are Applicable to one or more Content Hosts": [
        "N'afficher que les errata applicables à un ou plusieurs hôtes de contenu"
      ],
      "Only show Errata that are Installable on one or more Content Hosts": [
        "Ne montrer que les errata qui sont installables sur un ou plusieurs hôtes de contenu"
      ],
      "Only show Packages that are Applicable to one or more Content Hosts": [
        "Ne montrer que les paquets applicables à un ou plusieurs hôtes de contenu"
      ],
      "Only show Packages that are Upgradable on one or more Content Hosts": [
        "Renvoyer les paquets qui sont évolutifs sur un ou plusieurs hôtes de contenu"
      ],
      "Only show Subscriptions for products not already covered by a Subscription": [
        "Afficher uniquement les abonnements pour les produits qui ne sont pas déjà couverts par un abonnement"
      ],
      "Only show Subscriptions which can be applied to products installed on this Host": [
        "Afficher uniquement les Abonnements qui peuvent être appliqués aux produits installés sur cet Hôte"
      ],
      "Only show Subscriptions which can be attached to this Host": [
        "Afficher uniquement les abonnements qui peuvent être rattachés à cet hôte"
      ],
      "Only the Applications with a Helper can be restarted.": [
        "Seules les applications avec un assistant peuvent être relancées."
      ],
      "Operating System": [
        "Système d'exploitation"
      ],
      "Optimized Sync": [
        "Synchronisation optimisée"
      ],
      "Organization": [
        "Organisation"
      ],
      "Original Sync Date": [
        "Date de Sync d’origine"
      ],
      "OS": [
        "OS"
      ],
      "OSTree Repositories <div>{{ library.counts.ostree_repositories || 0 }}</div>": [
        "Créer des référentiels <div>{{ library.counts.ostree_repositories || 0 }} </div>"
      ],
      "Override to Disabled": [
        "Remplacer par «Désactiver»"
      ],
      "Override to Enabled": [
        "Remplacer par «Activer»"
      ],
      "Package": [
        "Paquet"
      ],
      "Package Actions": [
        "Actions paquet"
      ],
      "Package Group (Deprecated)": [
        "Groupe de paquets (déprécié)"
      ],
      "Package Groups": [
        "Groupes de paquets"
      ],
      "Package Groups for Repository:": [
        "Groupes de paquets pour le référentiel :"
      ],
      "Package Information": [
        "Informations paquet"
      ],
      "Package Install": [
        "Installation de paquets"
      ],
      "Package Installation, Removal, and Update": [
        "Installation, retrait et mise à jour des paquets"
      ],
      "Package Remove": [
        "Suppression de paquets"
      ],
      "Package Update": [
        "Mise à jour de paquets"
      ],
      "Package:": [
        "Paquet :"
      ],
      "Package/Group Name": [
        "Nom de Paquet/Groupe"
      ],
      "Packages": [
        "Paquets"
      ],
      "Packages <div>{{ library.counts.packages || 0 }}</div>": [
        "Packages <div>{{ library.counts.packages || 0 }} </div>"
      ],
      "Packages are automatically Applicable if they are Upgradable": [
        "Les paquets sont automatiquement applicables s'ils sont évolutifs"
      ],
      "Packages for Errata:": [
        "Paquets pour les Errata :"
      ],
      "Packages for:": [
        "Paquets pour :"
      ],
      "Parameters": [
        "Paramètres"
      ],
      "Part of a manifest list": [
        "Partie d'une liste de manifeste"
      ],
      "Password": [
        "Mot de passe"
      ],
      "Password of the upstream repository user for authentication. Leave empty if repository does not require authentication.": [
        "Mot de passe de l'utilisateur du référentiel en amont pour l'authentification. Laissez vide si le référentiel ne nécessite pas d'authentification."
      ],
      "Paste contents of Content Credential": [
        "Coller le contenu des références de contenu"
      ],
      "Path": [
        "Chemin"
      ],
      "Perform": [
        "Effectuer"
      ],
      "Performing host package actions is disabled because Katello is not configured for remote execution.": [
        ""
      ],
      "Performing host package actions is disabled because Katello is not configured for Remote Execution.": [
        ""
      ],
      "Physical": [
        "Physique"
      ],
      "Please enter cron below": [
        "Veuillez entrer le code ci-dessous"
      ],
      "Please make sure a Content View is selected.": [
        "Veuillez vous assurer qu'une vue de contenu est sélectionnée."
      ],
      "Please select an environment.": [
        "Tout d'abord, sélectionner un environnement"
      ],
      "Please select one from the list below and you will be redirected.": [
        "Veuillez en choisir un dans la liste ci-dessous et vous serez redirigé."
      ],
      "Plus %y more errors": [
        "Plus %y erreurs supplémentaires"
      ],
      "Plus 1 more error": [
        "Plus 1 erreur supplémentaire"
      ],
      "Previous Lifecycle Environment (%e/%cv)": [
        "Environnement de cycle de vie précédent (%e/%cv)"
      ],
      "Prior Environment": [
        "Environnement précédent"
      ],
      "Product": [
        "Produit"
      ],
      "Product delete operation has been initiated in the background.": [
        "L'opération de suppression du produit a été lancée en arrière-plan."
      ],
      "Product Enhancement Advisory": [
        "Avis sur l'amélioration des produits"
      ],
      "Product information for:": [
        "Information de produit pour :"
      ],
      "Product Management for Sync Plan:": [
        "Gestion de produits pour le plan de synchronisation :"
      ],
      "Product Name": [
        "Nom du produit"
      ],
      "Product Options": [
        "Options du produit"
      ],
      "Product Saved": [
        "Produit sauvegardé"
      ],
      "Product sync has been initiated in the background.": [
        "La synchronisation des produits a été lancée en arrière-plan."
      ],
      "Product syncs has been initiated in the background.": [
        "Des synchronisations de produits ont été lancées en arrière-plan."
      ],
      "Product verify checksum has been initiated in the background.": [
        "La somme de contrôle de la vérification des produits a été initiée en arrière-plan."
      ],
      "Products": [
        "Produits"
      ],
      "Products <div>{{ library.counts.products || 0 }}</div>": [
        "Produits <div>{{ library.counts.products || 0 }} </div>"
      ],
      "Products for": [
        "Produits pour"
      ],
      "Products not covered": [
        "Produits non couverts"
      ],
      "Provides": [
        "Procure"
      ],
      "Provisioning": [
        ""
      ],
      "Provisioning Details": [
        "Provisionnement - Détails"
      ],
      "Provisioning Host Details": [
        "Provisionnement - Détails sur l'hôte"
      ],
      "Published At": [
        "Publié à"
      ],
      "Published Repository Information": [
        "Informations sur les référentiels publiés"
      ],
      "Publishing Settings": [
        "Paramètres de publication"
      ],
      "Puppet Environment": [
        "Environnement Puppet"
      ],
      "Quantity": [
        "Quantité"
      ],
      "Quantity (To Add)": [
        "Quantité (à ajouter)"
      ],
      "RAM (GB)": [
        "RAM (GB)"
      ],
      "Reboot Suggested": [
        "Redémarrage suggéré"
      ],
      "Reboot Suggested?": [
        "Redémarrage suggéré ?"
      ],
      "Recalculate\\n          <i class=\\\"fa fa-spinner fa-spin\\\" ng-show=\\\"calculatingApplicability\\\"></i>": [
        "Recalculer\\n          <i class=\\\"fa fa-spinner fa-spin\\\" ng-show=\\\"calculatingApplicability\\\"></i>"
      ],
      "Reclaim Space": [
        "Récupération d’espace"
      ],
      "Recurring Logic": [
        "Logique récurrente"
      ],
      "Red Hat": [
        "Red Hat"
      ],
      "Red Hat Repositories page": [
        "Page des référentiels Red Hat"
      ],
      "Red Hat Repositories page.": [
        "Page des référentiels Red Hat."
      ],
      "Refresh Table": [
        "Rafraîchir le tableau"
      ],
      "Register a Content Host": [
        "Enregistrer un hôte de contenu"
      ],
      "Register Content Host": [
        "Enregistrer l'hôte du contenu"
      ],
      "Registered": [
        "Enregistré"
      ],
      "Registered By": [
        "Enregistré par"
      ],
      "Registered Through": [
        "Enregistré via"
      ],
      "Registry Name Pattern": [
        "Modèle de nom de registre"
      ],
      "Registry Search Parameter": [
        "Paramètre de recherche du registre"
      ],
      "Registry to Discover": [
        "Registre à découvrir"
      ],
      "Registry URL": [
        "URL du registre"
      ],
      "Release": [
        "Sortie"
      ],
      "Release Version": [
        "Version de sortie"
      ],
      "Release Version:": [
        "Version de sortie :"
      ],
      "Releases/Distributions": [
        "Sorties/Distributions"
      ],
      "Remote execution plugin is required to be able to run any helpers.": [
        "Le plugin d'exécution à distance est nécessaire pour pouvoir faire fonctionner les aides."
      ],
      "Remove": [
        "Supprimer"
      ],
      "Remove {{ table.numSelected  }} Container Image manifest?": [
        "Supprimer {{ table.numSelected  }} manifeste d'images de conteneur ?",
        "Supprimer {{ table.numSelected  }} manifestes d'images de conteneur ?",
        "Supprimer {{ table.numSelected  }} manifestes d'images de conteneur ?"
      ],
      "Remove Activation Key \\\"{{ activationKey.name }}\\\"?": [
        "Supprimer la clé d'activation \\\"{{ activationKey.name }}\\\" ?"
      ],
      "Remove Container Image Manifests": [
        "Supprimer les manifestes d'images de conteneurs"
      ],
      "Remove Content": [
        "Supprimer le contenu"
      ],
      "Remove Content Credential": [
        "Supprimer les références de contenu"
      ],
      "Remove Content Credential {{ contentCredential.name }}": [
        "Supprimer les références de contenu {{ contentCredential.name }}"
      ],
      "Remove Content?": [
        "Supprimer le contenu ?",
        "Supprimer le unités de contenu {{ table.numSelected }}  ?",
        "Supprimer le unités de contenu {{ table.numSelected }}  ?"
      ],
      "Remove Environment": [
        "Supprimer environnement"
      ],
      "Remove environment {{ environment.name }}?": [
        "Supprimer environnement {{ environment.name }}?"
      ],
      "Remove File?": [
        "Supprimer un fichier ?",
        "Supprimer {{ table.numSelected }} fichiers ?",
        "Supprimer {{ table.numSelected }} fichiers ?"
      ],
      "Remove Files": [
        "Supprimer des fichiers"
      ],
      "Remove From": [
        "Retirer de"
      ],
      "Remove Host Collection \\\"{{ hostCollection.name }}\\\"?": [
        "Afficher une collection d'hôtes \\\"{{ hostCollection.name }}\\\"?"
      ],
      "Remove Package?": [
        "Supprimer le paquet ?",
        "Supprimer {{ table.numSelected }} paquets ?",
        "Supprimer {{ table.numSelected }} paquets ?"
      ],
      "Remove Packages": [
        "Supprimer paquets"
      ],
      "Remove Product": [
        "Supprimer un produit"
      ],
      "Remove Product \\\"{{ product.name }}\\\"?": [
        "Supprimer le produit \\\"{{ product.name }}\\\" ?"
      ],
      "Remove product?": [
        "Retirer un produit ?",
        "Supprimer {{ table.getSelected().length }} produits ?",
        "Supprimer {{ table.getSelected().length }} produits ?"
      ],
      "Remove Repositories": [
        "Supprimer référentiels"
      ],
      "Remove Repository": [
        "Supprimer référentiel"
      ],
      "Remove Repository {{ repositoryWrapper.repository.name }}?": [
        "Supprimer le référentiel {{ repositoryWrapper.repository.name }} ?"
      ],
      "Remove repository?": [
        "Supprimer le référentiel ?",
        "Supprimer {{ table.numSelected }} référentiels ?",
        "Supprimer {{ table.numSelected }} référentiels ?"
      ],
      "Remove Selected": [
        "Supprimer Sélectionné"
      ],
      "Remove Successful.": [
        "Suppression réussie."
      ],
      "Remove Sync Plan": [
        "Supprimer le plan de synchronisation"
      ],
      "Remove Sync Plan \\\"{{ syncPlan.name }}\\\"?": [
        "Supprimer le plan de synchronisation \\\"{{ syncPlan.name }}\\\" ?"
      ],
      "Removed %x host collections from activation key \\\"%y\\\".": [
        "Supprimer %x collections d'hôtes de la clé d'activation \\\"%y\\\"."
      ],
      "Removed %x host collections from content host \\\"%y\\\".": [
        "Supprimer %x collections de l'hôtes de l’hôte de contenu \\\"%y\\\"."
      ],
      "Removed %x products from sync plan \\\"%y\\\".": [
        "Supprimer %x produits du plan de synchronisation \\\"%y\\\"."
      ],
      "Removing Repositories": [
        "Suppression des référentiels"
      ],
      "Repo Discovery": [
        "Repo Discovery"
      ],
      "Repositories": [
        "Référentiels"
      ],
      "Repositories containing Errata {{ errata.errata_id }}": [
        "Référentiels contenant des errata {{ errata.errata_id }}"
      ],
      "Repositories containing package {{ package.nvrea }}": [
        "Référentiels contenant le paquet {{ package.nvrea }}"
      ],
      "Repositories for": [
        "Référentiels pour"
      ],
      "Repositories for Deb:": [
        "Référentiels de Deb :"
      ],
      "Repositories for Errata:": [
        "Référentiels pour les Errata :"
      ],
      "Repositories for File:": [
        "Référentiels pour Fichier :"
      ],
      "Repositories for Package:": [
        "Référentiels pour paquet :"
      ],
      "Repositories for Product:": [
        "Référentiels pour Produit :"
      ],
      "Repositories to Create": [
        "Référentiels à créer"
      ],
      "Repository": [
        "Référentiel"
      ],
      "Repository \\\"%s\\\" successfully deleted": [
        "Suppression du référentiel \\\"%s\\\" réussie"
      ],
      "Repository %s successfully created.": [
        "Création du référentiel %s réussie."
      ],
      "Repository created": [
        "Référentiel créé"
      ],
      "Repository Discovery": [
        "Découvert Référentiel"
      ],
      "Repository HTTP proxy changes have been initiated in the background.": [
        "Les changements de proxy HTTP du référentiel ont été initiés en arrière-plan."
      ],
      "Repository Label": [
        "Balise du référentiel"
      ],
      "Repository Name": [
        "Nom du référentiel"
      ],
      "Repository Options": [
        "Options de référentiel"
      ],
      "Repository Path": [
        "Chemin d’accès du référentiel"
      ],
      "Repository Saved.": [
        "Référentiel sauvegardé."
      ],
      "Repository Sets": [
        "Ensembles de référentiels"
      ],
      "Repository Sets Management": [
        "Gestion des ensembles de référentiels"
      ],
      "Repository Sets settings saved successfully.": [
        "Paramètres d’ensembles de référentiels enregistrés."
      ],
      "Repository type": [
        "Type de référentiel"
      ],
      "Repository Type": [
        "Type de référentiel"
      ],
      "Repository URL": [
        "URL du référentiel"
      ],
      "Repository will also be removed from the following published content view versions!": [
        "L'environnement sera également supprimé des vues de contenu des versions publiées suivantes !"
      ],
      "Repository:": [
        "Référentiel :"
      ],
      "Republish Repository Metadata": [
        "Republier Métadonnées de référentiel"
      ],
      "Requirements": [
        "Exigences"
      ],
      "Requirements.yml": [
        "Exigences.yml"
      ],
      "Requires": [
        "Nécessite"
      ],
      "Reset": [
        "Restauration"
      ],
      "Reset to Default": [
        "Réinitialiser à la valeur par défaut"
      ],
      "Resolving the selected Traces will reboot the selected content hosts.": [
        "La résolution des traces sélectionnées redémarrera les hôtes de contenu sélectionnés."
      ],
      "Resolving the selected Traces will reboot this host.": [
        "La résolution des traces sélectionnées redémarrera cet hôte."
      ],
      "Restart": [
        "Redémarrer"
      ],
      "Restart Selected": [
        "Redémarrage sélectionné"
      ],
      "Restart Services on Content Host \\\"{{host.name}}\\\"?": [
        "Redémarrer les services sur l'hôte de contenu \\\"{{host.name}}\\\" ?"
      ],
      "Restrict to <br>OS version": [
        "Restreindre à version <br> du système d'exploitation"
      ],
      "Restrict to architecture": [
        "Se limiter à l'architecture"
      ],
      "Restrict to Architecture": [
        "Se limiter à l'Architecture"
      ],
      "Restrict to OS version": [
        "Restreindre à la version du système d'exploitation"
      ],
      "Result": [
        "Résultat"
      ],
      "Retain package versions": [
        "Conserver les versions du paquet"
      ],
      "Role": [
        "Rôle"
      ],
      "Role:": [
        "Rôle :"
      ],
      "RPM": [
        "RPM"
      ],
      "rpm Package Updates": [
        "rpm Mises à jour de paquets"
      ],
      "Run Auto-Attach": [
        "Lancer l'Auto-Attach"
      ],
      "Run Repository Creation\\n      <i class=\\\"fa fa-spinner fa-spin\\\" ng-show=\\\"creating()\\\"></i>": [
        "Exécuter Création Référentiel créé <i class=\\\"fa fa-spinner fa-spin\\\" ng-show=\\\"creating()\\\"></i>"
      ],
      "Run Sync Plan": [
        "Exécuter Plan Sync"
      ],
      "Save": [
        "Enregistrer"
      ],
      "Save Successful.": [
        "Enregistrement réussi."
      ],
      "Schema Version": [
        "Version du schéma"
      ],
      "Schema Version 1": [
        "Schéma Version 1"
      ],
      "Schema Version 2": [
        "Schéma Version 2"
      ],
      "Security": [
        "Sécurité"
      ],
      "Security Advisory": [
        "Avis de sécurité"
      ],
      "Select": [
        "Sélectionner"
      ],
      "Select a Content Source:": [
        "Sélectionner un affichage de contenu:"
      ],
      "Select Action": [
        "Choisir l'action"
      ],
      "Select an Organization": [
        "Sélectionner une organisation"
      ],
      "Select Content Host(s)": [
        ""
      ],
      "Select Content View": [
        "Sélectionner l'affichage de contenu"
      ],
      "Select this option if treeinfo files or other kickstart content is failing to syncronize from the upstream repository.": [
        ""
      ],
      "Selecting \\\"Complete Sync\\\" will cause only yum/deb repositories of the selected product to be synced.": [
        "En sélectionnant \\\"Complete Sync\\\", seuls les référentiels yum /deb du produit sélectionné seront synchronisés."
      ],
      "Selecting this option will exclude SRPMs from repository synchronization.": [
        "En sélectionnant cette option, les SRPM seront exclus de la synchronisation du référentiel."
      ],
      "Selecting this option will exclude treeinfo files from repository synchronization.": [
        ""
      ],
      "Selecting this option will result in Katello verifying that the upstream url's SSL certificates are signed by a trusted CA. Unselect if you do not want this verification.": [
        "En sélectionnant cette option, Katello vérifiera que les certificats SSL de l'url en amont sont signés par une AC de confiance. Désélectionnez cette option si vous ne voulez pas de cette vérification."
      ],
      "Service Level": [
        "Niveau de service"
      ],
      "Service Level (SLA)": [
        "Niveau de service (SLA)"
      ],
      "Service Level (SLA):": [
        "Niveau de service (SLA) :"
      ],
      "Set Release Version": [
        "Définir Version"
      ],
      "Severity": [
        "Sévérité"
      ],
      "Show All": [
        "Tout afficher"
      ],
      "Show all Repository Sets in Organization": [
        "Afficher tous les ensembles de référentiels d’ Organisation"
      ],
      "Size": [
        "Taille"
      ],
      "Skip dependency solving for a significant speed increase. If the update cannot be applied to the host, delete the incremental content view version and retry the application with dependency solving turned on.": [
        "Ignorez la résolution des dépendances pour obtenir une augmentation significative de la vitesse. Si la mise à jour ne peut pas être appliquée à l'hôte, supprimez la version incrémentielle de l’affichage de contenu et réessayez l'application en activant la résolution des dépendances."
      ],
      "Smart proxy currently reclaiming space...": [
        "Le smart proxy est entrain de récupérer le l’espace ..."
      ],
      "Smart proxy currently syncing to your locations...": [
        "Le smart proxy se synchronise actuellement avec vos emplacements..."
      ],
      "Smart proxy is synchronized": [
        "Le smart proxy est synchronisé"
      ],
      "Sockets": [
        "Sockets"
      ],
      "Solution": [
        "Solution"
      ],
      "Some of the Errata shown below may not be installable as they are not in this Content Host's\\n        Content View and Lifecycle Environment.  In order to apply such Errata an Incremental Update is required.": [
        "Certains des errata indiqués ci-dessous peuvent ne pas être installables car ils ne se trouvent pas dans le répertoire de cet hôte de contenu\\n        Vue du contenu et environnement du cycle de vie.  Afin d'appliquer ces errata, une mise à jour progressive est nécessaire."
      ],
      "Something went wrong when deleting the resource.": [
        "Quelque chose s'est mal passé lors de la suppression de la ressource."
      ],
      "Something went wrong when retrieving the resource.": [
        "Quelque chose s'est mal passé lors de la récupération de la ressource."
      ],
      "Something went wrong when saving the resource.": [
        "Quelque chose a mal tourné lors de la sauvegarde de la ressource."
      ],
      "Source RPM": [
        "RPM source"
      ],
      "Source RPMs": [
        "RPMs source"
      ],
      "Space reclamation is about to start...": [
        "La récupération d’espace est sur le point de commencer..."
      ],
      "SSL CA Cert": [
        "SSL CA Cert"
      ],
      "SSL Certificate": [
        "Certificat SSL"
      ],
      "SSL Client Cert": [
        "Certificat client SSL"
      ],
      "SSL Client Key": [
        "Clé client SSL"
      ],
      "Standard sync, optimized for speed by bypassing any unneeded steps.": [
        "Synchronisation standard, optimisée pour la vitesse en contournant les étapes inutiles."
      ],
      "Start Date": [
        "Date de début"
      ],
      "Start Time": [
        "Date de lancement"
      ],
      "Started At": [
        "Démarré à"
      ],
      "Starting": [
        "Démarrage"
      ],
      "Starts": [
        "Commence"
      ],
      "State": [
        "État"
      ],
      "Status": [
        "Statut"
      ],
      "Stream": [
        "Flux"
      ],
      "Subscription Details": [
        "Détails de l’abonnement"
      ],
      "Subscription Management": [
        "Gestion des abonnements"
      ],
      "Subscription Status": [
        "Statut des abonnements"
      ],
      "Subscription UUID": [
        "UUID de l’abonnement"
      ],
      "subscription-manager register --org=\\\"{{ activationKey.organization.label }}\\\" --activationkey=\\\"{{ activationKey.name }}\\\"": [
        "subscription-manager register --org=\\\"{{ activationKey.organization.label }}\\\" --activationkey=\\\"{{ activationKey.name }}\\\""
      ],
      "Subscriptions": [
        "Abonnements"
      ],
      "Subscriptions for Activation Key:": [
        "Abonnements pour la clé d'activation :"
      ],
      "Subscriptions for Content Host:": [
        "Abonnements pour l'hôte de contenu :"
      ],
      "Subscriptions for:": [
        "Abonnements pour :"
      ],
      "Success!": [
        "Réussi."
      ],
      "Successfully added %s subscriptions.": [
        "Ajout de %s abonnements avec succès."
      ],
      "Successfully initiated restart of services.": [
        "Lancement réussi du redémarrage des services."
      ],
      "Successfully removed %s items.": [
        "%s éléments supprimés."
      ],
      "Successfully removed %s subscriptions.": [
        "%s abonnements supprimés."
      ],
      "Successfully removed 1 item.": [
        "1 élément supprimé."
      ],
      "Successfully updated subscriptions.": [
        "Mise à jour des abonnements réussie."
      ],
      "Successfully uploaded content:": [
        "Téléchargement du contenu réussi :"
      ],
      "Summary": [
        "Résumé"
      ],
      "Support Level": [
        "Niveau de support"
      ],
      "Sync": [
        "Sync"
      ],
      "Sync Enabled": [
        "Sync activée"
      ],
      "Sync even if the upstream metadata appears to have no change. This option is only relevant for yum/deb repositories and will take longer than an optimized sync. Choose this option if:": [
        "Synchroniser même si les métadonnées en amont ne semblent pas avoir changé. Cette option ne concerne que les dépôts yum/deb et prendra plus de temps qu'une synchronisation optimisée. Choisissez cette option si :"
      ],
      "Sync Interval": [
        "Sync Intervalle"
      ],
      "Sync Now": [
        "Sync Now"
      ],
      "Sync Plan": [
        "Plan de Sync"
      ],
      "Sync Plan %s has been deleted.": [
        "Plan de Sync %s a été supprimé."
      ],
      "Sync Plan created and assigned to product.": [
        "Plan de Synchronisation créé et affecté au produit."
      ],
      "Sync Plan Management": [
        "Gestion du Plan de Sync"
      ],
      "Sync Plan saved": [
        "Plan de Sync sauvegardé"
      ],
      "Sync Plan Saved": [
        "Plan de Sync sauvegardé"
      ],
      "Sync Plan:": [
        "Plan de Sync :"
      ],
      "Sync Plans": [
        "Plans de Sync"
      ],
      "Sync Selected": [
        "Sync Sélectionnée"
      ],
      "Sync Settings": [
        "Paramètres de configuration de Sync"
      ],
      "Sync State": [
        "État de Sync"
      ],
      "Sync Status": [
        "Sync Statut"
      ],
      "Synced manually, no interval set.": [
        "Synchronisation manuelle, pas d'intervalle défini."
      ],
      "Synchronization is about to start...": [
        "La synchronisation est sur le point de commencer..."
      ],
      "Synchronization is being cancelled...": [
        "La synchronisation est annulée..."
      ],
      "System Purpose": [
        "Objectif système"
      ],
      "System purpose enables you to set the system's intended use on your network and improves reporting accuracy in the Subscriptions service of the Red Hat Hybrid Cloud Console.": [
        "L'objectif du système vous permet de définir l'utilisation prévue du système sur votre réseau et améliore la précision des rapports dans le service Abonnements de la console Red Hat Hybrid Cloud."
      ],
      "System Purpose Management": [
        "Gestion des objectifs système"
      ],
      "System Purpose Status": [
        "Statut Objectif system"
      ],
      "Tags": [
        "Balises"
      ],
      "Task Details": [
        "Détails de la tâche"
      ],
      "Tasks": [
        "Tâches"
      ],
      "Temporary": [
        "Temporaire"
      ],
      "The <i>Registry Name Pattern</i> overrides the default name by which container images may be pulled from the server. (By default this name is a combination of Organization, Lifecycle Environment, Content View, Product, and Repository labels.)\\n\\n          <br><br>The name may be constructed using ERB syntax. Variables available for use are:\\n\\n          <pre>\\norganization.name\\norganization.label\\nrepository.name\\nrepository.label\\nrepository.docker_upstream_name\\ncontent_view.label\\ncontent_view.name\\ncontent_view_version.version\\nproduct.name\\nproduct.label\\nlifecycle_environment.name\\nlifecycle_environment.label</pre>\\n\\n          Examples:\\n            <pre>\\n&lt;%= organization.label %&gt;-&lt;%= lifecycle_environment.label %&gt;-&lt;%= content_view.label %&gt;-&lt;%= product.label %&gt;-&lt;%= repository.label %&gt;\\n&lt;%= organization.label %&gt;/&lt;%= repository.docker_upstream_name %&gt;</pre>": [
        "Le <i> modèle de nom de registre</i> remplace le nom par défaut par lequel les images des conteneurs peuvent être extraites du serveur. (Par défaut, ce nom est une combinaison des balises Organisation, Environnement de cycle de vie, Vue du contenu, Produit et référentiel)\\n\\n            <br><br>Le nom peut être construit en utilisant la syntaxe ERB. Les variables disponibles pour l'utilisation sont :\\n\\n          <pre>\\norganisation.nom\\norganisation.laebeel\\nréférentiel.nom\\nrepository.label\\nrepository.docker_upstream_name\\ncontent_view.label\\ncontent_view.namBalisee\\ncontent_view_version.version\\nnom.du produit\\nproduit.label\\nlifecycle_environment.name\\nlifecycle_environment.label </pre>\\n          Exemples :  <pre>\\n            \\n&lt;%= organization.labeBalisel %&gt;-&lt;%= lifecycle_environment.label %&gt;-&lt;%= content_view.label %&gt;-&lt;%= product.label %&gt;-&lt;%= repository.label %&gt ;\\n&lt;%= organization.label %&gt;/&lt;%= repository.docker_upstream_name %&gt ;</pre>"
      ],
      "The Content View or Lifecycle Environment needs to be updated in order to make errata available to these hosts.": [
        "La vue du contenu ou l'environnement du cycle de vie doit être mis à jour afin de rendre les errata disponibles pour ces hôtes."
      ],
      "The filters below have this repository as the last affected repository!": [
        ""
      ],
      "The following actions can be performed on content hosts in this host collection:": [
        "Les actions suivantes peuvent être effectuées sur les hôtes de contenu de cette collection d'hôtes :"
      ],
      "The host has not reported any applicable packages for upgrade.": [
        "L'hôte n'a signalé aucun paquet applicable pour la mise à niveau."
      ],
      "The host has not reported any installed packages, registering with subscription-manager should cause these to be reported.": [
        "L'hôte n'a pas signalé de paquets installés, l'enregistrement auprès du gestionnaire d'abonnement devrait permettre de le faire."
      ],
      "The host requires being attached to a content view and the lifecycle environment you have chosen has no content views promoted to it.\\n              See the <a href=\\\"/content_views\\\">content views page</a> to manage and promote a content view.": [
        "L'hôte doit être attaché à une vue de contenu et l'environnement de cycle de vie que vous avez choisi n'a pas de vues de contenu qui lui sont promues.\\n              Consultez la <a href=\\\"/content_views\\\">page des vues de contenu</a> pour gérer et promouvoir une vue de contenu."
      ],
      "The maximum number of versions of each package to keep.": [
        "Le nombre maximum de versions de chaque paquet à conserver."
      ],
      "The page you are attempting to access requires selecting a specific organization.": [
        "La page à laquelle vous tentez d'accéder nécessite la sélection d'une organisation spécifique."
      ],
      "The remote execution feature is required to manage packages on this Host.": [
        "La fonction d'exécution à distance est nécessaire pour gérer les paquets sur cet hôte."
      ],
      "The Remote Execution plugin needs to be installed in order to resolve Traces.": [
        "Le plugin d'exécution à distance doit être installé afin de résoudre les traces."
      ],
      "The repository will only be available on content hosts with the selected architecture.": [
        ""
      ],
      "The repository will only be available on content hosts with the selected OS version.": [
        ""
      ],
      "The selected environment contains no Content Views, please select a different environment.": [
        "L'environnement sélectionné ne contient pas d’affichages de contenu, veuillez sélectionner un autre environnement."
      ],
      "The time the sync should happen in your current time zone.": [
        "L'heure à laquelle la synchronisation doit avoir lieu dans votre fuseau horaire actuel."
      ],
      "The token key to use for authentication.": [
        "La clé de jeton à utiliser pour l'authentification."
      ],
      "The URL to receive a session token from, e.g. used with Automation Hub.": [
        "L'URL à partir de laquelle recevoir un jeton de session, par exemple utilisé avec Automation Hub."
      ],
      "There are {{ errataCount }} total Errata in this organization but none match the above filters.": [
        "Il y a {{ errataCount }} errata dans cette organisation mais aucun ne correspond aux filtres ci-dessus."
      ],
      "There are {{ packageCount }} total Packages in this organization but none match the above filters.": [
        "Il y a un nombre total de {{ packageCount }} paquets dans cette organisation mais aucun ne correspond aux filtres ci-dessus."
      ],
      "There are no %(contentType)s that match the criteria.": [
        "Il n'y a pas de %(contentType)s qui corresponde aux critères."
      ],
      "There are no Content Views in this Environment.": [
        "Il n'y a pas d’affichages de contenus dans cet environnement."
      ],
      "There are no Content Views that match the criteria.": [
        "Il n'y a pas d’affichages de contenus qui correspondent aux critères."
      ],
      "There are no Errata associated with this Content Host to display.": [
        "Il n'y a pas d'errata associé à cet hôte de contenu à afficher."
      ],
      "There are no Errata in this organization.  Create one or more Products with Errata to view Errata on this page.": [
        "Il n'y a pas d'errata dans cette organisation.  Créez un ou plusieurs produits avec des errata pour afficher les errata sur cette page."
      ],
      "There are no Errata to display.": [
        "Il n'y a pas d'errata à afficher."
      ],
      "There are no Host Collections available. You can create new Host Collections after selecting 'Host Collections' under 'Hosts' in main menu.": [
        "Il n'y a pas de collections d'hôtes disponibles. Vous pouvez créer de nouvelles collections d'hôtes après avoir sélectionné \\\"Collections d'hôtes\\\" sous \\\"Hôtes\\\" dans le menu principal."
      ],
      "There are no Module Streams to display.": [
        "Il n'y a pas de flux de modules à afficher."
      ],
      "There are no Packages in this organization.  Create one or more Products with Packages to view Packages on this page.": [
        "Il n'y a pas de paquets dans cette organisation.  Créez un ou plusieurs produits avec des paquets pour voir les paquets sur cette page."
      ],
      "There are no Sync Plans available. You can create new Sync Plans after selecting 'Sync Plans' under 'Hosts' in main menu.": [
        "Il n'y a pas de plans de synchronisation disponibles. Vous pouvez créer de nouveaux plans de synchronisation après avoir sélectionné \\\"Plans de synchronisation\\\" sous \\\"Hôtes\\\" dans le menu principal."
      ],
      "There are no Traces to display.": [
        "Il n'y a pas de Traces à afficher."
      ],
      "There is currently an Incremental Update task in progress.  This update must finish before applying existing updates.": [
        "Une mise à jour progressive est actuellement en cours.  Cette mise à jour doit se terminer avant d'appliquer les mises à jour existantes."
      ],
      "These instructions will be removed in a future release. NEW: To register a content host without following these manual steps, see <a href=\\\"https://{{ katelloHostname }}/hosts/register\\\">Register Host</a>": [
        "Ces instructions seront supprimées dans une prochaine version. NOUVEAU : Pour enregistrer un hôte de contenu sans suivre ces étapes manuelles, voir <a href=\\\"https://{{ katelloHostname }}/hosts/register\\\">Enregistrer un hôte</a>"
      ],
      "This action will affect only those Content Hosts that require a change.\\n        If the Content Host does not have the selected Subscription no action will take place.": [
        "Cette action ne concernera que les hôtes de contenu qui nécessitent un changement.\\n        Si l'hôte de contenu ne dispose pas de l'abonnement sélectionné, aucune action n'aura lieu."
      ],
      "This activation key is not associated with any content hosts.": [
        "Cette clé d'activation n'est associée à aucun hôte de contenu."
      ],
      "This activation key may be used during system registration. For example:": [
        "Cette clé d'activation peut être utilisée lors de l'enregistrement du système. Par exemple :"
      ],
      "This change will be applied to <b>{{ hostCount }} systems.</b>": [
        "Cette modification sera appliquée aux <b>{{ hostCount }} systèmes.</b>"
      ],
      "This Container Image Tag is not present in any Lifecycle Environments.": [
        "Cette balise d'image de conteneur n'est présente dans aucun environnement de cycle de vie."
      ],
      "This Container Image Tag is not present in any Repositories.": [
        "Cette balise d'image de conteneur n'est présente dans aucun référentiel."
      ],
      "This operation may also remove managed resources linked to the host such as virtual machines and DNS records.\\n          Change the setting \\\"Delete Host upon Unregister\\\" to false on the <a href=\\\"/settings\\\">settings page</a> to prevent this.": [
        "Cette opération peut également supprimer les ressources gérées liées à l'hôte, telles que les machines virtuelles et les enregistrements DNS.\\n          Pour éviter cela, modifiez le paramètre \\\"Delete Host upon Unregister\\\" sur false dans la <a href=\\\"/settings\\\">page des paramètres</a>."
      ],
      "This organization has Simple Content Access enabled.  Hosts are not required to have subscriptions attached to access repositories.": [
        "Cette organisation a activé l'accès au contenu simple.  Les hôtes ne sont pas tenus de souscrire un abonnement pour accéder aux référentiels d'accès."
      ],
      "This organization is not using <a target=\\\"_blank\\\" href=\\\"https://access.redhat.com/articles/simple-content-access\\\">Simple Content Access.</a> Entitlement-based subscription management is deprecated and will be removed in Katello 4.12.": [
        ""
      ],
      "Title": [
        "Titre"
      ],
      "To register a content host to this server, follow these steps.": [
        "Pour enregistrer un hôte de contenu sur ce serveur, suivez les étapes suivantes."
      ],
      "Toggle Dropdown": [
        "Basculer la liste déroulante"
      ],
      "Token of the upstream repository user for authentication. Leave empty if repository does not require authentication.": [
        "Jeton de l'utilisateur du référentiel en amont pour l'authentification. Laissez vide si le référentiel ne nécessite pas d'authentification."
      ],
      "Topic": [
        "Sujet"
      ],
      "Tracer helps administrators identify applications that need to be restarted after a system is patched.": [
        "Tracer aide les administrateurs à identifier les applications qui doivent être redémarrées après qu'un système a été corrigé."
      ],
      "Traces": [
        "Traces"
      ],
      "Traces for:": [
        "Traces pour :"
      ],
      "Turn on Setting > Content > Allow deleting repositories in published content views": [
        "Activez Configuration > Contenu > Autoriser la suppression des référentiels dans les affichages de contenu publié"
      ],
      "Type": [
        "Type"
      ],
      "Unauthenticated Pull": [
        "Pull non authentifié"
      ],
      "Unknown": [
        "Inconnu"
      ],
      "Unlimited Content Hosts:": [
        "Hôtes de contenu illimité :"
      ],
      "Unlimited Hosts": [
        "Hôtes illimités"
      ],
      "Unprotected": [
        "Non protégé"
      ],
      "Unregister Host": [
        "Désenregistrer l'hôte"
      ],
      "Unregister Host \\\"{{host.name}}\\\"?": [
        "Désenregistrer l'hôte « {{host.name}} » ?"
      ],
      "Unregister Options:": [
        "Désenregistrer les options :"
      ],
      "Unregister the host as a subscription consumer.  Provisioning and configuration information is preserved.": [
        "Désinscrire l'hôte en tant que consommateur d'abonnement.  Les informations relatives au provisionnement et à la configuration sont conservées."
      ],
      "Unsupported Type!": [
        "Type non pris en charge !"
      ],
      "Update": [
        "Mise à jour"
      ],
      "Update All Deb Packages": [
        "Mise à jour de tous les paquets deb"
      ],
      "Update All Packages": [
        "Mise à jour de tous les packages"
      ],
      "Update Packages": [
        "Mettre à jour les packages"
      ],
      "Update Sync Plan": [
        "Mettre à jour le plan de synchronisation"
      ],
      "Updated": [
        "Mis à jour"
      ],
      "Upgradable": [
        "Pouvant être mis à niveau"
      ],
      "Upgradable For": [
        "Mise à niveau pour"
      ],
      "Upgradable Package": [
        "Package pouvant être mis à niveau"
      ],
      "Upgrade Available": [
        "Mise à niveau disponible"
      ],
      "Upgrade Selected": [
        "Mise à niveau sélectionnée"
      ],
      "Upload": [
        "Télécharger"
      ],
      "Upload Content Credential file": [
        "Télécharger fichier d’identifiants de contenu"
      ],
      "Upload File": [
        "Télécharger un fichier"
      ],
      "Upload Package": [
        "Télécharger le package"
      ],
      "Upload Requirements": [
        "Exigences en matière de téléchargement"
      ],
      "Upload Requirements.yml file <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'ansible_collection'\\\" uib-popover-html=\\\"requirementPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\">\\n        </a>": [
        "Télécharger le fichier Requirements.yml <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'ansible_collection'\\\" uib-popover-html=\\\"requirementPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\">\\n        </a>"
      ],
      "Uploading...": [
        "Téléchargement..."
      ],
      "Upstream Authentication Token": [
        "Jeton d’authentification en amont"
      ],
      "Upstream Authorization": [
        "Autorisation en amont"
      ],
      "Upstream Image Name": [
        "Nom de l'image en amont"
      ],
      "Upstream Password": [
        "Mot de passe en amont"
      ],
      "Upstream Repository Name": [
        "Nom du référentiel en amont"
      ],
      "Upstream URL": [
        "URL en amont"
      ],
      "Upstream Username": [
        "Nom d'utilisateur en amont"
      ],
      "Url": [
        "Url"
      ],
      "URL of the registry you want to sync. Example: https://registry-1.docker.io/ or https://quay.io/": [
        "URL du registre que vous souhaitez synchroniser. Exemple : https://registry-1.docker.io/ ou https://quay.io/"
      ],
      "URL to Discover": [
        "URL à découvrir"
      ],
      "URL to the repository base. Example: http://ftp.de.debian.org/debian/ <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"debURLPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Upstream URL\\\">\\n        </a>": [
        "URL du référentiel de base. Exemple : http://ftp.de.debian.org/debian/ <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"debURLPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Upstream URL\\\">\\n        </a>"
      ],
      "Usage Type": [
        "Type d'utilisation"
      ],
      "Usage Type:": [
        "Type d'utilisation :"
      ],
      "Use specific HTTP Proxy": [
        "Utiliser un proxy HTTP spécifique"
      ],
      "Use the cancel button on content view selection to revert your lifecycle environment selection.": [
        "Utilisez le bouton d'annulation de la sélection de la vue du contenu pour revenir à la sélection de l'environnement du cycle de vie."
      ],
      "Used as": [
        "Utilisé comme"
      ],
      "User": [
        "Utilisateur"
      ],
      "Username": [
        "Nom d'utilisateur"
      ],
      "Username of the upstream repository user for authentication. Leave empty if repository does not require authentication.": [
        "Nom d'utilisateur de l'utilisateur du référentiel en amont pour l'authentification. Laissez vide si le référentiel ne nécessite pas d'authentification."
      ],
      "Variant": [
        "Variante"
      ],
      "Verify Content Checksum": [
        "Vérifier la somme de contrôle du contenu"
      ],
      "Verify SSL": [
        "Vérifier SSL"
      ],
      "Version": [
        "Version"
      ],
      "Version {{ cvVersions['version'] }}": [
        "Version {{ cvVersions['version'] }}"
      ],
      "Versions": [
        "Versions"
      ],
      "via remote execution": [
        "via exécution distante"
      ],
      "via remote execution - customize first": [
        "via Exécution à distance - personnaliser d'abord"
      ],
      "View Container Image Manifest Lists for Repository:": [
        "Voir les listes de manifestes d'images de conteneurs pour le référentiel :"
      ],
      "View Docker Tags for Repository:": [
        "Voir les étiquettes Docker pour le référentiel :"
      ],
      "View job invocations.": [
        "Afficher les jobs lancés."
      ],
      "Virtual": [
        "Virtuel"
      ],
      "Virtual Guest": [
        "Invité virtuel"
      ],
      "Virtual Guests": [
        "Invités virtuels"
      ],
      "Virtual Host": [
        "Hôte virtuel"
      ],
      "Warning: reclaiming space for an \\\"On Demand\\\" repository will delete all cached content units.  Take precaution when cleaning custom repositories whose upstream parents don't keep old package versions.": [
        "Attention : la récupération d'espace pour un référentiel \\\"À la Demande\\\" supprimera toutes les unités de contenu mises en cache.  Prenez des précautions lorsque vous nettoyez des référentiels personnalisés dont les parents en amont ne conservent pas les anciennes versions des paquets."
      ],
      "weekly": [
        "hebdomadaire"
      ],
      "Weekly on {{ product.sync_plan.sync_date | date:'EEEE' }} at {{ product.sync_plan.sync_date | date:'mediumTime' }} (Server Time)": [
        "Hebdomadaire le {{ product.sync_plan.sync_date | date:'EEEE' }} à {{ product.sync_plan.sync_date | date:'mediumTime' }}(heure du serveur)"
      ],
      "When Auto Attach is disabled, registering systems will be attached to all associated subscriptions.": [
        "Lorsque l'option \\\"Auto Attach\\\" est désactivée, les systèmes d'enregistrement seront rattachés à tous les abonnements associés."
      ],
      "When Auto Attach is enabled, registering systems will be attached to all associated custom products and only associated Red Hat subscriptions required to satisfy the system's installed products.": [
        "Lorsque l'attachement automatique est activé, les systèmes d'enregistrement seront attachés à tous les produits personnalisés associés et uniquement aux abonnements Red Hat associés nécessaires pour satisfaire les produits installés du système."
      ],
      "Whitespace-separated list of components to sync (leave clear to sync all). Example: main <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"componentPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Components\\\">\\n        </a>": [
        "Liste séparée par des espaces des composants à synchroniser (laisser vide pour tout synchroniser). Exemple : main <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"componentPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Components\\\">\\n        </a>"
      ],
      "Whitespace-separated list of processor architectures to sync (leave clear to sync all). Example: amd64 <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"archPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Architectures\\\">\\n        </a>": [
        "Liste séparée par des espaces des architectures de processeur pour filtrer la synchronisation. Exemple : amd64 <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"archPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Architectures\\\">\\n        </a>"
      ],
      "Whitespace-separated list of releases/distributions to sync (required for syncing). Example: buster <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"distPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Releases/Distributions\\\">\\n        </a>": [
        "Liste de versions/distributions séparées par des virgules à sync (requis pour la sync). Exemple: buster <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"distPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Releases/Distributions\\\">\\n        </a>"
      ],
      "Working": [
        "Fonctionne"
      ],
      "Yes": [
        "Oui"
      ],
      "You can upload a requirements.yml file above to auto-fill contents <b>OR</b> paste contents of <a ng-href=\\\"https://docs.ansible.com/ansible/latest/galaxy/user_guide.html#install-multiple-collections-with-a-requirements-file\\\" target=\\\"_blank\\\"> Requirements.yml </a>below.": [
        "Vous pouvez télécharger un fichier requirements.yml ci-dessus pour remplir automatiquement le contenu <b> OU </b>coller le contenu de <a ng-href=\\\"https://docs.ansible.com/ansible/latest/galaxy/user_guide.html#install-multiple-collections-with-a-requirements-file\\\" target=\\\"_blank\\\"> Requirements.yml</a> ci-dessous."
      ],
      "You can upload a requirements.yml file below to auto-fill contents or paste contents of requirement.yml here": [
        "Vous pouvez télécharger un fichier requirements.yml ci-dessous pour remplir automatiquement le contenu ou coller le contenu de requirement.yml ici"
      ],
      "You cannot remove content from a redhat repository": [
        "Impossible de supprimer le contenu d'un référentiel Red Hat"
      ],
      "You cannot remove these repositories because you do not have permission.": [
        "Vous ne pouvez pas supprimer ces référentiels parce que vous n'en avez pas l'autorisation."
      ],
      "You cannot remove this product because it has repositories that are the last affected repository on content view filters": [
        ""
      ],
      "You cannot remove this product because it is a Red Hat product.": [
        "Vous ne pouvez pas retirer ce produit car il s'agit d'un produit Red Hat."
      ],
      "You cannot remove this product because it was published to a content view.": [
        "Vous ne pouvez pas supprimer ce produit parce qu'il a été publié dans une vue de contenu."
      ],
      "You cannot remove this product because you do not have permission.": [
        "Vous ne pouvez pas retirer ce produit parce que vous n'avez pas d'autorisation."
      ],
      "You cannot remove this repository because you do not have permission.": [
        "Vous ne pouvez pas supprimer ce référentiel parce que vous n'en avez pas l'autorisation."
      ],
      "You currently don't have any Activation Keys, you can add Activation Keys using the button on the right.": [
        "Vous n'avez actuellement aucune clé d'activation, vous pouvez en ajouter en utilisant le bouton de droite."
      ],
      "You currently don't have any Alternate Content Sources associated with this Content Credential.": [
        "Vous n'avez actuellement aucune autre source de contenu associée à cette référence de contenu."
      ],
      "You currently don't have any Container Image Tags.": [
        "Vous n'avez actuellement aucune étiquette d’image de contenu."
      ],
      "You currently don't have any Content Credential, you can add Content Credentials using the button on the right.": [
        "Vous n'avez actuellement aucun justificatif de contenu, vous pouvez en ajouter en utilisant le bouton de droite."
      ],
      "You currently don't have any Content Hosts, you can create new Content Hosts by selecting Contents Host from main menu and then clicking the button on the right.": [
        "Vous n'avez actuellement aucun hôte de contenu, vous pouvez créer de nouveaux hôtes de contenu en sélectionnant Hôte de contenu dans le menu principal et en cliquant sur le bouton de droite."
      ],
      "You currently don't have any Content Hosts, you can register one by clicking the button on the right and following the instructions.": [
        "Vous n'avez actuellement aucun hôte de contenu, vous pouvez en enregistrer un en cliquant sur le bouton à droite et en suivant les instructions."
      ],
      "You currently don't have any Files.": [
        "Vous n'avez actuellement aucun Fichier."
      ],
      "You currently don't have any Host Collections, you can add Host Collections using the button on the right.": [
        "Vous n'avez actuellement aucune collection d'hôtes, vous pouvez en ajouter en utilisant le bouton de droite."
      ],
      "You currently don't have any Hosts in this Host Collection, you can add Content Hosts after selecting the 'Add' tab.": [
        "Vous n'avez actuellement aucun hôte dans cette collection d'hôtes. Vous pouvez ajouter des hôtes de contenu en sélectionnant l'onglet \\\"Ajouter\\\"."
      ],
      "You currently don't have any Products associated with this Content Credential.": [
        "Vous n'avez actuellement aucun produit associé à cette référence de contenu."
      ],
      "You currently don't have any Products to subscribe to, you can add Products after selecting 'Products' under 'Content' in the main menu": [
        "Vous n'avez actuellement aucun produit à souscrire, vous pouvez ajouter des produits après avoir sélectionné \\\"Produits\\\" sous \\\"Contenu\\\" dans le menu principal"
      ],
      "You currently don't have any Products to subscribe to. You can add Products after selecting 'Products' under 'Content' in the main menu.": [
        "Vous n'avez actuellement aucun produit auquel vous pouvez vous abonner. Vous pouvez ajouter des produits après avoir sélectionné \\\"Produits\\\" sous \\\"Contenu\\\" dans le menu principal."
      ],
      "You currently don't have any Products<span bst-feature-flag=\\\"custom_products\\\">, you can add Products using the button on the right</span>.": [
        "Vous n'avez actuellement aucun produit <span bst-feature-flag=\\\"custom_products\\\">, vous pouvez ajouter des produits en utilisant le bouton de droite</span>."
      ],
      "You currently don't have any Repositories associated with this Content Credential.": [
        "Vous n'avez actuellement aucun référentiel associé à cette référence de contenu."
      ],
      "You currently don't have any Repositories included in this Product, you can add Repositories using the button on the right.": [
        "Vous n'avez actuellement aucun référentiel inclus dans ce produit, vous pouvez ajouter des référentiels en utilisant le bouton à droite."
      ],
      "You currently don't have any Subscriptions associated with this Activation Key, you can add Subscriptions after selecting the 'Add' tab.": [
        "Vous n'avez actuellement aucun abonnement associé à cette clé d'activation, vous pouvez ajouter des abonnements après avoir sélectionné l'onglet \\\"Ajouter\\\"."
      ],
      "You currently don't have any Subscriptions associated with this Content Host. You can add Subscriptions after selecting the 'Add' tab.": [
        "Vous n'avez actuellement aucun abonnement associé à cet hôte de contenu. Vous pouvez ajouter des abonnements après avoir sélectionné l'onglet \\\"Ajouter\\\"."
      ],
      "You currently don't have any Sync Plans.  A Sync Plan can be created by using the button on the right.": [
        "Vous n'avez actuellement aucun plan de synchronisation.  Un plan de synchronisation peut être créé en utilisant le bouton de droite."
      ],
      "You do not have any Installed Products": [
        "Vous n'avez pas de produits installés"
      ],
      "You must select a content view in order to save your environment.": [
        "Vous devez sélectionner une vue du contenu afin de sauvegarder votre environnement."
      ],
      "You must select a new content view before your change of environment can be saved. Use the cancel button on content view selection to revert your environment selection.": [
        "Vous devez sélectionner une nouvelle vue du contenu avant de pouvoir enregistrer votre changement d'environnement. Utilisez le bouton d'annulation de la sélection de la vue du contenu pour revenir à votre sélection d'environnement."
      ],
      "You must select a new content view before your change of lifecycle environment can be saved.": [
        "Vous devez sélectionner une nouvelle vue du contenu avant de pouvoir enregistrer votre changement d'environnement de cycle de vie."
      ],
      "You must select at least one Content Host in order to apply Errata.": [
        "Vous devez sélectionner au moins un hôte de contenu afin d'appliquer les errata."
      ],
      "You must select at least one Errata to apply.": [
        "Vous devez sélectionner au moins un erratum."
      ],
      "Your search returned zero %(contentType)s that match the criteria.": [
        "Votre recherche a donné zéro %(contentType)s correspondant aux critères."
      ],
      "Your search returned zero Activation Keys.": [
        "Votre recherche a donné zéro clé d'activation."
      ],
      "Your search returned zero Container Image Tags.": [
        "Votre recherche n'a donné aucun label d’image de conteneur."
      ],
      "Your search returned zero Content Credential.": [
        "Votre recherche n'a donné aucune référence de contenu."
      ],
      "Your search returned zero Content Hosts.": [
        "Votre recherche n'a donné aucun hôte de contenu."
      ],
      "Your search returned zero Content Views": [
        "Votre recherche a donné zéro Affichage de contenu"
      ],
      "Your search returned zero Content Views.": [
        "Votre recherche a donné zéro Affichages de contenu."
      ],
      "Your search returned zero Deb Packages.": [
        "Votre recherche a donné zéro paquet Deb."
      ],
      "Your search returned zero Debs.": [
        "Votre recherche a donné zéro Debs."
      ],
      "Your search returned zero Errata.": [
        "Votre recherche a donné zéro Errata."
      ],
      "Your search returned zero Erratum.": [
        "Votre recherche a donné zéro Erratum."
      ],
      "Your search returned zero Files.": [
        "Votre recherche a donné zéro Fichier."
      ],
      "Your search returned zero Host Collections.": [
        "Votre recherche a donné zéro collection d'hôtes."
      ],
      "Your search returned zero Hosts.": [
        "Votre recherche n'a donné aucun hôte."
      ],
      "Your search returned zero Lifecycle Environments.": [
        "Votre recherche a donné zéro environnement de cycle de vie."
      ],
      "Your search returned zero Module Streams.": [
        "Votre recherche n'a donné aucun flux de modules."
      ],
      "Your search returned zero Packages.": [
        "Votre recherche a donné zéro paquet."
      ],
      "Your search returned zero Products.": [
        "Votre recherche a donné zéro produit."
      ],
      "Your search returned zero Repositories": [
        "Votre recherche a donné zéro référentiels"
      ],
      "Your search returned zero Repositories.": [
        "Votre recherche a donné zéro référentiels."
      ],
      "Your search returned zero repository sets.": [
        "Votre recherche a donné zéro ensemble de référentiels."
      ],
      "Your search returned zero Repository Sets.": [
        "Votre recherche a donné zéro ensemble de référentiels."
      ],
      "Your search returned zero results.": [
        "Votre recherche n'a donné aucun résultat."
      ],
      "Your search returned zero Subscriptions.": [
        "Votre recherche a donné zéro Abonnement."
      ],
      "Your search returned zero Sync Plans.": [
        "Votre recherche a donné zéro Plan de synchronisation."
      ],
      "Your search returned zero Traces.": [
        "Votre recherche a donné zéro Traces."
      ],
      "Yum Metadata Checksum": [
        "Yum Metadata Checksum"
      ],
      "Yum metadata generation has been initiated in the background.  Click <a href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        "La génération de métadonnées a été lancée en arrière-plan.  Cliquez <a href=\\\"{{ taskUrl() }}\\\">ici</a> pour suivre les progrès."
      ],
      "Yum Repositories <div>{{ library.counts.yum_repositories || 0 }}</div>": [
        "Référentiels Yum <div>{{ library.counts.yum_repositories || 0 }} </div>"
      ]
    }
  }
};
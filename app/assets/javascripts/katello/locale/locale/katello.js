 locales['katello'] = locales['katello'] || {}; locales['katello']['locale'] = {
  "domain": "katello",
  "locale_data": {
    "katello": {
      "": {
        "Project-Id-Version": "",
        "Last-Translator": "Amit Upadhye <aupadhye@redhat.com>, 2023",
        "Language-Team": "Portuguese (Brazil) (https://app.transifex.com/foreman/teams/114/pt_BR/)",
        "Content-Type": "text/plain; charset=UTF-8",
        "Content-Transfer-Encoding": "8bit",
        "Language": "pt_BR",
        "Plural-Forms": "nplurals=3; plural=(n == 0 || n == 1) ? 0 : n != 0 && n % 1000000 == 0 ? 1 : 2;",
        "lang": "locale",
        "domain": "katello",
        "plural_forms": "nplurals=3; plural=(n == 0 || n == 1) ? 0 : n != 0 && n % 1000000 == 0 ? 1 : 2;"
      },
      "-- select an interval --": [
        "-- selecione um intervalo --"
      ],
      "(future)": [
        "(futuro)"
      ],
      "{{ 'Add Selected' | translate }}": [
        "{{ 'Add Selected' | translate }}"
      ],
      "{{ contentCredential.name }}": [
        "{{ contentCredential.name }}"
      ],
      "{{ deb.hosts_applicable_count }} Host(s)": [
        ""
      ],
      "{{ deb.hosts_applicable_count || 0 }} Applicable,": [
        ""
      ],
      "{{ deb.hosts_available_count }} Host(s)": [
        ""
      ],
      "{{ deb.hosts_available_count || 0 }} Upgradable": [
        ""
      ],
      "{{ errata.hosts_applicable_count || 0 }} Applicable,": [
        "{{ errata.hosts_applicable_count || 0 }} Aplicável,"
      ],
      "{{ errata.hosts_available_count || 0 }} Installable": [
        "{{ errata.hosts_available_count || 0 }} Instalável"
      ],
      "{{ errata.title }}": [
        "{{ errata.title }}"
      ],
      "{{ file.name }}": [
        "{{ file.name }}"
      ],
      "{{ host.display_name }}": [
        ""
      ],
      "{{ host.rhel_lifecycle_status_label }}": [
        ""
      ],
      "{{ host.subscription_facet_attributes.user.login }}": [
        "{{ host.subscription_facet_attributes.user.login }}"
      ],
      "{{ installedDebCount }} Host(s)": [
        ""
      ],
      "{{ installedPackageCount }} Host(s)": [
        "{{ installedPackageCount }} Hospedeiro(s)"
      ],
      "{{ package.hosts_applicable_count }} Host(s)": [
        "{{ package.hosts_applicable_count }} Hospedeiro(s)"
      ],
      "{{ package.hosts_applicable_count || 0 }} Applicable,": [
        "{{ package.hosts_applicable_count || 0 }} Aplicável,"
      ],
      "{{ package.hosts_available_count }} Host(s)": [
        "{{ package.hosts_available_count }} Hospedeiro(s)"
      ],
      "{{ package.hosts_available_count || 0 }} Upgradable": [
        "{{ package.hosts_available_count || 0 }} Atualizável"
      ],
      "{{ package.human_readable_size }} ({{ package.size }} Bytes)": [
        "{{ package.human_readable_size }} ({{ package.size }} Bytes)"
      ],
      "{{ product.active_task_count }}": [
        "{{ product.active_task_count }}"
      ],
      "{{ product.name }}": [
        "{{ product.name }}"
      ],
      "{{ repo.last_sync_words }} ago": [
        ""
      ],
      "{{ repository.content_counts.ansible_collection || 0 }} Ansible Collections": [
        ""
      ],
      "{{ repository.content_counts.deb || 0 }} deb Packages": [
        "{{ repository.content_counts.deb || 0 }} Pacotes deb"
      ],
      "{{ repository.content_counts.docker_manifest || 0 }} Container Image Manifests": [
        ""
      ],
      "{{ repository.content_counts.docker_manifest_list || 0 }} Container Image Manifest Lists": [
        ""
      ],
      "{{ repository.content_counts.docker_tag || 0 }} Container Image Tags": [
        ""
      ],
      "{{ repository.content_counts.erratum || 0 }} Errata": [
        "{{ repository.content_counts.erratum || 0 }} Errata"
      ],
      "{{ repository.content_counts.file || 0 }} Files": [
        "{{ repository.content_counts.file || 0 }} Arquivos"
      ],
      "{{ repository.content_counts.rpm || 0 }} Packages": [
        "{{ repository.content_counts.rpm || 0 }} Pacotes"
      ],
      "{{ repository.content_counts.srpm }} Source RPMs": [
        "{{ repository.content_counts.srpm }} Fonte RPMs"
      ],
      "{{ repository.last_sync_words }} ago": [
        "{{ repository.last_sync_words }} atrás"
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
        "* Estas Versões marcadas de Conteúdo Visualizado são de Composite Content Views.  Seus componentes que precisam de atualização estão listados abaixo."
      ],
      "/foreman_tasks/tasks/%taskId": [
        "/foreman_tasks/tasks/%taskId"
      ],
      "/job_invocations": [
        ""
      ],
      "%(consumed)s out of %(quantity)s": [
        "%(consumed)s de %(quantity)s"
      ],
      "%count environment(s) can be synchronized: %envs": [
        "%count ambiente(s) pode(m) ser sincronizado(s): %envs"
      ],
      "<a href=\\\"/foreman_tasks/tasks/{{repository.last_sync.id}}\\\">{{ repository.last_sync.result | capitalize}}</a>": [
        "<a href=\\\"/foreman_tasks/tasks/{{repository.last_sync.id}}\\\">{{ repository.last_sync.result | capitalize}}</a>"
      ],
      "<b>Additive:</b> new content available during sync will be added to the repository, and no content will be removed.": [
        ""
      ],
      "<b>Description</b>": [
        ""
      ],
      "<b>Issued</b>": [
        ""
      ],
      "<b>Mirror Complete</b>: a sync behaves exactly like \\\"Mirror Content Only\\\", but also mirrors metadata as well.  This is the fastest method, and preserves repository signatures, but is only supported by yum and not by all upstream repositories.": [
        ""
      ],
      "<b>Mirror Content Only</b>: any new content available during sync will be added to the repository and any content removed from the upstream repository will be removed from the local repository.": [
        ""
      ],
      "<b>Module Streams</b>": [
        ""
      ],
      "<b>Packages</b>": [
        ""
      ],
      "<b>Reboot Suggested</b>": [
        ""
      ],
      "<b>Solution</b>": [
        ""
      ],
      "<b>Title</b>": [
        ""
      ],
      "<b>Type</b>": [
        ""
      ],
      "<b>Updated</b>": [
        ""
      ],
      "<i class=\\\"fa fa-warning inline-icon\\\"></i>\\n  This Host is not currently registered with subscription-manager. Use the <a href=\\\"/hosts/register\\\">Register Host</a> workflow to complete registration.": [
        ""
      ],
      "1 Content Host": [
        "",
        "",
        ""
      ],
      "1 repository sync has errors.": [
        "",
        "",
        ""
      ],
      "1 repository sync in progress.": [
        "1 sincronia de repositório em andamento.",
        "{{ product.sync_summary.pending}} sincronia dos repositórios em andamento.",
        "{{ product.sync_summary.pending}} sincronia dos repositórios em andamento."
      ],
      "1 successfully synced repository.": [
        "1 repositório sincronizado com sucesso.",
        "{{ product.sync_summary.success}} sincronizou com sucesso os repositórios.",
        "{{ product.sync_summary.success}} sincronizou com sucesso os repositórios."
      ],
      "A comma-separated list of container image tags to exclude when syncing. Source images are excluded by default because they are often large and unwanted.": [
        ""
      ],
      "A comma-separated list of container image tags to include when syncing.": [
        ""
      ],
      "A sync has been initiated in the background, <a href=\\\"/foreman_tasks/tasks/{{ task.id }}\\\">click for more details</a>": [
        "Uma sincronização foi iniciada em segundo plano, <a href=\\\"/foreman_tasks/tasks/{{ task.id }}\\\">clique para mais detalhes</a>"
      ],
      "Account": [
        "Conta"
      ],
      "Action Type": [
        "Tipo de ação"
      ],
      "Actions": [
        "Ações"
      ],
      "Activation Key": [
        "Chave de ativação",
        "Chaves de ativação ",
        "Chaves de ativação "
      ],
      "Activation Key Content": [
        "Conteúdo da chave de ativação"
      ],
      "Activation Key removed.": [
        "Chave de ativação removida."
      ],
      "Activation Key updated": [
        "Chave de ativação atualizada"
      ],
      "Activation Key:": [
        "Chave de ativação:"
      ],
      "Activation Keys": [
        "Chaves de ativação "
      ],
      "Active Tasks": [
        "Tarefas ativas"
      ],
      "Add": [
        "Adicionar"
      ],
      "Add Content Hosts to:": [
        "Adicionar Hosts de Conteúdo a:"
      ],
      "Add Host Collections": [
        ""
      ],
      "Add hosts to the host collection to see available actions.": [
        ""
      ],
      "Add New Environment": [
        "Adicionar Novo Ambiente"
      ],
      "Add ons": [
        "Complementos"
      ],
      "Add ons:": [
        ""
      ],
      "Add Products": [
        ""
      ],
      "Add Selected": [
        "Adicionar selecionado"
      ],
      "Add Subscriptions": [
        "Adicionar subscrições"
      ],
      "Add Subscriptions for Activation Key:": [
        "Adicionar Assinaturas para Chave de Ativação:"
      ],
      "Add Subscriptions for Content Host:": [
        "Adicionar Assinaturas para Host de Conteúdo:"
      ],
      "Add To": [
        "Adicione a"
      ],
      "Added %x host collections to activation key \\\"%y\\\".": [
        "Acrescentei %x coleções de host à chave de ativação \\\"%y\\\"."
      ],
      "Added %x host collections to content host \\\"%y\\\".": [
        "Acrescentei %x coleções de anfitriões a anfitriões de conteúdo \\\"%y\\\"."
      ],
      "Added %x products to sync plan \\\"%y\\\".": [
        "Acrescentado %x produtos para plano de sincronização \\\"%y\\\"."
      ],
      "Adding Lifecycle Environment to the end of \\\"{{ priorEnvironment.name }}\\\"": [
        "Adicionando Ambiente de Ciclo de Vida ao final de \\\"{{ priorEnvironment.name }}\\\""
      ],
      "Additive": [
        ""
      ],
      "Advanced Sync": [
        "Sincronia Avançada"
      ],
      "Advisory": [
        "Assessoria"
      ],
      "Affected Hosts": [
        "Anfitriões afetados"
      ],
      "All": [
        ""
      ],
      "All Content Views": [
        "Todas as visualizações de conteúdo"
      ],
      "All Lifecycle Environments": [
        ""
      ],
      "All Repositories": [
        "Todos os Repositórios"
      ],
      "Alternate Content Sources": [
        ""
      ],
      "Alternate Content Sources for": [
        ""
      ],
      "An error occured: %s": [
        "Ocorreu um erro: %s"
      ],
      "An error occurred initiating the sync:": [
        "Ocorreu um erro ao iniciar a sincronização:"
      ],
      "An error occurred removing the Activation Key:": [
        "Ocorreu um erro ao remover a chave de ativação:"
      ],
      "An error occurred removing the content hosts.": [
        "Ocorreu um erro ao remover os hosts de conteúdo."
      ],
      "An error occurred removing the environment:": [
        "Ocorreu um erro ao remover o ambiente:"
      ],
      "An error occurred removing the Host Collection:": [
        "Ocorreu um erro ao remover a Coleção Anfitriã:"
      ],
      "An error occurred removing the subscriptions.": [
        "Ocorreu um erro ao remover as assinaturas."
      ],
      "An error occurred saving the Activation Key:": [
        "Ocorreu um erro ao salvar a chave de ativação:"
      ],
      "An error occurred saving the Content Host:": [
        "Ocorreu um erro ao salvar o Host de Conteúdo:"
      ],
      "An error occurred saving the Environment:": [
        "Ocorreu um erro ao salvar o Meio Ambiente:"
      ],
      "An error occurred saving the Host Collection:": [
        "Ocorreu um erro ao salvar a Coleção Anfitriã:"
      ],
      "An error occurred saving the Product:": [
        "Ocorreu um erro ao salvar o Produto:"
      ],
      "An error occurred saving the Repository:": [
        "Ocorreu um erro ao salvar o Repositório:"
      ],
      "An error occurred saving the Sync Plan:": [
        "Ocorreu um erro ao salvar o Plano de Sincronização:"
      ],
      "An error occurred trying to auto-attach subscriptions.  Please check your log for further information.": [
        "Ocorreu um erro na tentativa de autoatacar assinaturas.  Por favor, verifique seu log para maiores informações."
      ],
      "An error occurred updating the sync plan:": [
        "Ocorreu um erro ao atualizar o plano de sincronização:"
      ],
      "An error occurred while creating the Content Credential:": [
        "Ocorreu um erro durante a criação da Credencial de Conteúdo:"
      ],
      "An error occurred while creating the Product: %s": [
        "Ocorreu um erro durante a criação do Produto: %s"
      ],
      "An error occurred:": [
        "Ocorreu um erro:"
      ],
      "Ansible Collection Authorization": [
        ""
      ],
      "Ansible Collections": [
        "Coleções do Ansible"
      ],
      "Applicable": [
        "Aplicável"
      ],
      "Applicable Content Hosts": [
        "Hosts de Conteúdo Aplicável"
      ],
      "Applicable Deb Packages": [
        ""
      ],
      "Applicable Errata": [
        "Errata Aplicável"
      ],
      "Applicable Packages": [
        "Pacotes aplicáveis"
      ],
      "Applicable To": [
        "Aplicável a"
      ],
      "Applicable to Host": [
        "Aplicável ao Host"
      ],
      "Application": [
        "Aplicação"
      ],
      "Apply": [
        "Aplicar"
      ],
      "Apply {{ errata.errata_id }}": [
        "Aplicar {{ errata.errata_id }}"
      ],
      "Apply {{ errata.errata_id }} to {{ contentHostIds.length  }} Content Host(s)?": [
        "Aplicar {{ errata.errata_id }} para {{ contentHostIds.length  }} Host(s) de conteúdo?"
      ],
      "Apply {{ errata.errata_id }} to all Content Host(s)?": [
        "Aplicar {{ errata.errata_id }} a todo(s) Host(s) de Conteúdo?"
      ],
      "Apply {{ errataIds.length }} Errata to {{ contentHostIds.length }} Content Host(s)?": [
        "Aplicar {{ errataIds.length }} Errata para {{ contentHostIds.length }} Content Host(s)?"
      ],
      "Apply {{ errataIds.length }} Errata to all Content Host(s)?": [
        "Aplicar {{ errataIds.length }} Errata a todo(s) Host(s) de Conteúdo?"
      ],
      "Apply Errata": [
        "Aplicar Errata"
      ],
      "Apply Errata to Content Host \\\"{{host.display_name}}\\\"?": [
        ""
      ],
      "Apply Errata to Content Hosts": [
        "Aplicar Errata aos Hosts de Conteúdo"
      ],
      "Apply Errata to Content Hosts immediately after publishing.": [
        "Aplique Errata aos Hosts de Conteúdo imediatamente após a publicação."
      ],
      "Apply Selected": [
        "Aplicar Selecionado"
      ],
      "Apply to Content Hosts": [
        "Aplicar aos Hosts de Conteúdo"
      ],
      "Apply to Hosts": [
        "Aplicar para Anfitriões"
      ],
      "Applying": [
        "Aplicando"
      ],
      "Apt Actions": [
        ""
      ],
      "Arch": [
        "Arq."
      ],
      "Architecture": [
        "Arquitetura"
      ],
      "Architectures": [
        "Arquiteturas"
      ],
      "Are you sure you want to add the {{ table.numSelected }} content host(s) selected to the host collection(s) chosen?": [
        "Você tem certeza de que deseja adicionar o(s) anfitrião(s) de conteúdo {{ table.numSelected }} selecionado(s) à(s) coleção(ões) anfitriã(s) escolhida(s)?"
      ],
      "Are you sure you want to add the sync plan to the selected products(s)?": [
        "Você tem certeza de que deseja adicionar o plano de sincronização aos produtos selecionados?"
      ],
      "Are you sure you want to apply Errata to content host \\\"{{ host.display_name }}\\\"?": [
        ""
      ],
      "Are you sure you want to apply the {{ table.numSelected }} selected errata to the content hosts chosen?": [
        "Você tem certeza de que deseja aplicar as erratas selecionadas {{ table.numSelected }} aos anfitriões de conteúdo escolhidos?"
      ],
      "Are you sure you want to assign the {{ table.numSelected }} content host(s) selected to {{ selected.contentView.name }} in {{ selected.environment.name }}?": [
        "Você tem certeza de que deseja designar o(s) anfitrião(s) de conteúdo {{ table.numSelected }} selecionado(s) para {{ selected.contentView.name }} em {{ selected.environment.name }}?"
      ],
      "Are you sure you want to delete the {{ table.numSelected }} host(s) selected?": [
        ""
      ],
      "Are you sure you want to disable the {{ table.numSelected }} repository set(s) chosen?": [
        "Você tem certeza de que quer desativar o(s) conjunto(s) de repositório(s) {{ table.numSelected }} escolhido(s)?"
      ],
      "Are you sure you want to enable the {{ table.numSelected }} repository set(s) chosen?": [
        "Você tem certeza de que quer habilitar o(s) conjunto(s) de repositório(s) {{ table.numSelected }} escolhido(s)?"
      ],
      "Are you sure you want to install {{ content.content }} on the {{ getSelectedSystemIds().length }} system(s) selected?": [
        "Você tem certeza de que deseja instalar {{ content.content }} no(s) sistema(s) {{ getSelectedSystemIds().length }} selecionado(s)?"
      ],
      "Are you sure you want to remove {{ content.content }} from the {{ getSelectedSystemIds().length }} system(s) selected?": [
        "Você tem certeza de que quer remover {{ content.content }} do(s) sistema(s) {{ getSelectedSystemIds().length }} selecionado(s)?"
      ],
      "Are you sure you want to remove Activation Key \\\"{{ activationKey.name }}\\\"?": [
        "Você tem certeza que quer remover a Chave de Ativação \\\"{{ activationKey.name }}\\\"?"
      ],
      "Are you sure you want to remove Content Credential {{ contentCredential.name }}?": [
        "Você tem certeza de que deseja remover a Credencial de Conteúdo {{ contentCredential.name }}?"
      ],
      "Are you sure you want to remove environment {{ environment.name }}?": [
        ""
      ],
      "Are you sure you want to remove Host Collection \\\"{{ hostCollection.name }}\\\"?": [
        "Você tem certeza de que quer remover a Coleção Host \\\"{{ hostCollection.name }}\\\"?"
      ],
      "Are you sure you want to remove product \\\"{{ product.name }}\\\"?": [
        "Você tem certeza de que quer remover o produto \\\"{{ product.name }}\\\"?"
      ],
      "Are you sure you want to remove repository {{ repositoryWrapper.repository.name }} from all content views?": [
        ""
      ],
      "Are you sure you want to remove Sync Plan \\\"{{ syncPlan.name }}\\\"?": [
        "Você tem certeza de que quer remover o Sync Plan \\\"{{ syncPlan.name }}\\\"?"
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} content unit?": [
        "",
        "",
        ""
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} file?": [
        "",
        "",
        ""
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} package?": [
        "",
        "",
        ""
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} product?": [
        "",
        "",
        ""
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} repository?": [
        "",
        "",
        ""
      ],
      "Are you sure you want to remove the {{ table.numSelected }} Container Image manifest selected?": [
        "",
        "",
        ""
      ],
      "Are you sure you want to remove the {{ table.numSelected }} content host(s) selected from the host collection(s) chosen?": [
        "Você tem certeza de que deseja remover o(s) anfitrião(s) de conteúdo {{ table.numSelected }} selecionado(s) da(s) coleção(ões) anfitriã(s) escolhida(s)?"
      ],
      "Are you sure you want to remove the sync plan from the selected product(s)?": [
        "Você tem certeza de que deseja remover o plano de sincronização do(s) produto(s) selecionado(s)?"
      ],
      "Are you sure you want to reset to default the {{ table.numSelected }} repository set(s) chosen?": [
        "Você tem certeza de que quer redefinir para o padrão o(s) conjunto(s) de repositório(s) {{ table.numSelected }} escolhido(s)?"
      ],
      "Are you sure you want to restart services on content host \\\"{{ host.display_name }}\\\"?": [
        ""
      ],
      "Are you sure you want to restart the services on the selected content hosts?": [
        ""
      ],
      "Are you sure you want to set the HTTP Proxy to the selected products(s)?": [
        ""
      ],
      "Are you sure you want to set the Release Version the {{ table.numSelected }} content host(s) selected to {{ selected.release }}?. This action will affect only those Content Hosts that belong to the appropriate Content View and Lifecycle Environment containining that release version.": [
        "Você tem certeza de que deseja definir a Versão de Lançamento o(s) host(s) de conteúdo {{ table.numSelected }} selecionado(s) para {{ selected.release }}?. Esta ação afetará somente aqueles Hosts de conteúdo que pertencem à Visão de Conteúdo e Ambiente de Ciclo de Vida apropriados, contendo aquela versão de lançamento."
      ],
      "Are you sure you want to update {{ content.content }} on the {{ getSelectedSystemIds().length }} system(s) selected?": [
        "Você tem certeza de que deseja atualizar {{ content.content }} no(s) sistema(s) {{ getSelectedSystemIds().length }} selecionado(s)?"
      ],
      "Are you sure you want to update all packages on the {{ getSelectedSystemIds().length }} system(s) selected?": [
        "Você tem certeza de querer atualizar todos os pacotes no(s) sistema(s) {{ getSelectedSystemIds().length }} selecionado(s)?"
      ],
      "Assign": [
        "Atribuir"
      ],
      "Assign Lifecycle Environment and Content View": [
        ""
      ],
      "Assign Release Version": [
        "Atribuir Versão de Lançamento"
      ],
      "Assign System Purpose": [
        ""
      ],
      "Associations": [
        "Associações"
      ],
      "At least one Errata needs to be selected to Apply.": [
        "Pelo menos uma Errata precisa ser selecionada para se candidatar."
      ],
      "Attached": [
        "Anexado"
      ],
      "Auth Token": [
        ""
      ],
      "Auth URL": [
        ""
      ],
      "Author": [
        "Autor"
      ],
      "Auto-Attach": [
        "Auto-Attach"
      ],
      "Auto-attach available subscriptions to all selected hosts.": [
        ""
      ],
      "Auto-Attach Details": [
        ""
      ],
      "Auto-attach uses all available subscriptions, not a selected subset.": [
        ""
      ],
      "Automatic": [
        "Automático"
      ],
      "Available Module Streams": [
        ""
      ],
      "Available Schema Versions": [
        "Versões disponíveis do esquema"
      ],
      "Back To Errata List": [
        "Voltar à lista de erros"
      ],
      "Backend Identifier": [
        "Identificador backend"
      ],
      "Basic Information": [
        "Informações básicas"
      ],
      "Below are the repository content sets currently available for this content host through its subscriptions. For Red Hat subscriptions, additional content can be made available through the": [
        "Abaixo estão os conjuntos de conteúdo de repositório atualmente disponíveis para este hospedeiro de conteúdo através de suas assinaturas. Para as assinaturas da Red Hat, conteúdo adicional pode ser disponibilizado através do"
      ],
      "Below are the Repository Sets currently available for this activation key through its subscriptions. For Red Hat subscriptions, additional content can be made available through the": [
        "Abaixo estão os Conjuntos de Repositório atualmente disponíveis para esta chave de ativação através de suas assinaturas. Para as assinaturas da Red Hat, conteúdo adicional pode ser disponibilizado através do"
      ],
      "BIOS UUID": [
        ""
      ],
      "Bootable": [
        "Inicializavel"
      ],
      "Bug Fix": [
        "Correção de erro"
      ],
      "Bug Fix Advisory": [
        "Consultoria em correção de erros"
      ],
      "Build Host": [
        "Construir Host"
      ],
      "Build Information": [
        "Construir informações"
      ],
      "Build Time": [
        "Tempo de construção"
      ],
      "Bulk Task": [
        ""
      ],
      "Cancel": [
        "Cancelar"
      ],
      "Cannot clean Repository without the proper permissions.": [
        ""
      ],
      "Cannot clean Repository, a sync is already in progress.": [
        ""
      ],
      "Cannot Remove": [
        "Não é possível remover"
      ],
      "Cannot republish Repository without the proper permissions.": [
        "Não é possível republicar o Repositório sem as devidas permissões."
      ],
      "Cannot republish Repository, a sync is already in progress.": [
        "Não é possível republicar o Repositório, uma sincronização já está em andamento."
      ],
      "Cannot sync Repository without a URL.": [
        "Não é possível sincronizar o Repositório sem uma URL."
      ],
      "Cannot sync Repository without the proper permissions.": [
        "Não é possível sincronizar o Repositório sem as devidas permissões."
      ],
      "Cannot sync Repository, a sync is already in progress.": [
        "Não é possível sincronizar o Repositório, uma sincronização já está em andamento."
      ],
      "Capacity": [
        "Capacidade"
      ],
      "Certificate": [
        "Certificado"
      ],
      "Change assigned Lifecycle Environment or Content View": [
        "Mudança atribuída ao Ambiente do Ciclo de Vida ou Visão de Conteúdo"
      ],
      "Change Host Collections": [
        "Mudança de coleções de anfitriões"
      ],
      "Change Lifecycle Environment": [
        "Mudar o ambiente do ciclo de vida"
      ],
      "Changing default settings for content hosts that register with this activation key requires subscription-manager version 1.10 or newer to be installed on that host.": [
        "A mudança das configurações padrão para hosts de conteúdo que se registram com esta chave de ativação requer que a versão 1.10 ou mais recente do gerenciador de assinatura seja instalada naquele host."
      ],
      "Changing default settings requires subscription-manager version 1.10 or newer to be installed on this host.": [
        "A mudança das configurações padrão requer que a versão 1.10 ou mais recente do gerenciador de assinatura seja instalada neste host."
      ],
      "Changing download policy to \\\"On Demand\\\" will also clear the checksum type if set. The repository will use the upstream checksum type to verify downloads.": [
        ""
      ],
      "Changing the Content View will not affect the Content Host until its next checkin.\\n                To update the Content Host immediately run the following command:": [
        ""
      ],
      "Changing the Content View will not affect the Content Hosts until their next checkin.\\n        To update the Content Hosts immediately run the following command:": [
        ""
      ],
      "Checksum": [
        "Checksum"
      ],
      "Checksum Type": [
        "Tipo de Checksum"
      ],
      "Choose one of the registry options to discover containers. To examine a private registry choose \\\"Custom\\\" and provide the url for the private registry.": [
        ""
      ],
      "Click here to check the status of the task.": [
        "Clique aqui para verificar o status da tarefa."
      ],
      "Click here to select Errata for an Incremental Update.": [
        "Clique aqui para selecionar Errata para uma Atualização Incremental."
      ],
      "Click to monitor task progress.": [
        ""
      ],
      "Click to view task": [
        ""
      ],
      "Close": [
        "Fechar"
      ],
      "Collection Name": [
        ""
      ],
      "Complete Mirroring": [
        ""
      ],
      "Complete Sync": [
        "Sincronia completa"
      ],
      "Completed {{ repository.last_sync_words }} ago": [
        ""
      ],
      "Completely deletes the host including VM and disks, and removes all reporting, provisioning, and configuration information.": [
        ""
      ],
      "Components": [
        "Componentes"
      ],
      "Components:": [
        "Componentes:"
      ],
      "Composite View": [
        "Vista Composta"
      ],
      "Confirm": [
        "Confirmar"
      ],
      "Confirm services restart": [
        ""
      ],
      "Container Image Manifest": [
        "Manifesto de imagem de contêiner"
      ],
      "Container Image Manifest Lists": [
        "Listas de Manifestos de Imagens de Contêineres"
      ],
      "Container Image Manifests": [
        "Manifestos de imagens de contêineres"
      ],
      "Container Image metadata generation has been initiated in the background.  Click\\n      <a ng-href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        ""
      ],
      "Container Image Registry": [
        ""
      ],
      "Container Image Tags": [
        "Tags de imagem de contêiner"
      ],
      "Content": [
        "Conteúdo"
      ],
      "Content Counts": [
        "Contas de Conteúdo"
      ],
      "Content Credential": [
        ""
      ],
      "Content Credential %s has been created.": [
        "Foi criada a Credencial de Conteúdo %s."
      ],
      "Content Credential Contents": [
        "Conteúdo Conteúdo Credencial"
      ],
      "Content Credential successfully uploaded": [
        "Conteúdo Credencial carregado com sucesso"
      ],
      "Content credential updated": [
        "Credencial de conteúdo atualizada"
      ],
      "Content Credentials": [
        "Credenciais de conteúdo"
      ],
      "Content Host": [
        "Host de Conteúdo"
      ],
      "Content Host Bulk Content": [
        "Conteúdo Conteúdo do Host Bulk"
      ],
      "Content Host Bulk Subscriptions": [
        "Assinaturas em massa de conteúdo"
      ],
      "Content Host Content": [
        "Conteúdo Conteúdo do Host"
      ],
      "Content Host Counts": [
        "Conteúdos Contém"
      ],
      "Content Host Limit": [
        "Limite do Host de Conteúdo"
      ],
      "Content Host Module Stream Management": [
        ""
      ],
      "Content Host Properties": [
        "Propriedades do hospedeiro de conteúdo"
      ],
      "Content Host Registration": [
        "Registro de anfitrião de conteúdo"
      ],
      "Content Host Status": [
        "Status do hospedeiro de conteúdo"
      ],
      "Content Host Traces Management": [
        ""
      ],
      "Content Host:": [
        "Host de conteúdo:"
      ],
      "Content Hosts": [
        "Hosts de Conteúdo"
      ],
      "Content Hosts for Activation Key:": [
        "Chave de ativação de conteúdo:"
      ],
      "Content Hosts for:": [
        "Hosts de conteúdo para:"
      ],
      "Content Only": [
        ""
      ],
      "Content synced depends on the specifity of the URL and/or the optional requirements.yaml specified below <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'ansible_collection'\\\" uib-popover-html=\\\"collectionURLPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Upstream URL\\\">\\n        </a>": [
        ""
      ],
      "Content Type": [
        "Tipo de Conteúdo"
      ],
      "Content View": [
        "Visão do conteúdo"
      ],
      "Content View Version": [
        "Versão de visualização do conteúdo"
      ],
      "Content View:": [
        "Vista do conteúdo:"
      ],
      "Content Views": [
        "Exibições de conteúdo"
      ],
      "Content Views <div>{{ library.counts.content_views || 0 }}</div>": [
        "Visualizações de conteúdo <div>{{ library.counts.content_views || 0 }}</div>"
      ],
      "Content Views for Deb:": [
        "Visualizações de conteúdo para Deb:"
      ],
      "Content Views for File:": [
        "Visualizações de conteúdo para arquivo:"
      ],
      "Content Views that contain this Deb": [
        "Visualizações de conteúdo que contêm esta Deb"
      ],
      "Content Views that contain this File": [
        "Visualizações de conteúdo que contêm este arquivo"
      ],
      "Context": [
        "Contexto"
      ],
      "Contract": [
        "Contrato"
      ],
      "Copy Activation Key": [
        "Chave de ativação de cópia"
      ],
      "Copy Host Collection": [
        "Cópia da Coleção Host"
      ],
      "Cores per Socket": [
        "Núcleos por Tomada"
      ],
      "Create": [
        "Criar"
      ],
      "Create a copy of {{ activationKey.name }}": [
        "Crie uma cópia de {{ activationKey.name }}"
      ],
      "Create a copy of {{ hostCollection.name }}": [
        "Crie uma cópia de {{ hostCollection.name }}"
      ],
      "Create Activation Key": [
        "Criar chave de ativação"
      ],
      "Create Content Credential": [
        "Criar Credencial de Conteúdo"
      ],
      "Create Copy": [
        ""
      ],
      "Create Discovered Repositories": [
        "Criar Repositórios Descobertos"
      ],
      "Create Environment Path": [
        "Criar caminho ambiental"
      ],
      "Create Host Collection": [
        "Criar coleção de anfitriões"
      ],
      "Create Product": [
        "Criar Produto"
      ],
      "Create Repositories": [
        "Criar repositórios"
      ],
      "Create Selected": [
        "Criar Selecionado"
      ],
      "Create Status": [
        "Criar status"
      ],
      "Create Sync Plan": [
        "Criar Plano de Sincronização"
      ],
      "Creating repository...": [
        "Criando repositório..."
      ],
      "Critical": [
        "Crítico"
      ],
      "Cron Logic": [
        ""
      ],
      "ctrl-click or shift-click to select multiple Add ons": [
        ""
      ],
      "Current Lifecycle Environment (%e/%cv)": [
        ""
      ],
      "Current Subscriptions for Activation Key:": [
        "Assinaturas atuais para chave de ativação:"
      ],
      "Custom": [
        ""
      ],
      "custom cron": [
        ""
      ],
      "Custom Cron": [
        ""
      ],
      "Custom Cron : {{ product.sync_plan.cron_expression }}": [
        ""
      ],
      "Customize": [
        ""
      ],
      "CVEs": [
        "CVEs"
      ],
      "daily": [
        "diariamente"
      ],
      "Daily at {{ product.sync_plan.sync_date | date:'mediumTime' }} (Server Time)": [
        "Diariamente em {{ product.sync_plan.sync_date | date:'mediumTime' }} (horário do servidor)"
      ],
      "Date": [
        "Data"
      ],
      "deb metadata generation has been initiated in the background.  Click <a href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        "A geração de metadados deb foi iniciada em segundo plano.  Clique <a href=\\\"{{ taskUrl() }}\\\">Aqui</a> para monitorar o progresso."
      ],
      "Deb Package Actions": [
        ""
      ],
      "deb Package Updates": [
        ""
      ],
      "deb Packages": [
        "pacotes deb"
      ],
      "Deb Packages": [
        "Pacotes deb"
      ],
      "Deb Packages <div>{{ library.counts.debs || 0 }}</div>": [
        ""
      ],
      "Deb Packages for:": [
        ""
      ],
      "Deb Repositories": [
        "Repositórios de depuração"
      ],
      "Deb Repositories <div>{{ library.counts.deb_repositories || 0 }}</div>": [
        ""
      ],
      "Deb:": [
        "Deb:"
      ],
      "Debs": [
        "Depurações"
      ],
      "Default": [
        "Padrão"
      ],
      "Default Status": [
        ""
      ],
      "Delete": [
        "Excluir"
      ],
      "Delete {{ table.numSelected  }} Hosts?": [
        ""
      ],
      "Delete filters": [
        ""
      ],
      "Delete Hosts": [
        "Apagar hosts"
      ],
      "Delta RPM": [
        ""
      ],
      "Dependencies": [
        "Dependências"
      ],
      "Description": [
        "Descrição"
      ],
      "Details": [
        "Detalhes"
      ],
      "Details for Activation Key:": [
        "Detalhes da chave de ativação:"
      ],
      "Details for Container Image Tag:": [
        ""
      ],
      "Details for Product:": [
        "Detalhes do Produto:"
      ],
      "Details for Repository:": [
        "Detalhes para Repositório:"
      ],
      "Determines whether to require login to pull container images in this lifecycle environment.": [
        ""
      ],
      "Digest": [
        "Digest"
      ],
      "Disable": [
        "Desabilitar"
      ],
      "Disabled": [
        "Desativado"
      ],
      "Disabled (overridden)": [
        "Deficiente (anulado)"
      ],
      "Discover": [
        "Descubra"
      ],
      "Discover Repositories": [
        "Descobrir Repositórios "
      ],
      "Discovered Repository": [
        "Repositório Descoberto"
      ],
      "Discovery failed. Error: %s": [
        "A descoberta falhou. Erro: %s"
      ],
      "Distribution": [
        "Distribuição"
      ],
      "Distribution Information": [
        "Informações sobre distribuição"
      ],
      "Do not require a subscription entitlement certificate for accessing this repository.": [
        ""
      ],
      "Docker": [
        "Docker"
      ],
      "Docker metadata generation has been initiated in the background.  Click\\n            <a ng-href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        ""
      ],
      "Docker Repositories <div>{{ library.counts.docker_repositories || 0 }}</div>": [
        "Repositórios de Docker <div>{{ library.counts.docker_repositories || 0 }}</div>"
      ],
      "Docker Tags": [
        "Tags do Docker "
      ],
      "Done": [
        "Feito"
      ],
      "Download Policy": [
        "Política de download"
      ],
      "Enable": [
        "Habilitar"
      ],
      "Enable Traces": [
        ""
      ],
      "Enabled": [
        "Ativado"
      ],
      "Enabled (overridden)": [
        "Ativado (anulado)"
      ],
      "Enhancement": [
        "Melhoria"
      ],
      "Enter Package Group Name(s)...": [
        "Digite o(s) nome(s) do(s) grupo(s) de pacote(s)..."
      ],
      "Enter Package Name(s)...": [
        "Digite o(s) nome(s) do(s) pacote(s)..."
      ],
      "Environment": [
        "Ambiente"
      ],
      "Environment saved": [
        "Meio ambiente economizado"
      ],
      "Environment will also be removed from the following published content views!": [
        ""
      ],
      "Environments": [
        "Ambientes"
      ],
      "Environments List": [
        "Lista de Ambientes"
      ],
      "Errata": [
        "Erratas"
      ],
      "Errata <div>{{ library.counts.errata.total || 0 }}</div>": [
        "Errata <div>{{ library.counts.errata.total || 0 }}</div>"
      ],
      "Errata are automatically Applicable if they are Installable": [
        "Os erros são automaticamente aplicáveis se forem instaláveis"
      ],
      "Errata Details": [
        "Detalhes da Errata"
      ],
      "Errata for:": [
        "Errata para:"
      ],
      "Errata ID": [
        "Errata ID"
      ],
      "Errata Installation": [
        "Instalação de Errata"
      ],
      "Errata Task List": [
        "Lista de tarefas de erros"
      ],
      "Errata Tasks": [
        "Errata Tarefas"
      ],
      "Errata:": [
        "Errata:"
      ],
      "Error during upload:": [
        "Erro durante o upload:"
      ],
      "Error saving the Sync Plan:": [
        ""
      ],
      "Event": [
        "Evento"
      ],
      "Exclude Tags": [
        ""
      ],
      "Existing Product": [
        "Produto Existente"
      ],
      "Expires": [
        "Expira"
      ],
      "Export": [
        "Exportar"
      ],
      "Family": [
        "Família"
      ],
      "File Information": [
        "Informações do arquivo"
      ],
      "File removal been initiated in the background.  Click <a href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        "A remoção do arquivo foi iniciada em segundo plano.  Clique <a href=\\\"{{ taskUrl() }}\\\">Aqui</a> para monitorar o progresso."
      ],
      "File too large.": [
        "Arquivo muito grande."
      ],
      "File too large. Please use the CLI instead.": [
        "Arquivo muito grande. Por favor, use o CLI em seu lugar."
      ],
      "File:": [
        "Arquivo:"
      ],
      "Filename": [
        "Nome do arquivo"
      ],
      "Files": [
        "Arquivos"
      ],
      "Files in package {{ package.nvrea }}": [
        "Arquivos em pacote {{ package.nvrea }}"
      ],
      "Filter": [
        "Flitro"
      ],
      "Filter by Environment": [
        ""
      ],
      "Filter by Status:": [
        ""
      ],
      "Filter...": [
        "Filtro..."
      ],
      "Filters": [
        ""
      ],
      "Finished At": [
        "Concluído em"
      ],
      "For older operating systems such as Red Hat Enterprise Linux 5 or CentOS 5 it is recommended to use sha1.": [
        "Para sistemas operacionais mais antigos como o Red Hat Enterprise Linux 5 ou CentOS 5 é recomendado o uso do sha1."
      ],
      "For On Demand synchronization, only the metadata is downloaded during sync and packages are fetched and stored on the filesystem when clients request them.\\n          On Demand is not recommended for custom repositories unless the upstream repository maintains older versions of packages within the repository.\\n          The Immediate option will download all metadata and packages immediately during the sync.": [
        ""
      ],
      "Global Default": [
        ""
      ],
      "Global Default (None)": [
        ""
      ],
      "GPG Key": [
        "Chave GPG"
      ],
      "Group": [
        "Grupo"
      ],
      "Group Install (Deprecated)": [
        ""
      ],
      "Group package actions are being deprecated, and will be removed in a future version.": [
        ""
      ],
      "Group Remove (Deprecated)": [
        ""
      ],
      "Guests of": [
        "Convidados de"
      ],
      "Helper": [
        "Ajudante"
      ],
      "Host %s has been deleted.": [
        "O host %s foi excluído."
      ],
      "Host %s has been unregistered.": [
        "O host %s não foi registrado."
      ],
      "Host Collection Management": [
        "Gerenciamento de coleta de hospedagem"
      ],
      "Host Collection Membership": [
        "Afiliação a Coleta de Anfitriões"
      ],
      "Host Collection Membership Management": [
        ""
      ],
      "Host Collection removed.": [
        "Coleção de anfitriões removida."
      ],
      "Host Collection updated": [
        "Coleção de anfitriões atualizada"
      ],
      "Host Collection:": [
        "Coleção de anfitriões:"
      ],
      "Host Collections": [
        "Coleções de Host"
      ],
      "Host Collections for:": [
        "Coleções de anfitriões para:"
      ],
      "Host Count": [
        "Contagem de anfitriões"
      ],
      "Host Group": [
        "Grupo de Host"
      ],
      "Host Limit": [
        "Limite do anfitrião"
      ],
      "Hostname": [
        "Nome da máquina"
      ],
      "Hosts": [
        "Hosts"
      ],
      "hourly": [
        "de hora em hora"
      ],
      "Hourly at {{ product.sync_plan.sync_date | date:'m' }} minutes and {{ product.sync_plan.sync_date | date:'s' }} seconds": [
        "De hora em hora em {{ product.sync_plan.sync_date | date:'m' }} minutos e {{ product.sync_plan.sync_date | date:'s' }} segundos"
      ],
      "HTTP Proxy": [
        "Proxy HTTP"
      ],
      "HTTP Proxy Management": [
        ""
      ],
      "HTTP Proxy Policy": [
        ""
      ],
      "HTTP Proxy Policy:": [
        ""
      ],
      "HTTP Proxy:": [
        ""
      ],
      "HttpProxyPolicy": [
        "HttpProxyPolicy"
      ],
      "Id": [
        "Id"
      ],
      "Ignore SRPMs": [
        ""
      ],
      "Ignore treeinfo": [
        ""
      ],
      "Image": [
        "Imagem"
      ],
      "Immediate": [
        "Imediato(a)"
      ],
      "Important": [
        "Importante"
      ],
      "In order to browse this repository you must <a ng-href=\\\"/organizations/{{ organization }}/edit\\\">download the certificate</a>\\n            or ask your admin for a certificate.": [
        "Para navegar por este repositório você deve <a ng-href=\\\"/organizations/{{ organization }}/edit\\\">baixar o certificado</a>\\n            ou peça um certificado a seu administrador."
      ],
      "Include Tags": [
        ""
      ],
      "Independent Packages": [
        ""
      ],
      "Install": [
        "Instalar"
      ],
      "Install Selected": [
        "Instalação Selecionada"
      ],
      "Install the pre-built bootstrap RPM:": [
        "Instalar o RPM do bootstrap pré-construído:"
      ],
      "Installable": [
        "Instalável"
      ],
      "Installable Errata": [
        "Errata instalável"
      ],
      "Installable Updates": [
        "Atualizações instaláveis"
      ],
      "Installed": [
        "Instalados"
      ],
      "Installed Deb Packages": [
        ""
      ],
      "Installed On": [
        "Instalado em"
      ],
      "Installed Package": [
        "Pacote instalado"
      ],
      "Installed Packages": [
        "Pacotes instalados"
      ],
      "Installed Products": [
        "Produtos Instalados"
      ],
      "Installed Profile": [
        ""
      ],
      "Interfaces": [
        "Interfaces"
      ],
      "Interval": [
        "Intervalo"
      ],
      "IPv4 Address": [
        "Endereço IPv4"
      ],
      "IPv6 Address": [
        "Endereço IPv6"
      ],
      "Issued": [
        "Emitido em"
      ],
      "Katello Tracer": [
        ""
      ],
      "Label": [
        "Rótulo"
      ],
      "Last Checkin": [
        "Último Checkin"
      ],
      "Last Published": [
        "Publicado pela última vez"
      ],
      "Last Puppet Report": [
        "Último Relatório de Marionetes"
      ],
      "Last reclaim failed:": [
        ""
      ],
      "Last reclaim space failed:": [
        ""
      ],
      "Last Sync": [
        "Última Sincronia"
      ],
      "Last sync failed:": [
        ""
      ],
      "Last synced": [
        ""
      ],
      "Last Updated On": [
        "Última Atualização em"
      ],
      "Library": [
        "Biblioteca"
      ],
      "Library Repositories": [
        "Repositórios de bibliotecas"
      ],
      "Library Repositories that contain this Deb.": [
        "Repositórios de bibliotecas que contêm esta Deb."
      ],
      "Library Repositories that contain this File.": [
        "Repositórios da biblioteca que contêm este arquivo."
      ],
      "Library Synced Content": [
        "Biblioteca Conteúdo Sincronizado"
      ],
      "License": [
        "Licença"
      ],
      "Lifecycle Environment": [
        "Ambiente de Ciclo de Vida"
      ],
      "Lifecycle Environment Paths": [
        "Caminhos do ambiente do ciclo de vida"
      ],
      "Lifecycle Environment:": [
        ""
      ],
      "Lifecycle Environments": [
        "Ambientes de ciclo de vida"
      ],
      "Limit": [
        "Limite"
      ],
      "Limit Repository Sets to only those available in this Activation Key's Lifecycle  Environment": [
        ""
      ],
      "Limit Repository Sets to only those available in this Host's Lifecycle Environment": [
        "Limitar os Conjuntos de Repositório a apenas aqueles disponíveis no Ambiente de Ciclo de Vida deste Host"
      ],
      "Limit to environment": [
        "Limite ao meio ambiente"
      ],
      "Limit to Environment": [
        "Limite ao meio ambiente"
      ],
      "Limit to Lifecycle Environment": [
        ""
      ],
      "Limit:": [
        "Limite:"
      ],
      "List": [
        "Lista"
      ],
      "List Host Collections": [
        ""
      ],
      "List Hosts": [
        ""
      ],
      "List Products": [
        ""
      ],
      "List Subscriptions": [
        ""
      ],
      "List/Remove": [
        "Lista/Remover"
      ],
      "Loading...": [
        "Carregando..."
      ],
      "Loading...\\\"": [
        "Carregando...\\\""
      ],
      "Make filters apply to all repositories in the content view": [
        ""
      ],
      "Manage Ansible Collections for Repository:": [
        ""
      ],
      "Manage Container Image Manifests for Repository:": [
        ""
      ],
      "Manage Content for Repository:": [
        ""
      ],
      "Manage deb Packages for Repository:": [
        "Gerenciar pacotes de deb para Repositório:"
      ],
      "Manage Errata": [
        "Gerenciar Errata"
      ],
      "Manage Files for Repository:": [
        "Gerenciar Arquivos para Repositório:"
      ],
      "Manage Host Traces": [
        ""
      ],
      "Manage HTTP Proxy": [
        ""
      ],
      "Manage Module Streams": [
        ""
      ],
      "Manage Module Streams for Repository:": [
        ""
      ],
      "Manage Packages": [
        "Gerenciar pacotes"
      ],
      "Manage Packages for Repository:": [
        "Gerenciar Pacotes para Repositório:"
      ],
      "Manage Repository Sets": [
        "Gerenciar Conjuntos de Repositórios"
      ],
      "Manage Subscriptions": [
        "Gerenciar Assinaturas"
      ],
      "Manage Sync Plan": [
        "Gerenciar Plano de Sincronização"
      ],
      "Manage System Purpose": [
        ""
      ],
      "Manifest Lists": [
        "Listas Manifestativas"
      ],
      "Manifest Type": [
        "Tipo de Manifesto"
      ],
      "Metadata Expiration (Seconds)": [
        ""
      ],
      "Mirroring Policy": [
        ""
      ],
      "Model": [
        "Modelar"
      ],
      "Moderate": [
        "Moderado"
      ],
      "Modular": [
        ""
      ],
      "Module Stream Management": [
        ""
      ],
      "Module Stream metadata generation has been initiated in the background.  Click\\n      <a ng-href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        ""
      ],
      "Module Stream Packages": [
        ""
      ],
      "Module Streams": [
        "Fluxos de módulo"
      ],
      "Module Streams <div>{{ library.counts.module_streams || 0 }}</div>": [
        ""
      ],
      "Module Streams for:": [
        ""
      ],
      "More Details": [
        "Mais detalhes"
      ],
      "N/A": [
        "N/D"
      ],
      "Name": [
        "Nome"
      ],
      "Name of the upstream repository you want to sync. Example: 'quay/busybox' or 'fedora/ssh'.": [
        ""
      ],
      "Networking": [
        "Trabalho em rede"
      ],
      "Never": [
        "Nunca"
      ],
      "Never checked in": [
        ""
      ],
      "Never registered": [
        ""
      ],
      "Never synced": [
        "Nunca sincronizado"
      ],
      "New Activation Key": [
        "Nova chave de ativação"
      ],
      "New Content Credential": [
        ""
      ],
      "New Environment": [
        "Novo Ambiente"
      ],
      "New Host Collection": [
        ""
      ],
      "New Name:": [
        "Novo nome:"
      ],
      "New Product": [
        "Novo produto"
      ],
      "New Repository": [
        "Novo Repositório"
      ],
      "New Sync Plan": [
        "Novo Plano de Sincronização"
      ],
      "New sync plan successfully created.": [
        "Novo plano de sincronização criado com sucesso."
      ],
      "Next": [
        "Próximo"
      ],
      "Next Sync": [
        "Próxima Sincronia"
      ],
      "No": [
        "Não"
      ],
      "No alternate release version choices are available. The available releases are based upon what is available in \\\"{{ host.content_facet_attributes.content_view.name }}\\\", the selected <a href=\\\"/content_views\\\">content view</a> this content host is attached to for the given <a href=\\\"/lifecycle_environments\\\">lifecycle environment</a>, \\\"{{ host.content_facet_attributes.lifecycle_environment.name }}\\\".": [
        "Não há opções de versões alternativas disponíveis. As versões disponíveis são baseadas no que está disponível em \\\"{{ host.content_facet_attributes.content_view.name }}\\\", a visão de conteúdo selecionada <a href=\\\"/content_views\\\"></a> a que este anfitrião de conteúdo está anexado para o ambiente <a href=\\\"/lifecycle_environments\\\">dado ciclo de vida</a>, \\\"{{ host.content_facet_attributes.lifecycle_environment.name }}\\\"."
      ],
      "No Content Hosts match this Erratum.": [
        "Nenhum hospedeiro de conteúdo corresponde a este erro."
      ],
      "No Content Views contain this Deb": [
        "Nenhuma Vista de Conteúdo contém esta Deb"
      ],
      "No Content Views contain this File": [
        "Nenhuma vista de conteúdo contém este arquivo"
      ],
      "No content views exist for {{selected.environment.name}}": [
        "Não existem visualizações de conteúdo para {{selected.environment.name}}"
      ],
      "No discovered repositories.": [
        "Nenhum repositório descoberto."
      ],
      "No enabled Repository Sets provided through subscriptions.": [
        ""
      ],
      "No Host Collections match your search.": [
        "Nenhuma coleção de anfitriões corresponde à sua busca."
      ],
      "No Host Collections to show, you can add Host Collections after selecting 'Host Collections' under 'Hosts' in main menu.": [
        "Não há coleções de anfitriões para mostrar, você pode adicionar Coleções de anfitriões após selecionar 'Coleções de anfitriões' em 'Anfitriões' no menu principal."
      ],
      "No Host Collections to show, you can add Host Collections after selecting the 'Add' tab.": [
        "Sem Coleções Hospedeiras para mostrar, você pode adicionar Coleções Hospedeiras após selecionar a guia 'Adicionar'."
      ],
      "No HTTP Proxies found": [
        ""
      ],
      "No HTTP Proxy": [
        ""
      ],
      "No matching results.": [
        "Sem resultados correspondentes."
      ],
      "No Packages to show": [
        ""
      ],
      "No products are available to add to this Sync Plan.": [
        "Não há produtos disponíveis para adicionar a este Plano de Sincronização."
      ],
      "No products have been added to this Sync Plan.": [
        ""
      ],
      "No releases exist in the Library.": [
        "Não existem lançamentos na Biblioteca."
      ],
      "No Repositories contain this Deb": [
        "Nenhum Repositório contém este Deb"
      ],
      "No Repositories contain this Erratum.": [
        "Nenhum Repositório contém este erro."
      ],
      "No Repositories contain this File": [
        "Nenhum Repositório contém este arquivo"
      ],
      "No Repositories contain this Package.": [
        "Nenhum Repositório contém este pacote."
      ],
      "No repository sets provided through subscriptions.": [
        "Não são fornecidos conjuntos de repositórios através de assinaturas."
      ],
      "No restriction": [
        ""
      ],
      "No sync information available.": [
        "Não há informações de sincronização disponíveis."
      ],
      "No tasks exist for this resource.": [
        "Não existem tarefas para este recurso."
      ],
      "None": [
        "Nenhum"
      ],
      "Not Applicable": [
        ""
      ],
      "Not started": [
        "Não iniciado"
      ],
      "Not Synced": [
        "Não foi Sincronizado"
      ],
      "Number of CPUs": [
        "Número de CPUs"
      ],
      "Number of Repositories": [
        "Número de Repositórios"
      ],
      "On Demand": [
        "Sob demanda"
      ],
      "One or more of the selected Errata are not Installable via your published Content View versions running on the selected hosts.  The new Content View Versions (specified below)\\n      will be created which will make this Errata Installable in the host's Environment.  This new version will replace the current version in your host's Lifecycle\\n      Environment.  To install these errata immediately on hosts after publishing check the box below.": [
        "Uma ou mais das Erratas selecionadas não podem ser instaladas através de suas versões publicadas de Visualização de Conteúdo rodando nos hosts selecionados.  As novas Versões de Visualização de Conteúdo (especificadas abaixo)\\n      que tornará esta Errata Instalável no Ambiente do hospedeiro.  Esta nova versão substituirá a versão atual no Ciclo de Vida do seu host\\n      Meio ambiente.  Para instalar estas erratas imediatamente nos hosts após a publicação, marque a caixa abaixo."
      ],
      "One or more packages are not showing up in the local repository even though they exist in the upstream repository.": [
        ""
      ],
      "Only show content hosts where the errata is currently installable in the host's Lifecycle Environment.": [
        "Mostrar apenas os hosts de conteúdo onde a errata é atualmente instalável no ambiente do ciclo de vida do host."
      ],
      "Only show Errata that are Applicable to one or more Content Hosts": [
        "Mostrar apenas Erratas que se aplicam a um ou mais Hosts de Conteúdo"
      ],
      "Only show Errata that are Installable on one or more Content Hosts": [
        "Mostrar apenas Erratas que podem ser instaladas em um ou mais Hosts de Conteúdo"
      ],
      "Only show Packages that are Applicable to one or more Content Hosts": [
        "Mostrar apenas Pacotes que são aplicáveis a um ou mais Hosts de Conteúdo"
      ],
      "Only show Packages that are Upgradable on one or more Content Hosts": [
        "Mostrar apenas pacotes que podem ser atualizados em um ou mais Hosts de Conteúdo"
      ],
      "Only show Subscriptions for products not already covered by a Subscription": [
        "Mostrar apenas Assinaturas para produtos ainda não cobertos por uma Assinatura"
      ],
      "Only show Subscriptions which can be applied to products installed on this Host": [
        "Mostrar apenas Assinaturas que podem ser aplicadas aos produtos instalados neste Host"
      ],
      "Only show Subscriptions which can be attached to this Host": [
        "Mostrar apenas Assinaturas que podem ser anexadas a este Host"
      ],
      "Only the Applications with a Helper can be restarted.": [
        "Somente as aplicações com um Helper podem ser reiniciadas."
      ],
      "Operating System": [
        "Sistema Operacional"
      ],
      "Optimized Sync": [
        "Sincronia Otimizada"
      ],
      "Organization": [
        "Organização"
      ],
      "Original Sync Date": [
        "Data de Sincronização Original"
      ],
      "OS": [
        "OS"
      ],
      "OSTree Repositories <div>{{ library.counts.ostree_repositories || 0 }}</div>": [
        "OSTree Repositórios <div>{{ library.counts.ostree_repositories || 0 }}</div>"
      ],
      "Override to Disabled": [
        "Substituição para Deficientes"
      ],
      "Override to Enabled": [
        "Anular para Ativado"
      ],
      "Package": [
        "Pacote"
      ],
      "Package Actions": [
        "Ações do pacote"
      ],
      "Package Group (Deprecated)": [
        ""
      ],
      "Package Groups": [
        "Grupos de Pacote"
      ],
      "Package Groups for Repository:": [
        "Grupos de Pacotes para Repositório:"
      ],
      "Package Information": [
        "Informações sobre o pacote"
      ],
      "Package Install": [
        "Instalar Pacote"
      ],
      "Package Installation, Removal, and Update": [
        "Instalação, remoção e atualização de pacotes"
      ],
      "Package Remove": [
        "Remover Pacote"
      ],
      "Package Update": [
        "Atualizar Pacote"
      ],
      "Package:": [
        "Pacote:"
      ],
      "Package/Group Name": [
        "Nome do pacote/grupo"
      ],
      "Packages": [
        "Pacotes"
      ],
      "Packages <div>{{ library.counts.packages || 0 }}</div>": [
        "Pacotes <div>{{ library.counts.packages || 0 }}</div>"
      ],
      "Packages are automatically Applicable if they are Upgradable": [
        "Os pacotes são automaticamente aplicáveis se forem atualizáveis"
      ],
      "Packages for Errata:": [
        ""
      ],
      "Packages for:": [
        "Embalagens para:"
      ],
      "Parameters": [
        "Parâmetros"
      ],
      "Part of a manifest list": [
        "Parte de uma lista manifesta"
      ],
      "Password": [
        "Senha"
      ],
      "Password of the upstream repository user for authentication. Leave empty if repository does not require authentication.": [
        "Senha do usuário do repositório upstream para autenticação. Deixe em branco se o repositório não exigir autenticação."
      ],
      "Paste contents of Content Credential": [
        "Colar o conteúdo da Credencial de Conteúdo"
      ],
      "Path": [
        "Caminho"
      ],
      "Perform": [
        "Realizar"
      ],
      "Performing host package actions is disabled because Katello is not configured for remote execution.": [
        ""
      ],
      "Performing host package actions is disabled because Katello is not configured for Remote Execution.": [
        ""
      ],
      "Physical": [
        "Físico"
      ],
      "Please enter cron below": [
        ""
      ],
      "Please make sure a Content View is selected.": [
        ""
      ],
      "Please select an environment.": [
        "Por favor, selecione um ambiente."
      ],
      "Please select one from the list below and you will be redirected.": [
        "Selecione uma opção na lista abaixo e você será redirecionado."
      ],
      "Plus %y more errors": [
        "Mais %y mais erros"
      ],
      "Plus 1 more error": [
        "Mais 1 erro"
      ],
      "Previous Lifecycle Environment (%e/%cv)": [
        ""
      ],
      "Prior Environment": [
        ""
      ],
      "Product": [
        "Produto"
      ],
      "Product delete operation has been initiated in the background.": [
        ""
      ],
      "Product Enhancement Advisory": [
        "Assessoria para Melhoria de Produtos"
      ],
      "Product information for:": [
        "Informações sobre produtos para:"
      ],
      "Product Management for Sync Plan:": [
        "Gestão de Produtos para Sync Plan:"
      ],
      "Product Name": [
        "Nome do produto"
      ],
      "Product Options": [
        "Opções de produtos"
      ],
      "Product Saved": [
        "Produto Salvo"
      ],
      "Product sync has been initiated in the background.": [
        ""
      ],
      "Product syncs has been initiated in the background.": [
        ""
      ],
      "Product verify checksum has been initiated in the background.": [
        ""
      ],
      "Products": [
        "Produtos"
      ],
      "Products <div>{{ library.counts.products || 0 }}</div>": [
        "Produtos <div>{{ library.counts.products || 0 }}</div>"
      ],
      "Products for": [
        "Produtos para"
      ],
      "Products not covered": [
        "Produtos não cobertos"
      ],
      "Provides": [
        "Fornece"
      ],
      "Provisioning": [
        ""
      ],
      "Provisioning Details": [
        "Detalhes do provisionamento"
      ],
      "Provisioning Host Details": [
        "Detalhes sobre o provisionamento do host"
      ],
      "Published At": [
        "Publicado em"
      ],
      "Published Repository Information": [
        "Informações de Repositório Publicadas"
      ],
      "Publishing Settings": [
        ""
      ],
      "Puppet Environment": [
        "Ambiente puppet"
      ],
      "Quantity": [
        "Quantidade"
      ],
      "Quantity (To Add)": [
        ""
      ],
      "RAM (GB)": [
        "RAM (GB)"
      ],
      "Reboot Suggested": [
        "Reinicialização sugerida"
      ],
      "Reboot Suggested?": [
        "Sugestão de reinicialização?"
      ],
      "Recalculate\\n          <i class=\\\"fa fa-spinner fa-spin\\\" ng-show=\\\"calculatingApplicability\\\"></i>": [
        "Recalcule\\n          <i class=\\\"fa fa-spinner fa-spin\\\" ng-show=\\\"calculatingApplicability\\\"></i>"
      ],
      "Reclaim Space": [
        ""
      ],
      "Recurring Logic": [
        ""
      ],
      "Red Hat": [
        ""
      ],
      "Red Hat Repositories page": [
        "Página de Repositórios Red Hat"
      ],
      "Red Hat Repositories page.": [
        "Página de Repositórios Red Hat."
      ],
      "Refresh Table": [
        "Tabela de Atualização"
      ],
      "Register a Content Host": [
        "Registrar um hospedeiro de conteúdo"
      ],
      "Register Content Host": [
        "Registro de Conteúdo Host"
      ],
      "Registered": [
        "Registrado"
      ],
      "Registered By": [
        "Registrado por"
      ],
      "Registered Through": [
        "Registrado através de"
      ],
      "Registry Name Pattern": [
        "Padrão de nome de registro"
      ],
      "Registry Search Parameter": [
        ""
      ],
      "Registry to Discover": [
        "Registro para descobrir"
      ],
      "Registry URL": [
        "URL do registro"
      ],
      "Release": [
        "Lançamento"
      ],
      "Release Version": [
        "Versão de Lançamento"
      ],
      "Release Version:": [
        "Versão de lançamento:"
      ],
      "Releases/Distributions": [
        ""
      ],
      "Remote execution plugin is required to be able to run any helpers.": [
        "O plugin de execução remota é necessário para poder executar qualquer ajudante."
      ],
      "Remove": [
        "Remover"
      ],
      "Remove {{ table.numSelected  }} Container Image manifest?": [
        "",
        "",
        ""
      ],
      "Remove Activation Key \\\"{{ activationKey.name }}\\\"?": [
        "Remover chave de ativação \\\"{{ activationKey.name }}\\\"?"
      ],
      "Remove Container Image Manifests": [
        ""
      ],
      "Remove Content": [
        "Remover Conteúdo"
      ],
      "Remove Content Credential": [
        "Remover Credencial de Conteúdo"
      ],
      "Remove Content Credential {{ contentCredential.name }}": [
        "Remover Credencial de Conteúdo {{ contentCredential.name }}"
      ],
      "Remove Content?": [
        "",
        "",
        ""
      ],
      "Remove Environment": [
        "Remover Ambiente"
      ],
      "Remove environment {{ environment.name }}?": [
        ""
      ],
      "Remove File?": [
        "",
        "",
        ""
      ],
      "Remove Files": [
        "Remover arquivos"
      ],
      "Remove From": [
        "Remover de"
      ],
      "Remove Host Collection \\\"{{ hostCollection.name }}\\\"?": [
        "Remover coleção de anfitriões \\\"{{ hostCollection.name }}\\\"?"
      ],
      "Remove Package?": [
        "",
        "",
        ""
      ],
      "Remove Packages": [
        "Remover pacotes"
      ],
      "Remove Product": [
        "Remover Produto"
      ],
      "Remove Product \\\"{{ product.name }}\\\"?": [
        "Remover Produto \\\"{{ product.name }}\\\"?"
      ],
      "Remove product?": [
        "",
        "",
        ""
      ],
      "Remove Repositories": [
        "Retirar os Repositórios"
      ],
      "Remove Repository": [
        "Remover Repositório"
      ],
      "Remove Repository {{ repositoryWrapper.repository.name }}?": [
        ""
      ],
      "Remove repository?": [
        "",
        "",
        ""
      ],
      "Remove Selected": [
        "Remover Selecionado"
      ],
      "Remove Successful.": [
        "Retirar com sucesso."
      ],
      "Remove Sync Plan": [
        "Remover Plano de Sincronização"
      ],
      "Remove Sync Plan \\\"{{ syncPlan.name }}\\\"?": [
        "Remover Plano de Sincronização \\\"{{ syncPlan.name }}\\\"?"
      ],
      "Removed %x host collections from activation key \\\"%y\\\".": [
        "Removido %x coleções de host da chave de ativação \\\"%y\\\"."
      ],
      "Removed %x host collections from content host \\\"%y\\\".": [
        "Removido %x coleções de anfitriões de conteúdo de anfitriões \\\"%y\\\"."
      ],
      "Removed %x products from sync plan \\\"%y\\\".": [
        "Removido %x produtos do plano de sincronização \\\"%y\\\"."
      ],
      "Removing Repositories": [
        "Remoção de Repositórios"
      ],
      "Repo Discovery": [
        "Descoberta do Repo"
      ],
      "Repositories": [
        "Repositórios"
      ],
      "Repositories containing Errata {{ errata.errata_id }}": [
        "Repositórios contendo Errata {{ errata.errata_id }}"
      ],
      "Repositories containing package {{ package.nvrea }}": [
        "Repositórios contendo pacote {{ package.nvrea }}"
      ],
      "Repositories for": [
        "Repositórios para"
      ],
      "Repositories for Deb:": [
        "Repositórios para Deb:"
      ],
      "Repositories for Errata:": [
        "Repositórios de Errata:"
      ],
      "Repositories for File:": [
        "Repositórios para arquivo:"
      ],
      "Repositories for Package:": [
        "Repositórios para embalagem:"
      ],
      "Repositories for Product:": [
        "Repositórios de Produtos:"
      ],
      "Repositories to Create": [
        "Repositórios para criar"
      ],
      "Repository": [
        "Repo"
      ],
      "Repository \\\"%s\\\" successfully deleted": [
        "Repositório \\\"%s\\\" apagado com sucesso"
      ],
      "Repository %s successfully created.": [
        "Repositório %s criado com sucesso."
      ],
      "Repository created": [
        "Repositório criado"
      ],
      "Repository Discovery": [
        "Descoberta do Repositório"
      ],
      "Repository HTTP proxy changes have been initiated in the background.": [
        ""
      ],
      "Repository Label": [
        "Rótulo Repositório"
      ],
      "Repository Name": [
        "Nome do Repositório"
      ],
      "Repository Options": [
        "Opções de Repositório"
      ],
      "Repository Path": [
        "Caminho Repositório"
      ],
      "Repository Saved.": [
        "Repositório Salvo."
      ],
      "Repository Sets": [
        "Conjuntos Repositórios"
      ],
      "Repository Sets Management": [
        ""
      ],
      "Repository Sets settings saved successfully.": [
        "Repositório Define as configurações salvas com sucesso."
      ],
      "Repository type": [
        ""
      ],
      "Repository Type": [
        "Tipo de Repositório"
      ],
      "Repository URL": [
        "URL do Repositório"
      ],
      "Repository will also be removed from the following published content view versions!": [
        ""
      ],
      "Repository:": [
        "Repositório:"
      ],
      "Republish Repository Metadata": [
        "Republicar metadados de repositórios"
      ],
      "Requirements": [
        ""
      ],
      "Requirements.yml": [
        ""
      ],
      "Requires": [
        "Requer"
      ],
      "Reset": [
        ""
      ],
      "Reset to Default": [
        "Redefinir para o padrão"
      ],
      "Resolving the selected Traces will reboot the selected content hosts.": [
        ""
      ],
      "Resolving the selected Traces will reboot this host.": [
        ""
      ],
      "Restart": [
        "Reinicie"
      ],
      "Restart Selected": [
        "Reinício Selecionado"
      ],
      "Restart Services on Content Host \\\"{{host.display_name}}\\\"?": [
        ""
      ],
      "Restrict to <br>OS version": [
        ""
      ],
      "Restrict to architecture": [
        "Restringir-se à arquitetura"
      ],
      "Restrict to Architecture": [
        "Restringir-se à arquitetura"
      ],
      "Restrict to OS version": [
        ""
      ],
      "Result": [
        "Resultado"
      ],
      "Retain package versions": [
        ""
      ],
      "Role": [
        "Função"
      ],
      "Role:": [
        ""
      ],
      "RPM": [
        "RPM"
      ],
      "rpm Package Updates": [
        ""
      ],
      "Run Auto-Attach": [
        "Executar Auto-Attach"
      ],
      "Run Repository Creation\\n      <i class=\\\"fa fa-spinner fa-spin\\\" ng-show=\\\"creating()\\\"></i>": [
        "Criação do Repositório Run\\n      <i class=\\\"fa fa-spinner fa-spin\\\" ng-show=\\\"creating()\\\"></i>"
      ],
      "Run Sync Plan": [
        "Executar Plano de Sincronização"
      ],
      "Save": [
        "Salvar"
      ],
      "Save Successful.": [
        "Salvar o sucesso."
      ],
      "Schema Version": [
        "Versão esquemática"
      ],
      "Schema Version 1": [
        "Esquema Versão 1"
      ],
      "Schema Version 2": [
        "Esquema Versão 2"
      ],
      "Security": [
        "Segurança"
      ],
      "Security Advisory": [
        "Assessoria de Segurança"
      ],
      "Select": [
        "Selecionar"
      ],
      "Select a Content Source:": [
        "Selecione uma Fonte de Conteúdo:"
      ],
      "Select Action": [
        "Selecionar Ação"
      ],
      "Select an Organization": [
        "Selecionar uma organização"
      ],
      "Select Content Host(s)": [
        ""
      ],
      "Select Content View": [
        "Selecionar Visualização de Conteúdo"
      ],
      "Select this option if treeinfo files or other kickstart content is failing to syncronize from the upstream repository.": [
        ""
      ],
      "Selecting \\\"Complete Sync\\\" will cause only yum/deb repositories of the selected product to be synced.": [
        ""
      ],
      "Selecting this option will exclude SRPMs from repository synchronization.": [
        ""
      ],
      "Selecting this option will exclude treeinfo files from repository synchronization.": [
        ""
      ],
      "Selecting this option will result in Katello verifying that the upstream url's SSL certificates are signed by a trusted CA. Unselect if you do not want this verification.": [
        "Selecionando esta opção, a Katello verificará se os certificados SSL da url upstream são assinados por uma CA de confiança. Desselecione se você não quiser esta verificação."
      ],
      "Service Level": [
        "Nível de serviço"
      ],
      "Service Level (SLA)": [
        "Nível de serviço (SLA)"
      ],
      "Service Level (SLA):": [
        ""
      ],
      "Set Release Version": [
        "Versão de lançamento do conjunto"
      ],
      "Severity": [
        "Severidade"
      ],
      "Show All": [
        "Mostrar tudo"
      ],
      "Show all Repository Sets in Organization": [
        "Mostrar todos os Conjuntos Repositórios em Organização"
      ],
      "Size": [
        "Tam."
      ],
      "Skip dependency solving for a significant speed increase. If the update cannot be applied to the host, delete the incremental content view version and retry the application with dependency solving turned on.": [
        ""
      ],
      "Smart proxy currently reclaiming space...": [
        ""
      ],
      "Smart proxy currently syncing to your locations...": [
        "Proxy inteligente atualmente em sincronia com seus locais..."
      ],
      "Smart proxy is synchronized": [
        "O proxy inteligente é sincronizado"
      ],
      "Sockets": [
        "Sockets"
      ],
      "Solution": [
        "Solução"
      ],
      "Some of the Errata shown below may not be installable as they are not in this Content Host's\\n        Content View and Lifecycle Environment.  In order to apply such Errata an Incremental Update is required.": [
        "Algumas das Erratas mostradas abaixo podem não ser instaláveis, pois não estão neste Host de Conteúdo\\n        Visão do conteúdo e ambiente do ciclo de vida.  Para aplicar tais Erratas é necessária uma Atualização Incremental."
      ],
      "Something went wrong when deleting the resource.": [
        ""
      ],
      "Something went wrong when retrieving the resource.": [
        "Algo deu errado quando se recuperou o recurso."
      ],
      "Something went wrong when saving the resource.": [
        "Algo deu errado ao salvar o recurso."
      ],
      "Source RPM": [
        "RPM de origem"
      ],
      "Source RPMs": [
        "RPMs de Origem"
      ],
      "Space reclamation is about to start...": [
        ""
      ],
      "SSL CA Cert": [
        "SSL CA Cert"
      ],
      "SSL Certificate": [
        "Certificado SSL"
      ],
      "SSL Client Cert": [
        "Cliente SSL Cert"
      ],
      "SSL Client Key": [
        "Chave do cliente SSL"
      ],
      "Standard sync, optimized for speed by bypassing any unneeded steps.": [
        "Sincronização padrão, otimizada para a velocidade, contornando quaisquer passos desnecessários."
      ],
      "Start Date": [
        "Data de Início"
      ],
      "Start Time": [
        "Hora de início"
      ],
      "Started At": [
        "Começou em"
      ],
      "Starting": [
        "Início"
      ],
      "Starts": [
        "Inicia"
      ],
      "State": [
        "Estado"
      ],
      "Status": [
        "Estado"
      ],
      "Stream": [
        "Fluxo"
      ],
      "Subscription Details": [
        "Detalhes de subscrição"
      ],
      "Subscription Management": [
        "Gestão de Assinaturas"
      ],
      "Subscription Status": [
        "Estado de subscrição"
      ],
      "Subscription UUID": [
        ""
      ],
      "subscription-manager register --org=\\\"{{ activationKey.organization.label }}\\\" --activationkey=\\\"{{ activationKey.name }}\\\"": [
        "subscription-manager register --org=\\\"{{ activationKey.organization.label }}\\\" --activationkey=\\\"{{ activationKey.name }}\\\""
      ],
      "Subscriptions": [
        "Subscrições"
      ],
      "Subscriptions for Activation Key:": [
        "Assinaturas para chave de ativação:"
      ],
      "Subscriptions for Content Host:": [
        "Assinaturas para Host de Conteúdo:"
      ],
      "Subscriptions for:": [
        "Assinaturas para:"
      ],
      "Success!": [
        "Sucesso!"
      ],
      "Successfully added %s subscriptions.": [
        "Acrescentou com sucesso %s subscrições."
      ],
      "Successfully initiated restart of services.": [
        ""
      ],
      "Successfully removed %s items.": [
        "Removido com sucesso %s itens."
      ],
      "Successfully removed %s subscriptions.": [
        "Eliminadas com sucesso as assinaturas %s."
      ],
      "Successfully removed 1 item.": [
        "Removido com sucesso 1 item."
      ],
      "Successfully updated subscriptions.": [
        "Assinaturas atualizadas com sucesso."
      ],
      "Successfully uploaded content:": [
        "Conteúdo carregado com sucesso:"
      ],
      "Summary": [
        "Sumário"
      ],
      "Support Level": [
        "Nível de suporte"
      ],
      "Sync": [
        "Sincronizar"
      ],
      "Sync Enabled": [
        "Sinc Enabled"
      ],
      "Sync even if the upstream metadata appears to have no change. This option is only relevant for yum/deb repositories and will take longer than an optimized sync. Choose this option if:": [
        ""
      ],
      "Sync Interval": [
        "Intervalo de sincronização"
      ],
      "Sync Now": [
        "Sync Now"
      ],
      "Sync Plan": [
        "Plano de sincronização"
      ],
      "Sync Plan %s has been deleted.": [
        "O Sync Plan %s foi eliminado."
      ],
      "Sync Plan created and assigned to product.": [
        "Plano de sincronização criado e atribuído ao produto."
      ],
      "Sync Plan Management": [
        ""
      ],
      "Sync Plan saved": [
        ""
      ],
      "Sync Plan Saved": [
        "Plano de Sincronização Salvo"
      ],
      "Sync Plan:": [
        "Plano de sincronização:"
      ],
      "Sync Plans": [
        "Planos de Sincronização"
      ],
      "Sync Selected": [
        "Sinc Selected"
      ],
      "Sync Settings": [
        "Configurações de Sincronização"
      ],
      "Sync State": [
        "Estado do Sync"
      ],
      "Sync Status": [
        "Estado da Sincronização"
      ],
      "Synced manually, no interval set.": [
        "Sincronizado manualmente, sem intervalo definido."
      ],
      "Synchronization is about to start...": [
        "A sincronização está prestes a começar..."
      ],
      "Synchronization is being cancelled...": [
        "A sincronização está sendo cancelada..."
      ],
      "System Purpose": [
        "Objetivo do sistema"
      ],
      "System purpose enables you to set the system's intended use on your network and improves reporting accuracy in the Subscriptions service of the Red Hat Hybrid Cloud Console.": [
        ""
      ],
      "System Purpose Management": [
        ""
      ],
      "System Purpose Status": [
        ""
      ],
      "Tags": [
        "Tags"
      ],
      "Task Details": [
        "Detalhes da tarefa"
      ],
      "Tasks": [
        "Tarefas"
      ],
      "Temporary": [
        "Temporário"
      ],
      "The <i>Registry Name Pattern</i> overrides the default name by which container images may be pulled from the server. (By default this name is a combination of Organization, Lifecycle Environment, Content View, Product, and Repository labels.)\\n\\n          <br><br>The name may be constructed using ERB syntax. Variables available for use are:\\n\\n          <pre>\\norganization.name\\norganization.label\\nrepository.name\\nrepository.label\\nrepository.docker_upstream_name\\ncontent_view.label\\ncontent_view.name\\ncontent_view_version.version\\nproduct.name\\nproduct.label\\nlifecycle_environment.name\\nlifecycle_environment.label</pre>\\n\\n          Examples:\\n            <pre>\\n&lt;%= organization.label %&gt;-&lt;%= lifecycle_environment.label %&gt;-&lt;%= content_view.label %&gt;-&lt;%= product.label %&gt;-&lt;%= repository.label %&gt;\\n&lt;%= organization.label %&gt;/&lt;%= repository.docker_upstream_name %&gt;</pre>": [
        ""
      ],
      "The Content View or Lifecycle Environment needs to be updated in order to make errata available to these hosts.": [
        "A Visão do Conteúdo ou Ambiente do Ciclo de Vida precisa ser atualizada a fim de tornar as erratas disponíveis para esses anfitriões."
      ],
      "The filters below have this repository as the last affected repository!": [
        ""
      ],
      "The following actions can be performed on content hosts in this host collection:": [
        "As seguintes ações podem ser realizadas em hosts de conteúdo nesta coleção de hosts:"
      ],
      "The host has not reported any applicable packages for upgrade.": [
        "O anfitrião não relatou nenhum pacote aplicável para atualização."
      ],
      "The host has not reported any installed packages, registering with subscription-manager should cause these to be reported.": [
        "O anfitrião não relatou nenhum pacote instalado, o registro no gerenciador de assinaturas deve fazer com que estes sejam relatados."
      ],
      "The host requires being attached to a content view and the lifecycle environment you have chosen has no content views promoted to it.\\n              See the <a href=\\\"/content_views\\\">content views page</a> to manage and promote a content view.": [
        ""
      ],
      "The maximum number of versions of each package to keep.": [
        ""
      ],
      "The page you are attempting to access requires selecting a specific organization.": [
        "A página que você está tentando acessar requer a seleção de uma organização específica."
      ],
      "The remote execution feature is required to manage packages on this Host.": [
        ""
      ],
      "The Remote Execution plugin needs to be installed in order to resolve Traces.": [
        ""
      ],
      "The repository will only be available on content hosts with the selected architecture.": [
        ""
      ],
      "The repository will only be available on content hosts with the selected OS version.": [
        ""
      ],
      "The selected environment contains no Content Views, please select a different environment.": [
        "O ambiente selecionado não contém visualizações de conteúdo, favor selecionar um ambiente diferente."
      ],
      "The time the sync should happen in your current time zone.": [
        "A hora em que a sincronização deve acontecer em seu fuso horário atual."
      ],
      "The token key to use for authentication.": [
        ""
      ],
      "The URL to receive a session token from, e.g. used with Automation Hub.": [
        ""
      ],
      "There are {{ errataCount }} total Errata in this organization but none match the above filters.": [
        "Há {{ errataCount }} Errata total nesta organização, mas nenhuma corresponde aos filtros acima."
      ],
      "There are {{ packageCount }} total Packages in this organization but none match the above filters.": [
        "Há {{ packageCount }} pacotes totais nesta organização, mas nenhum corresponde aos filtros acima."
      ],
      "There are no %(contentType)s that match the criteria.": [
        ""
      ],
      "There are no Content Views in this Environment.": [
        "Não há visualizações de conteúdo neste Ambiente."
      ],
      "There are no Content Views that match the criteria.": [
        "Não há Visualizações de Conteúdo que correspondam aos critérios."
      ],
      "There are no Errata associated with this Content Host to display.": [
        "Não há Errata associada a este Host de Conteúdo para exibir."
      ],
      "There are no Errata in this organization.  Create one or more Products with Errata to view Errata on this page.": [
        "Não há Errata nesta organização.  Crie um ou mais Produtos com Errata para ver Errata nesta página."
      ],
      "There are no Errata to display.": [
        "Não há erros a serem exibidos."
      ],
      "There are no Host Collections available. You can create new Host Collections after selecting 'Host Collections' under 'Hosts' in main menu.": [
        "Não há coleções de anfitriões disponíveis. Você pode criar novas Coleções Host após selecionar 'Host Collections' em 'Hosts' no menu principal."
      ],
      "There are no Module Streams to display.": [
        ""
      ],
      "There are no Packages in this organization.  Create one or more Products with Packages to view Packages on this page.": [
        "Não há pacotes nesta organização.  Crie um ou mais Produtos com Pacotes para ver os Pacotes nesta página."
      ],
      "There are no Sync Plans available. You can create new Sync Plans after selecting 'Sync Plans' under 'Hosts' in main menu.": [
        "Não há Planos de Sincronização disponíveis. Você pode criar novos Planos de Sincronização após selecionar 'Planos de Sincronização' em 'Anfitriões' no menu principal."
      ],
      "There are no Traces to display.": [
        "Não há traços a serem exibidos."
      ],
      "There is currently an Incremental Update task in progress.  This update must finish before applying existing updates.": [
        "Há atualmente uma tarefa de Atualização Incremental em andamento.  Esta atualização deve ser concluída antes de aplicar as atualizações existentes."
      ],
      "These instructions will be removed in a future release. NEW: To register a content host without following these manual steps, see <a href=\\\"https://{{ katelloHostname }}/hosts/register\\\">Register Host</a>": [
        ""
      ],
      "This action will affect only those Content Hosts that require a change.\\n        If the Content Host does not have the selected Subscription no action will take place.": [
        "Esta ação afetará somente aqueles Hosts de Conteúdo que requerem uma mudança.\\n        Se o Host de Conteúdo não tiver a Assinatura selecionada, nenhuma ação ocorrerá."
      ],
      "This activation key is not associated with any content hosts.": [
        "Esta chave de ativação não está associada a nenhum anfitrião de conteúdo."
      ],
      "This activation key may be used during system registration. For example:": [
        "Esta chave de ativação pode ser usada durante o registro do sistema. Por exemplo, esta chave de ativação pode ser usada durante o registro do sistema:"
      ],
      "This change will be applied to <b>{{ hostCount }} systems.</b>": [
        ""
      ],
      "This Container Image Tag is not present in any Lifecycle Environments.": [
        ""
      ],
      "This Container Image Tag is not present in any Repositories.": [
        ""
      ],
      "This operation may also remove managed resources linked to the host such as virtual machines and DNS records.\\n          Change the setting \\\"Delete Host upon Unregister\\\" to false on the <a href=\\\"/settings\\\">settings page</a> to prevent this.": [
        "Esta operação também pode remover recursos gerenciados ligados ao host, tais como máquinas virtuais e registros DNS.\\n          Altere a configuração \\\"Delete Host upon Unregister\\\" para falsa na página de configuração <a href=\\\"/settings\\\"></a> para evitar isso."
      ],
      "This organization has Simple Content Access enabled.  Hosts are not required to have subscriptions attached to access repositories.": [
        ""
      ],
      "This organization is not using <a target=\\\"_blank\\\" href=\\\"https://access.redhat.com/articles/simple-content-access\\\">Simple Content Access.</a> Entitlement-based subscription management is deprecated and will be removed in Katello 4.12.": [
        ""
      ],
      "Title": [
        "Título"
      ],
      "To register a content host to this server, follow these steps.": [
        "Para registrar um host de conteúdo para este servidor, siga estes passos."
      ],
      "Toggle Dropdown": [
        "Alternância de queda"
      ],
      "Token of the upstream repository user for authentication. Leave empty if repository does not require authentication.": [
        ""
      ],
      "Topic": [
        "Tema"
      ],
      "Tracer helps administrators identify applications that need to be restarted after a system is patched.": [
        ""
      ],
      "Traces": [
        "Rastreamentos"
      ],
      "Traces for:": [
        "Traços para:"
      ],
      "Turn on Setting > Content > Allow deleting repositories in published content views": [
        ""
      ],
      "Type": [
        "Tipo"
      ],
      "Unauthenticated Pull": [
        "Puxada não autenticada"
      ],
      "Unknown": [
        "Desconhecido"
      ],
      "Unlimited Content Hosts:": [
        "Hosts de Conteúdo Ilimitado:"
      ],
      "Unlimited Hosts": [
        "Anfitriões Ilimitados"
      ],
      "Unprotected": [
        ""
      ],
      "Unregister Host": [
        "Cancelar registro de Host"
      ],
      "Unregister Host \\\"{{host.display_name}}\\\"?": [
        ""
      ],
      "Unregister Options:": [
        "Opções para cancelar o registro:"
      ],
      "Unregister the host as a subscription consumer.  Provisioning and configuration information is preserved.": [
        "Desregistrar o anfitrião como um consumidor de assinatura.  As informações de provisionamento e configuração são preservadas."
      ],
      "Unsupported Type!": [
        "Tipo sem suporte!"
      ],
      "Update": [
        "Atualizar"
      ],
      "Update All Deb Packages": [
        ""
      ],
      "Update All Packages": [
        "Atualização de todos os pacotes"
      ],
      "Update Packages": [
        "Pacotes de atualização"
      ],
      "Update Sync Plan": [
        "Atualizar Plano de Sinc"
      ],
      "Updated": [
        "Atualizados"
      ],
      "Upgradable": [
        "Atualizável"
      ],
      "Upgradable For": [
        "Atualizável para"
      ],
      "Upgradable Package": [
        "Pacote atualizável"
      ],
      "Upgrade Available": [
        ""
      ],
      "Upgrade Selected": [
        "Atualização Selecionada"
      ],
      "Upload": [
        "Upload"
      ],
      "Upload Content Credential file": [
        "Upload do arquivo de credenciais de conteúdo"
      ],
      "Upload File": [
        "Carregar arquivo"
      ],
      "Upload Package": [
        "Pacote de Upload"
      ],
      "Upload Requirements": [
        ""
      ],
      "Upload Requirements.yml file <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'ansible_collection'\\\" uib-popover-html=\\\"requirementPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\">\\n        </a>": [
        ""
      ],
      "Uploading...": [
        "Carregando..."
      ],
      "Upstream Authentication Token": [
        ""
      ],
      "Upstream Authorization": [
        ""
      ],
      "Upstream Image Name": [
        "Nome da imagem a montante"
      ],
      "Upstream Password": [
        "Senha upstream"
      ],
      "Upstream Repository Name": [
        "Nome do Repositório Upstream"
      ],
      "Upstream URL": [
        "URL a montante"
      ],
      "Upstream Username": [
        "Nome de usuário upstream"
      ],
      "Url": [
        "Url"
      ],
      "URL of the registry you want to sync. Example: https://registry-1.docker.io/ or https://quay.io/": [
        ""
      ],
      "URL to Discover": [
        "URL a descobrir"
      ],
      "URL to the repository base. Example: http://ftp.de.debian.org/debian/ <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"debURLPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Upstream URL\\\">\\n        </a>": [
        ""
      ],
      "Usage Type": [
        "Tipo de uso"
      ],
      "Usage Type:": [
        ""
      ],
      "Use specific HTTP Proxy": [
        ""
      ],
      "Use the cancel button on content view selection to revert your lifecycle environment selection.": [
        ""
      ],
      "Used as": [
        "Usado como"
      ],
      "User": [
        "Usuário"
      ],
      "Username": [
        "Nome do usuário"
      ],
      "Username of the upstream repository user for authentication. Leave empty if repository does not require authentication.": [
        "Nome de usuário do usuário do repositório upstream para autenticação. Deixe em branco se o repositório não exigir autenticação."
      ],
      "Variant": [
        "Variante"
      ],
      "Verify Content Checksum": [
        ""
      ],
      "Verify SSL": [
        "Verifique o SSL"
      ],
      "Version": [
        "Versão"
      ],
      "Version {{ cvVersions['version'] }}": [
        ""
      ],
      "Versions": [
        "Versões"
      ],
      "via remote execution": [
        "via execução remota"
      ],
      "via remote execution - customize first": [
        "via execução remota - personalizar primeiro"
      ],
      "View Container Image Manifest Lists for Repository:": [
        ""
      ],
      "View Docker Tags for Repository:": [
        ""
      ],
      "View job invocations.": [
        ""
      ],
      "Virtual": [
        "Virtual"
      ],
      "Virtual Guest": [
        "Sistema Virtual"
      ],
      "Virtual Guests": [
        "Convidados virtuais"
      ],
      "Virtual Host": [
        "Anfitrião virtual"
      ],
      "Warning: reclaiming space for an \\\"On Demand\\\" repository will delete all cached content units.  Take precaution when cleaning custom repositories whose upstream parents don't keep old package versions.": [
        ""
      ],
      "weekly": [
        "semanalmente"
      ],
      "Weekly on {{ product.sync_plan.sync_date | date:'EEEE' }} at {{ product.sync_plan.sync_date | date:'mediumTime' }} (Server Time)": [
        "Semanalmente em {{ product.sync_plan.sync_date | date:'EEEE' }} em {{ product.sync_plan.sync_date | date:'mediumTime' }} (horário do servidor)"
      ],
      "When Auto Attach is disabled, registering systems will be attached to all associated subscriptions.": [
        "Quando o Auto Attach estiver desativado, os sistemas de registro serão anexados a todas as assinaturas associadas."
      ],
      "When Auto Attach is enabled, registering systems will be attached to all associated custom products and only associated Red Hat subscriptions required to satisfy the system's installed products.": [
        ""
      ],
      "Whitespace-separated list of components to sync (leave clear to sync all). Example: main <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"componentPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Components\\\">\\n        </a>": [
        ""
      ],
      "Whitespace-separated list of processor architectures to sync (leave clear to sync all). Example: amd64 <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"archPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Architectures\\\">\\n        </a>": [
        ""
      ],
      "Whitespace-separated list of releases/distributions to sync (required for syncing). Example: buster <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"distPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Releases/Distributions\\\">\\n        </a>": [
        ""
      ],
      "Working": [
        "Trabalhando"
      ],
      "Yes": [
        "Sim"
      ],
      "You can upload a requirements.yml file above to auto-fill contents <b>OR</b> paste contents of <a ng-href=\\\"https://docs.ansible.com/ansible/latest/galaxy/user_guide.html#install-multiple-collections-with-a-requirements-file\\\" target=\\\"_blank\\\"> Requirements.yml </a>below.": [
        ""
      ],
      "You can upload a requirements.yml file below to auto-fill contents or paste contents of requirement.yml here": [
        ""
      ],
      "You cannot remove content from a redhat repository": [
        ""
      ],
      "You cannot remove these repositories because you do not have permission.": [
        "Você não pode remover estes repositórios porque não tem permissão."
      ],
      "You cannot remove this product because it has repositories that are the last affected repository on content view filters": [
        ""
      ],
      "You cannot remove this product because it is a Red Hat product.": [
        "Você não pode remover este produto porque é um produto da Red Hat."
      ],
      "You cannot remove this product because it was published to a content view.": [
        "Você não pode remover este produto porque ele foi publicado para uma visualização de conteúdo."
      ],
      "You cannot remove this product because you do not have permission.": [
        "Você não pode remover este produto porque não tem permissão."
      ],
      "You cannot remove this repository because you do not have permission.": [
        "Você não pode remover este repositório porque não tem permissão."
      ],
      "You currently don't have any Activation Keys, you can add Activation Keys using the button on the right.": [
        "Atualmente você não tem nenhuma Chave de Ativação, você pode adicionar Chaves de Ativação usando o botão da direita."
      ],
      "You currently don't have any Alternate Content Sources associated with this Content Credential.": [
        ""
      ],
      "You currently don't have any Container Image Tags.": [
        ""
      ],
      "You currently don't have any Content Credential, you can add Content Credentials using the button on the right.": [
        "Atualmente você não tem nenhuma Credencial de Conteúdo, você pode adicionar Credenciais de Conteúdo usando o botão à direita."
      ],
      "You currently don't have any Content Hosts, you can create new Content Hosts by selecting Contents Host from main menu and then clicking the button on the right.": [
        "Atualmente você não tem nenhum Host de Conteúdo, você pode criar novos Hosts de Conteúdo selecionando Host de Conteúdo no menu principal e depois clicando no botão à direita."
      ],
      "You currently don't have any Content Hosts, you can register one by clicking the button on the right and following the instructions.": [
        "Atualmente você não tem nenhum Hosts de Conteúdo, você pode registrar um clicando no botão à direita e seguindo as instruções."
      ],
      "You currently don't have any Files.": [
        "Atualmente você não tem nenhum Arquivo."
      ],
      "You currently don't have any Host Collections, you can add Host Collections using the button on the right.": [
        "Atualmente você não tem nenhuma Coleção Host, você pode adicionar Coleções Host usando o botão à direita."
      ],
      "You currently don't have any Hosts in this Host Collection, you can add Content Hosts after selecting the 'Add' tab.": [
        ""
      ],
      "You currently don't have any Products associated with this Content Credential.": [
        "Atualmente você não tem nenhum Produto associado a esta Credencial de Conteúdo."
      ],
      "You currently don't have any Products to subscribe to, you can add Products after selecting 'Products' under 'Content' in the main menu": [
        "Atualmente você não tem nenhum Produto para assinar, você pode adicionar Produtos após selecionar 'Produtos' em 'Conteúdo' no menu principal"
      ],
      "You currently don't have any Products to subscribe to. You can add Products after selecting 'Products' under 'Content' in the main menu.": [
        ""
      ],
      "You currently don't have any Products<span bst-feature-flag=\\\"custom_products\\\">, you can add Products using the button on the right</span>.": [
        "Atualmente você não tem nenhum Produto<span bst-feature-flag=\\\"custom_products\\\">, você pode adicionar Produtos usando o botão da direita</span>."
      ],
      "You currently don't have any Repositories associated with this Content Credential.": [
        "Atualmente você não tem nenhum Repositório associado a esta Credencial de Conteúdo."
      ],
      "You currently don't have any Repositories included in this Product, you can add Repositories using the button on the right.": [
        "Atualmente você não tem nenhum Repositório incluído neste Produto, você pode adicionar Repositórios usando o botão à direita."
      ],
      "You currently don't have any Subscriptions associated with this Activation Key, you can add Subscriptions after selecting the 'Add' tab.": [
        "Atualmente você não tem nenhuma Assinatura associada a esta Chave de Ativação, você pode adicionar Assinaturas após selecionar a guia 'Adicionar'."
      ],
      "You currently don't have any Subscriptions associated with this Content Host. You can add Subscriptions after selecting the 'Add' tab.": [
        ""
      ],
      "You currently don't have any Sync Plans.  A Sync Plan can be created by using the button on the right.": [
        "Atualmente você não tem nenhum Plano de Sincronização.  Um Plano de Sincronização pode ser criado usando o botão à direita."
      ],
      "You do not have any Installed Products": [
        "Você não tem nenhum produto instalado"
      ],
      "You must select a content view in order to save your environment.": [
        "Você deve selecionar uma visão de conteúdo para salvar seu ambiente."
      ],
      "You must select a new content view before your change of environment can be saved. Use the cancel button on content view selection to revert your environment selection.": [
        "Você deve selecionar uma nova visão de conteúdo antes que sua mudança de ambiente possa ser salva. Use o botão cancelar na seleção da visualização do conteúdo para reverter a seleção de seu ambiente."
      ],
      "You must select a new content view before your change of lifecycle environment can be saved.": [
        ""
      ],
      "You must select at least one Content Host in order to apply Errata.": [
        "Você deve selecionar pelo menos um Host de Conteúdo para poder aplicar Errata."
      ],
      "You must select at least one Errata to apply.": [
        "Você deve selecionar pelo menos uma Errata para se candidatar."
      ],
      "Your search returned zero %(contentType)s that match the criteria.": [
        ""
      ],
      "Your search returned zero Activation Keys.": [
        "Sua busca retornou zero Chaves de ativação."
      ],
      "Your search returned zero Container Image Tags.": [
        ""
      ],
      "Your search returned zero Content Credential.": [
        "Sua busca retornou Credencial de Conteúdo zero."
      ],
      "Your search returned zero Content Hosts.": [
        "Sua busca retornou Hosts de conteúdo zero."
      ],
      "Your search returned zero Content Views": [
        "Sua busca retornou zero visualizações de conteúdo"
      ],
      "Your search returned zero Content Views.": [
        "Sua busca retornou zero visualizações de conteúdo."
      ],
      "Your search returned zero Deb Packages.": [
        ""
      ],
      "Your search returned zero Debs.": [
        "Sua busca retornou zero débitos."
      ],
      "Your search returned zero Errata.": [
        "Sua busca retornou zero Errata."
      ],
      "Your search returned zero Erratum.": [
        "Sua busca retornou zero Erratum."
      ],
      "Your search returned zero Files.": [
        "Sua busca retornou zero arquivos."
      ],
      "Your search returned zero Host Collections.": [
        "Sua busca retornou zero Coleções Host."
      ],
      "Your search returned zero Hosts.": [
        "Sua busca retornou zero Hosts."
      ],
      "Your search returned zero Lifecycle Environments.": [
        "Sua busca retornou ambientes com ciclo de vida zero."
      ],
      "Your search returned zero Module Streams.": [
        ""
      ],
      "Your search returned zero Packages.": [
        "Sua busca retornou zero pacotes."
      ],
      "Your search returned zero Products.": [
        "Sua busca retornou zero Produtos."
      ],
      "Your search returned zero Repositories": [
        "Sua busca retornou zero Repositórios"
      ],
      "Your search returned zero Repositories.": [
        "Sua busca retornou zero Repositórios."
      ],
      "Your search returned zero repository sets.": [
        "Sua busca retornou conjuntos de repositório zero."
      ],
      "Your search returned zero Repository Sets.": [
        "Sua busca retornou zero Repositório Sets."
      ],
      "Your search returned zero results.": [
        "Sua busca retornou zero resultados."
      ],
      "Your search returned zero Subscriptions.": [
        "Sua busca retornou zero Assinaturas."
      ],
      "Your search returned zero Sync Plans.": [
        "Sua busca retornou planos de sincronização zero."
      ],
      "Your search returned zero Traces.": [
        "Sua busca retornou zero Traços."
      ],
      "Yum Metadata Checksum": [
        "Yum Metadata Checksum"
      ],
      "Yum metadata generation has been initiated in the background.  Click <a href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        "A geração de metadados Yum foi iniciada em segundo plano.  Clique <a href=\\\"{{ taskUrl() }}\\\">Aqui</a> para monitorar o progresso."
      ],
      "Yum Repositories <div>{{ library.counts.yum_repositories || 0 }}</div>": [
        "Repositórios Yum <div>{{ library.counts.yum_repositories || 0 }}</div>"
      ]
    }
  }
};
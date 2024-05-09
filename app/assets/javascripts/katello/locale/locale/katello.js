 locales['katello'] = locales['katello'] || {}; locales['katello']['locale'] = {
  "domain": "katello",
  "locale_data": {
    "katello": {
      "": {
        "Project-Id-Version": "",
        "Last-Translator": "Ewoud Kohl van Wijngaarden <ewoud+transifex@kohlvanwijngaarden.nl>, 2024",
        "Language-Team": "Chinese (China) (https://app.transifex.com/foreman/teams/114/zh_CN/)",
        "Content-Type": "text/plain; charset=UTF-8",
        "Content-Transfer-Encoding": "8bit",
        "Language": "zh_CN",
        "Plural-Forms": "nplurals=1; plural=0;",
        "lang": "locale",
        "domain": "katello",
        "plural_forms": "nplurals=1; plural=0;"
      },
      "-- select an interval --": [
        "-- 选择间隔 --"
      ],
      "(future)": [
        "（未来）"
      ],
      "{{ 'Add Selected' | translate }}": [
        "{{ 'Add Selected' | translate }}"
      ],
      "{{ contentCredential.name }}": [
        "{{ contentCredential.name }}"
      ],
      "{{ deb.hosts_applicable_count }} Host(s)": [
        "{{ deb.hosts_applicable_count }} 主机"
      ],
      "{{ deb.hosts_applicable_count || 0 }} Applicable,": [
        "{{ deb.hosts_applicable_count || 0 }} 适用。"
      ],
      "{{ deb.hosts_available_count }} Host(s)": [
        "{{ deb.hosts_available_count }} 主机"
      ],
      "{{ deb.hosts_available_count || 0 }} Upgradable": [
        "{{ deb.hosts_available_count || 0 }} 可升级"
      ],
      "{{ errata.hosts_applicable_count || 0 }} Applicable,": [
        "{{ errata.hosts_applicable_count || 0 }} 适用。"
      ],
      "{{ errata.hosts_available_count || 0 }} Installable": [
        "{{ errata.hosts_available_count || 0 }} 可安装"
      ],
      "{{ errata.title }}": [
        "{{ errata.title }}"
      ],
      "{{ file.name }}": [
        "{{ file.name }}"
      ],
      "{{ host.display_name }}": [
        "{{ host.display_name }}"
      ],
      "{{ host.rhel_lifecycle_status_label }}": [
        "{{ host.rhel_lifecycle_status_label }}"
      ],
      "{{ host.subscription_facet_attributes.user.login }}": [
        "{{ host.subscription_facet_attributes.user.login }}"
      ],
      "{{ installedDebCount }} Host(s)": [
        "{{ installedDebCount }} 主机"
      ],
      "{{ installedPackageCount }} Host(s)": [
        "{{ installedPackageCount }} 主机"
      ],
      "{{ package.hosts_applicable_count }} Host(s)": [
        "{{ package.hosts_applicable_count }} 主机"
      ],
      "{{ package.hosts_applicable_count || 0 }} Applicable,": [
        "{{ package.hosts_applicable_count || 0 }} 适用"
      ],
      "{{ package.hosts_available_count }} Host(s)": [
        "{{ package.hosts_available_count }} 主机"
      ],
      "{{ package.hosts_available_count || 0 }} Upgradable": [
        "{{ package.hosts_available_count || 0 }} 可升级"
      ],
      "{{ package.human_readable_size }} ({{ package.size }} Bytes)": [
        "{{ package.human_readable_size }} （{{ package.size }}字节）"
      ],
      "{{ product.active_task_count }}": [
        "{{ product.active_task_count }}"
      ],
      "{{ product.name }}": [
        "{{ product.name }}"
      ],
      "{{ repo.last_sync_words }} ago": [
        "{{ repo.last_sync_words }} 前"
      ],
      "{{ repository.content_counts.ansible_collection || 0 }} Ansible Collections": [
        "{{ repository.content_counts.ansible_collection || 0 }} Ansible 集"
      ],
      "{{ repository.content_counts.deb || 0 }} deb Packages": [
        "{{ repository.content_counts.deb || 0 }} deb 软件包"
      ],
      "{{ repository.content_counts.docker_manifest || 0 }} Container Image Manifests": [
        "{{ repository.content_counts.docker_manifest || 0 }} 容器镜像清单"
      ],
      "{{ repository.content_counts.docker_manifest_list || 0 }} Container Image Manifest Lists": [
        "{{ repository.content_counts.docker_manifest_list || 0 }} 容器镜像清单列表"
      ],
      "{{ repository.content_counts.docker_tag || 0 }} Container Image Tags": [
        "{{ repository.content_counts.docker_tag || 0 }} 容器镜像标签"
      ],
      "{{ repository.content_counts.erratum || 0 }} Errata": [
        "{{ repository.content_counts.erratum || 0 }} 勘误"
      ],
      "{{ repository.content_counts.file || 0 }} Files": [
        "{{ repository.content_counts.file || 0 }} 文件"
      ],
      "{{ repository.content_counts.rpm || 0 }} Packages": [
        "{{ repository.content_counts.rpm || 0 }} 软件包"
      ],
      "{{ repository.content_counts.srpm }} Source RPMs": [
        "{{ repository.content_counts.srpm }} 源 RPM"
      ],
      "{{ repository.last_sync_words }} ago": [
        "{{ repository.last_sync_words }} 前"
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
        "*这些标记的内容视图版本来自复合内容视图。它们的需要更新的组件在下面列出。"
      ],
      "/foreman_tasks/tasks/%taskId": [
        "/foreman_tasks/tasks/%taskId"
      ],
      "/job_invocations": [
        "/job_invocations"
      ],
      "%(consumed)s out of %(quantity)s": [
        "%(consumed)s（共%(quantity)s）"
      ],
      "%count environment(s) can be synchronized: %envs": [
        "%count 个可以同步的环境： %envs"
      ],
      "<a href=\\\"/foreman_tasks/tasks/{{repository.last_sync.id}}\\\">{{ repository.last_sync.result | capitalize}}</a>": [
        "<a href=\\\"/foreman_tasks/tasks/{{repository.last_sync.id}}\\\">{{ repository.last_sync.result | capitalize}}</a>"
      ],
      "<b>Additive:</b> new content available during sync will be added to the repository, and no content will be removed.": [
        "<b>Additive:</b> 同步时的新内容将添加到仓库中，且不会删除任何内容。"
      ],
      "<b>Description</b>": [
        "<b>描述</b>"
      ],
      "<b>Issued</b>": [
        "<b>发行</b>"
      ],
      "<b>Mirror Complete</b>: a sync behaves exactly like \\\"Mirror Content Only\\\", but also mirrors metadata as well.  This is the fastest method, and preserves repository signatures, but is only supported by yum and not by all upstream repositories.": [
        "<b>Mirror Complete</b> ：与 \\\"Mirror Content Only\\\" 完全相同的同步行为，同时还会镜像元数据。这是最快的方法，并保留存储库签名，但只被 yum 支持，并不是所有上游仓库都支持。"
      ],
      "<b>Mirror Content Only</b>: any new content available during sync will be added to the repository and any content removed from the upstream repository will be removed from the local repository.": [
        "<b>Mirror Content Only</b> ：同步期间可用的任何新内容都将添加到仓库中，所有从上游仓库中删除的内容都将从本地仓库中删除。"
      ],
      "<b>Module Streams</b>": [
        "<b>模块流</b>"
      ],
      "<b>Packages</b>": [
        "<b> 软件包</b>"
      ],
      "<b>Reboot Suggested</b>": [
        "<b>建议重启</b>"
      ],
      "<b>Solution</b>": [
        "<b>解决</b>"
      ],
      "<b>Title</b>": [
        "<b>标题</b>"
      ],
      "<b>Type</b>": [
        "<b>类型</b>"
      ],
      "<b>Updated</b>": [
        "<b>已更新</b>"
      ],
      "<i class=\\\"fa fa-warning inline-icon\\\"></i>\\n  This Host is not currently registered with subscription-manager. Use the <a href=\\\"/hosts/register\\\">Register Host</a> workflow to complete registration.": [
        "<i class=\\\"fa fa-warning inline-icon\\\"></i>\\n  该主机当前未使用 subscription-manager 注册。使用<a href=\\\"/hosts/register\\\">注册主机</a>流程来完成注册。"
      ],
      "1 Content Host": [
        "1 个内容主机"
      ],
      "1 repository sync has errors.": [
        "1 个存储库同步有错误。"
      ],
      "1 repository sync in progress.": [
        "1 个存储库正在进行同步。"
      ],
      "1 successfully synced repository.": [
        "1 个成功同步的存储库。"
      ],
      "A comma-separated list of container image tags to exclude when syncing. Source images are excluded by default because they are often large and unwanted.": [
        "同步时要排除的容器镜像标签列表(以逗号分隔)。默认会排除源镜像，因为它们通常很大且不需要。"
      ],
      "A comma-separated list of container image tags to include when syncing.": [
        "同步时要包含的容器镜像标签列表(以逗号分隔)。"
      ],
      "A sync has been initiated in the background, <a href=\\\"/foreman_tasks/tasks/{{ task.id }}\\\">click for more details</a>": [
        "同步已在后台启动，<a href=\\\"/foreman_tasks/tasks/{{ task.id }}\\\">点击查看详情</a>"
      ],
      "Account": [
        "帐号"
      ],
      "Action Type": [
        "操作类型"
      ],
      "Actions": [
        "操作"
      ],
      "Activation Key": [
        "激活码"
      ],
      "Activation Key Content": [
        "激活码内容"
      ],
      "Activation Key removed.": [
        "激活码已刪除"
      ],
      "Activation Key updated": [
        "激活码已更新"
      ],
      "Activation Key:": [
        "激活码："
      ],
      "Activation Keys": [
        "激活码"
      ],
      "Active Tasks": [
        "活跃的任务"
      ],
      "Add": [
        "添加"
      ],
      "Add Content Hosts to:": [
        "添加内容主机到："
      ],
      "Add Host Collections": [
        "添加主机集合"
      ],
      "Add hosts to the host collection to see available actions.": [
        "将主机添加到主机集合以查看可用操作。"
      ],
      "Add New Environment": [
        "添加新环境"
      ],
      "Add ons": [
        "附加组件"
      ],
      "Add ons:": [
        "附加组件："
      ],
      "Add Products": [
        "添加产品"
      ],
      "Add Selected": [
        "添加所选"
      ],
      "Add Subscriptions": [
        "添加订阅"
      ],
      "Add Subscriptions for Activation Key:": [
        "为激活码添加订阅："
      ],
      "Add Subscriptions for Content Host:": [
        "为内容主机添加订阅："
      ],
      "Add To": [
        "添加到"
      ],
      "Added %x host collections to activation key \\\"%y\\\".": [
        "将 %x 主机集添加到激活码 \\\"%y\\\"。"
      ],
      "Added %x host collections to content host \\\"%y\\\".": [
        "将 %x 主机集添加到内容主机 \\\"%y\\\"。"
      ],
      "Added %x products to sync plan \\\"%y\\\".": [
        "将 %x 产品添加到同步计划 \\\"%y\\\"。"
      ],
      "Adding Lifecycle Environment to the end of \\\"{{ priorEnvironment.name }}\\\"": [
        "将生命周期环境添加到“{{ priorEnvironment.name }}”的后面"
      ],
      "Additive": [
        "Additive"
      ],
      "Advanced Sync": [
        "高级同步"
      ],
      "Advisory": [
        "公告"
      ],
      "Affected Hosts": [
        "受影响的主机"
      ],
      "All": [
        "全部"
      ],
      "All Content Views": [
        "所有内容视图"
      ],
      "All Lifecycle Environments": [
        "所有生命周期环境"
      ],
      "All Repositories": [
        "所有仓库"
      ],
      "Alternate Content Sources": [
        "备用内容源"
      ],
      "Alternate Content Sources for": [
        "备用内容源"
      ],
      "An error occured: %s": [
        "发生了一个错误：%s"
      ],
      "An error occurred initiating the sync:": [
        "初始化同步时发生错误："
      ],
      "An error occurred removing the Activation Key:": [
        "删除激活码时发生错误："
      ],
      "An error occurred removing the content hosts.": [
        "删除内容主机时发生错误。"
      ],
      "An error occurred removing the environment:": [
        "删除环境时发生错误："
      ],
      "An error occurred removing the Host Collection:": [
        "删除主机集合时发生错误："
      ],
      "An error occurred removing the subscriptions.": [
        "删除订阅时发生错误。"
      ],
      "An error occurred saving the Activation Key:": [
        "保存激活码时发生错误："
      ],
      "An error occurred saving the Content Host:": [
        "保存内容主机时发生错误："
      ],
      "An error occurred saving the Environment:": [
        "保存环境时发生错误："
      ],
      "An error occurred saving the Host Collection:": [
        "保存主机集合时发生错误："
      ],
      "An error occurred saving the Product:": [
        "保存产品时发生错误："
      ],
      "An error occurred saving the Repository:": [
        "保存仓库时发生错误："
      ],
      "An error occurred saving the Sync Plan:": [
        "保存同步计划时发生错误："
      ],
      "An error occurred trying to auto-attach subscriptions.  Please check your log for further information.": [
        "尝试自动附加订阅时发生错误。请检查您的日志以获取更多信息。"
      ],
      "An error occurred updating the sync plan:": [
        "更新同步计划时发生错误："
      ],
      "An error occurred while creating the Content Credential:": [
        "创建内容凭证时发生错误："
      ],
      "An error occurred while creating the Product: %s": [
        "创建产品时发生错误： %s"
      ],
      "An error occurred:": [
        "发生了一个错误："
      ],
      "Ansible Collection Authorization": [
        "Ansible 集合授权"
      ],
      "Ansible Collections": [
        "Ansible 系列"
      ],
      "Applicable": [
        "适用"
      ],
      "Applicable Content Hosts": [
        "适用的内容主机"
      ],
      "Applicable Deb Packages": [
        "适用的 Deb 软件包"
      ],
      "Applicable Errata": [
        "适用的勘误"
      ],
      "Applicable Packages": [
        "适用软件包"
      ],
      "Applicable To": [
        "适用于"
      ],
      "Applicable to Host": [
        "适用于主机"
      ],
      "Application": [
        "应用"
      ],
      "Apply": [
        "应用"
      ],
      "Apply {{ errata.errata_id }}": [
        "应用 {{ errata.errata_id }}"
      ],
      "Apply {{ errata.errata_id }} to {{ contentHostIds.length  }} Content Host(s)?": [
        "应用{{ errata.errata_id }}至{{ contentHostIds.length  }}内容主机？"
      ],
      "Apply {{ errata.errata_id }} to all Content Host(s)?": [
        "应用{{ errata.errata_id }}到内容主机？"
      ],
      "Apply {{ errataIds.length }} Errata to {{ contentHostIds.length }} Content Host(s)?": [
        "应用 {{ errataIds.length }} 勘误到 {{ contentHostIds.length }} 内容主机?"
      ],
      "Apply {{ errataIds.length }} Errata to all Content Host(s)?": [
        "应用{{ errataIds.length }} 勘误到所有内容主机？"
      ],
      "Apply Errata": [
        "应用勘误"
      ],
      "Apply Errata to Content Host \\\"{{host.display_name}}\\\"?": [
        "将勘误应用于内容主机“{{host.display_name}} “？"
      ],
      "Apply Errata to Content Hosts": [
        "将勘误应用于内容主机"
      ],
      "Apply Errata to Content Hosts immediately after publishing.": [
        "发布后立即将勘误应用于内容主机。"
      ],
      "Apply Selected": [
        "应用选定"
      ],
      "Apply to Content Hosts": [
        "应用到内容主机"
      ],
      "Apply to Hosts": [
        "应用到主机"
      ],
      "Applying": [
        "应用"
      ],
      "Apt Actions": [
        "Apt 操作"
      ],
      "Arch": [
        "架构"
      ],
      "Architecture": [
        "架构"
      ],
      "Architectures": [
        "架构"
      ],
      "Are you sure you want to add the {{ table.numSelected }} content host(s) selected to the host collection(s) chosen?": [
        "您确定要添加{{ table.numSelected }}选定的内容主机到选定的主机集合？"
      ],
      "Are you sure you want to add the sync plan to the selected products(s)?": [
        "您确定要将同步计划添加到所选产品吗？"
      ],
      "Are you sure you want to apply Errata to content host \\\"{{ host.display_name }}\\\"?": [
        "确定要将勘误应用于内容主机“{{ host.display_name }} “？"
      ],
      "Are you sure you want to apply the {{ table.numSelected }} selected errata to the content hosts chosen?": [
        "您确定要应用{{ table.numSelected }}选择的勘误表到选择的内容主机？"
      ],
      "Are you sure you want to assign the {{ table.numSelected }} content host(s) selected to {{ selected.contentView.name }} in {{ selected.environment.name }}?": [
        "您确定要分配{{ table.numSelected }}所选的内容主机到{{ selected.environment.name }} 中的 {{ selected.contentView.name }}？"
      ],
      "Are you sure you want to delete the {{ table.numSelected }} host(s) selected?": [
        "您确定要删除{{ table.numSelected }} 个选定的主机？"
      ],
      "Are you sure you want to disable the {{ table.numSelected }} repository set(s) chosen?": [
        "您确定要禁用{{ table.numSelected }} 个选择的仓库？"
      ],
      "Are you sure you want to enable the {{ table.numSelected }} repository set(s) chosen?": [
        "您确定要启用{{ table.numSelected }} 个选择的仓库集？"
      ],
      "Are you sure you want to install {{ content.content }} on the {{ getSelectedSystemIds().length }} system(s) selected?": [
        "您确定要在 {{ getSelectedSystemIds().length }} 个选择的系统中安装 {{ content.content }}？"
      ],
      "Are you sure you want to remove {{ content.content }} from the {{ getSelectedSystemIds().length }} system(s) selected?": [
        "您确定要从 {{ getSelectedSystemIds().length }} 个选择的系统中删除 {{ content.content }}？"
      ],
      "Are you sure you want to remove Activation Key \\\"{{ activationKey.name }}\\\"?": [
        "您确定要删除激活码 \\\"{{ activationKey.name }}\\\"?"
      ],
      "Are you sure you want to remove Content Credential {{ contentCredential.name }}?": [
        "您确定要删除内容凭据{{ contentCredential.name }}？"
      ],
      "Are you sure you want to remove environment {{ environment.name }}?": [
        "您确定要删除环境 {{ environment.name }}?"
      ],
      "Are you sure you want to remove Host Collection \\\"{{ hostCollection.name }}\\\"?": [
        "您确定要删除主机集合”{{ hostCollection.name }}“？"
      ],
      "Are you sure you want to remove product \\\"{{ product.name }}\\\"?": [
        "您确定要删除产品\\\"{{ product.name }}\\\"？"
      ],
      "Are you sure you want to remove repository {{ repositoryWrapper.repository.name }} from all content views?": [
        "您确定要从所有内容视图中删除存储库 {{ repositoryWrapper.repository.name }} 吗？"
      ],
      "Are you sure you want to remove Sync Plan \\\"{{ syncPlan.name }}\\\"?": [
        "您确定要删除同步计划“{{ syncPlan.name }}”？"
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} content unit?": [
        "您确定要删除 {{ table.getSelected()[0].name }} 内容单元？"
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} file?": [
        "您确定要删除 {{ table.getSelected()[0].name }} 文件?"
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} package?": [
        "您确定要删除{{ table.getSelected()[0].name }} 软件包？"
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} product?": [
        "您确定要删除{{ table.getSelected()[0].name }}产品？"
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} repository?": [
        "您确定要删除{{ table.getSelected()[0].name }} 仓库？"
      ],
      "Are you sure you want to remove the {{ table.numSelected }} Container Image manifest selected?": [
        "您确定要删除{{ table.numSelected }} 个选择了的容器镜像清单？"
      ],
      "Are you sure you want to remove the {{ table.numSelected }} content host(s) selected from the host collection(s) chosen?": [
        "您确定要从所选的主机集合中删除{{ table.numSelected }}个选择的内容主机？"
      ],
      "Are you sure you want to remove the sync plan from the selected product(s)?": [
        "您确定要从所选产品中删除同步计划吗？"
      ],
      "Are you sure you want to reset to default the {{ table.numSelected }} repository set(s) chosen?": [
        "您确定要重置到选择的默认 {{ table.numSelected }} 仓库集？"
      ],
      "Are you sure you want to restart services on content host \\\"{{ host.display_name }}\\\"?": [
        "您确定要重启内容主机 \\\"{{ host.display_name }}\\\" 上的服务?"
      ],
      "Are you sure you want to restart the services on the selected content hosts?": [
        "您确定要在所选内容主机上重新启动服务吗？"
      ],
      "Are you sure you want to set the HTTP Proxy to the selected products(s)?": [
        "您确定要将HTTP代理设置为所选产品吗？"
      ],
      "Are you sure you want to set the Release Version the {{ table.numSelected }} content host(s) selected to {{ selected.release }}?. This action will affect only those Content Hosts that belong to the appropriate Content View and Lifecycle Environment containining that release version.": [
        "您确定要将{{ table.numSelected }}个选择的内容主机的发布版本设置到{{ selected.release }}？此操作将仅影响属于包含该发行版本的相应内容视图和生命周期环境的那些内容主机。"
      ],
      "Are you sure you want to update {{ content.content }} on the {{ getSelectedSystemIds().length }} system(s) selected?": [
        "您确定要在所选的 {{ getSelectedSystemIds().length }} 系统上更新 {{ content.content }}"
      ],
      "Are you sure you want to update all packages on the {{ getSelectedSystemIds().length }} system(s) selected?": [
        "您确定要在所选 {{ getSelectedSystemIds().length }} 系统上更新所有软件包?"
      ],
      "Assign": [
        "分配"
      ],
      "Assign Lifecycle Environment and Content View": [
        "分配生命周期环境和内容视图"
      ],
      "Assign Release Version": [
        "分配发行版本"
      ],
      "Assign System Purpose": [
        "分配系统目的"
      ],
      "Associations": [
        "关联"
      ],
      "At least one Errata needs to be selected to Apply.": [
        "至少需要选择一个勘误才能应用。"
      ],
      "Attached": [
        "已附加"
      ],
      "Auth Token": [
        "验证令牌"
      ],
      "Auth URL": [
        "验证网址"
      ],
      "Author": [
        "作者"
      ],
      "Auto-Attach": [
        "自动附加"
      ],
      "Auto-attach available subscriptions to all selected hosts.": [
        "自动附加所有所选主机的可用订阅。"
      ],
      "Auto-Attach Details": [
        "自动附加详细信息"
      ],
      "Auto-attach uses all available subscriptions, not a selected subset.": [
        "auto-attach 使用所有可用的订阅，而不是所选子集。"
      ],
      "Automatic": [
        "自动"
      ],
      "Available Module Streams": [
        "可用的模块流"
      ],
      "Available Schema Versions": [
        "可用的 Schema 版本"
      ],
      "Back To Errata List": [
        "返回勘误列表"
      ],
      "Backend Identifier": [
        "后端识别码"
      ],
      "Basic Information": [
        "基本信息"
      ],
      "Below are the repository content sets currently available for this content host through its subscriptions. For Red Hat subscriptions, additional content can be made available through the": [
        "以下是此内容主机当前可通过其订阅获得的存储库内容集。对于红帽订阅，可以通过以下方式提供其他内容："
      ],
      "Below are the Repository Sets currently available for this activation key through its subscriptions. For Red Hat subscriptions, additional content can be made available through the": [
        "以下是当前通过其订阅可用于此激活码的存储库集。对于红帽订阅，可以通过以下方式提供其他内容："
      ],
      "BIOS UUID": [
        "BIOS UUID"
      ],
      "Bootable": [
        "可引导的"
      ],
      "Bug Fix": [
        "程序漏洞修正"
      ],
      "Bug Fix Advisory": [
        "错误修复公告"
      ],
      "Build Host": [
        "构建主机"
      ],
      "Build Information": [
        "构建信息"
      ],
      "Build Time": [
        "构建时间"
      ],
      "Bulk Task": [
        "批量任务"
      ],
      "Cancel": [
        "取消"
      ],
      "Cannot clean Repository without the proper permissions.": [
        "没有适当的权限来清理仓库。"
      ],
      "Cannot clean Repository, a sync is already in progress.": [
        "无法清理仓库，一个同步已在进行中。"
      ],
      "Cannot Remove": [
        "无法删除"
      ],
      "Cannot republish Repository without the proper permissions.": [
        "没有适当的权限，无法重新发布仓库。"
      ],
      "Cannot republish Repository, a sync is already in progress.": [
        "无法重新发布仓库，同步已在进行中。"
      ],
      "Cannot sync Repository without a URL.": [
        "没有URL，无法同步仓库。"
      ],
      "Cannot sync Repository without the proper permissions.": [
        "没有适当的权限，无法同步仓库。"
      ],
      "Cannot sync Repository, a sync is already in progress.": [
        "一个同步已在进行中，无法同步仓库。"
      ],
      "Capacity": [
        "容量"
      ],
      "Certificate": [
        "证书"
      ],
      "Change assigned Lifecycle Environment or Content View": [
        "更改分配的生命周期环境或内容视图"
      ],
      "Change Host Collections": [
        "修改主机集"
      ],
      "Change Lifecycle Environment": [
        "修改生命周期环境"
      ],
      "Changing default settings for content hosts that register with this activation key requires subscription-manager version 1.10 or newer to be installed on that host.": [
        "更改使用此激活密钥注册的内容主机的默认设置，需要在该主机上安装 subscription-manager 1.10 或更高版本。"
      ],
      "Changing default settings requires subscription-manager version 1.10 or newer to be installed on this host.": [
        "更改默认设置需要在此主机上安装 subscription-manager 版本 1.10 或更高版本。"
      ],
      "Changing download policy to \\\"On Demand\\\" will also clear the checksum type if set. The repository will use the upstream checksum type to verify downloads.": [
        "将下载策略更改为\\\"On Demand\\\"也会清除 checksum 类型（如果设置）。存储库将使用上游校验和类型来验证下载。"
      ],
      "Changing the Content View will not affect the Content Host until its next checkin.\\n                To update the Content Host immediately run the following command:": [
        "更改内容视图将不会影响内容主机，直到其下一次签入。要立即更新内容主机，请运行以下命令："
      ],
      "Changing the Content View will not affect the Content Hosts until their next checkin.\\n        To update the Content Hosts immediately run the following command:": [
        "更改内容视图将不会影响内容主机，直到它们下次签入。要立即更新内容主机，请运行以下命令："
      ],
      "Checksum": [
        "校验和"
      ],
      "Checksum Type": [
        "Checksum 类型"
      ],
      "Choose one of the registry options to discover containers. To examine a private registry choose \\\"Custom\\\" and provide the url for the private registry.": [
        "选择一个 registry 选项以发现容器。要检查私有 registry，请选择“自定义”，并提供私有 registry 的URL。"
      ],
      "Click here to check the status of the task.": [
        "单击此处检查任务的状态。"
      ],
      "Click here to select Errata for an Incremental Update.": [
        "单击此处以选择勘误表进行增量更新。"
      ],
      "Click to monitor task progress.": [
        "单击以监视任务进度。"
      ],
      "Click to view task": [
        "点击查看任务"
      ],
      "Close": [
        "关闭"
      ],
      "Collection Name": [
        "集合名称"
      ],
      "Complete Mirroring": [
        "完整镜像"
      ],
      "Complete Sync": [
        "完成同步"
      ],
      "Completed {{ repository.last_sync_words }} ago": [
        "已完成{{ repository.last_sync_words }}前"
      ],
      "Completely deletes the host including VM and disks, and removes all reporting, provisioning, and configuration information.": [
        "完全删除主机（包括VM和磁盘），并删除所有报告，设置和配置信息。"
      ],
      "Components": [
        "组件"
      ],
      "Components:": [
        "组件："
      ],
      "Composite View": [
        "复合视图"
      ],
      "Confirm": [
        "确认"
      ],
      "Confirm services restart": [
        "确认服务重启"
      ],
      "Container Image Manifest": [
        "容器图像清单"
      ],
      "Container Image Manifest Lists": [
        "容器镜像清单列表"
      ],
      "Container Image Manifests": [
        "容器图像清单"
      ],
      "Container Image metadata generation has been initiated in the background.  Click\\n      <a ng-href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        "容器镜像元数据生成已在后台启动。请点击<a ng-href=\\\"{{ taskUrl() }}\\\">这里</a>监视进度。"
      ],
      "Container Image Registry": [
        "容器镜像 registry"
      ],
      "Container Image Tags": [
        "容器镜像标签"
      ],
      "Content": [
        "内容"
      ],
      "Content Counts": [
        "内容计数"
      ],
      "Content Credential": [
        "内容凭证"
      ],
      "Content Credential %s has been created.": [
        "内容凭证%s已被创造。"
      ],
      "Content Credential Contents": [
        "内容凭证内容"
      ],
      "Content Credential successfully uploaded": [
        "内容凭证已成功上传"
      ],
      "Content credential updated": [
        "內容凭证已更新"
      ],
      "Content Credentials": [
        "内容凭证"
      ],
      "Content Host": [
        "內容主机"
      ],
      "Content Host Bulk Content": [
        "内容主机批量内容"
      ],
      "Content Host Bulk Subscriptions": [
        "内容主机批量订阅"
      ],
      "Content Host Content": [
        "內容主机内容"
      ],
      "Content Host Counts": [
        "內容主机数"
      ],
      "Content Host Limit": [
        "内容主机限制"
      ],
      "Content Host Module Stream Management": [
        "内容主机模块流管理"
      ],
      "Content Host Properties": [
        "内容主机属性"
      ],
      "Content Host Registration": [
        "内容主机注册"
      ],
      "Content Host Status": [
        "内容主机状态"
      ],
      "Content Host Traces Management": [
        "内容主机跟踪管理"
      ],
      "Content Host:": [
        "內容主机"
      ],
      "Content Hosts": [
        "內容主机"
      ],
      "Content Hosts for Activation Key:": [
        "激活码的内容主机："
      ],
      "Content Hosts for:": [
        "內容主机用于："
      ],
      "Content Only": [
        "只包括内容"
      ],
      "Content synced depends on the specifity of the URL and/or the optional requirements.yaml specified below <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'ansible_collection'\\\" uib-popover-html=\\\"collectionURLPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Upstream URL\\\">\\n        </a>": [
        "同步的内容取决于URL的特殊性和/或下面指定的可选要求。 <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'ansible_collection'\\\" uib-popover-html=\\\"collectionURLPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Upstream URL\\\">\\n        </a>"
      ],
      "Content Type": [
        "内容类型"
      ],
      "Content View": [
        "内容视图"
      ],
      "Content View Version": [
        "內容视图版本"
      ],
      "Content View:": [
        "内容视图："
      ],
      "Content Views": [
        "内容视图"
      ],
      "Content Views <div>{{ library.counts.content_views || 0 }}</div>": [
        "内容视图 <div>{{ library.counts.content_views || 0 }}</div>"
      ],
      "Content Views for Deb:": [
        "用于 Deb 的内容视图："
      ],
      "Content Views for File:": [
        "用于文件的内容视图："
      ],
      "Content Views that contain this Deb": [
        "包含此 Deb 的内容视图"
      ],
      "Content Views that contain this File": [
        "包含此文件的内容视图"
      ],
      "Context": [
        "上下文"
      ],
      "Contract": [
        "合同"
      ],
      "Copy Activation Key": [
        "复制激活码"
      ],
      "Copy Host Collection": [
        "复制主机集"
      ],
      "Cores per Socket": [
        "每个插槽的内核数"
      ],
      "Create": [
        "创建"
      ],
      "Create a copy of {{ activationKey.name }}": [
        "创建一个 {{ activationKey.name }} 副本"
      ],
      "Create a copy of {{ hostCollection.name }}": [
        "创建一个 {{ hostCollection.name }} 副本"
      ],
      "Create Activation Key": [
        "创建激活码"
      ],
      "Create Content Credential": [
        "建立內容凭证"
      ],
      "Create Copy": [
        "创建复制"
      ],
      "Create Discovered Repositories": [
        "创建发现的仓库"
      ],
      "Create Environment Path": [
        "创建环境路径"
      ],
      "Create Host Collection": [
        "创建主机集"
      ],
      "Create Product": [
        "创建产品"
      ],
      "Create Repositories": [
        "创建仓库"
      ],
      "Create Selected": [
        "创建所选"
      ],
      "Create Status": [
        "创建状态"
      ],
      "Create Sync Plan": [
        "创建同步计划"
      ],
      "Creating repository...": [
        "正在创建仓库..."
      ],
      "Critical": [
        "关键"
      ],
      "Cron Logic": [
        "Cron 逻辑"
      ],
      "ctrl-click or shift-click to select multiple Add ons": [
        "按 Ctrl 或 Shift 以选择多个附加组件"
      ],
      "Current Lifecycle Environment (%e/%cv)": [
        "当前的生命周期环境 (%e/%cv)"
      ],
      "Current Subscriptions for Activation Key:": [
        "当前的激活码订阅："
      ],
      "Custom": [
        "定制"
      ],
      "custom cron": [
        "自定义 cron"
      ],
      "Custom Cron": [
        "自定义Cron"
      ],
      "Custom Cron : {{ product.sync_plan.cron_expression }}": [
        "自定义Cron： {{ product.sync_plan.cron_expression }}"
      ],
      "Customize": [
        "自定义"
      ],
      "CVEs": [
        "CVE"
      ],
      "daily": [
        "每日"
      ],
      "Daily at {{ product.sync_plan.sync_date | date:'mediumTime' }} (Server Time)": [
        "每天在{{ product.sync_plan.sync_date | date:'mediumTime' }}（服务器时间）"
      ],
      "Date": [
        "日期"
      ],
      "deb metadata generation has been initiated in the background.  Click <a href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        "deb元数据生成已在后台启动。请点击<a href=\\\"{{ taskUrl() }}\\\">这里</a>监视进度。"
      ],
      "Deb Package Actions": [
        "deb 软件包操作"
      ],
      "deb Package Updates": [
        "deb 软件包更新"
      ],
      "deb Packages": [
        "deb 软件包"
      ],
      "Deb Packages": [
        "Deb 软件包"
      ],
      "Deb Packages <div>{{ library.counts.debs || 0 }}</div>": [
        "Deb 软件包 <div>{{ library.counts.debs || 0 }}</div>"
      ],
      "Deb Packages for:": [
        "Deb 软件包用于："
      ],
      "Deb Repositories": [
        "Deb 存储库"
      ],
      "Deb Repositories <div>{{ library.counts.deb_repositories || 0 }}</div>": [
        "Deb 软件仓库 <div>{{ library.counts.deb_repositories || 0 }}</div>"
      ],
      "Deb:": [
        "Deb:"
      ],
      "Debs": [
        "Debs"
      ],
      "Default": [
        "默认"
      ],
      "Default Status": [
        "默认状态"
      ],
      "Delete": [
        "刪除"
      ],
      "Delete {{ table.numSelected  }} Hosts?": [
        "删除 {{ table.numSelected  }} 主机?"
      ],
      "Delete filters": [
        "删除过滤"
      ],
      "Delete Hosts": [
        "删除主机"
      ],
      "Delta RPM": [
        "Delta RPM"
      ],
      "Dependencies": [
        "依赖性"
      ],
      "Description": [
        "描述"
      ],
      "Details": [
        "详情"
      ],
      "Details for Activation Key:": [
        "激活码详情："
      ],
      "Details for Container Image Tag:": [
        "容器镜像标签的详情："
      ],
      "Details for Product:": [
        "产品详情："
      ],
      "Details for Repository:": [
        "仓库详情："
      ],
      "Determines whether to require login to pull container images in this lifecycle environment.": [
        "确定是否需要登录才能在此生命周期环境中提取容器镜像。"
      ],
      "Digest": [
        "文摘值"
      ],
      "Disable": [
        "禁用"
      ],
      "Disabled": [
        "禁用"
      ],
      "Disabled (overridden)": [
        "禁用（已覆盖）"
      ],
      "Discover": [
        "发现"
      ],
      "Discover Repositories": [
        "发现软件仓库"
      ],
      "Discovered Repository": [
        "发现的仓库"
      ],
      "Discovery failed. Error: %s": [
        "发现失败。错误： %s"
      ],
      "Distribution": [
        "发布"
      ],
      "Distribution Information": [
        "发布信息"
      ],
      "Do not require a subscription entitlement certificate for accessing this repository.": [
        "访问这个仓库不需要订阅授权证书。"
      ],
      "Docker": [
        "Docker"
      ],
      "Docker metadata generation has been initiated in the background.  Click\\n            <a ng-href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        "Docker元数据生成已在后台启动。请点击<a ng-href=\\\"{{ taskUrl() }}\\\">这里</a>监视进度。"
      ],
      "Docker Repositories <div>{{ library.counts.docker_repositories || 0 }}</div>": [
        "Docker 仓库 <div>{{ library.counts.docker_repositories || 0 }}</div>"
      ],
      "Docker Tags": [
        "Docker 标签"
      ],
      "Done": [
        "完成"
      ],
      "Download Policy": [
        "下载政策"
      ],
      "Enable": [
        "启用"
      ],
      "Enable Traces": [
        "启用跟踪"
      ],
      "Enabled": [
        "启用"
      ],
      "Enabled (overridden)": [
        "已启用（已覆盖）"
      ],
      "Enhancement": [
        "功能增强"
      ],
      "Enter Package Group Name(s)...": [
        "输入软件包组名称"
      ],
      "Enter Package Name(s)...": [
        "输入软件包名称..."
      ],
      "Environment": [
        "环境"
      ],
      "Environment saved": [
        "保存环境"
      ],
      "Environment will also be removed from the following published content views!": [
        "环境也将从以下发布的内容视图中移除！"
      ],
      "Environments": [
        "环境"
      ],
      "Environments List": [
        "环境列表"
      ],
      "Errata": [
        "勘误"
      ],
      "Errata <div>{{ library.counts.errata.total || 0 }}</div>": [
        "勘误<div>{{ library.counts.errata.total || 0 }}"
      ],
      "Errata are automatically Applicable if they are Installable": [
        "如果是可安装的，勘误将会自动可适用"
      ],
      "Errata Details": [
        "勘误详情"
      ],
      "Errata for:": [
        "勘误："
      ],
      "Errata ID": [
        "勘误 ID"
      ],
      "Errata Installation": [
        "勘误安装"
      ],
      "Errata Task List": [
        "勘误任务列表"
      ],
      "Errata Tasks": [
        "勘误任务"
      ],
      "Errata:": [
        "勘误："
      ],
      "Error during upload:": [
        "上载时发生错误："
      ],
      "Error saving the Sync Plan:": [
        "保存同步计划时出错："
      ],
      "Event": [
        "事件"
      ],
      "Exclude Tags": [
        "排除标签"
      ],
      "Existing Product": [
        "现有产品"
      ],
      "Expires": [
        "过期"
      ],
      "Export": [
        "导出"
      ],
      "Family": [
        "系列"
      ],
      "File Information": [
        "文件信息"
      ],
      "File removal been initiated in the background.  Click <a href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        "文件删除已在后台启动。请点击<a href=\\\"{{ taskUrl() }}\\\">这里</a>监视进度。"
      ],
      "File too large.": [
        "文件过大。"
      ],
      "File too large. Please use the CLI instead.": [
        "文件过大。请使用 CLI。"
      ],
      "File:": [
        "文件："
      ],
      "Filename": [
        "文件名"
      ],
      "Files": [
        "文件"
      ],
      "Files in package {{ package.nvrea }}": [
        "软件包 {{ package.nvrea }} 中的文件"
      ],
      "Filter": [
        "过滤器"
      ],
      "Filter by Environment": [
        "按环境过滤"
      ],
      "Filter by Status:": [
        "根据状态过滤："
      ],
      "Filter...": [
        "过滤器......"
      ],
      "Filters": [
        "过滤器"
      ],
      "Finished At": [
        "完成于"
      ],
      "For older operating systems such as Red Hat Enterprise Linux 5 or CentOS 5 it is recommended to use sha1.": [
        "对于较旧的操作系统，如 Red Hat Enterprise Linux 5 或CentOS 5，建议使用 sha1。"
      ],
      "For On Demand synchronization, only the metadata is downloaded during sync and packages are fetched and stored on the filesystem when clients request them.\\n          On Demand is not recommended for custom repositories unless the upstream repository maintains older versions of packages within the repository.\\n          The Immediate option will download all metadata and packages immediately during the sync.": [
        "对于按需同步，仅在同步期间下载元数据，并在客户端请求时将软件包提取并存储在文件系统中。对于自定义仓库，建议不要使用按需存储，除非上游仓库在仓库中维护较旧版本的软件包。 “立即”选项将在同步期间立即下载所有元数据和程序包。"
      ],
      "Global Default": [
        "全局默认值"
      ],
      "Global Default (None)": [
        "全局默认值（无）"
      ],
      "GPG Key": [
        "GPG 密钥"
      ],
      "Group": [
        "组"
      ],
      "Group Install (Deprecated)": [
        "组安装（已弃用）"
      ],
      "Group package actions are being deprecated, and will be removed in a future version.": [
        "组软件包操作已被弃用，并将在以后的版本中删除。"
      ],
      "Group Remove (Deprecated)": [
        "组删除（已弃用）"
      ],
      "Guests of": [
        "的客户"
      ],
      "Helper": [
        "帮助"
      ],
      "Host %s has been deleted.": [
        "主机 %s 已被删除。"
      ],
      "Host %s has been unregistered.": [
        "主机 %s 已被取消注册。"
      ],
      "Host Collection Management": [
        "主机集合管理"
      ],
      "Host Collection Membership": [
        "主机集合成员"
      ],
      "Host Collection Membership Management": [
        "主机集合成员资格管理"
      ],
      "Host Collection removed.": [
        "主机集合已删除"
      ],
      "Host Collection updated": [
        "主机集合已更新"
      ],
      "Host Collection:": [
        "主机集合："
      ],
      "Host Collections": [
        "主机集合"
      ],
      "Host Collections for:": [
        "主机集合："
      ],
      "Host Count": [
        "主机数"
      ],
      "Host Group": [
        "主机组"
      ],
      "Host Limit": [
        "主机限制"
      ],
      "Hostname": [
        "主机名"
      ],
      "Hosts": [
        "主机"
      ],
      "hourly": [
        "每小时"
      ],
      "Hourly at {{ product.sync_plan.sync_date | date:'m' }} minutes and {{ product.sync_plan.sync_date | date:'s' }} seconds": [
        "每小时{{ product.sync_plan.sync_date | date:'m' }}分钟和{{ product.sync_plan.sync_date | date:'s' }}秒"
      ],
      "HTTP Proxy": [
        "HTTP 代理"
      ],
      "HTTP Proxy Management": [
        "HTTP 代理管理"
      ],
      "HTTP Proxy Policy": [
        "HTTP 代理策略"
      ],
      "HTTP Proxy Policy:": [
        "HTTP 代理策略："
      ],
      "HTTP Proxy:": [
        "HTTP 代理："
      ],
      "HttpProxyPolicy": [
        "HttpProxyPolicy"
      ],
      "Id": [
        "ID"
      ],
      "If you want to upload individual packages, create a separate repository with an empty \\\"Upstream URL\\\" field.": [
        "如果要上传单个软件包，请使用一个空的 \\\"Upstream URL\\\" 字段创建单独的仓库。"
      ],
      "Ignore SRPMs": [
        "忽略 SRPM"
      ],
      "Ignore treeinfo": [
        "忽略 treeinfo"
      ],
      "Image": [
        "镜像"
      ],
      "Immediate": [
        "立即"
      ],
      "Important": [
        "重要"
      ],
      "In order to browse this repository you must <a ng-href=\\\"/organizations/{{ organization }}/edit\\\">download the certificate</a>\\n            or ask your admin for a certificate.": [
        "为了浏览此仓库，您必须<a ng-href=\\\"/organizations/{{ organization }}/edit\\\">下载证书</a>或向管理员询问证书。"
      ],
      "Include Tags": [
        "包含标签"
      ],
      "Independent Packages": [
        "独立软件包"
      ],
      "Install": [
        "安装"
      ],
      "Install Selected": [
        "安装所选"
      ],
      "Install the pre-built bootstrap RPM:": [
        "安装预构建的引导程序 RPM："
      ],
      "Installable": [
        "可安装"
      ],
      "Installable Errata": [
        "可安装的勘误"
      ],
      "Installable Updates": [
        "可安装的更新"
      ],
      "Installed": [
        "已安裝"
      ],
      "Installed Deb Packages": [
        "安装的 Deb 软件包"
      ],
      "Installed On": [
        "安装于"
      ],
      "Installed Package": [
        "已安装的软件包"
      ],
      "Installed Packages": [
        "已安装的软件包"
      ],
      "Installed Products": [
        "安装的产品"
      ],
      "Installed Profile": [
        "安装的配置集"
      ],
      "Interfaces": [
        "接口"
      ],
      "Interval": [
        "间隔"
      ],
      "IPv4 Address": [
        "IPv4 位址"
      ],
      "IPv6 Address": [
        "IPv6 地址"
      ],
      "Issued": [
        "发行"
      ],
      "Katello Tracer": [
        "Katello Tracer"
      ],
      "Label": [
        "标签"
      ],
      "Last Checkin": [
        "最后签到"
      ],
      "Last Published": [
        "最后发布的"
      ],
      "Last Puppet Report": [
        "最后的 Puppet 报告"
      ],
      "Last reclaim failed:": [
        "最后重新声明失败："
      ],
      "Last reclaim space failed:": [
        "最后的重新声明空间失败："
      ],
      "Last Sync": [
        "最后同步"
      ],
      "Last sync failed:": [
        "最后的同步失败："
      ],
      "Last synced": [
        "最后同步的"
      ],
      "Last Updated On": [
        "最后更新于："
      ],
      "Library": [
        "库"
      ],
      "Library Repositories": [
        "库仓库"
      ],
      "Library Repositories that contain this Deb.": [
        "包含此 Deb 的库仓库。"
      ],
      "Library Repositories that contain this File.": [
        "包含此文件的库仓库。"
      ],
      "Library Synced Content": [
        "库更新的内容"
      ],
      "License": [
        "许可证"
      ],
      "Lifecycle Environment": [
        "生命周期环境"
      ],
      "Lifecycle Environment Paths": [
        "生命周期环境路径"
      ],
      "Lifecycle Environment:": [
        "生命周期环境："
      ],
      "Lifecycle Environments": [
        "生命周期环境"
      ],
      "Limit": [
        "限制"
      ],
      "Limit Repository Sets to only those available in this Activation Key's Lifecycle  Environment": [
        "将仓库集限制为仅此激活码的生命周期环境中可用的仓库集"
      ],
      "Limit Repository Sets to only those available in this Host's Lifecycle Environment": [
        "将仓库集限制为仅此主机的生命周期环境中可用的仓库集"
      ],
      "Limit to environment": [
        "限制到环境"
      ],
      "Limit to Environment": [
        "限制到环境"
      ],
      "Limit to Lifecycle Environment": [
        "限制到生命周期环境"
      ],
      "Limit:": [
        "限制："
      ],
      "List": [
        "列出"
      ],
      "List Host Collections": [
        "列出主机集合"
      ],
      "List Hosts": [
        "列出主机"
      ],
      "List Products": [
        "列出产品"
      ],
      "List Subscriptions": [
        "列出订阅"
      ],
      "List/Remove": [
        "列出/删除"
      ],
      "Loading...": [
        "载入中..."
      ],
      "Loading...\\\"": [
        "加载...\\\""
      ],
      "Make filters apply to all repositories in the content view": [
        "使过滤应用到内容视图中的所有仓库"
      ],
      "Manage Ansible Collections for Repository:": [
        "管理仓库的 Ansible 集合："
      ],
      "Manage Container Image Manifests for Repository:": [
        "管理仓库的容器镜像清单："
      ],
      "Manage Content for Repository:": [
        "管理仓库的内容："
      ],
      "Manage deb Packages for Repository:": [
        "管理仓库的 deb 软件包："
      ],
      "Manage Errata": [
        "管理勘误"
      ],
      "Manage Files for Repository:": [
        "管理仓库文件："
      ],
      "Manage Host Traces": [
        "管理主机 Traces"
      ],
      "Manage HTTP Proxy": [
        "管理 HTTP 代理"
      ],
      "Manage Module Streams": [
        "管理模块流"
      ],
      "Manage Module Streams for Repository:": [
        "管理仓库的模块流："
      ],
      "Manage Packages": [
        "管理软件包"
      ],
      "Manage Packages for Repository:": [
        "管理仓库软件包："
      ],
      "Manage Repository Sets": [
        "管理仓库集"
      ],
      "Manage Subscriptions": [
        "管理订阅"
      ],
      "Manage Sync Plan": [
        "管理同步计划"
      ],
      "Manage System Purpose": [
        "管理系统目的"
      ],
      "Manifest Lists": [
        "清单列表"
      ],
      "Manifest Type": [
        "清单类型"
      ],
      "Metadata Expiration (Seconds)": [
        "元数据过期 (以秒为单位)"
      ],
      "Mirroring Policy": [
        "镜像策略"
      ],
      "Model": [
        "模型"
      ],
      "Moderate": [
        "中等"
      ],
      "Modular": [
        "模块化"
      ],
      "Module Stream Management": [
        "模块流管理"
      ],
      "Module Stream metadata generation has been initiated in the background.  Click\\n      <a ng-href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        "模块流元数据生成已在后台启动。请点击<a ng-href=\\\"{{ taskUrl() }}\\\">这里</a>监视进度。"
      ],
      "Module Stream Packages": [
        "模块流软件包"
      ],
      "Module Streams": [
        "模块流"
      ],
      "Module Streams <div>{{ library.counts.module_streams || 0 }}</div>": [
        "模块流<div>{{ library.counts.module_streams || 0 }}"
      ],
      "Module Streams for:": [
        "模块流："
      ],
      "More Details": [
        "更多详情"
      ],
      "N/A": [
        "不适用"
      ],
      "Name": [
        "名称"
      ],
      "Name of the upstream repository you want to sync. Example: 'quay/busybox' or 'fedora/ssh'.": [
        "您要同步的上游仓库的名称。例如：'quay/busybox' 或 'fedora/ssh'。"
      ],
      "Networking": [
        "网络"
      ],
      "Never": [
        "决不"
      ],
      "Never checked in": [
        "从未签到"
      ],
      "Never registered": [
        "从未注册"
      ],
      "Never synced": [
        "从未同步"
      ],
      "New Activation Key": [
        "新激活码"
      ],
      "New Content Credential": [
        "新内容凭证"
      ],
      "New Environment": [
        "新环境"
      ],
      "New Host Collection": [
        "新主机集合"
      ],
      "New Name:": [
        "新名称："
      ],
      "New Product": [
        "新产品"
      ],
      "New Repository": [
        "新仓库"
      ],
      "New Sync Plan": [
        "新同步计划"
      ],
      "New sync plan successfully created.": [
        "已成功创建新的同步计划。"
      ],
      "Next": [
        "下一个"
      ],
      "Next Sync": [
        "下一个同步"
      ],
      "No": [
        "否"
      ],
      "No alternate release version choices are available. The available releases are based upon what is available in \\\"{{ host.content_facet_attributes.content_view.name }}\\\", the selected <a href=\\\"/content_views\\\">content view</a> this content host is attached to for the given <a href=\\\"/lifecycle_environments\\\">lifecycle environment</a>, \\\"{{ host.content_facet_attributes.lifecycle_environment.name }}\\\".": [
        "没有其他可用的发行版本选择。可用版本基于“{{ host.content_facet_attributes.content_view.name }} ”，选中<a href=\\\"/content_views\\\">内容检视</a>此内容主机已附加到给定的<a href=\\\"/lifecycle_environments\\\">生命周期环境</a>，“{{ host.content_facet_attributes.lifecycle_environment.name }} ”。"
      ],
      "No Content Hosts match this Erratum.": [
        "没有内容主机与此勘误匹配。"
      ],
      "No Content Views contain this Deb": [
        "没有内容视图包含此 Deb"
      ],
      "No Content Views contain this File": [
        "没有内容视图包含此文件"
      ],
      "No content views exist for {{selected.environment.name}}": [
        "没有用于 {{selected.environment.name}} 的内容视图"
      ],
      "No discovered repositories.": [
        "没有发现的仓库。"
      ],
      "No enabled Repository Sets provided through subscriptions.": [
        "没有通过订阅提供的已启用仓库集。"
      ],
      "No Host Collections match your search.": [
        "没有主机集合与您的搜索匹配。"
      ],
      "No Host Collections to show, you can add Host Collections after selecting 'Host Collections' under 'Hosts' in main menu.": [
        "没有主机集合显示，您可以在主菜单中的“主机”下选择“主机集合”后添加主机集合。"
      ],
      "No Host Collections to show, you can add Host Collections after selecting the 'Add' tab.": [
        "没有主机集合可显示，您可以在选择“添加”选项卡后添加主机集合。"
      ],
      "No HTTP Proxies found": [
        "没有找到 HTTP 代理"
      ],
      "No HTTP Proxy": [
        "没有 HTTP 代理"
      ],
      "No matching results.": [
        "没有匹配的结果。"
      ],
      "No Packages to show": [
        "没有要显示的软件包"
      ],
      "No products are available to add to this Sync Plan.": [
        "没有可用于添加到此同步计划的产品。"
      ],
      "No products have been added to this Sync Plan.": [
        "未将任何产品添加到此同步计划中。"
      ],
      "No releases exist in the Library.": [
        "库中没有发行版本。"
      ],
      "No Repositories contain this Deb": [
        "没有仓库包含此 Deb"
      ],
      "No Repositories contain this Erratum.": [
        "没有仓库包含此勘误。"
      ],
      "No Repositories contain this File": [
        "没有仓库包含此文件"
      ],
      "No Repositories contain this Package.": [
        "没有仓库含此软件包。"
      ],
      "No repository sets provided through subscriptions.": [
        "没有通过订阅提供的仓库集。"
      ],
      "No restriction": [
        "没有限制"
      ],
      "No sync information available.": [
        "没有可用的同步信息。"
      ],
      "No tasks exist for this resource.": [
        "此资源不存在任何任务。"
      ],
      "None": [
        "没有"
      ],
      "Not Applicable": [
        "不适用"
      ],
      "Not started": [
        "未启动"
      ],
      "Not Synced": [
        "未同步"
      ],
      "Number of CPUs": [
        "CPU 的数量"
      ],
      "Number of Repositories": [
        "仓库数量"
      ],
      "On Demand": [
        "按需"
      ],
      "One or more of the selected Errata are not Installable via your published Content View versions running on the selected hosts.  The new Content View Versions (specified below)\\n      will be created which will make this Errata Installable in the host's Environment.  This new version will replace the current version in your host's Lifecycle\\n      Environment.  To install these errata immediately on hosts after publishing check the box below.": [
        "无法通过在选定主机上运行的已发布内容视图版本来安装一个或多个选定勘误。将创建新的内容视图版本（在下面指定），使该勘误可在主机的环境中安装。此新版本将替换主机的生命周期环境中的当前版本。要在发布后立即在主机上安装这些勘误，请选中以下框。"
      ],
      "One or more packages are not showing up in the local repository even though they exist in the upstream repository.": [
        "即使上游仓库中存在一个或多个软件包，它们也不会出现在本地仓库中。"
      ],
      "Only show content hosts where the errata is currently installable in the host's Lifecycle Environment.": [
        "仅显示内容主机当前在主机的生命周期环境中可安装勘误的主机。"
      ],
      "Only show Errata that are Applicable to one or more Content Hosts": [
        "仅显示适用于一个或多个内容主机的勘误"
      ],
      "Only show Errata that are Installable on one or more Content Hosts": [
        "仅显示可在一个或多个内容主机上安装的勘误"
      ],
      "Only show Packages that are Applicable to one or more Content Hosts": [
        "仅显示适用于一个或多个内容主机的软件包"
      ],
      "Only show Packages that are Upgradable on one or more Content Hosts": [
        "仅返回可在一个或多个主机上升级的软件包"
      ],
      "Only show Subscriptions for products not already covered by a Subscription": [
        "仅显示订阅尚未涵盖的产品的订阅"
      ],
      "Only show Subscriptions which can be applied to products installed on this Host": [
        "仅显示可应用于此主机上安装的产品的订阅"
      ],
      "Only show Subscriptions which can be attached to this Host": [
        "仅显示可以附加到该主机的订阅"
      ],
      "Only the Applications with a Helper can be restarted.": [
        "只有带有 Helper 的应用程序才能重新启动。"
      ],
      "Operating System": [
        "操作系统"
      ],
      "Optimized Sync": [
        "优化同步"
      ],
      "Organization": [
        "机构"
      ],
      "Original Sync Date": [
        "原始同步日期"
      ],
      "OS": [
        "OS"
      ],
      "OSTree Repositories <div>{{ library.counts.ostree_repositories || 0 }}</div>": [
        "OSTree 仓库 <div>{{ library.counts.ostree_repositories || 0 }}</div>"
      ],
      "Override to Disabled": [
        "覆盖禁用"
      ],
      "Override to Enabled": [
        "覆盖启用"
      ],
      "Package": [
        "软件包"
      ],
      "Package Actions": [
        "软件包操作"
      ],
      "Package Group (Deprecated)": [
        "软件包组（已弃用）"
      ],
      "Package Groups": [
        "软件包组"
      ],
      "Package Groups for Repository:": [
        "仓库的软件包组："
      ],
      "Package Information": [
        "软件包信息"
      ],
      "Package Install": [
        "软件包安装"
      ],
      "Package Installation, Removal, and Update": [
        "程序包的安装，删除和更新"
      ],
      "Package Remove": [
        "软件包删除"
      ],
      "Package Update": [
        "软件包更新"
      ],
      "Package:": [
        "软件包："
      ],
      "Package/Group Name": [
        "软件包/组名称"
      ],
      "Packages": [
        "软件包"
      ],
      "Packages <div>{{ library.counts.packages || 0 }}</div>": [
        "软件包<div>{{ library.counts.packages || 0 }}</div>"
      ],
      "Packages are automatically Applicable if they are Upgradable": [
        "如果软件包是可升级的，则自动适用"
      ],
      "Packages for Errata:": [
        "勘误软件包："
      ],
      "Packages for:": [
        "软件包："
      ],
      "Parameters": [
        "参数"
      ],
      "Part of a manifest list": [
        "清单列表的一部分"
      ],
      "Password": [
        "密码"
      ],
      "Password of the upstream repository user for authentication. Leave empty if repository does not require authentication.": [
        "用于身份验证的上游仓库用户的密码。如果仓库不需要身份验证，则保留为空。"
      ],
      "Paste contents of Content Credential": [
        "上载内容凭证内容"
      ],
      "Path": [
        "路径"
      ],
      "Perform": [
        "执行"
      ],
      "Performing host package actions is disabled because Katello is not configured for remote execution.": [
        "执行主机软件包操作被禁用，因为没有为远程执行配置 Katello。"
      ],
      "Performing host package actions is disabled because Katello is not configured for Remote Execution.": [
        "执行主机软件包操作被禁用，因为没有为远程执行配置 Katello。"
      ],
      "Physical": [
        "物理"
      ],
      "Please enter cron below": [
        "请在下面输入 cron"
      ],
      "Please make sure a Content View is selected.": [
        "请确保选择了内容视图。"
      ],
      "Please select an environment.": [
        "请先选择一个环境"
      ],
      "Please select one from the list below and you will be redirected.": [
        "请从下面的列表中选择一个，您将被重定向。"
      ],
      "Plus %y more errors": [
        "加%y个更多的错误"
      ],
      "Plus 1 more error": [
        "再加上 1 个错误"
      ],
      "Previous Lifecycle Environment (%e/%cv)": [
        "前面的生命周期环境 (%e/%cv)"
      ],
      "Prior Environment": [
        "前面的环境"
      ],
      "Product": [
        "产品"
      ],
      "Product delete operation has been initiated in the background.": [
        "产品删除操作已在后台启动。"
      ],
      "Product Enhancement Advisory": [
        "产品增强公告"
      ],
      "Product information for:": [
        "产品信息："
      ],
      "Product Management for Sync Plan:": [
        "同步计划的产品管理："
      ],
      "Product Name": [
        "产品名称"
      ],
      "Product Options": [
        "产品选项"
      ],
      "Product Saved": [
        "产品已保存"
      ],
      "Product sync has been initiated in the background.": [
        "产品同步已在后台启动。"
      ],
      "Product syncs has been initiated in the background.": [
        "产品同步已在后台启动。"
      ],
      "Product verify checksum has been initiated in the background.": [
        "产品验证校验和已在后台启动。"
      ],
      "Products": [
        "产品"
      ],
      "Products <div>{{ library.counts.products || 0 }}</div>": [
        "产品<div>{{ library.counts.products || 0 }}"
      ],
      "Products for": [
        "产品"
      ],
      "Products not covered": [
        "未涵盖的产品"
      ],
      "Provides": [
        "提供"
      ],
      "Provisioning": [
        "置备"
      ],
      "Provisioning Details": [
        "置备详情"
      ],
      "Provisioning Host Details": [
        "设置主机详情"
      ],
      "Published At": [
        "发表于"
      ],
      "Published Repository Information": [
        "发布的仓库信息"
      ],
      "Publishing Settings": [
        "发布设置"
      ],
      "Puppet Environment": [
        "Puppet 环境"
      ],
      "Quantity": [
        "数量"
      ],
      "Quantity (To Add)": [
        "数量（要添加的）"
      ],
      "RAM (GB)": [
        "RAM (GB)"
      ],
      "Reboot Suggested": [
        "建议重启"
      ],
      "Reboot Suggested?": [
        "重新启动建议？"
      ],
      "Recalculate\\n          <i class=\\\"fa fa-spinner fa-spin\\\" ng-show=\\\"calculatingApplicability\\\"></i>": [
        "重新计算\\n          <i class=\\\"fa fa-spinner fa-spin\\\" ng-show=\\\"calculatingApplicability\\\"></i>"
      ],
      "Reclaim Space": [
        "重新声明空间"
      ],
      "Recurring Logic": [
        "重复逻辑"
      ],
      "Red Hat": [
        "Red Hat"
      ],
      "Red Hat Repositories page": [
        "红帽仓库页"
      ],
      "Red Hat Repositories page.": [
        "红帽仓库页。"
      ],
      "Refresh Table": [
        "刷新表"
      ],
      "Register a Content Host": [
        "注册一个内容主机"
      ],
      "Register Content Host": [
        "注册内容主机"
      ],
      "Registered": [
        "注册"
      ],
      "Registered By": [
        "注册人"
      ],
      "Registered Through": [
        "注册通过"
      ],
      "Registry Name Pattern": [
        "Registry 名称特征"
      ],
      "Registry Search Parameter": [
        "Registry 搜索参数"
      ],
      "Registry to Discover": [
        "发现的 Registry"
      ],
      "Registry URL": [
        "Registry URL"
      ],
      "Release": [
        "发行"
      ],
      "Release Version": [
        "发行版本"
      ],
      "Release Version:": [
        "发行版本："
      ],
      "Releases/Distributions": [
        "发行版本/发行"
      ],
      "Remote execution plugin is required to be able to run any helpers.": [
        "需要远程执行插件才能运行任何帮助程序。"
      ],
      "Remove": [
        "移除"
      ],
      "Remove {{ table.numSelected  }} Container Image manifest?": [
        "删除{{ table.numSelected  }}容器图像清单？"
      ],
      "Remove Activation Key \\\"{{ activationKey.name }}\\\"?": [
        "删除激活码 \\\"{{ activationKey.name }}\\\"?"
      ],
      "Remove Container Image Manifests": [
        "删除容器图像清单"
      ],
      "Remove Content": [
        "删除内容"
      ],
      "Remove Content Credential": [
        "显示内容凭证"
      ],
      "Remove Content Credential {{ contentCredential.name }}": [
        "显示内容凭证{{ contentCredential.name }}"
      ],
      "Remove Content?": [
        "删除内容？"
      ],
      "Remove Environment": [
        "删除环境"
      ],
      "Remove environment {{ environment.name }}?": [
        "删除环境 {{ environment.name }}？"
      ],
      "Remove File?": [
        "删除文件？"
      ],
      "Remove Files": [
        "删除文件"
      ],
      "Remove From": [
        "从......中删除"
      ],
      "Remove Host Collection \\\"{{ hostCollection.name }}\\\"?": [
        "删除主机集合 \\\"{{ hostCollection.name }}\\\"?"
      ],
      "Remove Package?": [
        "删除软件包？"
      ],
      "Remove Packages": [
        "删除软件包"
      ],
      "Remove Product": [
        "删除产品"
      ],
      "Remove Product \\\"{{ product.name }}\\\"?": [
        "删除产品“{{ product.name }} “？"
      ],
      "Remove product?": [
        "删除产品？"
      ],
      "Remove Repositories": [
        "删除仓库"
      ],
      "Remove Repository": [
        "删除仓库"
      ],
      "Remove Repository {{ repositoryWrapper.repository.name }}?": [
        "删除仓库 {{ repositoryWrapper.repository.name }}？"
      ],
      "Remove repository?": [
        "删除仓库？"
      ],
      "Remove Selected": [
        "继续选择"
      ],
      "Remove Successful.": [
        "删除成功。"
      ],
      "Remove Sync Plan": [
        "更新同步计划"
      ],
      "Remove Sync Plan \\\"{{ syncPlan.name }}\\\"?": [
        "更新同步计划{{ syncPlan.name }}？"
      ],
      "Removed %x host collections from activation key \\\"%y\\\".": [
        "从激活码 \\\"%y\\\" 中删除的 %x 主机集合。"
      ],
      "Removed %x host collections from content host \\\"%y\\\".": [
        "从内容主机 \\\"%y\\\" 中删除的 %x 主机集合。"
      ],
      "Removed %x products from sync plan \\\"%y\\\".": [
        "从同步计划 \\\"%y\\\" 中删除 %x。"
      ],
      "Removing Repositories": [
        "删除仓库"
      ],
      "Repo Discovery": [
        "仓库发现"
      ],
      "Repositories": [
        "软件仓库"
      ],
      "Repositories containing Errata {{ errata.errata_id }}": [
        "包含勘误 {{ errata.errata_id }} 的仓库"
      ],
      "Repositories containing package {{ package.nvrea }}": [
        "包含软件包 {{ package.nvrea }} 的仓库"
      ],
      "Repositories for": [
        "仓库"
      ],
      "Repositories for Deb:": [
        "用于 Deb 的仓库："
      ],
      "Repositories for Errata:": [
        "用于勘误的仓库："
      ],
      "Repositories for File:": [
        "用于文件的仓库："
      ],
      "Repositories for Package:": [
        "用于软件包的仓库："
      ],
      "Repositories for Product:": [
        "用于产品的仓库："
      ],
      "Repositories to Create": [
        "创建的仓库"
      ],
      "Repository": [
        "仓库"
      ],
      "Repository \\\"%s\\\" successfully deleted": [
        "仓库 \\\"%s\\\" 成功删除"
      ],
      "Repository %s successfully created.": [
        "仓库 %s 成功创建。"
      ],
      "Repository created": [
        "仓库已建立"
      ],
      "Repository Discovery": [
        "仓库发现"
      ],
      "Repository HTTP proxy changes have been initiated in the background.": [
        "仓库 HTTP 代理更改已在后台启动。"
      ],
      "Repository Label": [
        "仓库标签"
      ],
      "Repository Name": [
        "仓库名称"
      ],
      "Repository Options": [
        "仓库选项"
      ],
      "Repository Path": [
        "仓库路径"
      ],
      "Repository Saved.": [
        "仓库已保存。"
      ],
      "Repository Sets": [
        "仓库集"
      ],
      "Repository Sets Management": [
        "仓库设置管理"
      ],
      "Repository Sets settings saved successfully.": [
        "仓库集设置已成功保存。"
      ],
      "Repository type": [
        "仓库类型"
      ],
      "Repository Type": [
        "仓库类型"
      ],
      "Repository URL": [
        "仓库 URL"
      ],
      "Repository will also be removed from the following published content view versions!": [
        "仓库也将从以下发布的内容视图版本中移除！"
      ],
      "Repository:": [
        "仓库："
      ],
      "Republish Repository Metadata": [
        "重新发布仓库元数据"
      ],
      "Requirements": [
        "要求"
      ],
      "Requirements.yml": [
        "Requirements.yml"
      ],
      "Requires": [
        "需要"
      ],
      "Reset": [
        "重置"
      ],
      "Reset to Default": [
        "重置为默认"
      ],
      "Resolving the selected Traces will reboot the selected content hosts.": [
        "解决选择的跟踪将重新启动选择的内容主机。"
      ],
      "Resolving the selected Traces will reboot this host.": [
        "重新启动该主机解决选定的跟踪。"
      ],
      "Restart": [
        "重新开始"
      ],
      "Restart Selected": [
        "重新启动所选"
      ],
      "Restart Services on Content Host \\\"{{host.display_name}}\\\"?": [
        "重新启动内容主机\\\"{{host.display_name}}\\\"上的服务？"
      ],
      "Restrict to <br>OS version": [
        "仅限 <br>操作系统版本"
      ],
      "Restrict to architecture": [
        "限制架构"
      ],
      "Restrict to Architecture": [
        "限制架构"
      ],
      "Restrict to OS version": [
        "仅限操作系统版本"
      ],
      "Result": [
        "结果"
      ],
      "Retain package versions": [
        "保持软件包版本"
      ],
      "Role": [
        "角色"
      ],
      "Role:": [
        "角色："
      ],
      "RPM": [
        "RPM"
      ],
      "rpm Package Updates": [
        "rpm 软件包更新"
      ],
      "Run Auto-Attach": [
        "运行自动附加"
      ],
      "Run Repository Creation\\n      <i class=\\\"fa fa-spinner fa-spin\\\" ng-show=\\\"creating()\\\"></i>": [
        "运行仓库创建\\n      <i class=\\\"fa fa-spinner fa-spin\\\" ng-show=\\\"creating()\\\"></i>"
      ],
      "Run Sync Plan": [
        "运行同步计划"
      ],
      "Save": [
        "保存"
      ],
      "Save Successful.": [
        "保存成功。"
      ],
      "Schema Version": [
        "模式版本"
      ],
      "Schema Version 1": [
        "模式版本1"
      ],
      "Schema Version 2": [
        "模式版本2"
      ],
      "Security": [
        "安全"
      ],
      "Security Advisory": [
        "安全公告"
      ],
      "Select": [
        "选择"
      ],
      "Select a Content Source:": [
        "选择一个内容源："
      ],
      "Select Action": [
        "选择操作"
      ],
      "Select an Organization": [
        "现在一个机构"
      ],
      "Select Content Host(s)": [
        "选择内容主机"
      ],
      "Select Content View": [
        "选择内容视图"
      ],
      "Select this option if treeinfo files or other kickstart content is failing to syncronize from the upstream repository.": [
        "如果 treeinfo 文件或其他 kickstart 内容无法从上游存储库同步，请选择这个选项。"
      ],
      "Selecting \\\"Complete Sync\\\" will cause only yum/deb repositories of the selected product to be synced.": [
        "选择\\\"完成同步\\\"将导致仅所选产品的 yum/deb 存储库被同步。"
      ],
      "Selecting this option will exclude SRPMs from repository synchronization.": [
        "选择此选项将从存储库同步中排除 SRPM。"
      ],
      "Selecting this option will exclude treeinfo files from repository synchronization.": [
        "选择这个选项将从存储库同步中排除 treeinfo 文件。"
      ],
      "Selecting this option will result in Katello verifying that the upstream url's SSL certificates are signed by a trusted CA. Unselect if you do not want this verification.": [
        "选择此选项将导致Katello验证上游URL的SSL证书是否由受信任的CA签名。如果您不希望进行此验证，请取消选择。"
      ],
      "Service Level": [
        "服务等级"
      ],
      "Service Level (SLA)": [
        "服务等级 (SLA)"
      ],
      "Service Level (SLA):": [
        "服务等级 (SLA)："
      ],
      "Set Release Version": [
        "设置发行版本"
      ],
      "Severity": [
        "严重性"
      ],
      "Show All": [
        "显示所有"
      ],
      "Show all Repository Sets in Organization": [
        "显示组织中的所有仓库集"
      ],
      "Size": [
        "大小"
      ],
      "Skip dependency solving for a significant speed increase. If the update cannot be applied to the host, delete the incremental content view version and retry the application with dependency solving turned on.": [
        "跳过对显著增长速度的依赖关系。如果无法对主机应用更新，请删除增量内容视图版本，并在打开依赖项的情况下重试应用程序。"
      ],
      "Smart proxy currently reclaiming space...": [
        "智能代理当前正在重新声明空间..."
      ],
      "Smart proxy currently syncing to your locations...": [
        "智能代理当前正在同步到您的位置..."
      ],
      "Smart proxy is synchronized": [
        "智能代理已同步"
      ],
      "Sockets": [
        "插槽"
      ],
      "Solution": [
        "解决"
      ],
      "Some of the Errata shown below may not be installable as they are not in this Content Host's\\n        Content View and Lifecycle Environment.  In order to apply such Errata an Incremental Update is required.": [
        "下面显示的某些勘误可能无法安装，因为它们不在此内容主机的内容视图和生命周期环境中。为了应用此类勘误，需要进行增量更新。"
      ],
      "Something went wrong when deleting the resource.": [
        "删除资源时出错。"
      ],
      "Something went wrong when retrieving the resource.": [
        "获取资源时出错。"
      ],
      "Something went wrong when saving the resource.": [
        "保存资源时出错。"
      ],
      "Source RPM": [
        "源 RPM"
      ],
      "Source RPMs": [
        "來源 RPM"
      ],
      "Space reclamation is about to start...": [
        "重新声明空间即将开始..."
      ],
      "SSL CA Cert": [
        "SSL CA 证书"
      ],
      "SSL Certificate": [
        "SSL 证书"
      ],
      "SSL Client Cert": [
        "SSL 客户端证书"
      ],
      "SSL Client Key": [
        "Pulp 客户端密钥"
      ],
      "Standard sync, optimized for speed by bypassing any unneeded steps.": [
        "标准同步，通过绕过不需要的步骤来优化速度。"
      ],
      "Start Date": [
        "开始日期"
      ],
      "Start Time": [
        "起始时间"
      ],
      "Started At": [
        "起始于"
      ],
      "Starting": [
        "开始"
      ],
      "Starts": [
        "开始"
      ],
      "State": [
        "状态"
      ],
      "Status": [
        "状态"
      ],
      "Stream": [
        "流"
      ],
      "Subscription Details": [
        "订阅详情"
      ],
      "Subscription Management": [
        "订阅管理"
      ],
      "Subscription Status": [
        "订阅状态"
      ],
      "Subscription UUID": [
        "订阅 UUID"
      ],
      "Subscriptions": [
        "订阅"
      ],
      "Subscriptions for Activation Key:": [
        "激活码订阅："
      ],
      "Subscriptions for Content Host:": [
        "内容主机订阅："
      ],
      "Subscriptions for:": [
        "订阅："
      ],
      "Success!": [
        "成功！"
      ],
      "Successfully added %s subscriptions.": [
        "已成功新增 %s 个订阅。"
      ],
      "Successfully initiated restart of services.": [
        "成功启动服务重启。"
      ],
      "Successfully removed %s items.": [
        "成功删除 %s 个项。"
      ],
      "Successfully removed %s subscriptions.": [
        "成功删除 %s 个订阅。"
      ],
      "Successfully removed 1 item.": [
        "成功删除 1 个项。"
      ],
      "Successfully updated subscriptions.": [
        "成功更新的订阅。"
      ],
      "Successfully uploaded content:": [
        "成功上传的内容："
      ],
      "Summary": [
        "摘要"
      ],
      "Support Level": [
        "支持级别"
      ],
      "Sync": [
        "同步"
      ],
      "Sync Enabled": [
        "已启用同步"
      ],
      "Sync even if the upstream metadata appears to have no change. This option is only relevant for yum/deb repositories and will take longer than an optimized sync. Choose this option if:": [
        "即使上游元数据没有变化，也要同步。此选项仅与 yum/deb 仓库相关，并且比优化的同步花费的时间更长。如果出现以下情况，请选择此选项："
      ],
      "Sync Interval": [
        "同步间隔"
      ],
      "Sync Now": [
        "立即同步"
      ],
      "Sync Plan": [
        "同步计划"
      ],
      "Sync Plan %s has been deleted.": [
        "同步计划 %s 已删除。"
      ],
      "Sync Plan created and assigned to product.": [
        "同步计划已创建并分配给产品。"
      ],
      "Sync Plan Management": [
        "同步计划管理"
      ],
      "Sync Plan saved": [
        "同步计划已保存"
      ],
      "Sync Plan Saved": [
        "同步计划已保存"
      ],
      "Sync Plan:": [
        "同步计划："
      ],
      "Sync Plans": [
        "同步计划"
      ],
      "Sync Selected": [
        "同步计划已选定"
      ],
      "Sync Settings": [
        "同步设置"
      ],
      "Sync State": [
        "同步状态"
      ],
      "Sync Status": [
        "同步状态"
      ],
      "Synced manually, no interval set.": [
        "手动同步，未设置间隔。"
      ],
      "Synchronization is about to start...": [
        "同步即将开始..."
      ],
      "Synchronization is being cancelled...": [
        "同步正在取消..."
      ],
      "System Purpose": [
        "系统目的"
      ],
      "System purpose enables you to set the system's intended use on your network and improves reporting accuracy in the Subscriptions service of the Red Hat Hybrid Cloud Console.": [
        "系统目的用于设置系统在网络中的使用目的，以便在 Red Hat Hybrid Cloud Console 的订阅服务中提高报告准确性。"
      ],
      "System Purpose Management": [
        "系统目的管理"
      ],
      "System Purpose Status": [
        "系统目的"
      ],
      "Tags": [
        "标签"
      ],
      "Task Details": [
        "任务详情"
      ],
      "Tasks": [
        "任务"
      ],
      "Temporary": [
        "临时"
      ],
      "The <i>Registry Name Pattern</i> overrides the default name by which container images may be pulled from the server. (By default this name is a combination of Organization, Lifecycle Environment, Content View, Product, and Repository labels.)\\n\\n          <br><br>The name may be constructed using ERB syntax. Variables available for use are:\\n\\n          <pre>\\norganization.name\\norganization.label\\nrepository.name\\nrepository.label\\nrepository.docker_upstream_name\\ncontent_view.label\\ncontent_view.name\\ncontent_view_version.version\\nproduct.name\\nproduct.label\\nlifecycle_environment.name\\nlifecycle_environment.label</pre>\\n\\n          Examples:\\n            <pre>\\n&lt;%= organization.label %&gt;-&lt;%= lifecycle_environment.label %&gt;-&lt;%= content_view.label %&gt;-&lt;%= product.label %&gt;-&lt;%= repository.label %&gt;\\n&lt;%= organization.label %&gt;/&lt;%= repository.docker_upstream_name %&gt;</pre>": [
        "<i>Registry Name Pattern</i> 会覆盖容器镜像可能从服务器抓取的默认名称。（默认情况下，这个名称是一个组合了机构、生命周期环境、内容视图和仓库的标签）\\n\\n          <br><br>The name may be constructed using ERB syntax. Variables available for use are:\\n\\n          <pre>\\norganization.name\\norganization.label\\nrepository.name\\nrepository.label\\nrepository.docker_upstream_name\\ncontent_view.label\\ncontent_view.name\\ncontent_view_version.version\\nproduct.name\\nproduct.label\\nlifecycle_environment.name\\nlifecycle_environment.label</pre>\\n\\n          Examples:\\n            <pre>\\n&lt;%= organization.label %&gt;-&lt;%= lifecycle_environment.label %&gt;-&lt;%= content_view.label %&gt;-&lt;%= product.label %&gt;-&lt;%= repository.label %&gt;\\n&lt;%= organization.label %&gt;/&lt;%= repository.docker_upstream_name %&gt;</pre>"
      ],
      "The Content View or Lifecycle Environment needs to be updated in order to make errata available to these hosts.": [
        "需要更新内容视图或生命周期环境，以使勘误可用于这些主机。"
      ],
      "The filters below have this repository as the last affected repository!": [
        "以下过滤器将此存储库作为最后一个受影响的存储库！"
      ],
      "The following actions can be performed on content hosts in this host collection:": [
        "可以在此主机集合中的内容主机上执行以下操作："
      ],
      "The host has not reported any applicable packages for upgrade.": [
        "主机尚未报告任何适用的软件包进行升级。"
      ],
      "The host has not reported any installed packages, registering with subscription-manager should cause these to be reported.": [
        "主机尚未报告任何已安装的软件包，请向subscription-manager注册以报告这些软件包。"
      ],
      "The host requires being attached to a content view and the lifecycle environment you have chosen has no content views promoted to it.\\n              See the <a href=\\\"/content_views\\\">content views page</a> to manage and promote a content view.": [
        "主机需要附加到内容视图，并且您选择的生命周期环境没有提升为内容视图的内容。见<a href=\\\"/content_views\\\">内容观看页面</a>管理和提升内容视图。"
      ],
      "The maximum number of versions of each package to keep.": [
        "要保留的每个软件包的最大版本数。"
      ],
      "The page you are attempting to access requires selecting a specific organization.": [
        "您尝试访问的页面需要选择一个特定的机构。"
      ],
      "The remote execution feature is required to manage packages on this Host.": [
        "需要远程执行功能才能管理此主机上的程序包。"
      ],
      "The Remote Execution plugin needs to be installed in order to resolve Traces.": [
        "需要安装远程执行插件才能解决跟踪。"
      ],
      "The repository will only be available on content hosts with the selected architecture.": [
        "该存储库将仅在具有所选架构的内容主机上可用。"
      ],
      "The repository will only be available on content hosts with the selected OS version.": [
        "存储库仅在带有所选操作系统版本的内容主机上可用。"
      ],
      "The selected environment contains no Content Views, please select a different environment.": [
        "所选环境不包含“内容视图”，请选择其他环境。"
      ],
      "The time the sync should happen in your current time zone.": [
        "同步应该在您当前时区中发生的时间。"
      ],
      "The token key to use for authentication.": [
        "用于身份验证的令牌密钥。"
      ],
      "The URL to receive a session token from, e.g. used with Automation Hub.": [
        "从以下网址接收会话令牌的网址：与 Automation Hub 一起使用。"
      ],
      "There are {{ errataCount }} total Errata in this organization but none match the above filters.": [
        "该机构中有{{ errataCount }}个总勘误，但没有一个与上述过滤器匹配。"
      ],
      "There are {{ packageCount }} total Packages in this organization but none match the above filters.": [
        "此组织中有{{ packageCount }}个软件包，但没有与上述过滤器匹配的软件包。"
      ],
      "There are no %(contentType)s that match the criteria.": [
        "没有符合条件的%(contentType)s"
      ],
      "There are no Content Views in this Environment.": [
        "此环境中没有内容视图。"
      ],
      "There are no Content Views that match the criteria.": [
        "没有符合条件的内容视图。"
      ],
      "There are no Errata associated with this Content Host to display.": [
        "没有与此内容主机关联的勘误可供显示。"
      ],
      "There are no Errata in this organization.  Create one or more Products with Errata to view Errata on this page.": [
        "该组织中没有勘误。使用带有勘误的一个或多个产品以在此页面上查看勘误。"
      ],
      "There are no Errata to display.": [
        "没有要显示的勘误。"
      ],
      "There are no Host Collections available. You can create new Host Collections after selecting 'Host Collections' under 'Hosts' in main menu.": [
        "没有可用的主机集合。在主菜单的“主机”下选择“主机集合”后，可以创建新的主机集合。"
      ],
      "There are no Module Streams to display.": [
        "没有要显示的模块流。"
      ],
      "There are no Packages in this organization.  Create one or more Products with Packages to view Packages on this page.": [
        "该机构中没有软件包。创建带有软件包的一个或多个产品以在此页面上查看软件包。"
      ],
      "There are no Sync Plans available. You can create new Sync Plans after selecting 'Sync Plans' under 'Hosts' in main menu.": [
        "没有可用的同步计划。在主菜单中的“主机”下选择“同步计划”后，您可以创建新的同步计划。"
      ],
      "There are no Traces to display.": [
        "没有要显示的 Traces。"
      ],
      "There is currently an Incremental Update task in progress.  This update must finish before applying existing updates.": [
        "当前正在执行一个增量更新任务。在应用现有更新之前，此更新必须完成。"
      ],
      "These instructions will be removed in a future release. NEW: To register a content host without following these manual steps, see <a href=\\\"https://{{ katelloHostname }}/hosts/register\\\">Register Host</a>": [
        "这些说明将在以后的版本中删除。新增：要在不按照这些手动步骤注册内容主机，请参阅<a href=\\\"https://{{ katelloHostname }}/hosts/register\\\">注册主机</a>"
      ],
      "This action will affect only those Content Hosts that require a change.\\n        If the Content Host does not have the selected Subscription no action will take place.": [
        "此操作将仅影响那些需要更改的内容主机。如果内容主机没有所选的订阅，则不会执行任何操作。"
      ],
      "This activation key is not associated with any content hosts.": [
        "此激活码没有与任何内容主机关联。"
      ],
      "This activation key may be used during <a href=\\\"/hosts/register?initialAKSelection={{ activationKey.name }}\\\">system registration.</a>": [
        "这个激活码可用于在<a href=\\\"/hosts/register?initialAKSelection={{ activationKey.name }}\\\">系统注册</a>过程中使用。"
      ],
      "This change will be applied to <b>{{ hostCount }} systems.</b>": [
        "此更改将应用于 <b>{{ hostCount }}系统。</b>"
      ],
      "This Container Image Tag is not present in any Lifecycle Environments.": [
        "此容器镜像标记在任何生命周期环境中均不存在。"
      ],
      "This Container Image Tag is not present in any Repositories.": [
        "此容器镜像标签没有任何软件仓库。"
      ],
      "This operation may also remove managed resources linked to the host such as virtual machines and DNS records.\\n          Change the setting \\\"Delete Host upon Unregister\\\" to false on the <a href=\\\"/settings\\\">settings page</a> to prevent this.": [
        "此操作还可以删除链接到主机的受管资源，例如虚拟机和DNS记录。将“取消注册时删除主机”设置更改为false<a href=\\\"/settings\\\">设定页面</a>为了防止这种情况。"
      ],
      "This organization has Simple Content Access enabled.  Hosts are not required to have subscriptions attached to access repositories.": [
        "该机构已启用“简单内容访问”。不需要主机将订阅附加到访问仓库。"
      ],
      "This organization is not using <a target=\\\"_blank\\\" href=\\\"https://access.redhat.com/articles/simple-content-access\\\">Simple Content Access.</a> Entitlement-based subscription management is deprecated and will be removed in Katello 4.12.": [
        "这个机构没有使用 <a target=\\\"_blank\\\" href=\\\"https://access.redhat.com/articles/simple-content-access\\\">简单内容访问。</a>基于权利的订阅管理已弃用，并将在 Katello 4.12 版本中删除。"
      ],
      "Title": [
        "提示"
      ],
      "To register a content host to this server, follow these steps.": [
        "要将内容主机注册到此服务器，请按照下列步骤操作。"
      ],
      "Toggle Dropdown": [
        "切换下拉"
      ],
      "Token of the upstream repository user for authentication. Leave empty if repository does not require authentication.": [
        "用于认证的上游仓库用户的令牌。如果仓库不需要身份验证，则保留为空。"
      ],
      "Topic": [
        "主题"
      ],
      "Tracer helps administrators identify applications that need to be restarted after a system is patched.": [
        "跟踪器可帮助管理员识别修补系统后需要重新启动的应用程序。"
      ],
      "Traces": [
        "Traces"
      ],
      "Traces for:": [
        "Traces"
      ],
      "Turn on Setting > Content > Allow deleting repositories in published content views": [
        "打开 Setting > Content > Allow 在发布的内容视图中删除仓库"
      ],
      "Type": [
        "类型"
      ],
      "Unauthenticated Pull": [
        "未经身份验证的 pull 操作"
      ],
      "Unknown": [
        "未知"
      ],
      "Unlimited Content Hosts:": [
        "无限的内容主机："
      ],
      "Unlimited Hosts": [
        "无限的主机"
      ],
      "Unprotected": [
        "未受保护"
      ],
      "Unregister Host": [
        "取消注册主机"
      ],
      "Unregister Host \\\"{{host.display_name}}\\\"?": [
        "取消注册主机 \\\"{{host.display_name}}\\\"?"
      ],
      "Unregister Options:": [
        "取消注册选项："
      ],
      "Unregister the host as a subscription consumer.  Provisioning and configuration information is preserved.": [
        "取消将主机注册为订阅消费者。设置和配置信息将保留。"
      ],
      "Unsupported Type!": [
        "不支持的类型！"
      ],
      "Update": [
        "更新"
      ],
      "Update All Deb Packages": [
        "更新所有 Deb 软件包"
      ],
      "Update All Packages": [
        "更新所有软件包"
      ],
      "Update Packages": [
        "更新软件包"
      ],
      "Update Sync Plan": [
        "更新同步计划"
      ],
      "Updated": [
        "已更新"
      ],
      "Upgradable": [
        "可升级"
      ],
      "Upgradable For": [
        "可升级"
      ],
      "Upgradable Package": [
        "可升级包"
      ],
      "Upgrade Available": [
        "升级可用"
      ],
      "Upgrade Selected": [
        "升级所选"
      ],
      "Upload": [
        "上载"
      ],
      "Upload Content Credential file": [
        "上载内容凭证文件"
      ],
      "Upload File": [
        "上传文件"
      ],
      "Upload Package": [
        "上传软件包"
      ],
      "Upload Requirements": [
        "上传要求"
      ],
      "Upload Requirements.yml file <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'ansible_collection'\\\" uib-popover-html=\\\"requirementPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\">\\n        </a>": [
        "上载Requirements.yml文件 <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'ansible_collection'\\\" uib-popover-html=\\\"requirementPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\">\\n        </a>"
      ],
      "Uploading...": [
        "上载中..."
      ],
      "Upstream Authentication Token": [
        "上游验证令牌"
      ],
      "Upstream Authorization": [
        "上游授权"
      ],
      "Upstream Image Name": [
        "上游镜像名称"
      ],
      "Upstream Password": [
        "上游密码"
      ],
      "Upstream Repository Name": [
        "上游仓库名称"
      ],
      "Upstream URL": [
        "上游 URL"
      ],
      "Upstream Username": [
        "上游用户名"
      ],
      "Url": [
        "Url"
      ],
      "URL of the registry you want to sync. Example: https://registry-1.docker.io/ or https://quay.io/": [
        "您要同步的 registry 的URL。例如：https：//registry-1.docker.io/或https://quay.io/"
      ],
      "URL to Discover": [
        "发现 URL"
      ],
      "URL to the repository base. Example: http://ftp.de.debian.org/debian/ <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"debURLPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Upstream URL\\\">\\n        </a>": [
        "到仓库基础的 URL。示例：http://ftp.de.debian.org/debian/ <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"debURLPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Upstream URL\\\">\\n        </a>"
      ],
      "Usage Type": [
        "使用类型"
      ],
      "Usage Type:": [
        "使用类型："
      ],
      "Use specific HTTP Proxy": [
        "使用特定的 HTTP 代理"
      ],
      "Use the cancel button on content view selection to revert your lifecycle environment selection.": [
        "使用内容视图选择上的“取消”按钮可以还原生命周期环境选择。"
      ],
      "Used as": [
        "用作"
      ],
      "User": [
        "用户"
      ],
      "Username": [
        "用户名"
      ],
      "Username of the upstream repository user for authentication. Leave empty if repository does not require authentication.": [
        "用于认证的上游仓库用户的用户名。如果仓库不需要身份验证，则保留为空。"
      ],
      "Variant": [
        "变体"
      ],
      "Verify Content Checksum": [
        "验证内容校验和"
      ],
      "Verify SSL": [
        "验证 SSL"
      ],
      "Version": [
        "版本"
      ],
      "Version {{ cvVersions['version'] }}": [
        "版本 {{ cvVersions['version'] }}"
      ],
      "Versions": [
        "版本"
      ],
      "via remote execution": [
        "通过远程执行"
      ],
      "via remote execution - customize first": [
        "通过远程执行 - 首先进行自定义"
      ],
      "View Container Image Manifest Lists for Repository:": [
        "查看仓库的容器镜像清单列表："
      ],
      "View Docker Tags for Repository:": [
        "查看仓库的 Docker 标签："
      ],
      "View job invocations.": [
        "列出工作调用"
      ],
      "Virtual": [
        "虚拟"
      ],
      "Virtual Guest": [
        "虚拟客户系统"
      ],
      "Virtual Guests": [
        "虚拟客户系统"
      ],
      "Virtual Host": [
        "虚拟主机"
      ],
      "Warning: reclaiming space for an \\\"On Demand\\\" repository will delete all cached content units.  Take precaution when cleaning custom repositories whose upstream parents don't keep old package versions.": [
        "警告：为 \\\"On Demand\\\" 仓库重新声明空间将删除所有缓存的内容单元。在清理其上游父项没有保留旧软件包版本的自定义软件仓库时需要非常小心。"
      ],
      "weekly": [
        "每周"
      ],
      "Weekly on {{ product.sync_plan.sync_date | date:'EEEE' }} at {{ product.sync_plan.sync_date | date:'mediumTime' }} (Server Time)": [
        "每周 {{ product.sync_plan.sync_date | date:'EEEE' }}在 {{ product.sync_plan.sync_date | date:'mediumTime' }}（服务器时间）"
      ],
      "When Auto Attach is disabled, registering systems will be attached to all associated subscriptions.": [
        "禁用“自动附加”后，注册系统将附加到所有关联的订阅中。"
      ],
      "When Auto Attach is enabled, registering systems will be attached to all associated custom products and only associated Red Hat subscriptions required to satisfy the system's installed products.": [
        "启用自动附加后，注册系统将附加到所有相关自定义产品中，且只有相关的红帽订阅以满足系统安装的产品。"
      ],
      "Whitespace-separated list of components to sync (leave clear to sync all). Example: main <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"componentPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Components\\\">\\n        </a>": [
        "以空格分隔的要同步的组件列表（留空可以同步所有组件）。例如：<a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"componentPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Components\\\">\\n        </a>"
      ],
      "Whitespace-separated list of processor architectures to sync (leave clear to sync all). Example: amd64 <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"archPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Architectures\\\">\\n        </a>": [
        "空格分隔的要同步的处理器体系结构列表留空可以同步所有组件）。例如：amd64 <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"archPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Architectures\\\">\\n        </a>"
      ],
      "Whitespace-separated list of releases/distributions to sync (required for syncing). Example: buster <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"distPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Releases/Distributions\\\">\\n        </a>": [
        "空格分隔的发行版本/发行列表（同步需要）。示例： buster <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"distPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Releases/Distributions\\\">\\n        </a>"
      ],
      "Working": [
        "工作"
      ],
      "Yes": [
        "是"
      ],
      "You can upload a requirements.yml file above to auto-fill contents <b>OR</b> paste contents of <a ng-href=\\\"https://docs.ansible.com/ansible/latest/galaxy/user_guide.html#install-multiple-collections-with-a-requirements-file\\\" target=\\\"_blank\\\"> Requirements.yml </a>below.": [
        "您可以上传上面的 requirements.yml 文件以自动填充内容<b>或</b>粘贴下面的<a ng-href=\\\"https://docs.ansible.com/ansible/latest/galaxy/user_guide.html#install-multiple-collections-with-a-requirements-file\\\" target=\\\"_blank\\\">Requirements.yml</a>内容。"
      ],
      "You can upload a requirements.yml file below to auto-fill contents or paste contents of requirement.yml here": [
        "您可以上传下面的 requirements.yml 文件以自动填充内容，或在此处粘贴 requirement.yml 的内容"
      ],
      "You cannot remove content from a redhat repository": [
        "您无法从 redhat 存储库中删除内容"
      ],
      "You cannot remove these repositories because you do not have permission.": [
        "您无权删除这些仓库。"
      ],
      "You cannot remove this product because it has repositories that are the last affected repository on content view filters": [
        "您无法删除此产品，因为它具有在内容视图过滤中最后一个受影响的存储库的存储库"
      ],
      "You cannot remove this product because it is a Red Hat product.": [
        "您不能删除此产品，因为它是红帽产品。"
      ],
      "You cannot remove this product because it was published to a content view.": [
        "您无法删除此产品，因为它已发布到内容视图。"
      ],
      "You cannot remove this product because you do not have permission.": [
        "您无权删除此产品。"
      ],
      "You cannot remove this repository because you do not have permission.": [
        "您无权删除此仓库。"
      ],
      "You currently don't have any Activation Keys, you can add Activation Keys using the button on the right.": [
        "您目前没有任何激活码，可以使用右侧的按钮添加激活码。"
      ],
      "You currently don't have any Alternate Content Sources associated with this Content Credential.": [
        "您当前没有与此内容凭证关联的 Alternate 内容源。"
      ],
      "You currently don't have any Container Image Tags.": [
        "您目前没有任何内容视图。"
      ],
      "You currently don't have any Content Credential, you can add Content Credentials using the button on the right.": [
        "您目前没有任何内容凭据，您可以使用右侧的按钮添加内容凭据。"
      ],
      "You currently don't have any Content Hosts, you can create new Content Hosts by selecting Contents Host from main menu and then clicking the button on the right.": [
        "当前您没有任何内容主机，可以通过从主菜单中选择“内容主机”，然后单击右侧的按钮来创建新的内容主机。"
      ],
      "You currently don't have any Content Hosts, you can register one by clicking the button on the right and following the instructions.": [
        "您目前没有任何内容主机，您可以通过单击右侧的按钮并按照说明进行注册。"
      ],
      "You currently don't have any Files.": [
        "您目前没有任何内容视图。"
      ],
      "You currently don't have any Host Collections, you can add Host Collections using the button on the right.": [
        "您目前没有任何主机集合，您可以使用右侧的按钮添加主机集合。"
      ],
      "You currently don't have any Hosts in this Host Collection, you can add Content Hosts after selecting the 'Add' tab.": [
        "您目前在此主机集合中没有任何主机，可以在选择“添加”选项卡后添加内容主机。"
      ],
      "You currently don't have any Products associated with this Content Credential.": [
        "您目前没有与此内容证书关联的任何产品。"
      ],
      "You currently don't have any Products to subscribe to, you can add Products after selecting 'Products' under 'Content' in the main menu": [
        "您目前没有要订阅的产品，可以在主菜单中的“内容”下选择“产品”后添加产品"
      ],
      "You currently don't have any Products to subscribe to. You can add Products after selecting 'Products' under 'Content' in the main menu.": [
        "您目前没有要订阅的任何产品。您可以在主菜单中的“内容”下选择“产品”后添加产品。"
      ],
      "You currently don't have any Products<span bst-feature-flag=\\\"custom_products\\\">, you can add Products using the button on the right</span>.": [
        "您目前没有任何产品<span bst-feature-flag=\\\"custom_products\\\">，您可以使用右侧的按钮添加产品</span>。"
      ],
      "You currently don't have any Repositories associated with this Content Credential.": [
        "您目前没有与此内容证书关联的任何仓库。"
      ],
      "You currently don't have any Repositories included in this Product, you can add Repositories using the button on the right.": [
        "您目前没有此产品中包含的任何仓库，您可以使用右侧的按钮添加仓库。"
      ],
      "You currently don't have any Subscriptions associated with this Activation Key, you can add Subscriptions after selecting the 'Add' tab.": [
        "您目前没有与此激活码关联的任何订阅，可以在选择“添加”标签后添加订阅。"
      ],
      "You currently don't have any Subscriptions associated with this Content Host. You can add Subscriptions after selecting the 'Add' tab.": [
        "您目前没有与此内容主机关联的任何订阅。您可以在选择“添加”标签后添加订阅。"
      ],
      "You currently don't have any Sync Plans.  A Sync Plan can be created by using the button on the right.": [
        "您目前没有任何同步计划。可以使用右侧的按钮创建同步计划。"
      ],
      "You do not have any Installed Products": [
        "您没有任何安装的产品"
      ],
      "You must select a content view in order to save your environment.": [
        "您必须选择一个内容视图才能保存环境。"
      ],
      "You must select a new content view before your change of environment can be saved. Use the cancel button on content view selection to revert your environment selection.": [
        "必须先选择一个新的内容视图，然后才能保存环境更改。使用内容视图选择上的取消按钮可以还原您的环境选择。"
      ],
      "You must select a new content view before your change of lifecycle environment can be saved.": [
        "必须先选择一个新的内容视图，然后才能保存生命周期环境更改。"
      ],
      "You must select at least one Content Host in order to apply Errata.": [
        "您必须至少选择一个内容主机才能应用勘误。"
      ],
      "You must select at least one Errata to apply.": [
        "您必须至少选择一个勘误来应用。"
      ],
      "Your search returned zero %(contentType)s that match the criteria.": [
        "您的搜索返回零个%(contentType)s符合条件"
      ],
      "Your search returned zero Activation Keys.": [
        "您的搜索返回了零个激活码。"
      ],
      "Your search returned zero Container Image Tags.": [
        "您的搜索返回了零个容器镜像标签。"
      ],
      "Your search returned zero Content Credential.": [
        "您的搜索返回了零个内容凭证。"
      ],
      "Your search returned zero Content Hosts.": [
        "您的搜索返回了零个内容主机。"
      ],
      "Your search returned zero Content Views": [
        "您的搜索返回了零个内容视图"
      ],
      "Your search returned zero Content Views.": [
        "您的搜索返回了零个内容视图。"
      ],
      "Your search returned zero Deb Packages.": [
        "您的搜索返回了零个 Deb 软件包。"
      ],
      "Your search returned zero Debs.": [
        "您的搜索返回了零个 Debs。"
      ],
      "Your search returned zero Errata.": [
        "您的搜索返回了零个勘误。"
      ],
      "Your search returned zero Erratum.": [
        "您的搜索返回了零个勘误。"
      ],
      "Your search returned zero Files.": [
        "您的搜索返回了零个文件。"
      ],
      "Your search returned zero Host Collections.": [
        "您的搜索返回了零个主机集合。"
      ],
      "Your search returned zero Hosts.": [
        "您的搜索返回了零个主机。"
      ],
      "Your search returned zero Lifecycle Environments.": [
        "您的搜索返回了零个生命周期环境。"
      ],
      "Your search returned zero Module Streams.": [
        "您的搜索返回了零个模块流。"
      ],
      "Your search returned zero Packages.": [
        "您的搜索返回了零个软件包。"
      ],
      "Your search returned zero Products.": [
        "您的搜索返回了零个产品。"
      ],
      "Your search returned zero Repositories": [
        "您的搜索返回了零个仓库"
      ],
      "Your search returned zero Repositories.": [
        "您的搜索返回了零个仓库。"
      ],
      "Your search returned zero repository sets.": [
        "您的搜索返回了零个仓库集。"
      ],
      "Your search returned zero Repository Sets.": [
        "您的搜索返回了零个仓库集。"
      ],
      "Your search returned zero results.": [
        "您的搜索返回了零个结果。"
      ],
      "Your search returned zero Subscriptions.": [
        "您的搜索返回了零个订阅。"
      ],
      "Your search returned zero Sync Plans.": [
        "您的搜索返回了零个同步计划。"
      ],
      "Your search returned zero Traces.": [
        "您的搜索返回了零个 Traces。"
      ],
      "Yum Metadata Checksum": [
        "Yum 元数据校验和"
      ],
      "Yum metadata generation has been initiated in the background.  Click <a href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        "Yum元数据生成已在后台启动。请点击<a href=\\\"{{ taskUrl() }}\\\">这里</a>监视进度。"
      ],
      "Yum Repositories <div>{{ library.counts.yum_repositories || 0 }}</div>": [
        "Yum 仓库 <div>{{ library.counts.yum_repositories || 0 }}</div>"
      ]
    }
  }
};
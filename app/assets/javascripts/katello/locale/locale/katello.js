 locales['katello'] = locales['katello'] || {}; locales['katello']['locale'] = {
  "domain": "katello",
  "locale_data": {
    "katello": {
      "": {
        "Project-Id-Version": "",
        "Last-Translator": "Bryan Kearney <bryan.kearney@gmail.com>, 2022",
        "Language-Team": "Chinese (Taiwan) (https://www.transifex.com/foreman/teams/114/zh_TW/)",
        "Content-Type": "text/plain; charset=UTF-8",
        "Content-Transfer-Encoding": "8bit",
        "Language": "zh_TW",
        "Plural-Forms": "nplurals=1; plural=0;",
        "lang": "locale",
        "domain": "katello",
        "plural_forms": "nplurals=1; plural=0;"
      },
      "-- select an interval --": [
        "-- 選擇一個間隔 --"
      ],
      "(future)": [
        ""
      ],
      "{{ 'Add Selected' | translate }}": [
        "{{ 'Add Selected' | 新增選擇 }}"
      ],
      "{{ contentCredential.name }}": [
        ""
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
        "{{ errata.hosts_applicable_count || 0 }} 可套用，"
      ],
      "{{ errata.hosts_available_count || 0 }} Installable": [
        "{{ errata.hosts_available_count || 0 }} 可安裝"
      ],
      "{{ errata.title }}": [
        ""
      ],
      "{{ file.name }}": [
        ""
      ],
      "{{ host.name }}": [
        ""
      ],
      "{{ host.subscription_facet_attributes.user.login }}": [
        ""
      ],
      "{{ installedDebCount }} Host(s)": [
        ""
      ],
      "{{ installedPackageCount }} Host(s)": [
        ""
      ],
      "{{ package.hosts_applicable_count }} Host(s)": [
        ""
      ],
      "{{ package.hosts_applicable_count || 0 }} Applicable,": [
        ""
      ],
      "{{ package.hosts_available_count }} Host(s)": [
        ""
      ],
      "{{ package.hosts_available_count || 0 }} Upgradable": [
        ""
      ],
      "{{ package.human_readable_size }} ({{ package.size }} Bytes)": [
        ""
      ],
      "{{ product.active_task_count }}": [
        ""
      ],
      "{{ product.name }}": [
        ""
      ],
      "{{ repository.content_counts.ansible_collection || 0 }} Ansible Collections": [
        ""
      ],
      "{{ repository.content_counts.deb || 0 }} deb Packages": [
        ""
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
        "{{ repository.content_counts.erratum || 0 }} 個勘誤"
      ],
      "{{ repository.content_counts.file || 0 }} Files": [
        ""
      ],
      "{{ repository.content_counts.rpm || 0 }} Packages": [
        "{{ repository.content_counts.rpm || 0 }} 個套件"
      ],
      "{{ repository.content_counts.srpm }} Source RPMs": [
        ""
      ],
      "{{ repository.last_sync_words }} ago": [
        "{{ repository.last_sync_words }} 前"
      ],
      "{{ repository.name }}": [
        ""
      ],
      "{{ type.display }}": [
        "{{ type.display }}"
      ],
      "{{header}}": [
        ""
      ],
      "{{option.description}}": [
        ""
      ],
      "{{urlDescription}}": [
        ""
      ],
      "* These marked Content View Versions are from Composite Content Views.  Their components needing updating are listed underneath.": [
        "* 這些被標記的內容視域來自於複合式內容視域。它們需要更新的元件列在下方。"
      ],
      "/foreman_tasks/tasks/%taskId": [
        ""
      ],
      "/job_invocations": [
        ""
      ],
      "%(consumed)s out of %(quantity)s": [
        "%(consumed)s，總數為 %(quantity)s"
      ],
      "%count environment(s) can be synchronized: %envs": [
        "%count 個環境可以被同步：%envs"
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
        ""
      ],
      "1 repository sync has errors.": [
        ""
      ],
      "1 repository sync in progress.": [
        "1 個軟體庫同步正在進行中。"
      ],
      "1 successfully synced repository.": [
        "1 個軟體庫已成功同步。"
      ],
      "A comma-separated list of container image tags to exclude when syncing. Source images are excluded by default because they are often large and unwanted.": [
        ""
      ],
      "A comma-separated list of container image tags to include when syncing.": [
        ""
      ],
      "A sync has been initiated in the background, <a href=\\\"/foreman_tasks/tasks/{{ task.id }}\\\">click for more details</a>": [
        ""
      ],
      "Account": [
        "帳號"
      ],
      "Action Type": [
        "動作類型"
      ],
      "Actions": [
        "動作"
      ],
      "Activation Key": [
        "啟動金鑰"
      ],
      "Activation Key Content": [
        "啟動金鑰的內容"
      ],
      "Activation Key removed.": [
        "啟動金鑰已移除。"
      ],
      "Activation Key updated": [
        "啟動金鑰已更新"
      ],
      "Activation Key:": [
        "啟動金鑰："
      ],
      "Activation Keys": [
        "啟動金鑰"
      ],
      "Active Tasks": [
        ""
      ],
      "Add": [
        "新增"
      ],
      "Add Content Hosts to:": [
        "新增內容主機至："
      ],
      "Add hosts to the host collection to see available actions.": [
        ""
      ],
      "Add New Environment": [
        "新增環境"
      ],
      "Add ons": [
        ""
      ],
      "Add ons:": [
        ""
      ],
      "Add Selected": [
        "加入選擇的項目"
      ],
      "Add Subscriptions for Activation Key:": [
        "為啟動金鑰新增訂閱："
      ],
      "Add Subscriptions for Content Host:": [
        "為內容主機新增訂閱："
      ],
      "Add To": [
        "加至"
      ],
      "Added %x host collections to activation key \\\"%y\\\".": [
        "已新增 %x 主機集項目至啟動金鑰「%y」。"
      ],
      "Added %x host collections to content host \\\"%y\\\".": [
        "已新增 %x 主機集項目至內容主機「%y」。"
      ],
      "Added %x products to sync plan \\\"%y\\\".": [
        "已新增 %x 產品至同步計畫「%y」。"
      ],
      "Adding Lifecycle Environment to the end of \\\"{{ priorEnvironment.name }}\\\"": [
        "新增生命週期環境至 \\\"{{ priorEnvironment.name }}\\\" 之後"
      ],
      "Additive": [
        ""
      ],
      "Advanced Sync": [
        ""
      ],
      "Advisory": [
        "諮詢"
      ],
      "Affected Hosts": [
        "受影響的主機"
      ],
      "All Content Views": [
        "所有內容視域"
      ],
      "All Lifecycle Environments": [
        ""
      ],
      "All Repositories": [
        "所有軟體庫"
      ],
      "Alternate Content Sources": [
        ""
      ],
      "Alternate Content Sources for": [
        ""
      ],
      "An error occured: %s": [
        ""
      ],
      "An error occurred initiating the sync:": [
        ""
      ],
      "An error occurred removing the Activation Key:": [
        "移除啟動金鑰時發生錯誤："
      ],
      "An error occurred removing the content hosts.": [
        "移除內容主機時發生錯誤："
      ],
      "An error occurred removing the environment:": [
        "移除環境時發生錯誤："
      ],
      "An error occurred removing the Host Collection:": [
        "移除主機集項目時發生錯誤："
      ],
      "An error occurred removing the subscriptions.": [
        "移除訂閱時發生錯誤："
      ],
      "An error occurred saving the Activation Key:": [
        "儲存啟動金鑰時發生錯誤："
      ],
      "An error occurred saving the Content Host:": [
        "儲存內容主機時發生錯誤："
      ],
      "An error occurred saving the Environment:": [
        "儲存環境時發生了錯誤："
      ],
      "An error occurred saving the Host Collection:": [
        "儲存主機集項目時發生錯誤："
      ],
      "An error occurred saving the Product:": [
        "儲存產品時發生錯誤："
      ],
      "An error occurred saving the Repository:": [
        "儲存軟體庫時發生錯誤："
      ],
      "An error occurred saving the Sync Plan:": [
        "儲存同步計畫時發生錯誤："
      ],
      "An error occurred trying to auto-attach subscriptions.  Please check your log for further information.": [
        "試圖自動連接訂閱服務時發生錯誤。請檢查日誌檔，以取得進一步訊息。"
      ],
      "An error occurred updating the sync plan:": [
        ""
      ],
      "An error occurred while creating the Content Credential:": [
        ""
      ],
      "An error occurred while creating the Product: %s": [
        ""
      ],
      "An error occurred:": [
        ""
      ],
      "Ansible Collection Authorization": [
        ""
      ],
      "Ansible Collections": [
        ""
      ],
      "Applicable": [
        "可套用"
      ],
      "Applicable Content Hosts": [
        ""
      ],
      "Applicable Deb Packages": [
        ""
      ],
      "Applicable Errata": [
        "可套用勘誤"
      ],
      "Applicable Packages": [
        "套件"
      ],
      "Applicable To": [
        ""
      ],
      "Applicable to Host": [
        ""
      ],
      "Application": [
        "應用程式"
      ],
      "Apply": [
        "套用"
      ],
      "Apply {{ errata.errata_id }}": [
        "套用 {{ errata.errata_id }}"
      ],
      "Apply {{ errata.errata_id }} to {{ contentHostIds.length  }} Content Host(s)?": [
        ""
      ],
      "Apply {{ errata.errata_id }} to all Content Host(s)?": [
        ""
      ],
      "Apply {{ errataIds.length }} Errata to {{ contentHostIds.length }} Content Host(s)?": [
        ""
      ],
      "Apply {{ errataIds.length }} Errata to all Content Host(s)?": [
        ""
      ],
      "Apply Errata": [
        "套用勘誤"
      ],
      "Apply Errata to Content Host \\\"{{host.name}}\\\"?": [
        "是否要套用勘誤至內容主機 \\\"{{host.name}}\\\"？"
      ],
      "Apply Errata to Content Hosts": [
        "套用勘誤至內容主機"
      ],
      "Apply Errata to Content Hosts immediately after publishing.": [
        "發佈後即刻套用勘誤至內容主機。"
      ],
      "Apply Selected": [
        "套用所選項目"
      ],
      "Apply to Content Hosts": [
        "套用內容主機"
      ],
      "Apply to Hosts": [
        "套用至主機"
      ],
      "Applying": [
        "正在套用"
      ],
      "Apt Actions": [
        ""
      ],
      "Arch": [
        "架構"
      ],
      "Architecture": [
        "架構"
      ],
      "Architectures": [
        "架構"
      ],
      "Are you sure you want to add the {{ table.numSelected }} content host(s) selected to the host collection(s) chosen?": [
        "確定要新增所選的 {{ table.numSelected }} 部內容主機至選擇的主機集項目中？"
      ],
      "Are you sure you want to add the sync plan to the selected products(s)?": [
        ""
      ],
      "Are you sure you want to apply Errata to content host \\\"{{ host.name }}\\\"?": [
        "確定要套用勘誤至內容主機 \\\"{{ host.name }}\\\"？"
      ],
      "Are you sure you want to apply the {{ table.numSelected }} selected errata to the content hosts chosen?": [
        ""
      ],
      "Are you sure you want to assign the {{ table.numSelected }} content host(s) selected to {{ selected.contentView.name }} in {{ selected.environment.name }}?": [
        "確定要指定所選的 {{ table.numSelected }} 部內容主機至 {{ selected.environment.name }} 的 {{ selected.contentView.name }}？"
      ],
      "Are you sure you want to delete the {{ table.numSelected }} host(s) selected?": [
        ""
      ],
      "Are you sure you want to disable the {{ table.numSelected }} repository set(s) chosen?": [
        ""
      ],
      "Are you sure you want to enable the {{ table.numSelected }} repository set(s) chosen?": [
        ""
      ],
      "Are you sure you want to install {{ content.content }} on the {{ getSelectedSystemIds().length }} system(s) selected?": [
        "確定要在所選的 {{ getSelectedSystemIds().length }} 部系統上安裝 {{ content.content }}？"
      ],
      "Are you sure you want to remove {{ content.content }} from the {{ getSelectedSystemIds().length }} system(s) selected?": [
        "確定要從所選擇的 {{ getSelectedSystemIds().length }} 部系統中移除 {{ content.content }}？"
      ],
      "Are you sure you want to remove Activation Key \\\"{{ activationKey.name }}\\\"?": [
        "確定要移除啟動金鑰 \\\"{{ activationKey.name }}\\\"？"
      ],
      "Are you sure you want to remove Content Credential {{ contentCredential.name }}?": [
        ""
      ],
      "Are you sure you want to remove environment {{ environment.name }}?": [
        ""
      ],
      "Are you sure you want to remove Host Collection \\\"{{ hostCollection.name }}\\\"?": [
        "確定要移除主機集項目 \\\"{{ hostCollection.name }}\\\"？"
      ],
      "Are you sure you want to remove product \\\"{{ product.name }}\\\"?": [
        "確定要移除產品 \\\"{{ product.name }}\\\"？"
      ],
      "Are you sure you want to remove repository {{ repositoryWrapper.repository.name }} from all content views?": [
        ""
      ],
      "Are you sure you want to remove Sync Plan \\\"{{ syncPlan.name }}\\\"?": [
        "確定要移除同步計畫 \\\"{{ syncPlan.name }}\\\"？"
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} content unit?": [
        ""
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} file?": [
        ""
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} package?": [
        ""
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} product?": [
        ""
      ],
      "Are you sure you want to remove the {{ table.getSelected()[0].name }} repository?": [
        ""
      ],
      "Are you sure you want to remove the {{ table.numSelected }} Container Image manifest selected?": [
        ""
      ],
      "Are you sure you want to remove the {{ table.numSelected }} content host(s) selected from the host collection(s) chosen?": [
        "確定要從所選擇的主機集項目中移除所選擇的 {{ table.numSelected }} 部內容主機？"
      ],
      "Are you sure you want to remove the sync plan from the selected product(s)?": [
        ""
      ],
      "Are you sure you want to reset to default the {{ table.numSelected }} repository set(s) chosen?": [
        ""
      ],
      "Are you sure you want to restart services on content host \\\"{{ host.name }}\\\"?": [
        ""
      ],
      "Are you sure you want to restart the services on the selected content hosts?": [
        ""
      ],
      "Are you sure you want to set the HTTP Proxy to the selected products(s)?": [
        ""
      ],
      "Are you sure you want to set the Release Version the {{ table.numSelected }} content host(s) selected to {{ selected.release }}?. This action will affect only those Content Hosts that belong to the appropriate Content View and Lifecycle Environment containining that release version.": [
        ""
      ],
      "Are you sure you want to update {{ content.content }} on the {{ getSelectedSystemIds().length }} system(s) selected?": [
        "確定要在所選的 {{ getSelectedSystemIds().length }} 部系統上更新 {{ content.content }}？"
      ],
      "Are you sure you want to update all packages on the {{ getSelectedSystemIds().length }} system(s) selected?": [
        ""
      ],
      "Assign": [
        "指定"
      ],
      "Assign Lifecycle Environment and Content View": [
        ""
      ],
      "Assign Release Version": [
        ""
      ],
      "Assign System Purpose": [
        ""
      ],
      "Associations": [
        "相聯性"
      ],
      "At least one Errata needs to be selected to Apply.": [
        "需要選擇至少一項勘誤來套用。"
      ],
      "Attached": [
        "已連接"
      ],
      "Auth Token": [
        ""
      ],
      "Auth URL": [
        ""
      ],
      "Author": [
        "作者"
      ],
      "Auto-Attach": [
        "自動連接"
      ],
      "Auto-Attach Details": [
        ""
      ],
      "Automatic": [
        "自動"
      ],
      "Available Module Streams": [
        ""
      ],
      "Available Schema Versions": [
        ""
      ],
      "Back To Errata List": [
        "回到勘誤清單"
      ],
      "Backend Identifier": [
        ""
      ],
      "Basic Information": [
        "基本資訊"
      ],
      "Below are the repository content sets currently available for this content host through its subscriptions. For Red Hat subscriptions, additional content can be made available through the": [
        "以下是目前可以讓此內容透過其訂閱來使用的軟體庫內容。Red Hat 訂閱的額外內容可透過這裡取得："
      ],
      "Below are the Repository Sets currently available for this activation key through its subscriptions. For Red Hat subscriptions, additional content can be made available through the": [
        ""
      ],
      "BIOS UUID": [
        ""
      ],
      "Bootable": [
        "可開機"
      ],
      "Bug Fix": [
        "錯誤修正"
      ],
      "Bug Fix Advisory": [
        "錯誤修正諮詢"
      ],
      "Build Host": [
        "組建主機"
      ],
      "Build Information": [
        ""
      ],
      "Build Time": [
        "組建時間"
      ],
      "Cancel": [
        "取消"
      ],
      "Cannot clean Repository without the proper permissions.": [
        ""
      ],
      "Cannot clean Repository, a sync is already in progress.": [
        ""
      ],
      "Cannot Remove": [
        ""
      ],
      "Cannot republish Repository without the proper permissions.": [
        ""
      ],
      "Cannot republish Repository, a sync is already in progress.": [
        ""
      ],
      "Cannot sync Repository without a URL.": [
        ""
      ],
      "Cannot sync Repository without the proper permissions.": [
        ""
      ],
      "Cannot sync Repository, a sync is already in progress.": [
        ""
      ],
      "Capacity": [
        "容量"
      ],
      "Certificate": [
        "憑證"
      ],
      "Change assigned Lifecycle Environment or Content View": [
        "變更已指定的生命週期環境或內容視域"
      ],
      "Change Host Collections": [
        ""
      ],
      "Change Lifecycle Environment": [
        ""
      ],
      "Changing default settings for content hosts that register with this activation key requires subscription-manager version 1.10 or newer to be installed on that host.": [
        "為向此註冊金鑰註冊的內容主機改變預設設定，需要在那台主機上安裝 1.10 以上版本的 subscription-manager。"
      ],
      "Changing default settings requires subscription-manager version 1.10 or newer to be installed on this host.": [
        "改變預設設定需要在此主機上安裝 1.10 以上版本的 subscription-manager。"
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
        "Checksum 類型"
      ],
      "Choose one of the registry options to discover containers. To examine a private registry choose \\\"Custom\\\" and provide the url for the private registry.": [
        ""
      ],
      "Click here to check the status of the task.": [
        "點選此處以檢查任務的狀態。"
      ],
      "Click here to select Errata for an Incremental Update.": [
        "點選此處以選擇勘誤進行遞增更新。"
      ],
      "Click to monitor task progress.": [
        ""
      ],
      "Click to view task": [
        ""
      ],
      "Close": [
        "關閉"
      ],
      "Collection Name": [
        ""
      ],
      "Complete Mirroring": [
        ""
      ],
      "Complete Sync": [
        ""
      ],
      "Completed {{ repository.last_sync_words }} ago": [
        ""
      ],
      "Completely deletes the host including VM and disks, and removes all reporting, provisioning, and configuration information.": [
        ""
      ],
      "Components": [
        "元件"
      ],
      "Components:": [
        "元件："
      ],
      "Composite View": [
        "複合視域"
      ],
      "Confirm": [
        "確認"
      ],
      "Confirm services restart": [
        ""
      ],
      "Container Image Manifest": [
        ""
      ],
      "Container Image Manifest Lists": [
        ""
      ],
      "Container Image Manifests": [
        ""
      ],
      "Container Image metadata generation has been initiated in the background.  Click\\n      <a ng-href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        ""
      ],
      "Container Image Registry": [
        ""
      ],
      "Container Image Tags": [
        ""
      ],
      "Content": [
        "內容"
      ],
      "Content Counts": [
        "內容的數量"
      ],
      "Content Credential %s has been created.": [
        ""
      ],
      "Content Credential Contents": [
        ""
      ],
      "Content Credential successfully uploaded": [
        ""
      ],
      "Content credential updated": [
        ""
      ],
      "Content Credentials": [
        ""
      ],
      "Content Host": [
        "內容主機"
      ],
      "Content Host Bulk Content": [
        "內容主機的大批內容"
      ],
      "Content Host Bulk Subscriptions": [
        "內容主機的大批訂閱"
      ],
      "Content Host Content": [
        "內容主機的內容"
      ],
      "Content Host Counts": [
        "內容主機計數"
      ],
      "Content Host Limit": [
        "內容主機的限制"
      ],
      "Content Host Properties": [
        "內容主機的屬性"
      ],
      "Content Host Registration": [
        "內容主機的註冊"
      ],
      "Content Host Status": [
        "內容主機的狀態"
      ],
      "Content Host:": [
        "{{ contentHost.name }"
      ],
      "Content Hosts": [
        "內容主機"
      ],
      "Content Hosts for Activation Key:": [
        "給啟動金鑰的內容主機："
      ],
      "Content Hosts for:": [
        "給以下使用的內容主機："
      ],
      "Content Only": [
        ""
      ],
      "Content synced depends on the specifity of the URL and/or the optional requirements.yaml specified below <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'ansible_collection'\\\" uib-popover-html=\\\"collectionURLPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Upstream URL\\\">\\n        </a>": [
        ""
      ],
      "Content Type": [
        "內容類型"
      ],
      "Content View": [
        "內容視域"
      ],
      "Content View Version": [
        "內容視域版本"
      ],
      "Content View:": [
        "內容視域："
      ],
      "Content Views": [
        "內容視域"
      ],
      "Content Views <div>{{ library.counts.content_views || 0 }}</div>": [
        "內容視域 <div>{{ library.counts.content_views || 0 }}</div>"
      ],
      "Content Views for Deb:": [
        ""
      ],
      "Content Views for File:": [
        ""
      ],
      "Content Views that contain this Deb": [
        ""
      ],
      "Content Views that contain this File": [
        ""
      ],
      "Context": [
        "內容"
      ],
      "Contract": [
        "合約"
      ],
      "Copy Activation Key": [
        "複製啟動金鑰"
      ],
      "Copy Host Collection": [
        ""
      ],
      "Cores per Socket": [
        "每個插槽的核心數"
      ],
      "Create": [
        "建立"
      ],
      "Create a copy of {{ activationKey.name }}": [
        ""
      ],
      "Create a copy of {{ hostCollection.name }}": [
        ""
      ],
      "Create Activation Key": [
        "建立啟動金鑰"
      ],
      "Create Content Credential": [
        ""
      ],
      "Create Discovered Repositories": [
        ""
      ],
      "Create Environment Path": [
        ""
      ],
      "Create Host Collection": [
        ""
      ],
      "Create Product": [
        ""
      ],
      "Create Selected": [
        "建立所選項目"
      ],
      "Create Status": [
        ""
      ],
      "Create Sync Plan": [
        "建立同步計畫"
      ],
      "Creating repository...": [
        ""
      ],
      "Critical": [
        "重要"
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
        "供啟動金鑰使用的現有訂閱："
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
        "CVE"
      ],
      "daily": [
        "每日"
      ],
      "Daily at {{ product.sync_plan.sync_date | date:'mediumTime' }} (Server Time)": [
        "每日的 {{ product.sync_plan.sync_date | date:'mediumTime' }}（伺服器時間）"
      ],
      "Date": [
        "日期"
      ],
      "deb metadata generation has been initiated in the background.  Click <a href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        ""
      ],
      "deb Package Updates": [
        ""
      ],
      "deb Packages": [
        ""
      ],
      "Deb Packages": [
        ""
      ],
      "Deb Packages <div>{{ library.counts.debs || 0 }}</div>": [
        ""
      ],
      "Deb Packages for:": [
        ""
      ],
      "Deb Repositories <div>{{ library.counts.deb_repositories || 0 }}</div>": [
        ""
      ],
      "Deb:": [
        ""
      ],
      "Default": [
        "預設值"
      ],
      "Default Status": [
        ""
      ],
      "Delete": [
        "刪除"
      ],
      "Delete {{ table.numSelected  }} Hosts?": [
        ""
      ],
      "Delete Hosts": [
        "刪除主機"
      ],
      "Delta RPM": [
        ""
      ],
      "Dependencies": [
        "相依性"
      ],
      "Description": [
        "描述"
      ],
      "Details": [
        "詳細資料"
      ],
      "Details for Activation Key:": [
        "啟動金鑰的詳細資料："
      ],
      "Details for Container Image Tag:": [
        ""
      ],
      "Details for Product:": [
        "產品的詳細資料："
      ],
      "Details for Repository:": [
        ""
      ],
      "Determines whether to require login to pull container images in this lifecycle environment.": [
        ""
      ],
      "Digest": [
        "消化"
      ],
      "Disable": [
        "停用"
      ],
      "Disabled": [
        "已停用"
      ],
      "Disabled (overridden)": [
        ""
      ],
      "Discover": [
        "尋找"
      ],
      "Discovered Repository": [
        ""
      ],
      "Discovery failed. Error: %s": [
        ""
      ],
      "Distribution": [
        "發行套件"
      ],
      "Distribution Information": [
        "散佈資訊"
      ],
      "Do not require a subscription entitlement certificate for accessing this repository.": [
        ""
      ],
      "Docker metadata generation has been initiated in the background.  Click\\n            <a ng-href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        ""
      ],
      "Docker Repositories <div>{{ library.counts.docker_repositories || 0 }}</div>": [
        "Docker 軟體庫 <div>{{ library.counts.docker_repositories || 0 }}</div>"
      ],
      "Done": [
        "完成"
      ],
      "Download Policy": [
        "下載政策"
      ],
      "Enable": [
        "啟用"
      ],
      "Enable Traces": [
        ""
      ],
      "Enabled": [
        "已啟用"
      ],
      "Enabled (overridden)": [
        ""
      ],
      "Enhancement": [
        "增強"
      ],
      "Enter Package Group Name(s)...": [
        "輸入套件群組名稱……"
      ],
      "Enter Package Name(s)...": [
        "輸入套件名稱……"
      ],
      "Environment": [
        "環境"
      ],
      "Environment saved": [
        "環境已儲存"
      ],
      "Environment will also be removed from the following published content views!": [
        ""
      ],
      "Environments List": [
        "環境清單"
      ],
      "Errata": [
        "勘誤"
      ],
      "Errata <div>{{ library.counts.errata.total || 0 }}</div>": [
        "勘誤 <div>{{ library.counts.errata.total || 0 }}</div>"
      ],
      "Errata are automatically Applicable if they are Installable": [
        ""
      ],
      "Errata Details": [
        "勘誤的詳細資料"
      ],
      "Errata for:": [
        "給以下使用的勘誤："
      ],
      "Errata ID": [
        "勘誤 ID"
      ],
      "Errata Installation": [
        "安裝勘誤"
      ],
      "Errata Task List": [
        "勘誤任務清單"
      ],
      "Errata Tasks": [
        "勘誤任務"
      ],
      "Errata:": [
        "勘誤："
      ],
      "Error during upload:": [
        "上傳時發生錯誤。"
      ],
      "Error saving the Sync Plan:": [
        ""
      ],
      "Event": [
        "事件"
      ],
      "Exclude Tags": [
        ""
      ],
      "Existing Product": [
        "既有的產品"
      ],
      "Expires": [
        "有效期限"
      ],
      "Export": [
        "匯出"
      ],
      "Family": [
        "家族"
      ],
      "File Information": [
        "檔案資訊"
      ],
      "File removal been initiated in the background.  Click <a href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        ""
      ],
      "File too large.": [
        ""
      ],
      "File too large. Please use the CLI instead.": [
        "檔案太大。請使用 CLI 來代替。"
      ],
      "File:": [
        ""
      ],
      "Filename": [
        "檔案名稱"
      ],
      "Files": [
        "檔案"
      ],
      "Files in package {{ package.nvrea }}": [
        ""
      ],
      "Filter": [
        "篩選器"
      ],
      "Filter by Status:": [
        ""
      ],
      "Filter...": [
        "篩選器……"
      ],
      "Finished At": [
        "完成於"
      ],
      "For older operating systems such as Red Hat Enterprise Linux 5 or CentOS 5 it is recommended to use sha1.": [
        "建議在較舊的作業系統上（例如 Red Hat Enterprise Linux 5 或是 CentOS 5）使用 sha1。"
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
        "GPG 金鑰"
      ],
      "Group": [
        "群組"
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
        "客座"
      ],
      "Helper": [
        ""
      ],
      "Host %s has been deleted.": [
        ""
      ],
      "Host %s has been unregistered.": [
        ""
      ],
      "Host Collection Management": [
        "管理主機集"
      ],
      "Host Collection Membership": [
        "主機集的成員"
      ],
      "Host Collection removed.": [
        "已移除主機集。"
      ],
      "Host Collection updated": [
        "已更新主機集"
      ],
      "Host Collection:": [
        "主機集："
      ],
      "Host Collections": [
        "主機集"
      ],
      "Host Collections for:": [
        "給以下使用的主機集："
      ],
      "Host Count": [
        "主機計數"
      ],
      "Host Group": [
        "主機群組"
      ],
      "Host Limit": [
        "主機限制"
      ],
      "Hostname": [
        "主機名稱"
      ],
      "Hosts": [
        "主機"
      ],
      "hourly": [
        "每小時"
      ],
      "Hourly at {{ product.sync_plan.sync_date | date:'m' }} minutes and {{ product.sync_plan.sync_date | date:'s' }} seconds": [
        "每小時於 {{ product.sync_plan.sync_date | date:'m' }} 分 {{ product.sync_plan.sync_date | date:'s' }} 秒"
      ],
      "HTTP Proxy": [
        "HTTP 代理"
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
        ""
      ],
      "Id": [
        "Id"
      ],
      "Ignore SRPMs": [
        ""
      ],
      "Image": [
        "影像"
      ],
      "Immediate": [
        "立即"
      ],
      "Important": [
        "重要"
      ],
      "In order to browse this repository you must <a ng-href=\\\"/organizations/{{ organization }}/edit\\\">download the certificate</a>\\n            or ask your admin for a certificate.": [
        ""
      ],
      "Include Tags": [
        ""
      ],
      "Independent Packages": [
        ""
      ],
      "Install": [
        "安裝"
      ],
      "Install Selected": [
        "安裝所選項目"
      ],
      "Install the pre-built bootstrap RPM:": [
        "安裝預建立的 bootstrap RPM："
      ],
      "Installable": [
        "可安裝"
      ],
      "Installable Errata": [
        "可安裝的勘誤"
      ],
      "Installable Updates": [
        ""
      ],
      "Installed": [
        "已安裝"
      ],
      "Installed Deb Packages": [
        ""
      ],
      "Installed On": [
        ""
      ],
      "Installed Package": [
        "已安裝的套件"
      ],
      "Installed Packages": [
        "已安裝的套件"
      ],
      "Installed Products": [
        "已安裝的產品"
      ],
      "Installed Profile": [
        ""
      ],
      "Interfaces": [
        "介面"
      ],
      "Interval": [
        "間隔"
      ],
      "IPv4 Address": [
        "IPv4 位址"
      ],
      "IPv6 Address": [
        "IPv6 位址"
      ],
      "Issued": [
        "已簽發"
      ],
      "Katello Agent": [
        "Katello 代理程式"
      ],
      "Katello Tracer": [
        ""
      ],
      "Katello-agent is deprecated and will be removed in a future release.": [
        ""
      ],
      "Label": [
        "標籤"
      ],
      "Last Checkin": [
        "前一次簽入"
      ],
      "Last Published": [
        "前一次出版"
      ],
      "Last Puppet Report": [
        "前一次 Puppet 報告"
      ],
      "Last reclaim space failed:": [
        ""
      ],
      "Last Sync": [
        "前一次同步"
      ],
      "Last sync failed:": [
        ""
      ],
      "Last synced": [
        ""
      ],
      "Last Updated On": [
        "最後更新於"
      ],
      "Library": [
        "函示庫"
      ],
      "Library Repositories": [
        "函式庫軟體庫"
      ],
      "Library Repositories that contain this Deb.": [
        ""
      ],
      "Library Repositories that contain this File.": [
        ""
      ],
      "Library Synced Content": [
        "函式庫已同步內容"
      ],
      "License": [
        "授權條款"
      ],
      "Lifecycle Environment": [
        "生命週期環境"
      ],
      "Lifecycle Environment Paths": [
        "生命週期環境的路徑"
      ],
      "Lifecycle Environment:": [
        ""
      ],
      "Lifecycle Environments": [
        "生命週期環境"
      ],
      "Limit": [
        "限制"
      ],
      "Limit Repository Sets to only those available in this Activation Key's Lifecycle Environment": [
        ""
      ],
      "Limit Repository Sets to only those available in this Host's Lifecycle Environment": [
        ""
      ],
      "Limit to environment": [
        ""
      ],
      "Limit to Environment": [
        ""
      ],
      "Limit to Lifecycle Environment": [
        ""
      ],
      "Limit:": [
        "限制："
      ],
      "List": [
        "清單"
      ],
      "List/Remove": [
        "列出/移除"
      ],
      "Loading...": [
        "載入中……"
      ],
      "Loading...\\\"": [
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
        ""
      ],
      "Manage Errata": [
        "管理勘誤"
      ],
      "Manage Files for Repository:": [
        ""
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
        "管理套件"
      ],
      "Manage Packages for Repository:": [
        "管理軟體庫的套件："
      ],
      "Manage Repository Sets": [
        ""
      ],
      "Manage Subscriptions": [
        ""
      ],
      "Manage Sync Plan": [
        ""
      ],
      "Manage System Purpose": [
        ""
      ],
      "Manifest Lists": [
        ""
      ],
      "Manifest Type": [
        ""
      ],
      "Mirroring Policy": [
        ""
      ],
      "Model": [
        "型號"
      ],
      "Moderate": [
        "控管"
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
        ""
      ],
      "Module Streams <div>{{ library.counts.module_streams || 0 }}</div>": [
        ""
      ],
      "Module Streams for:": [
        ""
      ],
      "More Details": [
        "更多詳細資訊"
      ],
      "N/A": [
        "N/A"
      ],
      "Name": [
        "名稱"
      ],
      "Name of the upstream repository you want to sync. Example: 'quay/busybox' or 'fedora/ssh'.": [
        ""
      ],
      "Networking": [
        "網路"
      ],
      "Never": [
        "永不"
      ],
      "Never checked in": [
        ""
      ],
      "Never registered": [
        ""
      ],
      "Never synced": [
        "從未同步"
      ],
      "New Activation Key": [
        "新增啟動金鑰"
      ],
      "New Environment": [
        "新增環境"
      ],
      "New Name:": [
        "新名稱："
      ],
      "New Product": [
        "新產品"
      ],
      "New Repository": [
        "新軟體庫"
      ],
      "New Sync Plan": [
        "新增同步計劃"
      ],
      "New sync plan successfully created.": [
        "已建立新的同步計劃。"
      ],
      "Next": [
        "下一步"
      ],
      "Next Sync": [
        "下個同步"
      ],
      "No": [
        "否"
      ],
      "No alternate release version choices are available. The available releases are based upon what is available in \\\"{{ host.content_facet_attributes.content_view.name }}\\\", the selected <a href=\\\"/content_views\\\">content view</a> this content host is attached to for the given <a href=\\\"/lifecycle_environments\\\">lifecycle environment</a>, \\\"{{ host.content_facet_attributes.lifecycle_environment.name }}\\\".": [
        ""
      ],
      "No Content Hosts match this Erratum.": [
        "沒有符合此勘誤的內容主機。"
      ],
      "No Content Views contain this Deb": [
        ""
      ],
      "No Content Views contain this File": [
        ""
      ],
      "No content views exist for {{selected.environment.name}}": [
        "{{selected.environment.name}} 沒有存在的內容視域"
      ],
      "No discovered repositories.": [
        ""
      ],
      "No enabled Repository Sets provided through subscriptions.": [
        ""
      ],
      "No Host Collections match your search.": [
        ""
      ],
      "No Host Collections to show, you can add Host Collections after selecting 'Host Collections' under 'Hosts' in main menu.": [
        "沒有可顯示的主機集，您可在選擇了主選單中，「主機」下的「主機集」之後新增主機集。"
      ],
      "No Host Collections to show, you can add Host Collections after selecting the 'Add' tab.": [
        "沒有可顯示的主機集，您可在選擇了「新增」分頁後新增主機集。"
      ],
      "No HTTP Proxies found": [
        ""
      ],
      "No HTTP Proxy": [
        ""
      ],
      "No matching results.": [
        ""
      ],
      "No products are available to add to this Sync Plan.": [
        ""
      ],
      "No products have been added to this Sync Plan.": [
        ""
      ],
      "No releases exist in the Library.": [
        ""
      ],
      "No Repositories contain this Deb": [
        ""
      ],
      "No Repositories contain this Erratum.": [
        "沒有包含了此勘誤的軟體庫。"
      ],
      "No Repositories contain this File": [
        ""
      ],
      "No Repositories contain this Package.": [
        "沒有包含此套件的軟體庫。"
      ],
      "No repository sets provided through subscriptions.": [
        ""
      ],
      "No restriction": [
        ""
      ],
      "No sync information available.": [
        ""
      ],
      "No tasks exist for this resource.": [
        ""
      ],
      "None": [
        "無"
      ],
      "Not Applicable": [
        ""
      ],
      "Not installed": [
        "未安裝"
      ],
      "Not started": [
        ""
      ],
      "Not Synced": [
        "未同步"
      ],
      "Number of CPUs": [
        "CPU 數量"
      ],
      "Number of Repositories": [
        ""
      ],
      "On Demand": [
        "視需求"
      ],
      "One or more of the selected Errata are not Installable via your published Content View versions running on the selected hosts.  The new Content View Versions (specified below)\\n      will be created which will make this Errata Installable in the host's Environment.  This new version will replace the current version in your host's Lifecycle\\n      Environment.  To install these errata immediately on hosts after publishing check the box below.": [
        "一或多個勘誤無法透過您在所選主機上執行的已發佈內容視域版本來進行安裝。新的內容視域版本（指定在下列部分中）\\n      將會被建立，以讓此勘誤能安裝在主機的環境中。這個新版本將會取代您主機的生命週期\\n      環境中的目前版本。若要在發佈之後即刻在主機上安裝這些勘誤，請選取下方的方塊。"
      ],
      "One or more packages are not showing up in the local repository even though they exist in the upstream repository.": [
        ""
      ],
      "Only show content hosts where the errata is currently installable in the host's Lifecycle Environment.": [
        "僅顯示主機生命週期環境中目前能安裝勘誤的內容主機。"
      ],
      "Only show Errata that are Applicable to one or more Content Hosts": [
        ""
      ],
      "Only show Errata that are Installable on one or more Content Hosts": [
        ""
      ],
      "Only show Packages that are Applicable to one or more Content Hosts": [
        ""
      ],
      "Only show Packages that are Upgradable on one or more Content Hosts": [
        ""
      ],
      "Only show Subscriptions for products not already covered by a Subscription": [
        ""
      ],
      "Only show Subscriptions which can be applied to products installed on this Host": [
        ""
      ],
      "Only show Subscriptions which can be attached to this Host": [
        ""
      ],
      "Only the Applications with a Helper can be restarted.": [
        ""
      ],
      "Operating System": [
        "作業系統"
      ],
      "Optimized Sync": [
        ""
      ],
      "Organization": [
        "組織"
      ],
      "Original Sync Date": [
        "原始同步日期"
      ],
      "OS": [
        "作業系統"
      ],
      "OSTree Repositories <div>{{ library.counts.ostree_repositories || 0 }}</div>": [
        "OSTree 軟體庫 <div>{{ library.counts.ostree_repositories || 0 }}</div>"
      ],
      "Override to Disabled": [
        ""
      ],
      "Override to Enabled": [
        ""
      ],
      "Package": [
        "套件"
      ],
      "Package Actions": [
        "套件動作"
      ],
      "Package Group (Deprecated)": [
        ""
      ],
      "Package Groups": [
        "套件群組"
      ],
      "Package Groups for Repository:": [
        "軟體庫的套件群組："
      ],
      "Package Information": [
        ""
      ],
      "Package Install": [
        "套件安裝"
      ],
      "Package Installation, Removal, and Update": [
        "套件安裝、移除與更新"
      ],
      "Package Remove": [
        "套件移除"
      ],
      "Package Update": [
        "套件更新"
      ],
      "Package:": [
        "套件："
      ],
      "Package/Group Name": [
        "套件/群組名稱"
      ],
      "Packages": [
        "套件"
      ],
      "Packages <div>{{ library.counts.packages || 0 }}</div>": [
        "套件 <div>{{ library.counts.packages || 0 }}</div>"
      ],
      "Packages are automatically Applicable if they are Upgradable": [
        ""
      ],
      "Packages for Errata:": [
        ""
      ],
      "Packages for:": [
        "套件屬於："
      ],
      "Parameters": [
        "參數"
      ],
      "Part of a manifest list": [
        ""
      ],
      "Password": [
        "密碼"
      ],
      "Password of the upstream repository user for authentication. Leave empty if repository does not require authentication.": [
        ""
      ],
      "Paste contents of Content Credential": [
        ""
      ],
      "Path": [
        "路徑"
      ],
      "Perform": [
        "執行"
      ],
      "Performing host package actions is disabled because Katello is not configured for Remote Execution or Katello Agent.": [
        ""
      ],
      "Physical": [
        "實體的"
      ],
      "Please enter cron below": [
        ""
      ],
      "Please make sure a Content View is selected.": [
        ""
      ],
      "Please select an environment.": [
        "請選擇一個環境。"
      ],
      "Please select one from the list below and you will be redirected.": [
        "請從下方清單中選擇一項，而您將會被重新導向。"
      ],
      "Plus %y more errors": [
        "加上 %y 個錯誤"
      ],
      "Plus 1 more error": [
        "加上 1 個錯誤"
      ],
      "Previous Lifecycle Environment (%e/%cv)": [
        ""
      ],
      "Prior Environment": [
        ""
      ],
      "Product": [
        "產品"
      ],
      "Product delete operation has been initiated in the background.": [
        ""
      ],
      "Product Enhancement Advisory": [
        "產品功能增強諮詢"
      ],
      "Product information for:": [
        "產品資訊："
      ],
      "Product Management for Sync Plan:": [
        "產品管理以進行同步計劃："
      ],
      "Product Name": [
        "產品名稱"
      ],
      "Product Options": [
        ""
      ],
      "Product Saved": [
        "產品已儲存"
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
        "產品"
      ],
      "Products <div>{{ library.counts.products || 0 }}</div>": [
        "產品 <div>{{ library.counts.products || 0 }}</div>"
      ],
      "Products for": [
        ""
      ],
      "Products not covered": [
        ""
      ],
      "Provides": [
        "供應方"
      ],
      "Provisioning Details": [
        "佈建詳細資訊"
      ],
      "Provisioning Host Details": [
        "佈建主機詳細資訊"
      ],
      "Published At": [
        "已發佈於"
      ],
      "Published Repository Information": [
        "已發佈的軟體庫資訊"
      ],
      "Publishing Settings": [
        ""
      ],
      "Puppet Environment": [
        "Puppet 環境"
      ],
      "Quantity": [
        "數量"
      ],
      "Quantity (To Add)": [
        ""
      ],
      "RAM (GB)": [
        "記憶體 (GB)"
      ],
      "Reboot Suggested": [
        "建議重新啟動"
      ],
      "Reboot Suggested?": [
        "建議重新啟動？"
      ],
      "Recalculate\\n          <i class=\\\"fa fa-spinner fa-spin\\\" ng-show=\\\"calculatingApplicability\\\"></i>": [
        ""
      ],
      "Reclaim Space": [
        ""
      ],
      "Recurring Logic": [
        ""
      ],
      "Red Hat Repositories page": [
        "Red Hat 軟體庫頁面"
      ],
      "Red Hat Repositories page.": [
        "Red Hat 軟體庫頁面。"
      ],
      "Refresh Table": [
        "更新表格"
      ],
      "Register a Content Host": [
        "註冊內容主機"
      ],
      "Register Content Host": [
        "註冊內容主機"
      ],
      "Registered": [
        "已註冊"
      ],
      "Registered By": [
        "由...註冊"
      ],
      "Registered Through": [
        ""
      ],
      "Registry Name Pattern": [
        "名稱"
      ],
      "Registry Search Parameter": [
        ""
      ],
      "Registry to Discover": [
        ""
      ],
      "Registry URL": [
        "登錄檔網址"
      ],
      "Release": [
        "發行版"
      ],
      "Release Version": [
        "發行版本"
      ],
      "Release Version:": [
        "發行版本："
      ],
      "Releases/Distributions": [
        ""
      ],
      "Remote execution plugin is required to be able to run any helpers.": [
        ""
      ],
      "Remove": [
        "移除"
      ],
      "Remove {{ table.numSelected  }} Container Image manifest?": [
        ""
      ],
      "Remove Activation Key \\\"{{ activationKey.name }}\\\"?": [
        "確定要移除啟動金鑰 \\\"{{ activationKey.name }}\\\"？"
      ],
      "Remove Container Image Manifests": [
        ""
      ],
      "Remove Content": [
        "移除內容"
      ],
      "Remove Content Credential": [
        ""
      ],
      "Remove Content Credential {{ contentCredential.name }}": [
        ""
      ],
      "Remove Content?": [
        ""
      ],
      "Remove Environment": [
        ""
      ],
      "Remove environment {{ environment.name }}?": [
        ""
      ],
      "Remove File?": [
        ""
      ],
      "Remove Files": [
        ""
      ],
      "Remove From": [
        "從...移除"
      ],
      "Remove Host Collection \\\"{{ hostCollection.name }}\\\"?": [
        "確定要移除主機集 \\\"{{ hostCollection.name }}\\\"？"
      ],
      "Remove Package?": [
        ""
      ],
      "Remove Packages": [
        "移除套件"
      ],
      "Remove Product": [
        "移除產品"
      ],
      "Remove Product \\\"{{ product.name }}\\\"?": [
        "確定要移除產品 \\\"{{ product.name }}\\\"？"
      ],
      "Remove product?": [
        ""
      ],
      "Remove Repositories": [
        "移除軟體庫"
      ],
      "Remove Repository": [
        "移除軟體庫"
      ],
      "Remove Repository {{ repositoryWrapper.repository.name }}?": [
        ""
      ],
      "Remove repository?": [
        ""
      ],
      "Remove Selected": [
        "移除已選擇的項目"
      ],
      "Remove Successful.": [
        "移除成功。"
      ],
      "Remove Sync Plan": [
        "移除同步計劃"
      ],
      "Remove Sync Plan \\\"{{ syncPlan.name }}\\\"?": [
        "確定要移除同步計畫 \\\"{{ syncPlan.name }}\\\"？"
      ],
      "Removed %x host collections from activation key \\\"%y\\\".": [
        "已從啟動金鑰 \\\"%y\\\" 移除了 %x 個主機集。"
      ],
      "Removed %x host collections from content host \\\"%y\\\".": [
        "已從內容主機 \\\"%y\\\" 移除了 %x 個主機集。"
      ],
      "Removed %x products from sync plan \\\"%y\\\".": [
        "已從同步計劃 \\\"%y\\\" 移除了 %x 個產品。"
      ],
      "Removing Repositories": [
        "移除軟體庫"
      ],
      "Repo Discovery": [
        "搜尋軟體庫"
      ],
      "Repositories": [
        "軟體庫"
      ],
      "Repositories containing Errata {{ errata.errata_id }}": [
        "包含勘誤 {{ errata.errata_id }} 的軟體庫"
      ],
      "Repositories containing package {{ package.nvrea }}": [
        "軟體庫包含套件 {{ package.nvrea }}"
      ],
      "Repositories for": [
        ""
      ],
      "Repositories for Deb:": [
        ""
      ],
      "Repositories for Errata:": [
        "勘誤的軟體庫："
      ],
      "Repositories for File:": [
        ""
      ],
      "Repositories for Package:": [
        "套件的軟體庫："
      ],
      "Repositories for Product:": [
        "產品的軟體庫："
      ],
      "Repositories to Create": [
        ""
      ],
      "Repository": [
        "軟體庫"
      ],
      "Repository \\\"%s\\\" successfully deleted": [
        "已成功刪除軟體庫 \\\"%s\\\""
      ],
      "Repository %s successfully created.": [
        "已成功建立軟體庫 %s。"
      ],
      "Repository created": [
        "軟體庫已建立"
      ],
      "Repository Discovery": [
        "探索軟體庫"
      ],
      "Repository HTTP proxy changes have been initiated in the background.": [
        ""
      ],
      "Repository Label": [
        "軟體庫標籤"
      ],
      "Repository Name": [
        "軟體庫名稱"
      ],
      "Repository Options": [
        ""
      ],
      "Repository Path": [
        ""
      ],
      "Repository Saved.": [
        "已儲存軟體庫。"
      ],
      "Repository Sets": [
        ""
      ],
      "Repository Sets settings saved successfully.": [
        ""
      ],
      "Repository Type": [
        "存放庫類型"
      ],
      "Repository URL": [
        "軟體庫 URL"
      ],
      "Repository will also be removed from the following published content view versions!": [
        ""
      ],
      "Repository:": [
        "軟體庫："
      ],
      "Requirements": [
        ""
      ],
      "Requirements.yml": [
        ""
      ],
      "Requires": [
        "需要"
      ],
      "Reset": [
        ""
      ],
      "Reset to Default": [
        ""
      ],
      "Resolving the selected Traces will reboot the selected content hosts.": [
        ""
      ],
      "Resolving the selected Traces will reboot this host.": [
        ""
      ],
      "Restart": [
        "重新啟動"
      ],
      "Restart Selected": [
        ""
      ],
      "Restart Services on Content Host \\\"{{host.name}}\\\"?": [
        ""
      ],
      "Restrict to <br>OS version": [
        ""
      ],
      "Restrict to architecture": [
        ""
      ],
      "Restrict to Architecture": [
        ""
      ],
      "Restrict to OS version": [
        ""
      ],
      "Result": [
        "結果"
      ],
      "Retain package versions": [
        ""
      ],
      "Role": [
        "角色"
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
        "執行自動連結"
      ],
      "Run Repository Creation\\n      <i class=\\\"fa fa-spinner fa-spin\\\" ng-show=\\\"creating()\\\"></i>": [
        ""
      ],
      "Run Sync Plan": [
        "執行同步計劃"
      ],
      "Save": [
        "儲存"
      ],
      "Save Successful.": [
        "儲存成功。"
      ],
      "Schema Version": [
        ""
      ],
      "Schema Version 1": [
        ""
      ],
      "Schema Version 2": [
        ""
      ],
      "Security": [
        "安全性"
      ],
      "Security Advisory": [
        "安全性諮詢"
      ],
      "Select": [
        "選擇"
      ],
      "Select a Content Source:": [
        "選擇一項內容來源："
      ],
      "Select Action": [
        "選擇動作"
      ],
      "Select an Organization": [
        "選擇組織"
      ],
      "Select Content View": [
        "選擇內容視域"
      ],
      "Selecting \\\"Complete Sync\\\" will cause only yum/deb repositories of the selected product to be synced.": [
        ""
      ],
      "Selecting this option will exclude SRPMs from repository synchronization.": [
        ""
      ],
      "Selecting this option will result in Katello verifying that the upstream url's SSL certificates are signed by a trusted CA. Unselect if you do not want this verification.": [
        ""
      ],
      "Service Level": [
        "服務等級"
      ],
      "Service Level (SLA)": [
        ""
      ],
      "Service Level (SLA):": [
        ""
      ],
      "Set Release Version": [
        ""
      ],
      "Severity": [
        "嚴重性"
      ],
      "Show All": [
        "顯示全部"
      ],
      "Show all Repository Sets in Organization": [
        ""
      ],
      "Size": [
        "大小"
      ],
      "Smart proxy currently reclaiming space...": [
        ""
      ],
      "Smart proxy currently syncing to your locations...": [
        ""
      ],
      "Smart proxy is synchronized": [
        ""
      ],
      "Sockets": [
        "插槽"
      ],
      "Solution": [
        "解決方案"
      ],
      "Some of the Errata shown below may not be installable as they are not in this Content Host's\\n        Content View and Lifecycle Environment.  In order to apply such Errata an Incremental Update is required.": [
        ""
      ],
      "Something went wrong when deleting the resource.": [
        ""
      ],
      "Something went wrong when retrieving the resource.": [
        "取得資源時發生錯誤："
      ],
      "Something went wrong when saving the resource.": [
        ""
      ],
      "Source RPM": [
        "來源 RPM"
      ],
      "Source RPMs": [
        "來源 RPM"
      ],
      "Space reclamation is about to start...": [
        ""
      ],
      "SSL CA Cert": [
        ""
      ],
      "SSL Certificate": [
        ""
      ],
      "SSL Client Cert": [
        ""
      ],
      "SSL Client Key": [
        "SSL 客戶端金鑰"
      ],
      "Standard sync, optimized for speed by bypassing any unneeded steps.": [
        ""
      ],
      "Start Date": [
        "起始日期"
      ],
      "Start Time": [
        "起始時間"
      ],
      "Started At": [
        "起始於"
      ],
      "Starting": [
        "正在開始"
      ],
      "Starts": [
        "起始"
      ],
      "State": [
        "狀態"
      ],
      "Status": [
        "狀態"
      ],
      "Stream": [
        ""
      ],
      "Subscription Details": [
        "訂閱詳細資訊"
      ],
      "Subscription Management": [
        "訂閱管理"
      ],
      "Subscription Status": [
        "訂閱狀態"
      ],
      "Subscription UUID": [
        ""
      ],
      "subscription-manager register --org=\\\"{{ activationKey.organization.label }}\\\" --activationkey=\\\"{{ activationKey.name }}\\\"": [
        "subscription-manager register --org=\\\"{{ activationKey.organization.label }}\\\" --activationkey=\\\"{{ activationKey.name }}\\\""
      ],
      "Subscriptions": [
        "訂閱服務"
      ],
      "Subscriptions for Activation Key:": [
        "啟動金鑰的訂閱："
      ],
      "Subscriptions for Content Host:": [
        "內容主機的訂閱："
      ],
      "Subscriptions for:": [
        "訂閱屬於："
      ],
      "Success!": [
        "成功！"
      ],
      "Successfully added %s subscriptions.": [
        "已成功新增了 %s 個訂閱。"
      ],
      "Successfully initiated restart of services.": [
        ""
      ],
      "Successfully removed %s items.": [
        "成功移除了 %s 個項目。"
      ],
      "Successfully removed %s subscriptions.": [
        "已成功移除了 %s 項訂閱。"
      ],
      "Successfully removed 1 item.": [
        "已成功移除了 1 個項目。"
      ],
      "Successfully scheduled an update of all packages": [
        ""
      ],
      "Successfully scheduled package installation": [
        ""
      ],
      "Successfully scheduled package removal": [
        ""
      ],
      "Successfully scheduled package update": [
        ""
      ],
      "Successfully updated subscriptions.": [
        "已成功更新了訂閱。"
      ],
      "Successfully uploaded content:": [
        ""
      ],
      "Summary": [
        "概要"
      ],
      "Support Level": [
        "支援等級"
      ],
      "Sync": [
        "同步"
      ],
      "Sync Enabled": [
        "已啟用同步"
      ],
      "Sync even if the upstream metadata appears to have no change. This option is only relevant for yum/deb repositories and will take longer than an optimized sync. Choose this option if:": [
        ""
      ],
      "Sync Interval": [
        "同步間隔"
      ],
      "Sync Now": [
        "現在同步"
      ],
      "Sync Plan": [
        "同步計劃"
      ],
      "Sync Plan %s has been deleted.": [
        "已刪除同步計劃 %s。"
      ],
      "Sync Plan created and assigned to product.": [
        ""
      ],
      "Sync Plan saved": [
        ""
      ],
      "Sync Plan Saved": [
        "已儲存同步計劃"
      ],
      "Sync Plan:": [
        "同步計劃："
      ],
      "Sync Plans": [
        "同步計劃"
      ],
      "Sync Selected": [
        ""
      ],
      "Sync Settings": [
        ""
      ],
      "Sync State": [
        "同步狀態"
      ],
      "Sync Status": [
        "同步狀態"
      ],
      "Synced manually, no interval set.": [
        "已手動同步，未設置間隔。"
      ],
      "Synchronization is about to start...": [
        "同步即將開始……"
      ],
      "Synchronization is being cancelled...": [
        "同步即將取消……"
      ],
      "System Purpose": [
        ""
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
        "標籤"
      ],
      "Task Details": [
        "任務的詳細資訊"
      ],
      "Tasks": [
        "任務"
      ],
      "Temporary": [
        "暫時性"
      ],
      "The <i>Registry Name Pattern</i> overrides the default name by which container images may be pulled from the server. (By default this name is a combination of Organization, Lifecycle Environment, Content View, Product, and Repository labels.)\\n\\n          <br><br>The name may be constructed using ERB syntax. Variables available for use are:\\n\\n          <pre>\\norganization.name\\norganization.label\\nrepository.name\\nrepository.label\\nrepository.docker_upstream_name\\ncontent_view.label\\ncontent_view.name\\ncontent_view_version.version\\nproduct.name\\nproduct.label\\nlifecycle_environment.name\\nlifecycle_environment.label</pre>\\n\\n          Examples:\\n            <pre>\\n&lt;%= organization.label %&gt;-&lt;%= lifecycle_environment.label %&gt;-&lt;%= content_view.label %&gt;-&lt;%= product.label %&gt;-&lt;%= repository.label %&gt;\\n&lt;%= organization.label %&gt;/&lt;%= repository.docker_upstream_name %&gt;</pre>": [
        ""
      ],
      "The Content View or Lifecycle Environment needs to be updated in order to make errata available to these hosts.": [
        "內容視域或生命週期環境需要更新才能讓這些主機使用勘誤。"
      ],
      "The following actions can be performed on content hosts in this host collection:": [
        "下列動作能在此主機集中的內容主機上執行："
      ],
      "The host has not reported any applicable packages for upgrade.": [
        ""
      ],
      "The host has not reported any installed packages, registering with subscription-manager should cause these to be reported.": [
        "主機未回報任何以安裝套件，使用 subscription-manager 註冊會導致這些被回報。"
      ],
      "The host requires being attached to a content view and the lifecycle environment you have chosen has no content views promoted to it.\\n              See the <a href=\\\"/content_views\\\">content views page</a> to manage and promote a content view.": [
        ""
      ],
      "The maximum number of versions of each package to keep.": [
        ""
      ],
      "The page you are attempting to access requires selecting a specific organization.": [
        "您嘗試存取的網頁需要選擇特定組織。"
      ],
      "The remote execution feature is required to manage packages on this Host.": [
        ""
      ],
      "The Remote Execution plugin needs to be installed in order to resolve Traces.": [
        ""
      ],
      "The repository will be enabled by default on content hosts with the selected architecture.": [
        ""
      ],
      "The repository will be enabled by default on content hosts with the selected OS version.": [
        ""
      ],
      "The selected environment contains no Content Views, please select a different environment.": [
        "選擇的環境不包含內容視域，請選擇一個不同的環境。"
      ],
      "The time the sync should happen in your current time zone.": [
        ""
      ],
      "The token key to use for authentication.": [
        ""
      ],
      "The URL to receive a session token from, e.g. used with Automation Hub.": [
        ""
      ],
      "There are {{ errataCount }} total Errata in this organization but none match the above filters.": [
        "此組織總共有 {{ errataCount }} 個勘誤，但沒有一個與上述篩選相符。"
      ],
      "There are {{ packageCount }} total Packages in this organization but none match the above filters.": [
        ""
      ],
      "There are no %(contentType)s that match the criteria.": [
        ""
      ],
      "There are no Content Views in this Environment.": [
        "此環境中沒有內容視域。"
      ],
      "There are no Content Views that match the criteria.": [
        "沒有符合條件的內容視域。"
      ],
      "There are no Errata associated with this Content Host to display.": [
        "沒有與此內容主機相聯的勘誤可顯示。"
      ],
      "There are no Errata in this organization.  Create one or more Products with Errata to view Errata on this page.": [
        "這個組織中沒有勘誤。請建立一或更多項產品與勘誤以在此網站上檢視勘誤。"
      ],
      "There are no Errata to display.": [
        "沒有可顯示的勘誤。"
      ],
      "There are no Host Collections available. You can create new Host Collections after selecting 'Host Collections' under 'Hosts' in main menu.": [
        "沒有可用的主機集。您可在選擇了主選單中，「主機」下的「主機集」之後建立新的主機集。"
      ],
      "There are no Module Streams to display.": [
        ""
      ],
      "There are no Packages in this organization.  Create one or more Products with Packages to view Packages on this page.": [
        "這個組織中沒有套件。請建立一或更多項產品與套件以在此網站上檢視套件。"
      ],
      "There are no Sync Plans available. You can create new Sync Plans after selecting 'Sync Plans' under 'Hosts' in main menu.": [
        ""
      ],
      "There are no Traces to display.": [
        ""
      ],
      "There is currently an Incremental Update task in progress.  This update must finish before applying existing updates.": [
        "目前正有一項遞增更新任務進行中。在套用既有更新之前，這項更新必須先完成。"
      ],
      "These instructions will be removed in a future release. NEW: To register a content host without following these manual steps, see <a href=\\\"https://{{ katelloHostname }}/hosts/register\\\">Register Host</a>": [
        ""
      ],
      "This action will affect only those Content Hosts that require a change.\\n        If the Content Host does not have the selected Subscription no action will take place.": [
        ""
      ],
      "This activation key is not associated with any content hosts.": [
        "此啟動金鑰不與任何內容主機相聯。"
      ],
      "This activation key may be used during system registration. For example:": [
        "此啟動金鑰能在進行系統註冊時使用。例如："
      ],
      "This change will be applied to <b>{{ hostCount }} systems.</b>": [
        ""
      ],
      "This Container Image Tag is not present in any Lifecycle Environments.": [
        ""
      ],
      "This operation may also remove managed resources linked to the host such as virtual machines and DNS records.\\n          Change the setting \\\"Delete Host upon Unregister\\\" to false on the <a href=\\\"/settings\\\">settings page</a> to prevent this.": [
        ""
      ],
      "This organization has Simple Content Access enabled.  Hosts are not required to have subscriptions attached to access repositories.": [
        ""
      ],
      "This organization is not using <a target=\\\"_blank\\\" href=\\\"https://access.redhat.com/articles/simple-content-access\\\">Simple Content Access.</a> Entitlement-based subscription management is deprecated and will be removed in a future version.": [
        ""
      ],
      "Title": [
        "標題"
      ],
      "To register a content host to this server, follow these steps.": [
        "若要向這部伺服器註冊內容主機，請依照下列步驟進行："
      ],
      "Toggle Dropdown": [
        ""
      ],
      "Token of the upstream repository user for authentication. Leave empty if repository does not require authentication.": [
        ""
      ],
      "Topic": [
        "主題"
      ],
      "Tracer helps administrators identify applications that need to be restarted after a system is patched.": [
        ""
      ],
      "Traces": [
        ""
      ],
      "Traces for:": [
        ""
      ],
      "Turn on Setting > Content > Allow deleting repositories in published content views": [
        ""
      ],
      "Type": [
        "類型"
      ],
      "Unauthenticated Pull": [
        ""
      ],
      "Unknown": [
        "不明"
      ],
      "Unlimited Content Hosts:": [
        "無限的內容主機："
      ],
      "Unlimited Hosts": [
        ""
      ],
      "Unprotected": [
        ""
      ],
      "Unregister Host": [
        "取消註冊主機"
      ],
      "Unregister Host \\\"{{host.name}}\\\"?": [
        ""
      ],
      "Unregister Options:": [
        ""
      ],
      "Unregister the host as a subscription consumer.  Provisioning and configuration information is preserved.": [
        ""
      ],
      "Unsupported Type!": [
        ""
      ],
      "Update": [
        "更新"
      ],
      "Update All Deb Packages": [
        ""
      ],
      "Update All Packages": [
        ""
      ],
      "Update Packages": [
        "升級套件"
      ],
      "Update Sync Plan": [
        "更新同步計劃"
      ],
      "Updated": [
        "已更新"
      ],
      "Upgradable": [
        ""
      ],
      "Upgradable For": [
        ""
      ],
      "Upgradable Package": [
        ""
      ],
      "Upgrade Available": [
        ""
      ],
      "Upgrade Selected": [
        ""
      ],
      "Upload": [
        "上傳"
      ],
      "Upload Content Credential file": [
        ""
      ],
      "Upload File": [
        "上傳檔案"
      ],
      "Upload Package": [
        "上傳套件"
      ],
      "Upload Requirements": [
        ""
      ],
      "Upload Requirements.yml file <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'ansible_collection'\\\" uib-popover-html=\\\"requirementPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\">\\n        </a>": [
        ""
      ],
      "Uploading...": [
        "正在上傳..."
      ],
      "Upstream Authentication Token": [
        ""
      ],
      "Upstream Authorization": [
        ""
      ],
      "Upstream Image Name": [
        ""
      ],
      "Upstream Password": [
        ""
      ],
      "Upstream Repository Name": [
        "上游軟體庫名稱"
      ],
      "Upstream URL": [
        ""
      ],
      "Upstream Username": [
        ""
      ],
      "Url": [
        "網址"
      ],
      "URL of the registry you want to sync. Example: https://registry-1.docker.io/ or https://quay.io/": [
        ""
      ],
      "URL to Discover": [
        ""
      ],
      "URL to the repository base. Example: http://ftp.de.debian.org/debian/ <a class=\\\"fa fa-question-circle\\\" ng-show=\\\"repository.content_type === 'deb'\\\" uib-popover-html=\\\"debURLPopover\\\" popover-class=\\\"popover-large\\\" popover-trigger=\\\"'outsideClick'\\\" popover-append-to-body=\\\"true\\\" popover-title=\\\"Upstream URL\\\">\\n        </a>": [
        ""
      ],
      "Usage Type": [
        ""
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
        ""
      ],
      "User": [
        "使用者"
      ],
      "Username": [
        "使用者名稱"
      ],
      "Username of the upstream repository user for authentication. Leave empty if repository does not require authentication.": [
        ""
      ],
      "Variant": [
        "變體"
      ],
      "Verify Content Checksum": [
        ""
      ],
      "Verify SSL": [
        "驗證 SSL"
      ],
      "Version": [
        "版本"
      ],
      "Version {{ cvVersions['version'] }}": [
        ""
      ],
      "Versions": [
        "版本"
      ],
      "via Katello agent": [
        "透過 Katello 代理程式"
      ],
      "via Katello Agent": [
        "透過 Katello 代理程式"
      ],
      "via remote execution": [
        "透過遠端執行"
      ],
      "via remote execution - customize first": [
        "透過遠端執行 - 先自訂"
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
        "虛擬"
      ],
      "Virtual Guest": [
        "虛擬客座"
      ],
      "Virtual Guests": [
        "虛擬客座端"
      ],
      "Virtual Host": [
        "虛擬主機"
      ],
      "Warning: reclaiming space for an \\\"On Demand\\\" repository will delete all cached content units.  Take precaution when cleaning custom repositories whose upstream parents don't keep old package versions.": [
        ""
      ],
      "weekly": [
        "每週"
      ],
      "Weekly on {{ product.sync_plan.sync_date | date:'EEEE' }} at {{ product.sync_plan.sync_date | date:'mediumTime' }} (Server Time)": [
        "每週在 {{ product.sync_plan.sync_date | date:'EEEE' }} 上於 {{ product.sync_plan.sync_date | date:'mediumTime' }}（伺服器時間）"
      ],
      "When Auto Attach is disabled, registering systems will be attached to all associated subscriptions.": [
        "當停用了自動連接時，註冊的系統將會被連至所有相聯的訂閱。"
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
        "處理"
      ],
      "Yes": [
        "是"
      ],
      "You can upload a requirements.yml file above to auto-fill contents <b>OR</b> paste contents of <a ng-href=\\\"https://docs.ansible.com/ansible/latest/galaxy/user_guide.html#install-multiple-collections-with-a-requirements-file\\\" target=\\\"_blank\\\"> Requirements.yml </a>below.": [
        ""
      ],
      "You can upload a requirements.yml file below to auto-fill contents or paste contents of requirement.yml here": [
        ""
      ],
      "You cannot remove these repositories because you do not have permission.": [
        "您無法移除這些軟體庫，因為您沒有權限。"
      ],
      "You cannot remove this product because it is a Red Hat product.": [
        "您無法移除這項產品，因為這是一項 Red Hat 產品。"
      ],
      "You cannot remove this product because it was published to a content view.": [
        "您無法移除這項產品，因為它已發佈至某個內容視域。"
      ],
      "You cannot remove this product because you do not have permission.": [
        "您無法移除這項產品，因為您沒有權限。"
      ],
      "You cannot remove this repository because you do not have permission.": [
        "您無法移除此軟體庫，因為您沒有權限。"
      ],
      "You currently don't have any Activation Keys, you can add Activation Keys using the button on the right.": [
        "您目前沒有任何啟動金鑰，您可使用右方的按鈕來新增啟動金鑰。"
      ],
      "You currently don't have any Alternate Content Sources associated with this Content Credential.": [
        ""
      ],
      "You currently don't have any Container Image Tags.": [
        ""
      ],
      "You currently don't have any Content Credential, you can add Content Credentials using the button on the right.": [
        ""
      ],
      "You currently don't have any Content Hosts, you can create new Content Hosts by selecting Contents Host from main menu and then clicking the button on the right.": [
        "您目前沒有任何內容主機，您可藉由從主選單選擇內容主機然後按下右方的按鈕來建立新的內容主機。"
      ],
      "You currently don't have any Content Hosts, you can register one by clicking the button on the right and following the instructions.": [
        "您目前沒有任何內容主機，您可藉由點選右方的按鈕並依照指示進行，以註冊內容主機。"
      ],
      "You currently don't have any Files.": [
        ""
      ],
      "You currently don't have any Host Collections, you can add Host Collections using the button on the right.": [
        "您目前沒有任何主機集，您可藉由使用右方的按鈕來新增主機集。"
      ],
      "You currently don't have any Hosts in this Host Group, you can add Content Hosts after selecting the 'Add' tab.": [
        "您目前在這個主機群組中沒有任何主機，您可在選擇了「新增」分頁後新增內容主機。"
      ],
      "You currently don't have any Products associated with this Content Credential.": [
        ""
      ],
      "You currently don't have any Products to subscribe to, you can add Products after selecting 'Products' under 'Content' in the main menu": [
        "您目前沒有任何能訂閱的產品，您可在選擇了主選單中「內容」下的「產品」之後來新增產品。"
      ],
      "You currently don't have any Products to subscribe to. You can add Products after selecting 'Products' under 'Content' in the main menu.": [
        ""
      ],
      "You currently don't have any Products<span bst-feature-flag=\\\"custom_products\\\">, you can add Products using the button on the right</span>.": [
        "您目前沒有任何產品<span bst-feature-flag=\\\"custom_products\\\">，您可藉由使用右方的的按鈕來新增產品。</span>。"
      ],
      "You currently don't have any Repositories associated with this Content Credential.": [
        ""
      ],
      "You currently don't have any Repositories included in this Product, you can add Repositories using the button on the right.": [
        "您目前沒有任何軟體庫包含在這項產品中，您可藉由使用右方的按鈕來新增軟體庫。"
      ],
      "You currently don't have any Subscriptions associated with this Activation Key, you can add Subscriptions after selecting the 'Add' tab.": [
        "您目前沒有任何與此啟動金鑰相聯的訂閱，您可在選擇了「新增」分頁後新增訂閱。"
      ],
      "You currently don't have any Subscriptions associated with this Content Host. You can add Subscriptions after selecting the 'Add' tab.": [
        ""
      ],
      "You currently don't have any Sync Plans.  A Sync Plan can be created by using the button on the right.": [
        "您目前沒有任何同步計畫。同步計畫能藉由使用右方的按鈕來建立。"
      ],
      "You do not have any Installed Products": [
        "您尚未安裝任何產品"
      ],
      "You must select a content view in order to save your environment.": [
        "您必須選擇一項內容視域以儲存您的環境。"
      ],
      "You must select a new content view before your change of environment can be saved. Use the cancel button on content view selection to revert your environment selection.": [
        "若要儲存您的環境變更，您必須先選擇新的內容視域。請使用內容視域上的取消按鈕來復原您的環境選擇。"
      ],
      "You must select a new content view before your change of lifecycle environment can be saved.": [
        ""
      ],
      "You must select at least one Content Host in order to apply Errata.": [
        "您必須選擇至少一個內容主機才能套用勘誤。"
      ],
      "You must select at least one Errata to apply.": [
        "您至少必須選擇一個勘誤。"
      ],
      "Your search returned zero %(contentType)s that match the criteria.": [
        ""
      ],
      "Your search returned zero Activation Keys.": [
        ""
      ],
      "Your search returned zero Container Image Tags.": [
        ""
      ],
      "Your search returned zero Content Credential.": [
        ""
      ],
      "Your search returned zero Content Hosts.": [
        ""
      ],
      "Your search returned zero Content Views": [
        ""
      ],
      "Your search returned zero Content Views.": [
        ""
      ],
      "Your search returned zero Deb Packages.": [
        ""
      ],
      "Your search returned zero Debs.": [
        ""
      ],
      "Your search returned zero Errata.": [
        ""
      ],
      "Your search returned zero Erratum.": [
        ""
      ],
      "Your search returned zero Files.": [
        ""
      ],
      "Your search returned zero Host Collections.": [
        ""
      ],
      "Your search returned zero Hosts.": [
        ""
      ],
      "Your search returned zero Lifecycle Environments.": [
        ""
      ],
      "Your search returned zero Module Streams.": [
        ""
      ],
      "Your search returned zero Packages.": [
        ""
      ],
      "Your search returned zero Products.": [
        ""
      ],
      "Your search returned zero Repositories": [
        ""
      ],
      "Your search returned zero Repositories.": [
        ""
      ],
      "Your search returned zero repository sets.": [
        ""
      ],
      "Your search returned zero Repository Sets.": [
        ""
      ],
      "Your search returned zero results.": [
        ""
      ],
      "Your search returned zero Subscriptions.": [
        ""
      ],
      "Your search returned zero Sync Plans.": [
        ""
      ],
      "Your search returned zero Traces.": [
        ""
      ],
      "Yum Metadata Checksum": [
        "Yum Metadata Checksum"
      ],
      "Yum metadata generation has been initiated in the background.  Click <a href=\\\"{{ taskUrl() }}\\\">Here</a> to monitor the progress.": [
        "已在背景開始了 Yum metadata 的產生。請按<a href=\\\"{{ taskUrl() }}\\\">此</a>來監控進度。"
      ],
      "Yum Repositories <div>{{ library.counts.yum_repositories || 0 }}</div>": [
        "Yum 軟體庫 <div>{{ library.counts.yum_repositories || 0 }}</div>"
      ]
    }
  }
};
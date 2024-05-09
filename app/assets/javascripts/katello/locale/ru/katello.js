 locales['katello'] = locales['katello'] || {}; locales['katello']['ru'] = {
  "domain": "katello",
  "locale_data": {
    "katello": {
      "": {
        "Project-Id-Version": "katello 2.4.0-RC1",
        "Report-Msgid-Bugs-To": "",
        "PO-Revision-Date": "2017-12-19 20:14+0000",
        "Last-Translator": "Bryan Kearney <bryan.kearney@gmail.com>, 2022",
        "Language-Team": "Russian (https://www.transifex.com/foreman/teams/114/ru/)",
        "MIME-Version": "1.0",
        "Content-Type": "text/plain; charset=UTF-8",
        "Content-Transfer-Encoding": "8bit",
        "Language": "ru",
        "Plural-Forms": "nplurals=4; plural=(n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<12 || n%100>14) ? 1 : n%10==0 || (n%10>=5 && n%10<=9) || (n%100>=11 && n%100<=14)? 2 : 3);",
        "lang": "ru",
        "domain": "katello",
        "plural_forms": "nplurals=4; plural=(n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<12 || n%100>14) ? 1 : n%10==0 || (n%10>=5 && n%10<=9) || (n%100>=11 && n%100<=14)? 2 : 3);"
      },
      "\\n* Product = '%{product}', Repository = '%{repository}'": [
        ""
      ],
      " %{errata_count} Errata": [
        ""
      ],
      " %{modulemd_count} Module Stream(s)": [
        ""
      ],
      " %{package_count} Package(s)": [
        ""
      ],
      " (${item.published_at_words} ago)": [
        ""
      ],
      " (${version.published_at_words} ago)": [
        ""
      ],
      " Content view updated": [
        ""
      ],
      " DEBs": [
        ""
      ],
      " Either select the latest content view or the content view version. Cannot set both.": [
        ""
      ],
      " RPMs": [
        ""
      ],
      " The base path can be a web address or a filesystem location.": [
        ""
      ],
      " The base path must be a web address pointing to the root RHUI content directory.": [
        ""
      ],
      " View task details ": [
        ""
      ],
      " ago": [
        ""
      ],
      " ago.": [
        ""
      ],
      " and": [
        ""
      ],
      " are out of the environment path order. The recommended practice is to promote to the next environment in the path.": [
        ""
      ],
      " content view is used in listed composite content views.": [
        ""
      ],
      " content view is used in listed content views. For more information, ": [
        ""
      ],
      " environment cannot be set to an environment already on its path": [
        "это окружение уже в цепочке"
      ],
      " found.": [
        ""
      ],
      " is out of the environment path order. The recommended practice is to promote to the next environment in the path.": [
        ""
      ],
      " or any step on the left.": [
        ""
      ],
      " to manage and promote content views, or select a different environment.": [
        ""
      ],
      "${deleteFlow ? 'Deleting' : 'Removing'} version ${versionNameToRemove}": [
        ""
      ],
      "${option}": [
        ""
      ],
      "${pluralize(akResponse.length, 'activation key')} will be moved to content view ${selectedCVNameForAK} in ": [
        ""
      ],
      "${pluralize(hostResponse.length, 'host')} will be moved to content view ${selectedCVNameForHosts} in ": [
        ""
      ],
      "${pluralize(versionCount, 'content view version')} in the environments below will be removed when content view is deleted": [
        ""
      ],
      "${selectedContentType}": [
        ""
      ],
      "${selectedContentType} will appear here when created.": [
        ""
      ],
      "%s %s has %s Hosts and %s Hostgroups that will need to be reassociated post deletion. Delete %s?": [
        ""
      ],
      "%s Available": [
        "%s доступно"
      ],
      "%s Errata": [
        "Исправления: %s"
      ],
      "%s Host": [
        "",
        ""
      ],
      "%s Used": [
        "%s занято"
      ],
      "%s ago": [
        "%s назад"
      ],
      "%s content type is not enabled.": [
        ""
      ],
      "%s guests": [
        ""
      ],
      "%s has already been deleted": [
        ""
      ],
      "%s is not a valid package name": [
        "Недопустимое имя пакета: %s"
      ],
      "%s is not a valid path": [
        ""
      ],
      "%s is required": [
        ""
      ],
      "%s is unreachable. %s": [
        ""
      ],
      "%{errata} (%{total} other errata)": [
        "%{errata} (других исправлений: %{total})"
      ],
      "%{errata} (%{total} other errata) install canceled": [
        "Установка %{errata} отменена (других исправлений: %{total})"
      ],
      "%{errata} (%{total} other errata) install failed": [
        "Не удалось установить %{errata} (других исправлений: %{total})"
      ],
      "%{errata} (%{total} other errata) install timed out": [
        "Время ожидания установки %{errata} истекло (других исправлений: %{total})"
      ],
      "%{errata} (%{total} other errata) installed": [
        "%{errata} установлено (других исправлений: %{total})"
      ],
      "%{errata} erratum install canceled": [
        "Установка %{errata} отменена"
      ],
      "%{errata} erratum install failed": [
        "Не удалось установить %{errata}"
      ],
      "%{errata} erratum install timed out": [
        "Время ожидания установки %{errata} истекло"
      ],
      "%{errata} erratum installed": [
        "Исправление %{errata} установлено"
      ],
      "%{expiring_subs} subscriptions in %{subject} are going to expire in less than %{days} days. Please renew them before they expire to guarantee your hosts will continue receiving content.": [
        ""
      ],
      "%{group} (%{total} other package groups)": [
        "%{group} (других групп: %{total})"
      ],
      "%{group} (%{total} other package groups) install canceled": [
        "Установка %{group} отменена (других групп: %{total})"
      ],
      "%{group} (%{total} other package groups) install failed": [
        "Не удалось установить %{group} (других групп: %{total})"
      ],
      "%{group} (%{total} other package groups) install timed out": [
        "Время ожидания установки %{group} истекло (других групп: %{total})"
      ],
      "%{group} (%{total} other package groups) installed": [
        "Установка %{group} завершена (других групп: %{total})"
      ],
      "%{group} (%{total} other package groups) remove canceled": [
        "Удаление %{group} отменено (других групп: %{total})"
      ],
      "%{group} (%{total} other package groups) remove failed": [
        "Не удалось удалить %{group} (других групп: %{total})"
      ],
      "%{group} (%{total} other package groups) remove timed out": [
        "Время ожидания удаления %{group} истекло (других групп: %{total})"
      ],
      "%{group} (%{total} other package groups) removed": [
        "Удаление %{group} успешно (других групп: %{total})"
      ],
      "%{group} (%{total} other package groups) update canceled": [
        "Обновление %{group} отменено (других групп: %{total})"
      ],
      "%{group} (%{total} other package groups) update failed": [
        "Не удалось обновить %{group} (других групп: %{total})"
      ],
      "%{group} (%{total} other package groups) update timed out": [
        "Время ожидания обновления %{group} истекло (других групп: %{total})"
      ],
      "%{group} (%{total} other package groups) updated": [
        "Обновление %{group} завершено (других групп: %{total})"
      ],
      "%{group} package group install canceled": [
        "Установка группы %{group} отменена"
      ],
      "%{group} package group install failed": [
        "Не удалось установить группу %{group}"
      ],
      "%{group} package group install timed out": [
        "Время ожидания установки группы %{group} истекло"
      ],
      "%{group} package group installed": [
        "Группа %{group} установлена"
      ],
      "%{group} package group remove canceled": [
        "Удаление группы %{group} отменено"
      ],
      "%{group} package group remove failed": [
        "Не удалось удалить группу %{group} "
      ],
      "%{group} package group remove timed out": [
        "Время ожидания удаления группы %{group} истекло"
      ],
      "%{group} package group removed": [
        "Группа %{group} удалена"
      ],
      "%{group} package group update canceled": [
        "Обновление группы %{group} отменено"
      ],
      "%{group} package group update failed": [
        "Не удалось обновить группу %{group} "
      ],
      "%{group} package group update timed out": [
        "Время ожидания обновления группы %{group} истекло"
      ],
      "%{group} package group updated": [
        "Группа %{group} обновлена"
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
        "%{package} (других пакетов: %{total})"
      ],
      "%{package} (%{total} other packages) install canceled": [
        "Установка %{package} отменена (других пакетов: %{total})"
      ],
      "%{package} (%{total} other packages) install failed": [
        "Не удалось установить %{package} (других пакетов: %{total})"
      ],
      "%{package} (%{total} other packages) install timed out": [
        "Время ожидания установки %{package} истекло (других пакетов: %{total})"
      ],
      "%{package} (%{total} other packages) installed": [
        "%{package} установлен (других пакетов: %{total})"
      ],
      "%{package} (%{total} other packages) remove canceled": [
        "Удаление %{package} отменено (других пакетов: %{total})"
      ],
      "%{package} (%{total} other packages) remove failed": [
        "Не удалось удалить %{package} (других пакетов: %{total})"
      ],
      "%{package} (%{total} other packages) remove timed out": [
        "Время ожидания удаления %{package} истекло (других пакетов: %{total})"
      ],
      "%{package} (%{total} other packages) removed": [
        "%{package} удален (других пакетов: %{total})"
      ],
      "%{package} (%{total} other packages) update canceled": [
        "Обновление %{package} отменено (других пакетов: %{total})"
      ],
      "%{package} (%{total} other packages) update failed": [
        "Не удалось обновить %{package} (других пакетов: %{total})"
      ],
      "%{package} (%{total} other packages) update timed out": [
        "Время ожидания обновления %{package} истекло (других пакетов: %{total})"
      ],
      "%{package} (%{total} other packages) updated": [
        "%{package} обновлен (других пакетов: %{total})"
      ],
      "%{package} package install canceled": [
        "Установка %{package} отменена"
      ],
      "%{package} package install timed out": [
        "Время ожидания установки %{package} истекло"
      ],
      "%{package} package remove canceled": [
        "Удаление %{package} отменено"
      ],
      "%{package} package remove failed": [
        "Не удалось удалить %{package}"
      ],
      "%{package} package remove timed out": [
        "Время ожидания удаления %{package} истекло"
      ],
      "%{package} package removed": [
        "%{package} удален"
      ],
      "%{package} package update canceled": [
        "Обновление %{package} отменено"
      ],
      "%{package} package update failed": [
        "Не удалось обновить %{package}"
      ],
      "%{package} package update timed out": [
        "Время ожидания обновления %{package} истекло"
      ],
      "%{package} package updated": [
        "%{package} обновлен"
      ],
      "%{release}: %{number_of_hosts} hosts are approaching end of %{lifecycle} on %{end_date}. Please upgrade them before support expires. Check Report Host - Statuses for detail.": [
        ""
      ],
      "%{sla}": [
        "%{sla}"
      ],
      "%{subject}'s disk is %{percentage} full. Since this proxy is running Pulp, it needs disk space to publish content views. Please ensure the disk does not get full.": [
        ""
      ],
      "%{unused_substitutions} cannot be specified for %{content_name} as that information is not substitutable in %{content_url} ": [
        ""
      ],
      "%{used} of %{total}": [
        "%{used} из %{total}"
      ],
      "%{value} can contain only lowercase letters, numbers, dashes and dots.": [
        ""
      ],
      "%{view_label} could not be promoted to %{environment_label} because the content view and the environment are not in the same organization!": [
        ""
      ],
      "'%{item}' does not exist in the backend system [ Candlepin ].  Either remove and re-enable the repository or try refreshing the manifest before synchronizing. ": [
        ""
      ],
      "'%{item}' does not exist in the backend system [ Candlepin ].  Either remove the invalid repository or try refreshing the manifest before promoting. ": [
        ""
      ],
      "'%{item}' does not exist in the backend system [ Candlepin ].  Remove and recreate the repository before synchronizing. ": [
        ""
      ],
      "'%{item}' does not exist in the backend system [ Candlepin ].  Remove the invalid repository before promoting. ": [
        ""
      ],
      "'%{item}' in this content view does not exist in the backend system [ Candlepin ].  Either remove the invalid repository or try refreshing the manifest before publishing again. ": [
        ""
      ],
      "'%{item}' in this content view does not exist in the backend system [ Candlepin ].  Remove the invalid repository before publishing again. ": [
        ""
      ],
      "(Orphaned)": [
        "(потерян)"
      ],
      "(unset)": [
        ""
      ],
      ", and": [
        ""
      ],
      ", must be unique to major and version id version.": [
        ""
      ],
      ": '%s' is a built-in environment": [
        ""
      ],
      ":a_resource identifier": [
        ""
      ],
      "<b>PROMOTION</b> SUMMARY": [
        "СВОДКА <b>ПЕРЕНОСОВ</b> "
      ],
      "<b>SYNC</b> SUMMARY": [
        "СВОДКА <b>СИНХРОНИЗАЦИИ</b>"
      ],
      "A CV version already exists with the same major and minor version (%{major}.%{minor})": [
        ""
      ],
      "A Pool and its Subscription cannot belong to different organizations.": [
        ""
      ],
      "A backend service [ %s ] is unreachable": [
        "Базовая служба [ %s ] недоступна"
      ],
      "A large number of errata are unapplied in this content view, so only the first 100 are shown.": [
        "Показаны первые 100 непримененных исправлений."
      ],
      "A large number of errata were synced for this repository, so only the first 100 are shown.": [
        "Исправления синхронизированы. Здесь показаны первые 100 исправлений."
      ],
      "A list of subscriptions expiring soon": [
        ""
      ],
      "A new version of ": [
        ""
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
        "Сводный отчет после переноса представлений со списком узлов, для которых доступны исправления"
      ],
      "A remote execution job is in progress": [
        ""
      ],
      "A remote execution job is in progress.": [
        ""
      ],
      "A service level for auto-healing process, e.g. SELF-SUPPORT": [
        "Уровень обслуживания для автоматического восстановления (например, SELF-SUPPORT)"
      ],
      "A smart proxy seems to have been refreshed without pulpcore being running. Please refresh the smart proxy after ensuring that pulpcore services are running.": [
        ""
      ],
      "A summary of available and applicable errata for your hosts": [
        "Краткий обзор исправлений для ваших узлов"
      ],
      "A summary of new errata after a repository is synchronized": [
        "Краткий обзор новых исправлений после синхронизации репозитория"
      ],
      "ANY": [
        ""
      ],
      "About page": [
        ""
      ],
      "Abstract": [
        ""
      ],
      "Abstract async task": [
        "Абстрактная асинхронная задача"
      ],
      "Access to Red Hat Subscription Management is prohibited. If you would like to change this, please update the content setting 'Subscription connection enabled'.": [
        ""
      ],
      "Account Number": [
        "Номер учетной записи"
      ],
      "Action": [
        "Команда"
      ],
      "Action not allowed for the default smart proxy.": [
        ""
      ],
      "Action unauthorized to be performed in this organization.": [
        ""
      ],
      "Activation Key information": [
        ""
      ],
      "Activation Key will no longer be available for use. This operation cannot be undone.": [
        ""
      ],
      "Activation Keys": [
        "Ключи активации"
      ],
      "Activation key": [
        "Ключ активации"
      ],
      "Activation key ID": [
        "Идентификатор ключа активации"
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
        ""
      ],
      "Activation key(s) to use during registration": [
        ""
      ],
      "Activation keys": [
        ""
      ],
      "Activation keys can be managed {here}.": [
        ""
      ],
      "Activation keys for subscription-manager client, required for CentOS and Red Hat Enterprise Linux. Required only if host group has no activation keys.": [
        ""
      ],
      "Activation keys may be used during {system_registration}.": [
        ""
      ],
      "Activation keys: ": [
        ""
      ],
      "Active only": [
        "Активные"
      ],
      "Add": [
        "Добавить"
      ],
      "Add Bookmark": [
        "Добавить закладку"
      ],
      "Add DEB rule": [
        ""
      ],
      "Add RPM rule": [
        ""
      ],
      "Add Subscriptions": [
        ""
      ],
      "Add a subscription to a host": [
        "Выделить подписки узлу"
      ],
      "Add an alternate content source": [
        ""
      ],
      "Add components to the content view": [
        ""
      ],
      "Add content": [
        ""
      ],
      "Add content view": [
        ""
      ],
      "Add content views": [
        ""
      ],
      "Add custom cron logic for sync plan": [
        ""
      ],
      "Add errata": [
        ""
      ],
      "Add filter rule": [
        ""
      ],
      "Add host to collections": [
        ""
      ],
      "Add host to host collections": [
        ""
      ],
      "Add host to the host collection": [
        "Добавить узел в коллекцию"
      ],
      "Add lifecycle environments to the smart proxy": [
        ""
      ],
      "Add new bookmark": [
        ""
      ],
      "Add one or more host collections to one or more hosts": [
        "Добавить узлы в коллекции"
      ],
      "Add ons": [
        ""
      ],
      "Add products to sync plan": [
        "Включить продукты в план синхронизации"
      ],
      "Add repositories": [
        ""
      ],
      "Add repositories with package groups to content view to select them here.": [
        ""
      ],
      "Add rule": [
        ""
      ],
      "Add source": [
        ""
      ],
      "Add subscriptions": [
        ""
      ],
      "Add subscriptions consumed by a manifest from Red Hat Subscription Management": [
        ""
      ],
      "Add subscriptions to one or more hosts": [
        ""
      ],
      "Add subscriptions using the Add Subscriptions button.": [
        ""
      ],
      "Add to a host collection": [
        ""
      ],
      "Add-ons": [
        ""
      ],
      "Added": [
        ""
      ],
      "Added %s": [
        ""
      ],
      "Added Content:": [
        ""
      ],
      "Added component to content view": [
        ""
      ],
      "Additional content": [
        ""
      ],
      "Affected Repositories": [
        ""
      ],
      "Affected repositories": [
        ""
      ],
      "After configuring Foreman, configuration must also be updated on {hosts}. Choose one of the following options to update {hosts}:": [
        ""
      ],
      "After generating the incremental update, apply the changes to the specified hosts.  Only Errata are supported currently.": [
        "После генерации инкрементного обновления применить изменения к выбранным системам. В настоящее время поддерживаются только исправления."
      ],
      "All": [
        "Все"
      ],
      "All Media": [
        "Все носители"
      ],
      "All Repositories": [
        "Все репозитории"
      ],
      "All available architectures for this repo are enabled.": [
        ""
      ],
      "All errata applied": [
        "Все исправления применены"
      ],
      "All errata up-to-date": [
        ""
      ],
      "All subpaths must have a slash at the end and none at the front": [
        ""
      ],
      "All up to date": [
        ""
      ],
      "All versions": [
        ""
      ],
      "All versions will be removed from these environments": [
        ""
      ],
      "Allow a host to be registered to multiple content view environments with 'subscription-manager register --environments'.": [
        ""
      ],
      "Allow deleting repositories in published content views": [
        ""
      ],
      "Allow host registrations to bypass 'Host Profile Assume' as long as the host is in build mode.": [
        ""
      ],
      "Allow hosts to re-register themselves only when they are in build mode": [
        ""
      ],
      "Allow multiple content views": [
        ""
      ],
      "Allow new host registrations to assume registered profiles with matching hostname as long as the registering DMI UUID is not used by another host.": [
        ""
      ],
      "Also include the latest upgradable package version for each host package": [
        ""
      ],
      "Alter a host's host collections": [
        ""
      ],
      "Alternate Content Source HTTP Proxy": [
        ""
      ],
      "Alternate Content Sources": [
        ""
      ],
      "Alternate content source ${name} created": [
        ""
      ],
      "Alternate content source ID": [
        ""
      ],
      "Alternate content source deleted": [
        ""
      ],
      "Alternate content source edited": [
        ""
      ],
      "Alternate content sources define new locations to download content from at repository or smart proxy sync time.": [
        ""
      ],
      "Alternate content sources use the HTTP proxy of their assigned smart proxy for communication.": [
        ""
      ],
      "Always Use Latest (currently %{version})": [
        ""
      ],
      "Always update to latest version": [
        ""
      ],
      "Amount of workers in the pool to handle the execution of host-related tasks. When set to 0, the default queue will be used instead. Restart of the dynflowd/foreman-tasks service is required.": [
        ""
      ],
      "An alternate content source can be added by using the \\\\\\\"Add source\\\\\\\" button below.": [
        ""
      ],
      "An environment is missing a prior": [
        ""
      ],
      "An error occurred during the sync \\n%{error_message}": [
        "Во время синхронизации произошла ошибка:\\n%{error_message}"
      ],
      "An error occurred during upload \\n%{error_message}": [
        ""
      ],
      "Another component already includes content view with ID %s": [
        ""
      ],
      "Ansible Collection": [
        ""
      ],
      "Ansible Collections": [
        ""
      ],
      "Ansible collection": [
        ""
      ],
      "Ansible collections": [
        ""
      ],
      "Applicability Batch Size": [
        ""
      ],
      "Applicable": [
        "Применимо"
      ],
      "Applicable Content Hosts": [
        ""
      ],
      "Applicable errata apply to at least one package installed on the host.": [
        ""
      ],
      "Application": [
        "Программа"
      ],
      "Apply": [
        "Применить"
      ],
      "Apply erratum": [
        ""
      ],
      "Apply to all repositories in the CV": [
        ""
      ],
      "Apply to subset of repositories": [
        ""
      ],
      "Apply via customized remote execution": [
        ""
      ],
      "Apply via remote execution": [
        ""
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
        "Архитектура"
      ],
      "Architecture": [
        "Архитектура"
      ],
      "Architecture of content in the repository": [
        ""
      ],
      "Architecture restricted to {archRestricted}. If host architecture does not match, the repository will not be available on this host.": [
        ""
      ],
      "Architecture(s)": [
        "Архитектура"
      ],
      "Are you sure you want to delete %(entitlementCount)s subscription(s)? This action will remove the subscription(s) and refresh your manifest. All systems using these subscription(s) will lose them and also may lose access to updates and Errata.": [
        ""
      ],
      "Are you sure you want to delete the manifest?": [
        ""
      ],
      "Array of Content override parameters": [
        ""
      ],
      "Array of Content override parameters to be added in bulk": [
        ""
      ],
      "Array of Pools to be updated. Only pools originating upstream are accepted.": [
        ""
      ],
      "Array of Trace IDs": [
        ""
      ],
      "Array of components to add": [
        ""
      ],
      "Array of content view component IDs to remove. Identifier of the component association": [
        ""
      ],
      "Array of host ids": [
        "Список идентификаторов узлов"
      ],
      "Array of local pool IDs. Only pools originating upstream are accepted.": [
        ""
      ],
      "Array of pools to add": [
        ""
      ],
      "Array of subscriptions to add": [
        "Массив добавляемых подписок"
      ],
      "Array of subscriptions to remove": [
        "Массив удаляемых подписок"
      ],
      "Array of uploads to import": [
        ""
      ],
      "Artifact Id and relative path are needed to create content": [
        ""
      ],
      "Artifacts": [
        ""
      ],
      "Assign system purpose attributes on one or more hosts": [
        ""
      ],
      "Assign the %{count} host with no %{taxonomy_single} to %{taxonomy_name}": [
        "",
        ""
      ],
      "Assign the environment and content view to one or more hosts": [
        ""
      ],
      "Assign the release version to one or more hosts": [
        ""
      ],
      "Associated location IDs": [
        ""
      ],
      "Associated version": [
        ""
      ],
      "Associations": [
        "Связи"
      ],
      "At least one Content View Version must be specified": [
        "Необходимо выбрать хотя бы одну версию представления"
      ],
      "At least one activation key must be provided": [
        "Требуется ключ активации."
      ],
      "At least one activation key must have a lifecycle environment and content view assigned to it": [
        "По крайней мере одному ключу активации должно быть сопоставлено представление и окружение жизненного цикла"
      ],
      "At least one of the selected items requires the host to reboot": [
        ""
      ],
      "At least one organization must exist.": [
        "Должна существовать как минимум одна организация."
      ],
      "Atleast one errata type needs to be selected.": [
        ""
      ],
      "Attach a subscription": [
        "Назначить подписку"
      ],
      "Attach subscriptions": [
        "Выделить подписки"
      ],
      "Attach subscriptions to %s": [
        "Выделить подписки %s"
      ],
      "Attempted to destroy consumer %s from candlepin, but consumer does not exist in candlepin": [
        ""
      ],
      "Auth URL requires Auth token be set.": [
        ""
      ],
      "Authentication type": [
        ""
      ],
      "Author": [
        "Автор"
      ],
      "Auto Publish - Triggered by '%s'": [
        ""
      ],
      "Auto attach subscriptions": [
        "Выбрать подписки автоматически"
      ],
      "Auto publish": [
        ""
      ],
      "Autopublish": [
        ""
      ],
      "Available": [
        "Доступно"
      ],
      "Available Entitlements": [
        ""
      ],
      "Available Repositories": [
        ""
      ],
      "Available schema versions": [
        ""
      ],
      "Back": [
        "Назад"
      ],
      "Backend System Status": [
        "Состояние базовой системы"
      ],
      "Base URL": [
        ""
      ],
      "Base URL for finding alternate content": [
        ""
      ],
      "Base URL to perform repo discovery on": [
        ""
      ],
      "Basearch to disable": [
        "Исключить $basearch"
      ],
      "Basearch to enable": [
        "Включить $basearch"
      ],
      "Basic authentication password": [
        ""
      ],
      "Basic authentication username": [
        ""
      ],
      "Batch size to sync repositories in.": [
        ""
      ],
      "Before continuing, ensure that all of the following prerequisites are met:": [
        ""
      ],
      "Before removing versions you must move activation keys to an environment where the associated version is not in use.": [
        ""
      ],
      "Before removing versions you must move hosts to an environment where the associated version is not in use. ": [
        ""
      ],
      "Below are the repository sets currently available for this content host. For Red Hat subscriptions, additional content can be made available through the {rhrp}. Changing default settings requires subscription-manager 1.10 or newer to be installed on this host.": [
        ""
      ],
      "Beta": [
        "Beta"
      ],
      "Bind an entitlement to an allocation": [
        ""
      ],
      "Bind entitlements to an allocation": [
        ""
      ],
      "Bookmark this search": [
        "Добавить в закладки"
      ],
      "Bookmarks marked as public are available to all users": [
        ""
      ],
      "Both": [
        ""
      ],
      "Both major and minor parameters have to be used to override a CV version": [
        ""
      ],
      "Bug Fix": [
        "Исправление"
      ],
      "Bugfix": [
        "Исправление ошибок"
      ],
      "Bugs": [
        ""
      ],
      "Bulk alternate content source delete has started.": [
        ""
      ],
      "Bulk alternate content source refresh has started.": [
        ""
      ],
      "Bulk generate applicability for host %s": [
        ""
      ],
      "Bulk generate applicability for hosts": [
        ""
      ],
      "Bulk remove versions from a content view and reassign systems and keys": [
        ""
      ],
      "CDN Configuration": [
        ""
      ],
      "CDN Configuration for Red Hat Content": [
        ""
      ],
      "CDN Configuration updated.": [
        ""
      ],
      "CDN configuration is set to Export Sync (disconnected). Repository enablement/disablement is not permitted on this page.": [
        ""
      ],
      "CDN configuration type. One of %s.": [
        ""
      ],
      "CDN loading error: %s not found": [
        ""
      ],
      "CDN loading error: access denied to %s": [
        ""
      ],
      "CDN loading error: access forbidden to %s": [
        ""
      ],
      "CVE identifier": [
        "Идентификатор CVE"
      ],
      "CVEs": [
        "CVE"
      ],
      "Calculate Applicable Errata based on a particular Content View": [
        "Определить подходящие исправления для заданного представления"
      ],
      "Calculate Applicable Errata based on a particular Environment": [
        "Определить подходящие исправления для заданного окружения"
      ],
      "Can communicate with the Red Hat Portal for subscriptions.": [
        ""
      ],
      "Can only remove content from within the Default Content View": [
        "Содержимое может удаляться только из представления, используемого по умолчанию"
      ],
      "Can't update the '%s' environment": [
        "Не удалось обновить окружение «%s»"
      ],
      "Cancel": [
        "Отмена"
      ],
      "Cancel repository discovery": [
        "Отменить поиск репозиториев"
      ],
      "Cancel running smart proxy synchronization": [
        ""
      ],
      "Canceled": [
        "Отменена"
      ],
      "Cancelled.": [
        "Отменено."
      ],
      "Candlepin": [
        ""
      ],
      "Candlepin Event": [
        "Событие Candlepin"
      ],
      "Candlepin ID of pool to add": [
        ""
      ],
      "Candlepin consumer %s has already been removed": [
        ""
      ],
      "Candlepin is not running properly": [
        ""
      ],
      "Candlepin returned different consumer uuid than requested (%s), updating uuid in subscription_facet.": [
        ""
      ],
      "Cannot add %s repositories to a content view.": [
        "Репозитории %s не могут быть добавлены в представление."
      ],
      "Cannot add a repository from an Organization other than %s.": [
        "Репозитории могут добавляться только из организации %s."
      ],
      "Cannot add component versions to a non-composite content view": [
        "Версии, составляющие сложное представление, не могут добавляться в простое представление"
      ],
      "Cannot add composite versions to a composite content view": [
        "Составные версии не могут быть добавлены в составное представление"
      ],
      "Cannot add composite versions to another composite content view": [
        "Сложные версии не могут добавляться в другое сложное представление"
      ],
      "Cannot add default content view to composite content view": [
        "Исходное представление не может входить в составное представление"
      ],
      "Cannot add disabled Red Hat product %s to sync plan!": [
        ""
      ],
      "Cannot add disabled products to sync plan!": [
        ""
      ],
      "Cannot add generated content view versions to composite content view": [
        ""
      ],
      "Cannot add product %s because it is disabled.": [
        ""
      ],
      "Cannot add repositories to a composite content view": [
        "Нельзя добавлять репозитории в сложное представление"
      ],
      "Cannot associate a Red Hat provider with a custom product": [
        ""
      ],
      "Cannot associate a component to a non composite content view": [
        ""
      ],
      "Cannot be disabled because it is part of a published content view": [
        ""
      ],
      "Cannot calculate name for custom repos": [
        ""
      ],
      "Cannot clone into the Default Content View": [
        ""
      ],
      "Cannot delete '%{view}' due to associated %{dependent}: %{names}.": [
        ""
      ],
      "Cannot delete Red Hat product: %{product}": [
        ""
      ],
      "Cannot delete from %s, view does not exist there.": [
        "Нельзя удалить представление из %s, так как его там нет"
      ],
      "Cannot delete product with repositories published in a content view.  Product: %{product}, %{view_versions}": [
        ""
      ],
      "Cannot delete product: %{product} with repositories that are the last affected repository in content view filters. Delete these repositories before deleting product.": [
        ""
      ],
      "Cannot delete provider with attached products": [
        "Вы не можете удалить провайдер, который связан с продуктами"
      ],
      "Cannot delete redhat product content": [
        ""
      ],
      "Cannot delete the default Location for subscribed hosts. If you no longer want this Location, change the default Location for subscribed hosts under Administer > Settings, tab Content.": [
        ""
      ],
      "Cannot delete the last Location.": [
        ""
      ],
      "Cannot delete version while it is in environment %s": [
        "Прежде чем удалить версию, исключите ее из окружения %s"
      ],
      "Cannot delete version while it is in environments: %s": [
        ""
      ],
      "Cannot delete version while it is in use by composite content views: %s": [
        ""
      ],
      "Cannot delete view while it exists in environments": [
        "Прежде чем удалить представление, исключите его из окружений"
      ],
      "Cannot import a composite content view": [
        ""
      ],
      "Cannot import a custom subscription from a redhat product.": [
        ""
      ],
      "Cannot incrementally export from a filtered and a non-filtered content view version. The exported content view version '%{content_view} %{current}'  cannot be incrementally updated from version '%{from}.'.  Please do a full export.": [
        ""
      ],
      "Cannot incrementally export from a incrementally exported version and a regular version or vice-versa.  The exported Content View Version '%{content_view} %{current}' cannot be incrementally exported from version '%{from}.' Please do a full export.": [
        ""
      ],
      "Cannot perform an incremental update on a Composite Content View Version (%{name} version version %{version}": [
        "Невозможно выполнить инкрементное обновление для сложного представления (%{name}, версия %{version}"
      ],
      "Cannot perform an incremental update on a Generated Content View Version (%{name} version version %{version}": [
        ""
      ],
      "Cannot promote environment out of sequence. Use force to bypass restriction.": [
        "Представление должно продвигаться последовательно по цепочке. Чтобы снять ограничения, включите принудительный режим."
      ],
      "Cannot publish a composite with rpm filenames": [
        ""
      ],
      "Cannot publish a link repository if multiple component clones are specified": [
        ""
      ],
      "Cannot publish default content view": [
        "Исходное представление не может быть опубликовано"
      ],
      "Cannot register a system to the '%s' environment": [
        "Не удалось зарегистрировать систему в окружении «%s»"
      ],
      "Cannot remove '%{view}' from environment '%{env}' due to associated %{dependent}: %{names}.": [
        ""
      ],
      "Cannot remove content from a non-custom repository": [
        "Содержимое репозиториев Red Hat не может быть удалено."
      ],
      "Cannot remove content view from environment. Content view '%{view}' is not in lifecycle environment '%{env}'.": [
        "Представление «%{view}» не входит в окружение «%{env}»."
      ],
      "Cannot set attribute %{attr} for content type %{type}": [
        ""
      ],
      "Cannot set auto publish to a non-composite content view": [
        ""
      ],
      "Cannot skip metadata check on non-yum/deb repositories.": [
        ""
      ],
      "Cannot specify components for non-composite views": [
        "Простые представления не могут содержать другие представления"
      ],
      "Cannot specify content for composite views": [
        "Сложное представление не может включать в себя содержимое напрямую"
      ],
      "Cannot sync file:// repositories with the On Demand Download Policy": [
        ""
      ],
      "Cannot upload Ansible collections.": [
        ""
      ],
      "Cannot upload Container Image content.": [
        ""
      ],
      "Capacity": [
        "Вместимость"
      ],
      "Change Content Source": [
        ""
      ],
      "Change content source": [
        ""
      ],
      "Change content view environments": [
        ""
      ],
      "Change host content source": [
        ""
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
        ""
      ],
      "Check services before actions": [
        ""
      ],
      "Checksum": [
        "Контрольная сумма"
      ],
      "Checksum is a required parameter.": [
        ""
      ],
      "Checksum of file to upload": [
        ""
      ],
      "Checksum of the repository, currently 'sha1' & 'sha256' are supported": [
        ""
      ],
      "Checksum type cannot be set for yum repositories with on demand download policy.": [
        ""
      ],
      "Choose content credentials if required for this RHUI source.": [
        ""
      ],
      "Clear any previous registration and run subscription-manager with --force.": [
        ""
      ],
      "Clear filters": [
        ""
      ],
      "Clear search": [
        ""
      ],
      "Click here to go to the tasks page for the task.": [
        ""
      ],
      "Click to see repositories available to add.": [
        ""
      ],
      "Click {update} below to save changes.": [
        ""
      ],
      "Clone": [
        "Клонировать"
      ],
      "Close": [
        "Закрыть"
      ],
      "Collapse All": [
        "Свернуть все"
      ],
      "Comma-separated list of subpaths. All subpaths must have a slash at the end and none at the front.": [
        ""
      ],
      "Comma-separated list of tags to exclude when syncing a container image repository. Default: any tag ending in \\\"-source\\\"": [
        ""
      ],
      "Comma-separated list of tags to sync for a container image repository": [
        ""
      ],
      "Compare": [
        ""
      ],
      "Component": [
        "Компонент"
      ],
      "Component Content View": [
        ""
      ],
      "Component Version: '%{cvv}', Product: '%{product}', Repository: '%{repo}' ": [
        ""
      ],
      "Components": [
        "Компоненты"
      ],
      "Composite": [
        "Составное"
      ],
      "Composite Content View": [
        ""
      ],
      "Composite Content View '%{subject}' failed auto-publish": [
        ""
      ],
      "Composite content view": [
        "Составное представление"
      ],
      "Composite content views": [
        ""
      ],
      "Compute resource IDs": [
        "Идентификаторы ресурсов"
      ],
      "Configuration still must be updated on {hosts}": [
        ""
      ],
      "Configuration updated on Foreman": [
        ""
      ],
      "Confirm Deletion": [
        ""
      ],
      "Confirm delete manifest": [
        ""
      ],
      "Consider changing the Lifecycle Environment's Registry Name Pattern to something more specific.": [
        ""
      ],
      "Consisting of multiple content views": [
        ""
      ],
      "Consists of content views": [
        ""
      ],
      "Consists of repositories": [
        ""
      ],
      "Consumed": [
        "Используется"
      ],
      "Container Image Manifest": [
        ""
      ],
      "Container Image Repositories are not protected at this time. They need to be published via http to be available to containers.": [
        ""
      ],
      "Container Image Tag": [
        ""
      ],
      "Container Image Tags": [
        ""
      ],
      "Container Image repo '%{repo}' is present in multiple component content views.": [
        ""
      ],
      "Container Images": [
        ""
      ],
      "Container image tag": [
        ""
      ],
      "Container image tags": [
        ""
      ],
      "Container manifest lists": [
        ""
      ],
      "Container manifests": [
        ""
      ],
      "Container tags": [
        ""
      ],
      "Content": [
        "Содержимое"
      ],
      "Content Count": [
        ""
      ],
      "Content Credential ID": [
        ""
      ],
      "Content Credential numeric identifier": [
        ""
      ],
      "Content Credential to use for SSL CA. Relevant only for 'upstream_server' type.": [
        ""
      ],
      "Content Credentials": [
        ""
      ],
      "Content Details": [
        ""
      ],
      "Content Download URL": [
        "URL загрузки содержимого"
      ],
      "Content Facet for host with id %s is non-existent. Skipping applicability calculation.": [
        ""
      ],
      "Content Hosts": [
        "Узлы содержимого"
      ],
      "Content Source": [
        "Источник содержимого"
      ],
      "Content Sync": [
        "Синхронизация содержимого"
      ],
      "Content Types": [
        ""
      ],
      "Content View": [
        "Представление"
      ],
      "Content View %{view}: Versions: %{versions}": [
        ""
      ],
      "Content View Details": [
        ""
      ],
      "Content View Filter id": [
        "Идентификатор фильтра представления"
      ],
      "Content View Filter identifier. Use to filter by ID": [
        ""
      ],
      "Content View ID": [
        "Идентификатор представления"
      ],
      "Content View Name": [
        "Имя представления"
      ],
      "Content View Version %{id} not in all specified environments %{envs}": [
        "Версия %{id} не входит в состав всех окружений %{envs}"
      ],
      "Content View Version Ids to perform an incremental update on.  May contain composites as well as one or more components to update.": [
        "Идентификаторы версий представления для инкрементного обновления. Может включать и сложные представления, и отдельные компоненты."
      ],
      "Content View Version identifier": [
        ""
      ],
      "Content View Version not set": [
        ""
      ],
      "Content View Version specified in the metadata - '%{name}' already exists. If you wish to replace the existing version, delete %{name} and try again. ": [
        ""
      ],
      "Content View Version: '%{cvv}', Product: '%{product}', Repository: '%{repo}' ": [
        ""
      ],
      "Content View id": [
        ""
      ],
      "Content View label not provided.": [
        ""
      ],
      "Content Views": [
        "Представления"
      ],
      "Content cannot be imported into a Composite Content View. ": [
        ""
      ],
      "Content credential": [
        ""
      ],
      "Content credentials": [
        ""
      ],
      "Content facet for host %s has more than one content view. Use #content_views instead.": [
        ""
      ],
      "Content facet for host %s has more than one lifecycle environment. Use #lifecycle_environments instead.": [
        ""
      ],
      "Content files to upload. Can be a single file or array of files.": [
        "Отправляемые файлы (один или несколько)."
      ],
      "Content host must be unregistered before performing this action.": [
        ""
      ],
      "Content hosts": [
        ""
      ],
      "Content imported by %{user} into content view '%{name}'": [
        ""
      ],
      "Content not uploaded to pulp": [
        ""
      ],
      "Content override search parameters": [
        ""
      ],
      "Content source": [
        ""
      ],
      "Content source ID": [
        ""
      ],
      "Content source was not set for host '%{host}'": [
        ""
      ],
      "Content type": [
        ""
      ],
      "Content type %{content_type_string} does not belong to an enabled repo type.": [
        ""
      ],
      "Content type %{content_type} is incompatible with repositories of type %{repo_type}": [
        ""
      ],
      "Content view": [
        ""
      ],
      "Content view ${name} created": [
        ""
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
        "Представление «%{view} не входит в окружение «%{env}»."
      ],
      "Content view '%{view}' is not in lifecycle environment '%{env}'.": [
        "Представление «%{view} не входит в окружение «%{env}»."
      ],
      "Content view ID": [
        ""
      ],
      "Content view and environment not set for registration.": [
        ""
      ],
      "Content view and lifecycle environment must be provided together": [
        ""
      ],
      "Content view details": [
        ""
      ],
      "Content view does not need a publish since there are no audited changes since the last publish. Pass check_needs_publish parameter as false if you don't want to check if content view needs a publish.": [
        ""
      ],
      "Content view environments and activation key must all belong to the same organization": [
        ""
      ],
      "Content view environments must have both a content view and an environment": [
        ""
      ],
      "Content view has repository label '%s' which is not specified in repos_units parameter.": [
        ""
      ],
      "Content view identifier": [
        "Идентификатор представления"
      ],
      "Content view label": [
        "Метка представления"
      ],
      "Content view must be specified": [
        ""
      ],
      "Content view name": [
        ""
      ],
      "Content view not provided in the metadata": [
        ""
      ],
      "Content view numeric identifier": [
        "Числовой идентификатор представления"
      ],
      "Content view promote failure": [
        ""
      ],
      "Content view publish failure": [
        ""
      ],
      "Content view version export history identifier": [
        ""
      ],
      "Content view version identifier": [
        "Идентификатор версии представления"
      ],
      "Content view version import history identifier": [
        ""
      ],
      "Content view version is empty": [
        ""
      ],
      "Content views": [
        ""
      ],
      "Content will be synced from the alternate content source first, then the original source if the ACS is not reachable.": [
        ""
      ],
      "Content_Host_Status": [
        ""
      ],
      "Contents of requirement yaml file to sync from URL": [
        ""
      ],
      "Context": [
        ""
      ],
      "Contract": [
        "Контракт"
      ],
      "Contract Number": [
        "Номер контракта"
      ],
      "Copied to clipboard": [
        ""
      ],
      "Copy": [
        ""
      ],
      "Copy an activation key": [
        "Копировать ключ активации"
      ],
      "Copy content view": [
        ""
      ],
      "Copy to clipboard": [
        "Скопировано в буфер обмена"
      ],
      "Copy version units to library": [
        ""
      ],
      "Cores per socket": [
        "Ядер на сокет"
      ],
      "Cores: %s": [
        ""
      ],
      "Could not delete organization '%s'.": [
        "Ошибка удаления организации «%s»."
      ],
      "Could not find %{content} with id '%{id}' in repository.": [
        "%{content} с идентификатором «%{id}» в репозитории не найдено."
      ],
      "Could not find %{count} errata.  Only found: %{found}": [
        ""
      ],
      "Could not find %{name} resource with id %{id}. %{perms_message}": [
        ""
      ],
      "Could not find %{name} resources with ids %{ids}": [
        ""
      ],
      "Could not find Environment with ids: %s": [
        ""
      ],
      "Could not find Lifecycle Environment with id '%{id}'.": [
        "Окружение с идентификатором «%{id}» не найдено."
      ],
      "Could not find a host with id %s": [
        ""
      ],
      "Could not find a smart proxy with pulp feature.": [
        ""
      ],
      "Could not find all specified errata ids: %s": [
        ""
      ],
      "Could not find environments for promotion": [
        ""
      ],
      "Could not remove the lifecycle environment from the smart proxy": [
        ""
      ],
      "Couldn't establish a connection to %s": [
        ""
      ],
      "Couldn't find %{content_type} with id '%{id}'": [
        ""
      ],
      "Couldn't find %{type} Filter with id %{id}": [
        "Фильтр %{type}  с идентификатором %{id} не найден."
      ],
      "Couldn't find ContentViewFilter with id=%s": [
        "Фильтр с идентификатором %s не найден."
      ],
      "Couldn't find Organization '%s'.": [
        "Организация «%s» не найдена."
      ],
      "Couldn't find activation key '%s'": [
        "Ключ активации «%s» не найден."
      ],
      "Couldn't find activation key content view id '%s'": [
        "Представление с идентификатором «%s» для ключа активации не найдено."
      ],
      "Couldn't find activation key environment '%s'": [
        "Окружение «%s» для ключа активации не найдено."
      ],
      "Couldn't find consumer '%s'": [
        "Получатель «%s» не найден."
      ],
      "Couldn't find content host content view id '%s'": [
        "Представление с идентификатором «%s» для узла содержимого не найдено."
      ],
      "Couldn't find content host environment '%s'": [
        "Окружение «%s» не найдено."
      ],
      "Couldn't find content view '%s'": [
        "Представление «%s» не найдено."
      ],
      "Couldn't find content view version '%s'": [
        "Версия «%s» не найдена."
      ],
      "Couldn't find content view versions '%s'": [
        "Версии «%s» не обнаружены."
      ],
      "Couldn't find content view with id: '%s'": [
        ""
      ],
      "Couldn't find environment '%s'": [
        "Окружение «%s» не найдено."
      ],
      "Couldn't find errata ids '%s'": [
        "Исправления «%s» не найдены."
      ],
      "Couldn't find host collection '%s'": [
        "Коллекция «%s» не найдена"
      ],
      "Couldn't find host with host id '%s'": [
        "Узел с идентификатором «%s» не найден"
      ],
      "Couldn't find organization '%s'": [
        "Организация «%s» не найдена"
      ],
      "Couldn't find prior-environment '%s'": [
        "Предыдущее окружение «%s» не найдено"
      ],
      "Couldn't find product with id '%s'": [
        "Продукт с ID «%s» не найден."
      ],
      "Couldn't find products with id '%s'": [
        ""
      ],
      "Couldn't find repository '%s'": [
        "Репозиторий «%s»  не найден."
      ],
      "Couldn't find smart proxies with id '%s'": [
        ""
      ],
      "Couldn't find smart proxies with name '%s'": [
        ""
      ],
      "Couldn't find specified content view and lifecycle environment.": [
        ""
      ],
      "Couldn't find subject of synchronization": [
        "Не удалось найти объект синхронизации"
      ],
      "Create": [
        "Создать"
      ],
      "Create ACS": [
        ""
      ],
      "Create Alternate Content Source": [
        ""
      ],
      "Create Export History": [
        ""
      ],
      "Create Import History": [
        ""
      ],
      "Create Repositories": [
        ""
      ],
      "Create Syncable Export History": [
        ""
      ],
      "Create a Content Credential": [
        ""
      ],
      "Create a content view": [
        "Создать представление"
      ],
      "Create a custom product": [
        ""
      ],
      "Create a custom repository": [
        "Создать дополнительный репозиторий"
      ],
      "Create a filter rule. The parameters included should be based upon the filter type.": [
        "Создать правило фильтрации. Список параметров определяется типом фильтра."
      ],
      "Create a host collection": [
        "Создать коллекцию"
      ],
      "Create a product": [
        "Создать продукт"
      ],
      "Create a sync plan": [
        "Создать план синхронизации"
      ],
      "Create an activation key": [
        "Создать ключ активации"
      ],
      "Create an alternate content source to download content from during repository syncing.  Note: alternate content sources are global and affect ALL sync actions on their smart proxies regardless of organization.": [
        ""
      ],
      "Create an environment": [
        "Создать окружение"
      ],
      "Create an environment in an organization": [
        "Создать окружение в организации"
      ],
      "Create an upload request": [
        "Создать запрос передачи"
      ],
      "Create content credentials with the generated SSL certificate and key.": [
        ""
      ],
      "Create content view": [
        ""
      ],
      "Create filter": [
        ""
      ],
      "Create host collection": [
        ""
      ],
      "Create new activation key": [
        ""
      ],
      "Create organization": [
        "Создать организацию"
      ],
      "Create package filter rule": [
        ""
      ],
      "Create rule": [
        ""
      ],
      "Credentials": [
        ""
      ],
      "Critical": [
        "Критично"
      ],
      "Cron expression is not valid!": [
        ""
      ],
      "Current organization does not have a manifest imported.": [
        ""
      ],
      "Current organization is not set.": [
        ""
      ],
      "Current organization not set.": [
        ""
      ],
      "Custom": [
        ""
      ],
      "Custom CDN": [
        ""
      ],
      "Custom Content Repositories": [
        "Другие репозитории"
      ],
      "Custom cron expression only needs to be set for interval value of custom cron": [
        ""
      ],
      "Custom repositories cannot be disabled.": [
        "Дополнительно настроенные репозитории не могут быть отключены."
      ],
      "Customize with Rex": [
        ""
      ],
      "DEB name": [
        ""
      ],
      "DEB package updates": [
        ""
      ],
      "Database connection": [
        "Подключение к базе данных"
      ],
      "Date": [
        "Дата"
      ],
      "Date format is incorrect.": [
        "Неверный формат даты."
      ],
      "Days Remaining": [
        ""
      ],
      "Days from Now": [
        ""
      ],
      "Deb": [
        ""
      ],
      "Deb Package": [
        ""
      ],
      "Deb Packages": [
        ""
      ],
      "Deb name": [
        ""
      ],
      "Deb package identifiers to filter content by": [
        ""
      ],
      "Deb packages": [
        ""
      ],
      "Debian packages": [
        ""
      ],
      "Debug Certificate": [
        "Сертификат отладки"
      ],
      "Debug RPM": [
        ""
      ],
      "Default Custom Repository download policy": [
        ""
      ],
      "Default HTTP Proxy": [
        ""
      ],
      "Default HTTP proxy for syncing content": [
        ""
      ],
      "Default Location where new subscribed hosts will put upon registration": [
        ""
      ],
      "Default PXEGrub template for new Operating Systems created from synced content": [
        ""
      ],
      "Default PXEGrub2 template for new Operating Systems created from synced content": [
        ""
      ],
      "Default PXELinux template for new Operating Systems created from synced content": [
        ""
      ],
      "Default Red Hat Repository download policy": [
        ""
      ],
      "Default Smart Proxy download policy": [
        ""
      ],
      "Default System SLA": [
        "SLA по умолчанию"
      ],
      "Default content view versions cannot be promoted": [
        "Используемое по умолчанию представление не может переноситься."
      ],
      "Default download policy for Smart Proxy syncs (either 'inherit', immediate', or 'on_demand')": [
        ""
      ],
      "Default download policy for custom repositories (either 'immediate' or 'on_demand')": [
        ""
      ],
      "Default download policy for enabled Red Hat repositories (either 'immediate' or 'on_demand')": [
        ""
      ],
      "Default export format": [
        ""
      ],
      "Default export format for content-exports(either 'syncable' or 'importable')": [
        ""
      ],
      "Default finish template for new Operating Systems created from synced content": [
        ""
      ],
      "Default iPXE template for new Operating Systems created from synced content": [
        ""
      ],
      "Default kexec template for new Operating Systems created from synced content": [
        ""
      ],
      "Default location for subscribed hosts": [
        ""
      ],
      "Default partitioning table for new Operating Systems created from synced content": [
        ""
      ],
      "Default provisioning template for Operating Systems created from synced content": [
        ""
      ],
      "Default provisioning template for new Atomic Operating Systems created from synced content": [
        ""
      ],
      "Default synced OS Atomic template": [
        ""
      ],
      "Default synced OS PXEGrub template": [
        ""
      ],
      "Default synced OS PXEGrub2 template": [
        ""
      ],
      "Default synced OS PXELinux template": [
        ""
      ],
      "Default synced OS finish template": [
        ""
      ],
      "Default synced OS iPXE template": [
        ""
      ],
      "Default synced OS kexec template": [
        ""
      ],
      "Default synced OS partition table": [
        ""
      ],
      "Default synced OS provisioning template": [
        ""
      ],
      "Default synced OS user-data": [
        ""
      ],
      "Default user data for new Operating Systems created from synced content": [
        ""
      ],
      "Define RHUI repository paths with guided steps.": [
        ""
      ],
      "Define repositories structured under a common web or filesystem path.": [
        ""
      ],
      "Delete": [
        "Удалить"
      ],
      "Delete Activation Key": [
        "Удалить ключ активации"
      ],
      "Delete Host upon unregister": [
        ""
      ],
      "Delete Lifecycle Environment": [
        "Удалить окружение"
      ],
      "Delete Manifest": [
        "Удалить манифест"
      ],
      "Delete Product": [
        "Удалить продукт"
      ],
      "Delete Upstream Subscription": [
        ""
      ],
      "Delete Version": [
        ""
      ],
      "Delete a content view": [
        "Удалить представление"
      ],
      "Delete a filter rule": [
        "Удалить правило фильтрации"
      ],
      "Delete activation key?": [
        ""
      ],
      "Delete all subscriptions attached to activation keys.": [
        ""
      ],
      "Delete all subscriptions that are attached to running hosts.": [
        ""
      ],
      "Delete an organization": [
        "Удалить организацию"
      ],
      "Delete an upload request": [
        "Удалить запрос передачи"
      ],
      "Delete content view": [
        ""
      ],
      "Delete content view filters that have this repository as the last associated repository. Defaults to true. If false, such filters will now apply to all repositories in the content view.": [
        ""
      ],
      "Delete manifest from Red Hat provider": [
        "Удалить манифест провайдера Red Hat"
      ],
      "Delete multiple filters from a content view": [
        ""
      ],
      "Delete version": [
        ""
      ],
      "Delete versions": [
        ""
      ],
      "Deleted %{host_count} %{hosts}": [
        ""
      ],
      "Deleted consumer '%s'": [
        "«%s» удален."
      ],
      "Deleted from ": [
        ""
      ],
      "Deleted from %{environment}": [
        "Удалено из %{environment}"
      ],
      "Deleting content view : ": [
        ""
      ],
      "Deleting manifest in '%{subject}' failed.": [
        ""
      ],
      "Deleting version {versionList}": [
        ""
      ],
      "Deleting versions: {versionList}": [
        ""
      ],
      "Description": [
        "Описание"
      ],
      "Description for the alternate content source": [
        ""
      ],
      "Description for the content view": [
        "Описание представления"
      ],
      "Description for the new published content view version": [
        "Описание новой версии опубликованного представления"
      ],
      "Description of the repository": [
        ""
      ],
      "Designate this Content View for importing from upstream servers only. Defaults to false": [
        ""
      ],
      "Desired quantity of the pool": [
        ""
      ],
      "Destination Server name": [
        ""
      ],
      "Destroy": [
        "Удалить"
      ],
      "Destroy Alternate Content Source": [
        ""
      ],
      "Destroy Content Host": [
        "Удалить узел"
      ],
      "Destroy Content Host %s": [
        ""
      ],
      "Destroy a Content Credential": [
        ""
      ],
      "Destroy a custom repository": [
        "Удалить настроенный репозиторий"
      ],
      "Destroy a host collection": [
        "Удалить коллекцию"
      ],
      "Destroy a product": [
        "Удалить продукт"
      ],
      "Destroy a sync plan": [
        "Удалить план синхронизации"
      ],
      "Destroy an activation key": [
        "Удалить ключ активации"
      ],
      "Destroy an alternate content source.": [
        ""
      ],
      "Destroy an environment": [
        "Удалить окружение"
      ],
      "Destroy an environment in an organization": [
        "Удалить окружение из организации"
      ],
      "Destroy one or more alternate content sources": [
        ""
      ],
      "Destroy one or more hosts": [
        "Уничтожить один или несколько узлов"
      ],
      "Destroy one or more products": [
        "Удалить продукты"
      ],
      "Destroy one or more repositories": [
        "Удалить репозитории"
      ],
      "Details": [
        "Свойства"
      ],
      "Determining settings for ${name}": [
        ""
      ],
      "Digest": [
        ""
      ],
      "Directly setting package lists on composite content views is not allowed. Please update the components, then re-publish the composite.": [
        ""
      ],
      "Directory containing the exported Content View Version": [
        ""
      ],
      "Disable": [
        "Отключить"
      ],
      "Disable Red Hat Insights.": [
        ""
      ],
      "Disable Simple Content Access": [
        ""
      ],
      "Disable a repository from the set": [
        ""
      ],
      "Disable module stream": [
        ""
      ],
      "Disabled": [
        "Отключено"
      ],
      "Disabling Simple Content Access failed for '%{subject}'.": [
        ""
      ],
      "Discover": [
        "Поиск"
      ],
      "Discover Repositories": [
        "Поиск репозиториев"
      ],
      "Distribute archived content view versions": [
        ""
      ],
      "Do not include this array of content views": [
        "Исключить указанный массив представлений"
      ],
      "Do not wait for the ImportUpload action to finish. Default: false": [
        ""
      ],
      "Do not wait for the update action to finish. Default: true": [
        ""
      ],
      "Domain IDs": [
        "Идентификаторы доменов"
      ],
      "Download Policy of the capsule, must be one of %s": [
        ""
      ],
      "Download a debug certificate": [
        "Загрузить сертификат отладки"
      ],
      "Download rate limit": [
        ""
      ],
      "Duplicate artifact detected": [
        ""
      ],
      "Duplicate repositories in content view versions": [
        ""
      ],
      "Duration": [
        "Продолжительность"
      ],
      "ERRATA ADVISORY": [
        "РЕКОМЕНДАЦИИ ИСПРАВЛЕНИЙ"
      ],
      "Edit": [
        "Изменить"
      ],
      "Edit RPM rule": [
        ""
      ],
      "Edit URL and subpaths": [
        ""
      ],
      "Edit activation key": [
        ""
      ],
      "Edit content view assignment": [
        ""
      ],
      "Edit content view environments": [
        ""
      ],
      "Edit credentials": [
        ""
      ],
      "Edit details": [
        ""
      ],
      "Edit filter rule": [
        ""
      ],
      "Edit package filter rule": [
        ""
      ],
      "Edit products": [
        ""
      ],
      "Edit rule": [
        ""
      ],
      "Edit smart proxies": [
        ""
      ],
      "Edit system purpose attributes": [
        ""
      ],
      "Editing Entitlements": [
        ""
      ],
      "Either both parameters 'content_view_id' and 'environment_id' should be specified or neither should be specified": [
        "content_view_id и environment_id не могут использоваться по отдельности"
      ],
      "Either environments or versions must be specified.": [
        "Необходимо указать окружение или версию"
      ],
      "Either organization ID or environment ID needs to be specified": [
        "Необходимо указать ID организации или окружения"
      ],
      "Either packages or groups must be provided": [
        "Необходимо предоставить список пакетов или их групп "
      ],
      "Either set the content view with the latest flag or set the content view version": [
        ""
      ],
      "Either set the latest content view or the content view version. Cannot set both": [
        ""
      ],
      "Empty content view versions": [
        ""
      ],
      "Enable": [
        "Включить"
      ],
      "Enable Red Hat repositories": [
        ""
      ],
      "Enable Simple Content Access": [
        ""
      ],
      "Enable Tracer": [
        ""
      ],
      "Enable Traces": [
        ""
      ],
      "Enable a repository from the set": [
        "Включить репозиторий из набора"
      ],
      "Enable repository sets": [
        ""
      ],
      "Enable/Disable auto publish of composite view": [
        ""
      ],
      "Enabled": [
        "Включен"
      ],
      "Enabled Repositories": [
        "Активные репозитории"
      ],
      "Enabling Simple Content Access failed for '%{subject}'.": [
        ""
      ],
      "Enabling Tracer requires installing the katello-host-tools-tracer package on the host.": [
        ""
      ],
      "End Date": [
        "Срок действия"
      ],
      "End date": [
        ""
      ],
      "Ends": [
        "Заканчивается"
      ],
      "Enhancement": [
        "Расширенные функции"
      ],
      "Enter a name": [
        ""
      ],
      "Enter a name for your source.": [
        ""
      ],
      "Enter a valid date: MM/DD/YYYY": [
        ""
      ],
      "Enter basic authentication information or choose content credentials if required for this source.": [
        ""
      ],
      "Enter in the base path and any subpaths that should be searched for alternate content.": [
        ""
      ],
      "Entitlements": [
        ""
      ],
      "Environment": [
        "Окружение"
      ],
      "Environment ID": [
        ""
      ],
      "Environment IDs": [
        "Идентификаторы окружений"
      ],
      "Environment cannot be in its own promotion path": [
        "Путь переноса не может быть таким же как исходный путь"
      ],
      "Environment identifier": [
        ""
      ],
      "Environment name": [
        ""
      ],
      "Environments": [
        "Окружения"
      ],
      "Epoch": [
        ""
      ],
      "Equal to": [
        ""
      ],
      "Errata": [
        "Исправления"
      ],
      "Errata - by date range": [
        ""
      ],
      "Errata ID": [
        "Идентификатор"
      ],
      "Errata Install": [
        "Установка исправлений"
      ],
      "Errata Install scheduled by %s": [
        "Установка назначена: %s"
      ],
      "Errata and package information will be updated at the next host check-in or package action.": [
        ""
      ],
      "Errata and package information will be updated immediately.": [
        ""
      ],
      "Errata id of the erratum (RHSA-2012:108)": [
        ""
      ],
      "Errata mail": [
        "Почта"
      ],
      "Errata to exclusively include in the action": [
        ""
      ],
      "Errata to explicitly exclude in the action. All other applicable errata will be included in the action, unless an included parameter is passed as well.": [
        ""
      ],
      "Errata type": [
        ""
      ],
      "Erratum": [
        "Исправление"
      ],
      "Erratum Install Canceled": [
        "Установка исправления отменена"
      ],
      "Erratum Install Complete": [
        "Исправление установлено"
      ],
      "Erratum Install Failed": [
        "Не удалось установить исправление"
      ],
      "Erratum Install Timed Out": [
        "Время ожидания установки исправления истекло"
      ],
      "Error": [
        "Ошибка"
      ],
      "Error connecting to Pulp service": [
        "Произошла ошибка при подключении к сервису Pulp"
      ],
      "Error connecting. Got: %s": [
        ""
      ],
      "Error loading content views": [
        ""
      ],
      "Error refreshing status for %s: ": [
        ""
      ],
      "Error retrieving Pulp storage": [
        "Произошла ошибка при извлечении хранилища Pulp"
      ],
      "Exceeds available quantity": [
        ""
      ],
      "Exclude": [
        "Исключить"
      ],
      "Exclude all RPMs not associated to any errata": [
        ""
      ],
      "Exclude all module streams not associated to any errata": [
        ""
      ],
      "Exclude filter": [
        ""
      ],
      "Excluded": [
        ""
      ],
      "Excluded errata": [
        ""
      ],
      "Excludes": [
        ""
      ],
      "Exit": [
        ""
      ],
      "Expand All": [
        "Развернуть все"
      ],
      "Expire soon days": [
        ""
      ],
      "Expired ": [
        ""
      ],
      "Expires ": [
        ""
      ],
      "Export": [
        "Экспорт"
      ],
      "Export CSV": [
        ""
      ],
      "Export Library": [
        ""
      ],
      "Export Repository": [
        ""
      ],
      "Export Sync": [
        ""
      ],
      "Export Types": [
        ""
      ],
      "Export as CSV": [
        ""
      ],
      "Export failed: One or more repositories needs to be synced (with Immediate download policy.)": [
        ""
      ],
      "Export formats.Choose syncable if the exported content needs to be in a yum format. This option is only available for %{syncable_repos} repositories. Choose importable if the importing server uses the same version  and exported content needs to be one of %{importable_repos} repositories.": [
        ""
      ],
      "Export history identifier used for incremental export. If not provided the most recent export history will be used.": [
        ""
      ],
      "Exported content view": [
        "Экспортируемое представление"
      ],
      "Exported version": [
        "Экспорт версии"
      ],
      "Extended support": [
        ""
      ],
      "Facts successfully updated.": [
        "Системная статистика обновлена."
      ],
      "Failed": [
        "Сбой"
      ],
      "Failed to delete %{host}: %{errors}": [
        ""
      ],
      "Failed to delete latest content view version of Content View '%{subject}'.": [
        ""
      ],
      "Failed to find %{content} with id '%{id}'.": [
        "%{content} с идентификатором «%{id}» не найдено."
      ],
      "Fails if any of the repositories belonging to this organization are unexportable. False by default.": [
        ""
      ],
      "Fails if any of the repositories belonging to this version are unexportable. False by default.": [
        ""
      ],
      "Fetch applicable errata for one or more hosts.": [
        ""
      ],
      "Fetch available module streams for hosts.": [
        ""
      ],
      "Fetch installable errata for one or more hosts.": [
        ""
      ],
      "Fetch pxe files": [
        ""
      ],
      "Fetch traces for one or more hosts": [
        ""
      ],
      "Fetching content credentials": [
        ""
      ],
      "Field to sort the results on": [
        "Поле сортировки"
      ],
      "File": [
        "Файл"
      ],
      "File contents": [
        ""
      ],
      "Filename": [
        "Имя файла"
      ],
      "Files": [
        "Файлы"
      ],
      "Filter by Product": [
        ""
      ],
      "Filter by type": [
        ""
      ],
      "Filter composite versions whose publish was triggered by the specified component version": [
        ""
      ],
      "Filter content view versions that contain the file": [
        ""
      ],
      "Filter created": [
        "Фильтр создан"
      ],
      "Filter deleted": [
        "Фильтр удален"
      ],
      "Filter edited": [
        ""
      ],
      "Filter only composite content views": [
        "Показать только сложные представления"
      ],
      "Filter out composite content views": [
        "Исключить сложные представления"
      ],
      "Filter out default content views": [
        "Исключить исходные представления"
      ],
      "Filter products by host id": [
        "Отфильтровать результаты по идентификатору узла"
      ],
      "Filter products by name": [
        "Список продуктов по имени"
      ],
      "Filter products by organization": [
        "Список продуктов по организации"
      ],
      "Filter products by subscription": [
        "Список продуктов по подписке"
      ],
      "Filter products by sync plan id": [
        "Список продуктов по идентификатору плана синхронизации"
      ],
      "Filter repositories by content unit type (erratum, docker_tag, etc.). Check the \\\"Indexed?\\\" types here: /katello/api/repositories/repository_types": [
        ""
      ],
      "Filter rule added": [
        ""
      ],
      "Filter rule edited": [
        ""
      ],
      "Filter rule removed": [
        ""
      ],
      "Filter rules added": [
        ""
      ],
      "Filter rules deleted": [
        ""
      ],
      "Filter versions by environment": [
        "Выбор версий по окружению"
      ],
      "Filter versions by version number": [
        "Выбор по номеру версии"
      ],
      "Filter versions that are components in the specified composite version": [
        "Отфильтровать составляющие сложной версии"
      ],
      "Filtered index content": [
        "Содержимое фильтруемого индекса"
      ],
      "Filters": [
        "Фильтры"
      ],
      "Filters deleted": [
        ""
      ],
      "Filters were applied to this version.": [
        ""
      ],
      "Filters will be applied to this content view version.": [
        ""
      ],
      "Find the relative path for each RHUI repository and combine them in a comma-separated list.": [
        ""
      ],
      "Finish": [
        ""
      ],
      "Finished": [
        "Готово"
      ],
      "Force": [
        ""
      ],
      "Force a sync and validate the checksums of all content. Non-yum repositories (or those with \\\\\\n                                                     On Demand download policy) are skipped.": [
        ""
      ],
      "Force a sync and validate the checksums of all content. Only used with yum repositories.": [
        ""
      ],
      "Force content view promotion and bypass lifecycle environment restriction": [
        ""
      ],
      "Force delete the repository by removing it from all content view versions": [
        ""
      ],
      "Force metadata regeneration to proceed. Dangerous operation when version has repositories with the 'Complete Mirroring' mirroring policy": [
        ""
      ],
      "Force metadata regeneration to proceed. Dangerous when repositories use the 'Complete Mirroring' mirroring policy": [
        ""
      ],
      "Force promotion": [
        ""
      ],
      "Force regenerate applicability.": [
        ""
      ],
      "Force sync even if no upstream changes are detected. Non-yum repositories are skipped.": [
        ""
      ],
      "Force sync even if no upstream changes are detected. Only used with yum or deb repositories.": [
        ""
      ],
      "Forces a republish of the specified repository, regenerating metadata and symlinks on the filesystem. Not allowed for repositories with the 'Complete Mirroring' mirroring policy.": [
        ""
      ],
      "Forces a republish of the version's repositories' metadata": [
        ""
      ],
      "Full description": [
        ""
      ],
      "Full support": [
        ""
      ],
      "GPG Key URL": [
        "URL ключа GPG"
      ],
      "Generate RHUI certificates for the desired repositories as necessary.": [
        ""
      ],
      "Generate and Download": [
        "Создать и загрузить"
      ],
      "Generate errata status from directly-installable content": [
        ""
      ],
      "Generate host applicability": [
        ""
      ],
      "Generate repository applicability": [
        ""
      ],
      "Generated": [
        ""
      ],
      "Generated content views cannot be assigned to hosts or activation keys": [
        ""
      ],
      "Generated content views cannot be directly published. They can updated only via export.": [
        ""
      ],
      "Get all content available, not just that provided by subscriptions": [
        ""
      ],
      "Get all content available, not just that provided by subscriptions.": [
        ""
      ],
      "Get content and overrides for the host": [
        "Возвращает список переопределений для заданного узла"
      ],
      "Get current smart proxy synchronization status": [
        ""
      ],
      "Get info about a repository set": [
        "Получить информацию о наборе репозиториев"
      ],
      "Get list of available repositories for the repository set": [
        ""
      ],
      "Get status of synchronisation for given repository": [
        "Получить статус синхронизации для выбранного репозитория"
      ],
      "Given a set of hosts and errata, lists the content view versions and environments that need updating.": [
        "В качестве исходных данных принимает список узлов и исправлений и возвращает список версий представлений и окружения, которые могут быть обновлены."
      ],
      "Given criteria doesn't match any DEBs. Try changing your rule.": [
        ""
      ],
      "Given criteria doesn't match any activation keys. Try changing your rule.": [
        ""
      ],
      "Given criteria doesn't match any hosts. Try changing your rule.": [
        ""
      ],
      "Given criteria doesn't match any non-modular RPMs. Try changing your rule.": [
        ""
      ],
      "Go to job details": [
        ""
      ],
      "Go to task page": [
        ""
      ],
      "Greater than": [
        ""
      ],
      "Guests of": [
        "Гости"
      ],
      "HTTP Proxies": [
        ""
      ],
      "HTTP Proxy identifier to associated": [
        ""
      ],
      "HW properties": [
        ""
      ],
      "Has to be > 0": [
        ""
      ],
      "Help": [
        ""
      ],
      "Helper": [
        ""
      ],
      "Hide affected activation keys": [
        ""
      ],
      "Hide affected hosts": [
        ""
      ],
      "Hide description": [
        ""
      ],
      "History": [
        "Журнал"
      ],
      "History will appear here when the content view is published or promoted.": [
        ""
      ],
      "Host": [
        "Узел"
      ],
      "Host %s has not been registered with subscription-manager.": [
        "%s не был зарегистрирован в subscription-manager"
      ],
      "Host %{hostname}: Cannot add content view environment to content facet. The host's content source '%{content_source}' does not sync lifecycle environment '%{lce}'.": [
        ""
      ],
      "Host %{name} cannot be assigned release version %{release_version}.": [
        ""
      ],
      "Host '%{name}' does not belong to an organization": [
        "Узел «%{name}» не принадлежит ни одной организации"
      ],
      "Host Can Re-Register Only In Build": [
        ""
      ],
      "Host Collection name": [
        "Имя коллекции"
      ],
      "Host Collections": [
        "Коллекции узлов"
      ],
      "Host Duplicate DMI UUIDs": [
        ""
      ],
      "Host Errata Advisory": [
        "Рекомендации для узла"
      ],
      "Host ID": [
        "Идентификатор узла"
      ],
      "Host Limit": [
        ""
      ],
      "Host Profile Assume": [
        ""
      ],
      "Host Profile Can Change In Build": [
        ""
      ],
      "Host Tasks Workers Pool Size": [
        ""
      ],
      "Host collection": [
        ""
      ],
      "Host collection '%{name}' exceeds maximum usage limit of '%{limit}'": [
        "Коллекция «%{name}» превысила максимально допустимое ограничение %{limit}"
      ],
      "Host collection is empty.": [
        "Пустая коллекция."
      ],
      "Host collections": [
        ""
      ],
      "Host collections updated": [
        ""
      ],
      "Host content and subscription details": [
        "Свойства подписки и содержимого"
      ],
      "Host content source will remain the same. Click Save below to update the host's content view environment.": [
        ""
      ],
      "Host content view and environment updated": [
        ""
      ],
      "Host content view environment(s) updated": [
        ""
      ],
      "Host content view environments updating.": [
        ""
      ],
      "Host creation was skipped for %s because it shares a BIOS UUID with %s. To report this hypervisor, override its dmi.system.uuid fact or set 'candlepin.use_system_uuid_for_matching' to 'true' in the Candlepin configuration.": [
        ""
      ],
      "Host errata advisory": [
        ""
      ],
      "Host group IDs": [
        "Идентификаторы группы узлов"
      ],
      "Host has not been registered with subscription-manager": [
        "Узел не был зарегистрирован в subscription-manager"
      ],
      "Host has not been registered with subscription-manager.": [
        "Узел не был зарегистрирован в subscription-manager."
      ],
      "Host id to list applicable deb packages for": [
        ""
      ],
      "Host id to list applicable errata for": [
        ""
      ],
      "Host id to list applicable packages for": [
        ""
      ],
      "Host lifecycle support expiration notification": [
        ""
      ],
      "Host was not found by the subscription UUID: '%s', this can happen if the host is registered already, but not to this instance": [
        ""
      ],
      "Host with ID %s already exists in the host collection.": [
        ""
      ],
      "Host with ID %s does not exist in the host collection.": [
        ""
      ],
      "Host with ID %s not found.": [
        ""
      ],
      "Hosts": [
        "Узлы"
      ],
      "Hosts to update": [
        ""
      ],
      "Hosts with Installable Errata": [
        "Узлы с доступными для установки исправлениями"
      ],
      "Hosts: ": [
        ""
      ],
      "How many repositories should be synced concurrently on the capsule. A smaller number may lead to longer sync times. A larger number will increase dynflow load.": [
        ""
      ],
      "How to order the sorted results (e.g. ASC for ascending)": [
        "Порядок сортировки (например, ASC — по возрастанию)"
      ],
      "Hypervisors": [
        "Гипервизоры"
      ],
      "Hypervisors update": [
        "Обновление гипервизоров"
      ],
      "ID of a HTTP Proxy": [
        ""
      ],
      "ID of a content view to show repositories in": [
        "Идентификатор представления для репозиториев"
      ],
      "ID of a content view version to show repositories in": [
        "Идентификатор версии представления для получения списка репозиториев"
      ],
      "ID of a product to list repository sets from": [
        "Идентификатор продукта для получения набора репозиториев"
      ],
      "ID of a product to show repositories of": [
        "Идентификатор продукта для получения списка репозиториев"
      ],
      "ID of an environment to show repositories in": [
        "Идентификатор окружения для получения списка репозиториев"
      ],
      "ID of an organization to show repositories in": [
        "Идентификатор организации для получения списка репозиториев"
      ],
      "ID of the Organization": [
        ""
      ],
      "ID of the activation key": [
        "Идентификатор ключа активации"
      ],
      "ID of the environment": [
        "Идентификатор окружения"
      ],
      "ID of the host": [
        "Идентификатор узла"
      ],
      "ID of the host collection": [
        "Идентификатор коллекции"
      ],
      "ID of the organization": [
        "Идентификатор организации"
      ],
      "ID of the product containing the repository set": [
        "Идентификатор продукта с набором репозиториев"
      ],
      "ID of the repository set": [
        "Идентификатор набора репозиториев"
      ],
      "ID of the repository set to disable": [
        ""
      ],
      "ID of the repository set to enable": [
        "Идентификатор набора репозиториев для активации"
      ],
      "ID of the repository within the set to disable": [
        ""
      ],
      "ID of the sync plan": [
        "Идентификатор плана синхронизации"
      ],
      "ID: %s doesn't exist ": [
        ""
      ],
      "IDs of products to copy repository information from into a Simplified Alternate Content Source. Products must include at least one repository of the chosen content type.": [
        ""
      ],
      "Id of a deb package to find repositories that contain the deb": [
        ""
      ],
      "Id of a file to find repositories that contain the file": [
        ""
      ],
      "Id of a rpm package to find repositories that contain the rpm": [
        ""
      ],
      "Id of an ansible collection to find repositories that contain the ansible collection": [
        ""
      ],
      "Id of an erratum to find repositories that contain the erratum": [
        "Идентификатор исправления для получения списка репозиториев"
      ],
      "Id of the HTTP proxy to use with alternate content sources": [
        ""
      ],
      "Id of the content host": [
        "Идентификатор узла содержимого"
      ],
      "Id of the content view to limit the synchronization on": [
        ""
      ],
      "Id of the content view to limit verifying checksum on": [
        ""
      ],
      "Id of the environment to limit the synchronization on": [
        "Идентификатор синхронизируемого окружения"
      ],
      "Id of the environment to limit verifying checksum on": [
        ""
      ],
      "Id of the host": [
        "Идентификатор узла"
      ],
      "Id of the host collection": [
        "Идентификатор коллекции"
      ],
      "Id of the lifecycle environment": [
        "Идентификатор окружения жизненного цикла"
      ],
      "Id of the organization to get the status for": [
        "Идентификатор организации"
      ],
      "Id of the organization to limit environments on": [
        "Идентификатор организации для выборки окружений"
      ],
      "Id of the repository to limit the synchronization on": [
        ""
      ],
      "Id of the repository to limit verifying checksum on": [
        ""
      ],
      "Id of the smart proxy": [
        ""
      ],
      "Idenifier of the SSL CA Cert": [
        ""
      ],
      "Identifier of the GPG key": [
        "Идентификатор ключа GPG"
      ],
      "Identifier of the SSL Client Cert": [
        ""
      ],
      "Identifier of the SSL Client Key": [
        ""
      ],
      "Identifier of the content credential containing the SSL CA Cert": [
        ""
      ],
      "Identifier of the content credential containing the SSL Client Cert": [
        ""
      ],
      "Identifier of the content credential containing the SSL Client Key": [
        ""
      ],
      "Identifiers for Lifecycle Environment": [
        ""
      ],
      "Identifies whether the repository should be unavailable on a client with a non-matching OS version.\\nPass [] to make repo available for clients regardless of OS version. Maximum length 1; allowed tags are: %s": [
        ""
      ],
      "Ids of smart proxies to associate": [
        ""
      ],
      "If SSL should be verified for the upstream URL": [
        ""
      ],
      "If hosts fail to register because of duplicate DMI UUIDs, add their comma-separated values here. Subsequent registrations will generate a unique DMI UUID for the affected hosts.": [
        ""
      ],
      "If product certificates should be used to authenticate to a custom CDN.": [
        ""
      ],
      "If specified, remove the first instance of a subscription with matching id and quantity": [
        "Если задано, удалить указанное число подписок в соответствии с заданным идентификатором"
      ],
      "If the smart proxies' assigned HTTP proxies should be used": [
        ""
      ],
      "If this is enabled, a composite content view may not be published or promoted unless the component content view versions that it includes exist in the target environment.": [
        ""
      ],
      "If this is enabled, and register_hostname_fact is set and provided, registration will look for a new host by name only using that fact, and will skip all hostname matching": [
        ""
      ],
      "If this is enabled, repositories can be deleted even when they belong to published content views. The deleted repository will be removed from all content view versions.": [
        ""
      ],
      "If this is enabled, repositories of content view versions without environments (\\\"archived\\\") will be distributed at '/pulp/content/<organization>/content_views/<content view>/X.Y/...'.": [
        ""
      ],
      "If true, only errata that can be installed without an incremental update will affect the host's errata status.": [
        ""
      ],
      "If true, only return repository sets that are associated with an active subscriptions": [
        ""
      ],
      "If true, only return repository sets that have been enabled. Defaults to false": [
        ""
      ],
      "If true, return custom repository sets along with redhat repos. Will be ignored if repository_type is supplied.": [
        ""
      ],
      "If true, when adding the specified errata or packages, any needed dependencies will be copied as well. Defaults to true": [
        ""
      ],
      "If true, will publish a new composite version using any specified content_view_version_id that has been promoted to a lifecycle environment": [
        ""
      ],
      "If you would prefer to move some of these hosts to different content views or environments then {clickHere} to manage these hosts individually.": [
        ""
      ],
      "Ignorable content can be only set for Yum repositories.": [
        ""
      ],
      "Ignore %s cannot be set in combination with the 'Complete Mirroring' mirroring policy.": [
        ""
      ],
      "Ignore errors": [
        ""
      ],
      "Ignore subscription manager errors": [
        ""
      ],
      "Ignore subscription-manager errors for `subscription-manager register` command": [
        ""
      ],
      "Ignore subscriptions that are unavailable to the specified host": [
        "Показать доступные подписки для указанного узла"
      ],
      "Ignored hosts": [
        ""
      ],
      "Image": [
        ""
      ],
      "Immediate": [
        "Немедленный"
      ],
      "Import": [
        "Импорт"
      ],
      "Import Content View Version": [
        ""
      ],
      "Import Default Content View": [
        ""
      ],
      "Import Manifest": [
        "Импорт манифеста"
      ],
      "Import Repository": [
        ""
      ],
      "Import Types": [
        ""
      ],
      "Import a Manifest": [
        ""
      ],
      "Import a Manifest to Begin": [
        ""
      ],
      "Import a content view version": [
        ""
      ],
      "Import a content view version to the library": [
        ""
      ],
      "Import a manifest using the Manifest tab above.": [
        ""
      ],
      "Import a repository": [
        ""
      ],
      "Import a subscription manifest to give hosts access to Red Hat content.": [
        ""
      ],
      "Import new manifest": [
        ""
      ],
      "Import only": [
        ""
      ],
      "Import only Content Views cannot be directly publsihed. Content can only be updated by importing into the view.": [
        ""
      ],
      "Import uploads into a repository": [
        "Импорт новых компонентов из репозитория"
      ],
      "Import-only can not be changed after creation": [
        ""
      ],
      "Import-only content views can not be published directly": [
        ""
      ],
      "Import/Export": [
        ""
      ],
      "Important": [
        "Важно"
      ],
      "Importing manifest into '%{subject}' failed.": [
        ""
      ],
      "In Progress": [
        "Выполняется"
      ],
      "In progress": [
        ""
      ],
      "Include": [
        "Включить"
      ],
      "Include all RPMs not associated to any errata": [
        ""
      ],
      "Include all module streams not associated to any errata": [
        ""
      ],
      "Include content views generated by imports/exports. Defaults to false": [
        ""
      ],
      "Include filter": [
        ""
      ],
      "Included": [
        ""
      ],
      "Included errata": [
        ""
      ],
      "Includes": [
        ""
      ],
      "Includes associated content view filter ids in response": [
        ""
      ],
      "Inclusion type": [
        ""
      ],
      "Incremental Update": [
        "Инкрементное обновление"
      ],
      "Incremental Update incomplete.": [
        "Инкрементное обновление не завершено."
      ],
      "Incremental Update of  Content View Version(s) ": [
        ""
      ],
      "Incremental Update of %{content_view_count} Content View Version(s) ": [
        ""
      ],
      "Incremental update": [
        ""
      ],
      "Incremental update requires at least one content unit": [
        ""
      ],
      "Incremental update specified for composite %{name} version %{version}, but no components updated.": [
        "Для %{name} %{version} было выбрано инкрементное обновление, но изменений компонентов не зарегистрировано."
      ],
      "Index content": [
        "Индексировать содержимое"
      ],
      "Index errata": [
        "Индексировать исправления"
      ],
      "Index module streams": [
        ""
      ],
      "Index package groups": [
        "Индексировать группы пакетов"
      ],
      "Informable Type must be one of the following [ %{list} ]": [
        "Тип может принимать значения: [ %{list} ]"
      ],
      "Inherit from Repository": [
        ""
      ],
      "Initiate a sync of the products attached to the sync plan": [
        "Инициировать синхронизацию продуктов в соответствии с планом синхронизации"
      ],
      "Install": [
        "Установить"
      ],
      "Install errata using scoped search query": [
        ""
      ],
      "Install errata via Katello interface": [
        "Установить исправления с помощью Katello"
      ],
      "Install package group via Katello interface": [
        "Установить пакет с помощью Katello"
      ],
      "Install package via Katello interface": [
        "Установить пакет с помощью Katello"
      ],
      "Install packages": [
        ""
      ],
      "Install packages via Katello interface": [
        ""
      ],
      "Install via customized remote execution": [
        ""
      ],
      "Install via remote execution": [
        ""
      ],
      "Installable": [
        "Доступно для установки"
      ],
      "Installable errata are applicable errata that are available in the host's content view and lifecycle environment.": [
        ""
      ],
      "Installable updates": [
        ""
      ],
      "Installation status": [
        ""
      ],
      "Installed": [
        "Установлено"
      ],
      "Installed Packages": [
        "Установленные пакеты"
      ],
      "Installed module profiles will be removed. Additionally, all packages whose names are provided by specific modules will be removed. Packages required by other installed modules profiles and packages whose names are also provided by other modules are not removed.": [
        ""
      ],
      "Installed products": [
        ""
      ],
      "Installed profile": [
        ""
      ],
      "Installed version": [
        ""
      ],
      "Installing Erratum...": [
        "Установка исправления..."
      ],
      "Installing Package Group...": [
        "Установка группы пакетов..."
      ],
      "Installing Package...": [
        "Установка пакета..."
      ],
      "Instance update": [
        ""
      ],
      "Instance-based": [
        "Экземпляр"
      ],
      "Interpret specified object to return only Host Collections that can be associated with specified object. The value 'host' is supported.": [
        "Ограничивает результаты только теми коллекциями, которые доступны для указанного здесь объекта. Поддерживается значение «host»."
      ],
      "Interpret specified object to return only Products that can be associated with specified object.  Only 'sync_plan' is supported.": [
        "Ограничивает результаты только теми продуктами, которые  доступны для указанного здесь объекта. На данный момент поддерживается только значение «sync_plan»."
      ],
      "Interval cannot be nil": [
        ""
      ],
      "Interval not set correctly": [
        ""
      ],
      "Invalid association of the content view id. Content View must match the content view version being saved": [
        ""
      ],
      "Invalid content label: %s": [
        ""
      ],
      "Invalid content type '%{content_type}' provided. Content types can be one of %{content_types}": [
        "Предоставлен неверный тип содержимого: «%{ content_type }». Тип может быть одним из %{ content_types }"
      ],
      "Invalid date range. The erratum filter rule start date must come before the end date": [
        "Недопустимый диапазон. Дата начала не может быть позднее даты окончания."
      ],
      "Invalid erratum filter rule specified, 'errata_id' cannot be specified in the same tuple as 'start_date', 'end_date' or 'types'": [
        "Недопустимое правило: «errata_id» не может использоваться вместе со «start_date», «end_date», «types»"
      ],
      "Invalid erratum filter rule specified, Must specify at least one of the following: 'errata_id', 'start_date', 'end_date' or 'types'": [
        ""
      ],
      "Invalid erratum types %{invalid_types} provided. Erratum type can be any of %{valid_types}": [
        "Неверные типы исправлений: %{invalid_types}. Допускается: %{valid_types}"
      ],
      "Invalid event_type %s": [
        ""
      ],
      "Invalid export format provided. Format must be one of  %s ": [
        ""
      ],
      "Invalid filter rule specified, 'version' cannot be specified in the same tuple as 'min_version' or 'max_version'": [
        "Неверное правило: «version» не может использоваться вместе с «min_version» и «max_version»"
      ],
      "Invalid mirroring policy for repository type %{type}, only %{policies} are valid.": [
        ""
      ],
      "Invalid parameters sent in the request for this operation. Please contact a system administrator.": [
        "Запрос операции содержит недопустимые параметры. Обратитесь к администратору."
      ],
      "Invalid parameters sent. You may have mistyped the address. If you continue having trouble with this, please contact an Administrator.": [
        "Отправлены неверные параметры. Возможно, был введен неверный адрес. Если ошибка повторится, обратитесь к администратору."
      ],
      "Invalid params provided - content_type must be one of %s": [
        "Неверные значения параметров. Параметр content_type может принимать следующие значения: %s"
      ],
      "Invalid params provided - date_type must be one of %s": [
        "Неверные значения параметров. Параметр date_type может принимать следующие значения: %s"
      ],
      "Invalid params provided - with_content must be one of %s": [
        ""
      ],
      "Invalid path provided. Content can be only imported from file system. ": [
        ""
      ],
      "Invalid release version: [%s]": [
        ""
      ],
      "Invalid repository in the metadata %{repo} error=%{error}": [
        ""
      ],
      "Invalid value specified for Container Image repositories.": [
        ""
      ],
      "Invalid value specified for ignorable content.": [
        ""
      ],
      "Invalid value specified for ignorable content. Permissible values %s": [
        ""
      ],
      "Issued": [
        "Опубликовано"
      ],
      "Issued from": [
        ""
      ],
      "It is only allowed for Non-Redhat Yum repositories.": [
        ""
      ],
      "Job '${description}' completed": [
        ""
      ],
      "Job '${description}' has started.": [
        ""
      ],
      "Katello ID of local pool to update": [
        ""
      ],
      "Katello: Configure host for new content source": [
        ""
      ],
      "Katello: Install Errata": [
        ""
      ],
      "Katello: Install Package": [
        ""
      ],
      "Katello: Install Package Group": [
        ""
      ],
      "Katello: Install errata by search query": [
        ""
      ],
      "Katello: Install packages by search query": [
        ""
      ],
      "Katello: Module Stream Actions": [
        ""
      ],
      "Katello: Remove Package": [
        ""
      ],
      "Katello: Remove Package Group": [
        ""
      ],
      "Katello: Remove Packages by search query": [
        ""
      ],
      "Katello: Resolve Traces": [
        ""
      ],
      "Katello: Service Restart": [
        ""
      ],
      "Katello: Update Package": [
        ""
      ],
      "Katello: Update Package Group": [
        ""
      ],
      "Katello: Update Packages by search query": [
        ""
      ],
      "Katello: Upload Profile": [
        ""
      ],
      "Key-value hash of subscription-manager facts, nesting uses a period delimiter (.)": [
        "Пары ключей и их значений, содержащих факты для subscription-manager. В качестве разделителя для вложенных фактов используется точка."
      ],
      "Kickstart": [
        ""
      ],
      "Kickstart repositories can only be assigned to hosts in the Red Hat family": [
        ""
      ],
      "Kickstart repository ID": [
        ""
      ],
      "Kickstart repository was not set for host '%{host}'": [
        ""
      ],
      "Label": [
        "Метка"
      ],
      "Label of the content": [
        "Метка содержимого"
      ],
      "Label of the content view": [
        ""
      ],
      "Last check-in:": [
        ""
      ],
      "Last checkin": [
        ""
      ],
      "Last published": [
        ""
      ],
      "Last refresh": [
        ""
      ],
      "Last refresh :": [
        ""
      ],
      "Last seen": [
        ""
      ],
      "Last sync": [
        ""
      ],
      "Last task": [
        ""
      ],
      "Latest (automatically updates)": [
        ""
      ],
      "Latest Errata": [
        "Последние исправления"
      ],
      "Latest version": [
        ""
      ],
      "Learn more about adding subscription manifests ": [
        ""
      ],
      "Legacy UI": [
        ""
      ],
      "Legacy content host UI": [
        ""
      ],
      "Less than": [
        ""
      ],
      "Library": [
        "Library"
      ],
      "Library lifecycle environments may not be deleted.": [
        "Окружения Library не могут быть удалены."
      ],
      "Library repository id to restrict comparisons to": [
        "Идентификатор репозитория Library для проведения сравнения"
      ],
      "Lifecycle": [
        ""
      ],
      "Lifecycle Environment": [
        "Окружение"
      ],
      "Lifecycle Environment %s has associated Activation Keys. Please change or remove the associated Activation Keys before trying to delete this lifecycle environment.": [
        "С окружением %s связаны ключи активации. Измените или удалите ключи, прежде чем удалить окружение."
      ],
      "Lifecycle Environment %s has associated Hosts. Please unregister or move the associated Hosts before trying to delete this lifecycle environment.": [
        ""
      ],
      "Lifecycle Environment ID": [
        "Идентификатор окружения жизненного цикла"
      ],
      "Lifecycle Environment Label": [
        ""
      ],
      "Lifecycle Environments": [
        "Окружения жизненного цикла"
      ],
      "Lifecycle environment": [
        ""
      ],
      "Lifecycle environment '%{environment}' is not attached to this capsule.": [
        "Окружение «%{environment}» не связано с этой капсулой."
      ],
      "Lifecycle environment '%{env}' cannot be used with content view '%{view}'": [
        ""
      ],
      "Lifecycle environment ID": [
        ""
      ],
      "Lifecycle environment must be specified": [
        ""
      ],
      "Lifecycle environment was not attached to the smart proxy; therefore, no changes were made.": [
        ""
      ],
      "Lifecycle environment: {lce}": [
        ""
      ],
      "Lifecycle environments cannot be modifed on the default Smart proxy.  The content from all Lifecycle Environments will exist on this Smart proxy.": [
        ""
      ],
      "Limit actions to content in the host's environment.": [
        ""
      ],
      "Limit content to Red Hat / custom": [
        ""
      ],
      "Limit content to enabled / disabled / overridden": [
        ""
      ],
      "Limit content to just that available in the activation key's content view version": [
        ""
      ],
      "Limit content to just that available in the host's content view version": [
        ""
      ],
      "Limit content to just that available in the host's or activation key's content view version and lifecycle environment.": [
        ""
      ],
      "Limit the repository type. Available types endpoint: /katello/api/repositories/repository_types": [
        ""
      ],
      "Limit to environment": [
        ""
      ],
      "Limits": [
        "Ограничения"
      ],
      "List %s": [
        ""
      ],
      "List :resource": [
        ""
      ],
      "List :resource_id": [
        ""
      ],
      "List Content Credentials": [
        ""
      ],
      "List a host's subscriptions": [
        "Возвращает список подписок для заданного узла"
      ],
      "List activation keys": [
        "Показать ключи активации"
      ],
      "List all :resource_id": [
        "Список всех :resource_id"
      ],
      "List all organizations": [
        "Показать все организации"
      ],
      "List alternate content sources.": [
        ""
      ],
      "List an activation key's subscriptions": [
        "Показать подписки ключа активации"
      ],
      "List available releases in the organization": [
        ""
      ],
      "List available subscriptions from Red Hat Subscription Management": [
        ""
      ],
      "List components attached to this content view": [
        ""
      ],
      "List content counts for the smart proxy": [
        ""
      ],
      "List content view versions": [
        "Показать версии представления"
      ],
      "List content views": [
        "Показать представления"
      ],
      "List deb packages": [
        ""
      ],
      "List deb packages installed on the host": [
        ""
      ],
      "List environment paths": [
        "Показать диаграммы окружений"
      ],
      "List environments in an organization": [
        "Показать окружения в организации"
      ],
      "List errata": [
        "Показать исправления"
      ],
      "List errata available for the content host": [
        "Показать исправления для узла"
      ],
      "List export histories": [
        ""
      ],
      "List filter rules": [
        "Показать правила фильтрации"
      ],
      "List host collections": [
        "Возвращает коллекции узлов"
      ],
      "List host collections in an activation key": [
        "Возвращает коллекции для заданного ключа активации"
      ],
      "List host collections the activation key does not belong to": [
        ""
      ],
      "List host collections within an organization": [
        "Возвращает коллекции в организации"
      ],
      "List import histories": [
        ""
      ],
      "List module streams available to the host": [
        ""
      ],
      "List of Errata ids": [
        "Список идентификаторов исправлений"
      ],
      "List of Products for sync plan": [
        "Список продуктов в плане синхронизации"
      ],
      "List of alternate content source IDs": [
        ""
      ],
      "List of component content view version ids for composite views": [
        "Список идентификаторов версий компонентов для сложных представлений"
      ],
      "List of content units to ignore while syncing a yum repository. Must be subset of %s": [
        ""
      ],
      "List of enabled repo urls for the repo (Only first is used.)": [
        "Список адресов репозиториев (будет использоваться первый адрес)"
      ],
      "List of enabled repositories": [
        "Список подключенных репозиториев"
      ],
      "List of errata ids to exclude and not run an action on, (ex: RHSA-2019:1168)": [
        ""
      ],
      "List of errata ids to perform an action on, (ex: RHSA-2019:1168)": [
        ""
      ],
      "List of host collection IDs to associate with activation key": [
        "Список идентификаторов коллекций, которым будет назначен ключ активации"
      ],
      "List of host collection IDs to disassociate from the activation key": [
        "Список идентификаторов коллекций, из которых ключ активации будет удален"
      ],
      "List of host collection ids": [
        "Список идентификаторов коллекций"
      ],
      "List of host collection ids to update": [
        "Список идентификаторов новых коллекций узла"
      ],
      "List of host id to list available module streams for": [
        ""
      ],
      "List of host ids to exclude and not run an action on": [
        "Список идентификаторов узлов, которые должны быть исключены при выполнении действия"
      ],
      "List of host ids to perform an action on": [
        "Список идентификаторов узлов, над которыми будет выполняться действие"
      ],
      "List of host ids to replace the hosts in host collection": [
        "Список идентификаторов узлов в составе коллекции"
      ],
      "List of hypervisor guest uuids": [
        ""
      ],
      "List of package group names (Deprecated)": [
        ""
      ],
      "List of package names": [
        "Список названий пакетов"
      ],
      "List of product ids": [
        "Список идентификаторов продуктов"
      ],
      "List of product ids to add to the sync plan": [
        "Список идентификаторов продуктов для добавления в план синхронизации"
      ],
      "List of product ids to remove from the sync plan": [
        "Список идентификаторов продуктов для исключения из плана синхронизации"
      ],
      "List of products in an organization": [
        "Список продуктов в организации"
      ],
      "List of products installed on the host": [
        "Список установленных на узле продуктов"
      ],
      "List of repositories belonging to a product in an environment": [
        ""
      ],
      "List of repositories for a content view": [
        "Список репозиториев для представления"
      ],
      "List of repositories for a docker meta tag": [
        ""
      ],
      "List of repositories for a product": [
        ""
      ],
      "List of repositories in an organization": [
        ""
      ],
      "List of repository ids": [
        "Список идентификаторов репозиториев"
      ],
      "List of resources types that will be automatically associated": [
        ""
      ],
      "List of subscription products in a subscription": [
        "Список продуктов для указанной подписки"
      ],
      "List of subscription products in an activation key": [
        "Список продуктов подписки для ключа активации"
      ],
      "List of versions to exclude and not run an action on": [
        ""
      ],
      "List of versions to perform an action on": [
        ""
      ],
      "List organization subscriptions": [
        "Возвращает список подписок организации"
      ],
      "List packages": [
        "Показать пакеты"
      ],
      "List packages installed on the host": [
        "Возвращает список установленных на узле пакетов"
      ],
      "List products": [
        "Показать продукты"
      ],
      "List repositories in the environment": [
        ""
      ],
      "List repository sets for a product.": [
        "Показать наборы репозиториев для продукта"
      ],
      "List repository sets.": [
        ""
      ],
      "List services that need restarting on the host": [
        ""
      ],
      "List srpms": [
        ""
      ],
      "List subscriptions": [
        ""
      ],
      "List sync plans": [
        "Показать планы синхронизации"
      ],
      "List the lifecycle environments attached to the smart proxy": [
        ""
      ],
      "List the lifecycle environments not attached to the smart proxy": [
        ""
      ],
      "Loading": [
        "Загружается"
      ],
      "Loading versions": [
        ""
      ],
      "Loading...": [
        "Загрузка..."
      ],
      "Low": [
        ""
      ],
      "Maintenance support": [
        ""
      ],
      "Make copy of a content view": [
        "Создать копию представления"
      ],
      "Make copy of a host collection": [
        "Создать копию коллекции"
      ],
      "Make sure all the component content views are published before publishing/promoting the composite content view. This restriction is optional and can be modified in the Administrator -> Settings -> Content page using the restrict_composite_view flag.": [
        ""
      ],
      "Manage Manifest": [
        "Манифест"
      ],
      "Manifest": [
        ""
      ],
      "Manifest History": [
        "Журнал манифеста"
      ],
      "Manifest deleted": [
        ""
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
        ""
      ],
      "Manifest in '%{subject}' deleted.": [
        ""
      ],
      "Manifest in '%{subject}' failed to refresh.": [
        ""
      ],
      "Manifest in '%{subject}' imported.": [
        ""
      ],
      "Manifest in '%{subject}' refreshed.": [
        ""
      ],
      "Manifest in organization %{subject} has an identity certificate that will expire in %{days_remaining} days, on %{manifest_expire_date}. To extend the expiration date, please refresh your manifest.": [
        ""
      ],
      "Manifest refresh timeout": [
        ""
      ],
      "Manifest refreshed": [
        ""
      ],
      "Manual": [
        "Вручную"
      ],
      "Manual authentication": [
        ""
      ],
      "Mark Content Host Statuses as Unknown for %s": [
        ""
      ],
      "Matching RPMs based on your created filter rule. Remember, RPM filters don't apply to modular RPMs.": [
        ""
      ],
      "Matching content": [
        ""
      ],
      "Max %(maxQuantity)s": [
        ""
      ],
      "Max Hosts (%{limit}) reached for activation key '%{name}'": [
        "Достигнуто максимальное число узлов (%{limit}) для ключа «%{name}»."
      ],
      "Maximum download rate when syncing a repository (requests per second). Use 0 for no limit.": [
        ""
      ],
      "Maximum number of content hosts exceeded for host collection(s): %s": [
        ""
      ],
      "Maximum number of hosts in the host collection": [
        "Максимальное число узлов в коллекции"
      ],
      "Maximum version": [
        ""
      ],
      "May not add a type or date range rule to a filter that has existing rules.": [
        "Если фильтр уже содержит правила, то правила выбора типа и диапазона времени не могут быть добавлены."
      ],
      "May not add an id rule to a filter that has an existing type or date range rule.": [
        "Если фильтр содержит правила выбора типа и диапазона времени, то правило выбора идентификатора не может быть добавлено."
      ],
      "Media Selection": [
        ""
      ],
      "Medium IDs": [
        "ID носителя"
      ],
      "Message": [
        "Сообщение"
      ],
      "Messaging connection": [
        "Система обмена сообщениями"
      ],
      "Metadata generate": [
        ""
      ],
      "Metadata republishing is risky on 'Complete Mirroring' repositories. Change the mirroring policy and try again.\\nAlternatively, use the 'force' parameter to regenerate metadata locally. On the next sync, the upstream repository's metadata will overwrite local metadata for 'Complete Mirroring' repositories.": [
        ""
      ],
      "Metadata taken from the upstream export history for this Content View Version": [
        ""
      ],
      "Minimum version": [
        ""
      ],
      "Missing activation key!": [
        ""
      ],
      "Missing arguments %{substitutions} for %{content_url}": [
        "Отсутствуют аргументы %{substitutions} для %{content_url}"
      ],
      "Model": [
        "Модель"
      ],
      "Moderate": [
        "Средний"
      ],
      "Modular": [
        ""
      ],
      "Module Stream": [
        ""
      ],
      "Module Stream Details": [
        ""
      ],
      "Module Streams": [
        ""
      ],
      "Module stream": [
        ""
      ],
      "Module streams": [
        ""
      ],
      "Module streams will appear here after enabling Red Hat repositories or creating custom products.": [
        ""
      ],
      "Multi-entitlement": [
        "Многократные полномочия"
      ],
      "N/A": [
        "нет"
      ],
      "NA": [
        "нет"
      ],
      "NOTE: Content view version '%{content_view} %{current}' does not have any exportable repositories. At least one repository with any of the following types is required to be able to export: '%{exportable_types}'.": [
        ""
      ],
      "NOTE: Unable to export repository '%{repository}' because it does not have an exportable content type.": [
        ""
      ],
      "NOTE: Unable to export repository '%{repository}' because it does not have an syncably exportable content type.": [
        ""
      ],
      "NOTE: Unable to fully export '%{organization}' organization's library because it contains repositories without the 'immediate' download policy. Update the download policy and sync affected repositories to include them in the export. \\n %{repos}": [
        ""
      ],
      "NOTE: Unable to fully export Content View Version '%{content_view} %{current}' it contains repositories with un-exportable content types. \\n %{repos}": [
        ""
      ],
      "NOTE: Unable to fully export Content View Version '%{content_view} %{current}' it contains repositories without the 'immediate' download policy. Update the download policy and sync affected repositories. Once synced republish the content view and export the generated version. \\n %{repos}": [
        ""
      ],
      "NOTE: Unable to fully export repository '%{repository}' because it does not have the 'immediate' download policy. Update the download policy and sync the affected repository to include them in the export.": [
        ""
      ],
      "Name": [
        "Имя"
      ],
      "Name and label of default content view should not be changed": [
        ""
      ],
      "Name is a required parameter.": [
        ""
      ],
      "Name of new activation key": [
        "Имя нового ключа активации"
      ],
      "Name of the Content Credential": [
        ""
      ],
      "Name of the alternate content source": [
        ""
      ],
      "Name of the content view": [
        "Имя представления"
      ],
      "Name of the host": [
        "Имя узла"
      ],
      "Name of the repository": [
        ""
      ],
      "Name of the upstream docker repository": [
        ""
      ],
      "Name source": [
        ""
      ],
      "Names of smart proxies to associate": [
        ""
      ],
      "Needs to only be set for docker tags": [
        ""
      ],
      "Needs to only be set for file repositories or docker tags": [
        ""
      ],
      "Nest": [
        "Вложить"
      ],
      "Network Sync": [
        ""
      ],
      "Never": [
        "Никогда"
      ],
      "Never Synced": [
        "Никогда"
      ],
      "New Errata": [
        "Новые исправления"
      ],
      "New content view name": [
        "Имя нового представления"
      ],
      "New host collection name": [
        "Имя новой коллекции"
      ],
      "New name cannot be blank": [
        "Имя не может быть пустым."
      ],
      "New name for the content view": [
        "Новое имя представления"
      ],
      "New version is available: Version ${latestVersion}": [
        ""
      ],
      "Newly published": [
        ""
      ],
      "Newly published version will be the same as the previous version.": [
        ""
      ],
      "No": [
        "Нет"
      ],
      "No Activation Keys selected": [
        ""
      ],
      "No Activation keys to select": [
        ""
      ],
      "No Content View": [
        "Нет представления"
      ],
      "No Content found": [
        ""
      ],
      "No Red Hat products currently exist, please import a manifest %(anchorBegin)s here %(anchorEnd)s to receive Red Hat content. No repository sets available.": [
        ""
      ],
      "No Service Level Preference": [
        "Уровень обслуживания не определен"
      ],
      "No URL found for a container registry. Please check the configuration.": [
        ""
      ],
      "No Version of Content View %{component} already exists as a component of the composite Content View %{composite} version %{version}": [
        "Нет версий представления %{component} в версии %{version} сложного представления %{composite}"
      ],
      "No action is needed because there are no applicable errata for this host.": [
        ""
      ],
      "No action required": [
        ""
      ],
      "No applicable errata": [
        ""
      ],
      "No applications to restart": [
        ""
      ],
      "No artifacts to show": [
        ""
      ],
      "No available component content view updates": [
        ""
      ],
      "No available repository or filter updates": [
        ""
      ],
      "No content": [
        ""
      ],
      "No content added.": [
        ""
      ],
      "No content ids provided": [
        "Не заданы идентификаторы содержимого"
      ],
      "No content in selected versions.": [
        ""
      ],
      "No content view history events found.": [
        "Нет событий."
      ],
      "No content views available": [
        ""
      ],
      "No content views available for the selected environment": [
        ""
      ],
      "No content views to add yet": [
        ""
      ],
      "No content views yet": [
        ""
      ],
      "No content_view_version_ids provided": [
        "Параметр content_view_version_ids не определен"
      ],
      "No description": [
        ""
      ],
      "No description provided": [
        ""
      ],
      "No docker manifests to delete after ignoring manifests with tags or manifest lists": [
        ""
      ],
      "No enabled repositories match your search criteria.": [
        ""
      ],
      "No environment": [
        ""
      ],
      "No environments": [
        ""
      ],
      "No errata filter rules yet": [
        ""
      ],
      "No errata matching given search query": [
        ""
      ],
      "No errata to add yet": [
        ""
      ],
      "No errors": [
        "Нет ошибок"
      ],
      "No existing export history was found to perform an incremental export. A full export must be performed": [
        ""
      ],
      "No file uploaded": [
        "Нет отправленных файлов"
      ],
      "No filters yet": [
        ""
      ],
      "No history yet": [
        ""
      ],
      "No host collections": [
        ""
      ],
      "No host collections found.": [
        "Нет коллекций."
      ],
      "No host collections yet": [
        ""
      ],
      "No hosts found": [
        ""
      ],
      "No hosts registered with subscription-manager found in selection.": [
        "Среди выбранных узлов нет узлов, зарегистрированных с помощью subscription-manager"
      ],
      "No hosts were specified": [
        ""
      ],
      "No installed packages and/or enabled repositories have been reported by %s.": [
        ""
      ],
      "No items have been specified.": [
        ""
      ],
      "No manifest file uploaded": [
        "Нет загруженных файлов манифеста"
      ],
      "No manifest found. Import a manifest with the appropriate subscriptions before importing content.": [
        ""
      ],
      "No manifest imported": [
        ""
      ],
      "No matching ": [
        ""
      ],
      "No matching ${name} found.": [
        ""
      ],
      "No matching ${selectedContentType} found": [
        ""
      ],
      "No matching DEB found.": [
        ""
      ],
      "No matching activation keys found.": [
        ""
      ],
      "No matching alternate content sources found": [
        ""
      ],
      "No matching content views found": [
        ""
      ],
      "No matching errata found": [
        ""
      ],
      "No matching filter rules found.": [
        ""
      ],
      "No matching filters found": [
        ""
      ],
      "No matching history record found": [
        ""
      ],
      "No matching host collections found": [
        ""
      ],
      "No matching hosts found.": [
        ""
      ],
      "No matching non-modular RPM found.": [
        ""
      ],
      "No matching packages found": [
        ""
      ],
      "No matching repositories found": [
        ""
      ],
      "No matching repository sets found": [
        ""
      ],
      "No matching traces found": [
        ""
      ],
      "No matching version found": [
        ""
      ],
      "No module stream filter rules yet": [
        ""
      ],
      "No module streams to add yet.": [
        ""
      ],
      "No new packages installed": [
        "Нет новых пакетов"
      ],
      "No package groups yet": [
        ""
      ],
      "No packages": [
        ""
      ],
      "No packages available to install": [
        ""
      ],
      "No packages available to install on this host. Please check the host's content view and lifecycle environment.": [
        ""
      ],
      "No packages removed": [
        "Удаление пакетов не производилось"
      ],
      "No packages updated": [
        "Пакеты не обновлены"
      ],
      "No pool IDs were provided.": [
        ""
      ],
      "No pools available": [
        ""
      ],
      "No pools were provided.": [
        ""
      ],
      "No processes require restarting": [
        ""
      ],
      "No products are enabled.": [
        ""
      ],
      "No profiles to show": [
        ""
      ],
      "No pulp workers running.": [
        "Нет работающих обработчиков Pulp."
      ],
      "No pulpcore content apps are running at %s.": [
        ""
      ],
      "No pulpcore workers are running at %s.": [
        ""
      ],
      "No recently synced products": [
        "Нет недавно синхронизированных продуктов."
      ],
      "No recurring logic tied to the sync plan.": [
        ""
      ],
      "No repositories added yet": [
        ""
      ],
      "No repositories available to add": [
        ""
      ],
      "No repositories available.": [
        ""
      ],
      "No repositories enabled.": [
        ""
      ],
      "No repositories selected.": [
        ""
      ],
      "No repositories to show": [
        ""
      ],
      "No repository sets match your search criteria.": [
        ""
      ],
      "No repository sets to show.": [
        ""
      ],
      "No rules yet": [
        ""
      ],
      "No services defined, is this class extended?": [
        "Сервисы не определены. Возможно, это расширение класса?"
      ],
      "No start time currently available.": [
        "Время начала не определено."
      ],
      "No subscriptions match your search criteria.": [
        ""
      ],
      "No syncable repositories found for selected products and options.": [
        ""
      ],
      "No uploads param specified. An array of uploads to import is required.": [
        ""
      ],
      "No versions yet": [
        ""
      ],
      "Non-security errata applicable": [
        "Доступны исправления общего характера"
      ],
      "Non-security errata installable": [
        ""
      ],
      "Non-system event": [
        "Несистемное событие"
      ],
      "None": [
        "Нет"
      ],
      "None provided": [
        ""
      ],
      "Not a number": [
        ""
      ],
      "Not added": [
        ""
      ],
      "Not all necessary pulp workers running at %s.": [
        ""
      ],
      "Not installed": [
        "Не установлено"
      ],
      "Not running": [
        ""
      ],
      "Not yet published": [
        "Нет"
      ],
      "Note: Deleting a subscription manifest is STRONGLY discouraged.": [
        ""
      ],
      "Note: Deleting a subscription manifest is STRONGLY discouraged. Deleting a manifest will:": [
        ""
      ],
      "Note: The number in parentheses reflects all applicable errata from the Library environment that are unavailable to the host. You will need to promote this content to the relevant content view in order to make it available.": [
        ""
      ],
      "Nothing selected": [
        ""
      ],
      "Number of CPU(s)": [
        ""
      ],
      "Number of host applicability calculations to process per task.": [
        ""
      ],
      "Number of results per page to return": [
        "Число элементов на странице"
      ],
      "Number of results per page to return.": [
        ""
      ],
      "Number to Allocate": [
        ""
      ],
      "OS restricted to {osRestricted}. If host OS does not match, the repository will not be available on this host.": [
        ""
      ],
      "OSTree Branch": [
        "Ветвь OSTree"
      ],
      "OSTree Ref": [
        ""
      ],
      "OSTree Refs": [
        ""
      ],
      "OSTree ref": [
        ""
      ],
      "OSTree refs": [
        ""
      ],
      "Object to show subscriptions available for, either 'host' or 'activation_key'": [
        "Ограничивает результаты только теми подписками, которые доступны для указанного здесь объекта. Допустимые значения: «host», «activation_key»."
      ],
      "On Demand": [
        "По требованию"
      ],
      "On the RHUA Instance, check the available repositories.": [
        ""
      ],
      "On-disk location for pulp 3 exported repositories": [
        ""
      ],
      "Once the prerequisites are met, select a provider to install katello-host-tools-tracer": [
        ""
      ],
      "One of parameters [ %s ] required but not specified.": [
        "Отсутствует обязательный параметр [ %s ] "
      ],
      "One of yum or docker": [
        ""
      ],
      "One or more hosts not found": [
        ""
      ],
      "One or more ids (%{ids}) were not found for %{assoc}.  You may not have permissions to see them.": [
        ""
      ],
      "One or more processes require restarting": [
        ""
      ],
      "Only On Demand repositories may have space reclaimed.": [
        ""
      ],
      "Only On Demand smart proxies may have space reclaimed.": [
        ""
      ],
      "Only one Red Hat provider permitted for an Organization": [
        "Для каждой организации может быть добавлен только один провайдер Red Hat."
      ],
      "Only repositories not published in a content view can be disabled. Published repositories must be deleted from the repository details page.": [
        ""
      ],
      "Only returns id and quantity fields": [
        ""
      ],
      "Operators": [
        "Операторы"
      ],
      "Organization": [
        "Организация"
      ],
      "Organization %s is being deleted.": [
        "Организация %s удаляется."
      ],
      "Organization ID": [
        "Код организации"
      ],
      "Organization ID is required": [
        ""
      ],
      "Organization Information not provided.": [
        ""
      ],
      "Organization cannot be blank.": [
        "Организация не может быть пустой."
      ],
      "Organization id": [
        "Идентификатор организации"
      ],
      "Organization identifier": [
        "Идентификатор организации"
      ],
      "Organization label": [
        "Метка организации"
      ],
      "Organization not found": [
        ""
      ],
      "Organization required": [
        "Требуется организация"
      ],
      "Orphaned Content Protection Time": [
        ""
      ],
      "Orphaned content facets for deleted hosts exist for the content view and environment. Please run rake task : katello:clean_orphaned_facets and try again!": [
        ""
      ],
      "Other": [
        "Другие"
      ],
      "Other Content Types": [
        ""
      ],
      "Overridden": [
        ""
      ],
      "Override content for activation_key": [
        "Переопределить содержимое для activation_key"
      ],
      "Override key or name. Note if name is not provided the default name will be 'enabled'": [
        ""
      ],
      "Override parameter key or name. Note if name is not provided the default name will be 'enabled'": [
        ""
      ],
      "Override the major version number": [
        ""
      ],
      "Override the minor version number": [
        ""
      ],
      "Override to a boolean value or 'default'": [
        ""
      ],
      "Override to disabled": [
        ""
      ],
      "Override to enabled": [
        ""
      ],
      "Override value. Provide a boolean value if name is 'enabled'": [
        ""
      ],
      "Package": [
        "Пакет"
      ],
      "Package Group": [
        "Группа пакетов"
      ],
      "Package Group Install": [
        "Установка группы пакетов"
      ],
      "Package Group Install Canceled": [
        "Установка группы пакетов отменена"
      ],
      "Package Group Install Complete": [
        "Группа пакетов установлена"
      ],
      "Package Group Install Failed": [
        "Не удалось установить группу пакетов"
      ],
      "Package Group Install Timed Out": [
        "Истекло время ожидания установки группы пакетов"
      ],
      "Package Group Install scheduled by %s": [
        "Установку группы пакетов назначил: %s"
      ],
      "Package Group Remove": [
        "Удаление группы пакетов"
      ],
      "Package Group Remove Canceled": [
        "Удаление группы пакетов отменено"
      ],
      "Package Group Remove Complete": [
        "Группа пакетов удалена"
      ],
      "Package Group Remove Failed": [
        "Не удалось удалить группу пакетов"
      ],
      "Package Group Remove Timed Out": [
        "Время ожидания удаления группы пакетов истекло"
      ],
      "Package Group Remove scheduled by %s": [
        "Удаление группы пакетов назначил: %s"
      ],
      "Package Group Update": [
        "Обновление группы пакетов"
      ],
      "Package Group Update scheduled by %s": [
        "Обновление группы пакетов назначил: %s"
      ],
      "Package Groups": [
        "Группы пакетов"
      ],
      "Package Install": [
        "Установка пакета"
      ],
      "Package Install Canceled": [
        "Установка пакета отменена"
      ],
      "Package Install Complete": [
        "Пакет установлен"
      ],
      "Package Install Failed": [
        "Не удалось установить пакет"
      ],
      "Package Install Timed Out": [
        "Время ожидания установки пакета истекло"
      ],
      "Package Install scheduled by %s": [
        "Установку пакета назначил: %s"
      ],
      "Package Remove": [
        "Удаление пакета"
      ],
      "Package Remove Canceled": [
        "Удаление пакета отменено"
      ],
      "Package Remove Complete": [
        "Пакет удалён"
      ],
      "Package Remove Failed": [
        "Не удалось удалить пакет"
      ],
      "Package Remove Timed Out": [
        "Время ожидания удаления пакета истекло"
      ],
      "Package Remove scheduled by %s": [
        "Удаление пакета назначил: %s"
      ],
      "Package Type": [
        ""
      ],
      "Package Types": [
        ""
      ],
      "Package Update": [
        "Обновление пакетов"
      ],
      "Package Update Canceled": [
        "Обновление пакета отменено"
      ],
      "Package Update Complete": [
        "Пакеты обновлены"
      ],
      "Package Update Failed": [
        "Не удалось обновить пакет"
      ],
      "Package Update Timed Out": [
        "Время ожидания обновления пакета истекло"
      ],
      "Package Update scheduled by %s": [
        "Обновление пакета назначил: %s"
      ],
      "Package group update canceled": [
        "Обновление группы пакетов отменено"
      ],
      "Package group update complete": [
        "Группа пакетов обновлена."
      ],
      "Package group update failed": [
        "Не удалось обновить группу пакетов"
      ],
      "Package group update timed out": [
        "Время ожидания обновления группы пакетов истекло"
      ],
      "Package groups": [
        ""
      ],
      "Package identifiers to filter content by": [
        ""
      ],
      "Package install failed: \\\"%{package}\\\"": [
        ""
      ],
      "Package installation: \\\"%{package}\\\" ": [
        ""
      ],
      "Package types to sync for Python content, separated by comma. Leave empty to get every package type. Package types are: bdist_dmg, bdist_dumb, bdist_egg, bdist_msi, bdist_rpm, bdist_wheel, bdist_wininst, sdist.": [
        ""
      ],
      "Packages": [
        "Пакеты"
      ],
      "Packages must be provided": [
        "Необходимо указать пакеты"
      ],
      "Packages will appear here when available.": [
        ""
      ],
      "Page number, starting at 1": [
        "Номер страницы, начиная с 1"
      ],
      "Partition template IDs": [
        "Код шаблона таблицы разделов"
      ],
      "Password": [
        "Пароль"
      ],
      "Password for authentication. Relevant only for 'upstream_server' type.": [
        ""
      ],
      "Password of the upstream repository user used for authentication": [
        ""
      ],
      "Password to access URL": [
        ""
      ],
      "Path": [
        "Путь"
      ],
      "Path suffixes for finding alternate content": [
        ""
      ],
      "Paused": [
        "Приостановлена"
      ],
      "Pending tasks detected in repositories of this content view. Please wait for the tasks: ": [
        ""
      ],
      "Perform a module stream action via Katello interface": [
        ""
      ],
      "Perform an Incremental Update on one or more Content View Versions": [
        "Выполнить инкрементное обновление версий представления"
      ],
      "Performs a full-export of a content view version.": [
        ""
      ],
      "Performs a full-export of the repositories in library.": [
        ""
      ],
      "Performs a full-export of the repository in library.": [
        ""
      ],
      "Performs a incremental-export of the repository in library.": [
        ""
      ],
      "Performs an incremental-export of a content view version.": [
        ""
      ],
      "Performs an incremental-export of the repositories in library.": [
        ""
      ],
      "Permission Denied. User '%{user}' does not have permissions to access organization '%{org}'.": [
        "Отказ в разрешении. У «%{user}» нет прав доступа к организации «%{org}»."
      ],
      "Physical": [
        " Физическая"
      ],
      "Plan numeric identifier": [
        "Числовой идентификатор плана"
      ],
      "Please add some repositories.": [
        ""
      ],
      "Please create some content views.": [
        ""
      ],
      "Please enter a positive number above zero": [
        ""
      ],
      "Please enter digits only": [
        ""
      ],
      "Please limit number to 10 digits": [
        ""
      ],
      "Please select a content source before assigning a kickstart repository": [
        ""
      ],
      "Please select a lifecycle environment and a content view to move these activation keys.": [
        ""
      ],
      "Please select a lifecycle environment and a content view to move this activation key.": [
        ""
      ],
      "Please select a lifecycle environment and content view to view activation keys.": [
        ""
      ],
      "Please select an architecture before assigning a kickstart repository": [
        ""
      ],
      "Please select an operating system before assigning a kickstart repository": [
        ""
      ],
      "Please select one from the list below and you will be redirected.": [
        "Чтобы перейти на страницу, выберите организацию из списка."
      ],
      "Please wait while the task starts..": [
        ""
      ],
      "Please wait...": [
        "Подождите..."
      ],
      "Policy to set for mirroring content.  Must be one of %s.": [
        ""
      ],
      "Prefer registered through proxy for remote execution": [
        ""
      ],
      "Prefer using a proxy to which a host is registered when using remote execution": [
        ""
      ],
      "Prevent from further updates": [
        ""
      ],
      "Prior Content View Version specified in the metadata - '%{name}' does not exist. Please import the metadata for '%{name}' before importing '%{current}' ": [
        ""
      ],
      "Problem searching": [
        ""
      ],
      "Problem searching errata": [
        ""
      ],
      "Problem searching host collections": [
        ""
      ],
      "Problem searching module streams": [
        ""
      ],
      "Problem searching packages": [
        ""
      ],
      "Problem searching repository sets": [
        ""
      ],
      "Problem searching traces": [
        ""
      ],
      "Product": [
        "Продукт"
      ],
      "Product Content": [
        "Содержание продукта"
      ],
      "Product Create": [
        "Создать продукт"
      ],
      "Product ID": [
        "Идентификатор продукта"
      ],
      "Product and Repositories": [
        "Продукты и репозитории"
      ],
      "Product architecture": [
        ""
      ],
      "Product description": [
        "Описание продукта"
      ],
      "Product id as listed from a host's installed products, \\\\\\n        this is not the same product id as the products api returns": [
        ""
      ],
      "Product label": [
        ""
      ],
      "Product name": [
        "Название продукта"
      ],
      "Product name as listed from a host's installed products": [
        "Название продукта в соответствии с указанным в списке установленных продуктов"
      ],
      "Product the repository belongs to": [
        "Продукт, с которым будет ассоциирован новый репозиторий"
      ],
      "Product version": [
        ""
      ],
      "Product with ID %s not found in Candlepin. Skipping content import for it.": [
        ""
      ],
      "Product: '%{product}', Repository: '%{repository}'": [
        ""
      ],
      "Product: '%{product}', Repository: '%{repo}' ": [
        ""
      ],
      "Products": [
        "Продукты"
      ],
      "Products updated.": [
        ""
      ],
      "Profiles": [
        ""
      ],
      "Promote": [
        "Продвижение"
      ],
      "Promote a content view version": [
        "Продвинуть версию представления"
      ],
      "Promote errata": [
        ""
      ],
      "Promote version ${versionNameToPromote}": [
        ""
      ],
      "Promoted to ": [
        ""
      ],
      "Promoted to %{environment}": [
        "Продвинуто в %{environment}"
      ],
      "Promotion Summary": [
        "Сводка переносов"
      ],
      "Promotion Summary for %{content_view}": [
        "Сводка переносов %{content_view}"
      ],
      "Promotion to Environment": [
        ""
      ],
      "Provide the required information and click {update} below to save changes.": [
        ""
      ],
      "Provided Products": [
        "Продукты"
      ],
      "Provided pool with id %s has no upstream entitlement": [
        ""
      ],
      "Provisioning template IDs": [
        "Идентификаторы шаблонов"
      ],
      "Proxies": [
        "Прокси"
      ],
      "Proxy sync failure": [
        ""
      ],
      "Public": [
        "Общее"
      ],
      "Public key block in DER encoding or certificate content": [
        ""
      ],
      "Publish": [
        "Опубликовать"
      ],
      "Publish Lifecycle Environment Repositories": [
        ""
      ],
      "Publish a content view": [
        "Опубликовать представление"
      ],
      "Publish new version": [
        ""
      ],
      "Publish new version - ": [
        ""
      ],
      "Published date": [
        ""
      ],
      "Published new version": [
        "Опубликована новая версия"
      ],
      "Publishing ${name}": [
        ""
      ],
      "Publishing content view": [
        ""
      ],
      "Pulp": [
        "Pulp"
      ],
      "Pulp 3 export destination filepath": [
        ""
      ],
      "Pulp 3 is not enabled on Smart proxy!": [
        ""
      ],
      "Pulp bulk load size": [
        ""
      ],
      "Pulp database connection issue at %s.": [
        ""
      ],
      "Pulp database connection issue.": [
        "Не удалось подключиться к базе данных Pulp."
      ],
      "Pulp disk space notification": [
        ""
      ],
      "Pulp does not appear to be running at %s.": [
        ""
      ],
      "Pulp does not appear to be running.": [
        "Похоже, Pulp не выполняется."
      ],
      "Pulp message bus connection issue at %s.": [
        ""
      ],
      "Pulp message bus connection issue.": [
        "Не удалось подключиться к шине обмена сообщениями Pulp."
      ],
      "Pulp node": [
        "Узел Pulp"
      ],
      "Pulp redis connection issue at %s.": [
        ""
      ],
      "Pulp server version": [
        "Версия сервера Pulp"
      ],
      "Pulp storage": [
        "Хранилище Pulp"
      ],
      "Pulp task error": [
        "Ошибка задачи Pulp"
      ],
      "Python Package": [
        ""
      ],
      "Python Packages": [
        ""
      ],
      "Python package": [
        ""
      ],
      "Python packages": [
        ""
      ],
      "Python packages to exclude from the upstream URL, names separated by newline. You may also specify versions, for example: django~=2.0.": [
        ""
      ],
      "Python packages to include from the upstream URL, names separated by newline. You may also specify versions, for example: django~=2.0. Leave empty to include every package.": [
        ""
      ],
      "Quantity": [
        "Количество"
      ],
      "Quantity must not be above ${pool.available}": [
        ""
      ],
      "Quantity of entitlements to bind": [
        ""
      ],
      "Quantity of specified subscription to remove": [
        ""
      ],
      "Quantity of this subscription to add": [
        "Количество добавляемых подписок"
      ],
      "Quantity of this subscriptions to add": [
        "Количество добавляемых подписок"
      ],
      "Quantity to Allocate": [
        ""
      ],
      "RAM": [
        ""
      ],
      "RAM: %s GB": [
        ""
      ],
      "RH Repos": [
        ""
      ],
      "RHEL Lifecycle status": [
        ""
      ],
      "RHEL lifecycle": [
        ""
      ],
      "RHUI": [
        ""
      ],
      "RPM": [
        "RPM"
      ],
      "RPM Package Groups": [
        ""
      ],
      "RPM Packages": [
        ""
      ],
      "RPM name": [
        ""
      ],
      "RPM package groups": [
        ""
      ],
      "RPM package updates": [
        ""
      ],
      "RPM packages": [
        ""
      ],
      "RPMs": [
        "RPM"
      ],
      "Range": [
        "диапазон"
      ],
      "Realm IDs": [
        "Идентификаторы областей"
      ],
      "Reassign affected activation key": [
        ""
      ],
      "Reassign affected activation keys": [
        ""
      ],
      "Reassign affected host": [
        ""
      ],
      "Reassign affected hosts": [
        ""
      ],
      "Reboot host": [
        ""
      ],
      "Reboot required": [
        ""
      ],
      "Reclaim Space": [
        ""
      ],
      "Reclaim space from On Demand repositories": [
        ""
      ],
      "Reclaim space from all On Demand repositories on a smart proxy": [
        ""
      ],
      "Reclaim space from an On Demand repository": [
        ""
      ],
      "Recommended Repositories": [
        ""
      ],
      "Red Hat": [
        ""
      ],
      "Red Hat CDN": [
        ""
      ],
      "Red Hat CDN URL": [
        "Сеть доставки содержимого Red Hat"
      ],
      "Red Hat Repositories": [
        "Репозитории Red Hat"
      ],
      "Red Hat Repositories page": [
        "репозитории Red Hat"
      ],
      "Red Hat content will be consumed from an {type}.": [
        ""
      ],
      "Red Hat content will be consumed from the {type}.": [
        ""
      ],
      "Red Hat content will be consumed from {type}.": [
        ""
      ],
      "Red Hat content will be enabled and consumed via the {type} process.": [
        ""
      ],
      "Red Hat products cannot be manipulated.": [
        "Продукты Red Hat не могут изменяться"
      ],
      "Red Hat provider can not be deleted": [
        "Провайдер Red Hat не может быть удален"
      ],
      "Red Hat repositories cannot be manipulated.": [
        "Репозитории Red Hat не могут быть изменены"
      ],
      "Refresh": [
        "Обновить"
      ],
      "Refresh Alternate Content Source": [
        ""
      ],
      "Refresh Content Host Statuses for %s": [
        ""
      ],
      "Refresh Manifest": [
        "Обновить манифест"
      ],
      "Refresh all alternate content sources": [
        ""
      ],
      "Refresh alternate content sources": [
        ""
      ],
      "Refresh an alternate content source. Refreshing, like repository syncing, is required before using an alternate content source.": [
        ""
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
        "Обновить ранее импортированный манифест провайдера Red Hat"
      ],
      "Refresh source": [
        ""
      ],
      "Refresh_Content_Host_Status": [
        ""
      ],
      "Register a host with subscription and information": [
        ""
      ],
      "Register host '%s' before attaching subscriptions": [
        ""
      ],
      "Registered": [
        "Зарегистрирован"
      ],
      "Registered at": [
        ""
      ],
      "Registered by": [
        ""
      ],
      "Registered on": [
        ""
      ],
      "Registering to multiple environments is not enabled.": [
        ""
      ],
      "Registration details": [
        ""
      ],
      "Registry name pattern results in duplicate container image names for these repositories: %s.": [
        ""
      ],
      "Registry name pattern results in invalid container image name of member repository '%{name}'": [
        ""
      ],
      "Registry name pattern will result in invalid container image name of member repositories": [
        ""
      ],
      "Reindex subscriptions": [
        "Повторно индексировать подписки"
      ],
      "Related composite content views": [
        ""
      ],
      "Related composite content views: ": [
        ""
      ],
      "Related content views": [
        ""
      ],
      "Related content views will appear here when created.": [
        ""
      ],
      "Related content views: ": [
        ""
      ],
      "Release": [
        "Релиз"
      ],
      "Release version": [
        ""
      ],
      "Release version for this Host to use (7Server, 7.1, etc)": [
        ""
      ],
      "Release version of the content host": [
        "Версия релиза узла содержимого"
      ],
      "Releasever to disable": [
        "Выключить $releasever "
      ],
      "Releasever to enable": [
        "Включить $releasever "
      ],
      "Reload data": [
        "Перезагрузить"
      ],
      "Remote execution is enabled.": [
        ""
      ],
      "Remote execution job '${description}' failed.": [
        ""
      ],
      "Remove": [
        "Удалить"
      ],
      "Remove Content": [
        "Удалить содержимое"
      ],
      "Remove Version": [
        "Удалить версию"
      ],
      "Remove Versions and Associations": [
        "Удалить версии и связи"
      ],
      "Remove a content view from an environment": [
        "Удалить представление из окружения"
      ],
      "Remove any `katello-ca-consumer` rpms before registration and run subscription-manager with `--force` argument.": [
        ""
      ],
      "Remove components from the content view": [
        ""
      ],
      "Remove content view version": [
        "Удалить версию представления"
      ],
      "Remove from Environment": [
        "Удалить из окружения"
      ],
      "Remove from environment": [
        ""
      ],
      "Remove from environments": [
        ""
      ],
      "Remove host from collections": [
        ""
      ],
      "Remove host from host collections": [
        ""
      ],
      "Remove hosts from the host collection": [
        "Удалить узлы из коллекции"
      ],
      "Remove lifecycle environments from the smart proxy": [
        ""
      ],
      "Remove module stream": [
        ""
      ],
      "Remove one or more host collections from one or more hosts": [
        "Удалить узлы из коллекций"
      ],
      "Remove one or more subscriptions from an upstream manifest": [
        ""
      ],
      "Remove package group via Katello interface": [
        "Удалить группу пакетов с помощью Katello"
      ],
      "Remove package via Katello interface": [
        "Удалить пакет с помощью Katello"
      ],
      "Remove packages via Katello interface": [
        ""
      ],
      "Remove products from sync plan": [
        "Исключить продукты из плана синхронизации"
      ],
      "Remove subscriptions": [
        "Удалить подписки"
      ],
      "Remove subscriptions from %s": [
        "Удалить подписки %s"
      ],
      "Remove subscriptions from a host": [
        ""
      ],
      "Remove subscriptions from one or more hosts": [
        ""
      ],
      "Remove versions and/or environments from a content view and reassign systems and keys": [
        "Удалить версии и окружения из представления и переназначить системы и ключи"
      ],
      "Remove versions from environments": [
        ""
      ],
      "Removed component from content view": [
        ""
      ],
      "Removed components from content view": [
        ""
      ],
      "Removing Package Group...": [
        "Удаление группы..."
      ],
      "Removing Package...": [
        "Удаление пакета..."
      ],
      "Removing product %{prod_name} with ID %{prod_id} from ACS %{acs_name} with ID %{acs_id}": [
        ""
      ],
      "Removing this version from all environments will not delete the version. Version will still be available for later promotion.": [
        ""
      ],
      "Replace content source on the target machine": [
        ""
      ],
      "Repo ID": [
        ""
      ],
      "Repo Type": [
        "Тип репозитория"
      ],
      "Repo label": [
        ""
      ],
      "Repositories": [
        "Репозитории"
      ],
      "Repositories are not available for enablement while CDN configuration is set to Air-gapped (disconnected).": [
        ""
      ],
      "Repositories common to the selected content view versions will merge, resulting in a composite content view that is a union of all content from each of the content view versions.": [
        ""
      ],
      "Repositories from published Content Views are not allowed.": [
        "Нельзя использовать репозитории из опубликованных представлений."
      ],
      "Repository": [
        "Репозиторий"
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
        ""
      ],
      "Repository '%(repoName)s' has been enabled.": [
        ""
      ],
      "Repository ID": [
        ""
      ],
      "Repository Id associated with the kickstart repo used for provisioning": [
        ""
      ],
      "Repository cannot be deleted since it has already been included in a published Content View. Please delete all Content View versions containing this repository before attempting to delete it or use --remove-from-content-view-versions flag to automatically remove the repository from all published versions.": [
        ""
      ],
      "Repository cannot be disabled since it has already been promoted.": [
        "Репозиторий не может быть отключен, так как он уже был перенесен."
      ],
      "Repository has already been cloned to %{cv_name} in environment %{to_env}": [
        "Репозиторий уже скопирован в %{cv_name} в окружении %{to_env}"
      ],
      "Repository id": [
        "ID репозитория"
      ],
      "Repository identifier": [
        "Идентификатор репозитория"
      ],
      "Repository label '%s' is not associated with content view.": [
        ""
      ],
      "Repository name": [
        ""
      ],
      "Repository not found": [
        "Репозиторий не найден"
      ],
      "Repository path": [
        ""
      ],
      "Repository set disabled": [
        ""
      ],
      "Repository set enabled": [
        ""
      ],
      "Repository set name to search on": [
        "Имя искомого набора репозиториев"
      ],
      "Repository set reset to default": [
        ""
      ],
      "Repository sets": [
        ""
      ],
      "Repository sets are not available for custom products.": [
        "Для дополнительных продуктов наборы репозиториев недоступны."
      ],
      "Repository sets disabled": [
        ""
      ],
      "Repository sets enabled": [
        ""
      ],
      "Repository sets reset to default": [
        ""
      ],
      "Repository sets will appear here after enabling Red Hat repositories or creating custom products.": [
        ""
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
        ""
      ],
      "Republish Version Repositories": [
        ""
      ],
      "Republish repository metadata": [
        ""
      ],
      "Require you to upload the subscription-manifest and re-attach subscriptions to hosts and activation keys.": [
        ""
      ],
      "Requirements is not valid yaml.": [
        ""
      ],
      "Requirements yaml should be a key-value pair structure.": [
        ""
      ],
      "Requirements yaml should have a 'collections' key": [
        ""
      ],
      "Requires Virt-Who": [
        ""
      ],
      "Reset": [
        ""
      ],
      "Reset filters": [
        ""
      ],
      "Reset module stream": [
        ""
      ],
      "Reset to default": [
        "Восстановить исходные"
      ],
      "Reset to the default state": [
        ""
      ],
      "Resolve traces": [
        ""
      ],
      "Resolve traces for one or more hosts": [
        ""
      ],
      "Resolve traces via Katello interface": [
        ""
      ],
      "Resource": [
        "Источник"
      ],
      "Restart Services via Katello interface": [
        ""
      ],
      "Restart app": [
        ""
      ],
      "Restart via customized remote execution": [
        ""
      ],
      "Restart via remote execution": [
        ""
      ],
      "Restrict composite content view promotion": [
        ""
      ],
      "Result": [
        "Результат"
      ],
      "Retrieve a single errata for a host": [
        "Извлечь отдельное исправление для узла"
      ],
      "Return Red Hat (non-custom) products only": [
        ""
      ],
      "Return content that can be added to the specified object.  The values 'content_view_version' and 'content_view_filter are supported.": [
        ""
      ],
      "Return custom products only": [
        ""
      ],
      "Return deb packages that are applicable to one or more hosts (defaults to true if host_id is specified)": [
        ""
      ],
      "Return deb packages that are upgradable on one or more hosts": [
        ""
      ],
      "Return deb packages that can be added to the specified object.  Only the value 'content_view_version' is supported.": [
        ""
      ],
      "Return enabled products only": [
        ""
      ],
      "Return errata that are applicable to one or more hosts (defaults to true if host_id is specified)": [
        ""
      ],
      "Return errata that are applicable to this host. Defaults to false)": [
        ""
      ],
      "Return errata that are upgradable on one or more hosts": [
        ""
      ],
      "Return errata that can be added to the specified object.  The values 'content_view_version' and 'content_view_filter are supported.": [
        ""
      ],
      "Return name and stream information only)": [
        ""
      ],
      "Return only errata of a particular severity (None, Low, Moderate, Important, Critical)": [
        ""
      ],
      "Return only errata of a particular type (security, bugfix, enhancement)": [
        ""
      ],
      "Return only packages of a particular status (upgradable or up-to-date)": [
        ""
      ],
      "Return only subscriptions which can be attached to the upstream allocation": [
        ""
      ],
      "Return only the latest version of each package": [
        ""
      ],
      "Return only the upstream pools which map to the given Katello pool IDs": [
        ""
      ],
      "Return packages that are applicable to one or more hosts (defaults to true if host_id is specified)": [
        ""
      ],
      "Return packages that are upgradable on one or more hosts": [
        ""
      ],
      "Return packages that can be added to the specified object.  Only the value 'content_view_version' is supported.": [
        ""
      ],
      "Return same, different or all results": [
        ""
      ],
      "Return subscriptions that match installed products of the specified host": [
        "Вернуть список подписок для продуктов, установленных на указанном узле"
      ],
      "Return subscriptions which do not overlap with a currently-attached subscription": [
        "Вернуть только те подписки, которые не пересекаются с уже оформленной подпиской"
      ],
      "Return the content of a Content Credential, used directly by yum": [
        ""
      ],
      "Return the content of a repo gpg key, used directly by yum": [
        "Вернуть содержимое ключа GPG, используемого в yum"
      ],
      "Return the enabled content types": [
        ""
      ],
      "Returns content that can be both added and is currently added to the object. The value 'content_view_filter' is supported": [
        ""
      ],
      "Review affected environment": [
        ""
      ],
      "Review affected environments": [
        ""
      ],
      "Review details": [
        ""
      ],
      "Review the information below and click ": [
        ""
      ],
      "Review your currently selected changes for ": [
        ""
      ],
      "Role": [
        "Роль"
      ],
      "Role of host": [
        ""
      ],
      "Roles": [
        "Роли"
      ],
      "Rules to be added": [
        ""
      ],
      "Run Sync Plan:": [
        ""
      ],
      "Run job invocation": [
        ""
      ],
      "Running": [
        "Работает"
      ],
      "SKU": [
        ""
      ],
      "SLA": [
        ""
      ],
      "SRPM details": [
        ""
      ],
      "SSL CA Content Credential": [
        ""
      ],
      "SSL CA certificate": [
        ""
      ],
      "SSL client certificate": [
        ""
      ],
      "SSL client key": [
        ""
      ],
      "SUBSCRIPTIONS EXPIRING SOON": [
        ""
      ],
      "Save": [
        "Сохранить"
      ],
      "Saving alternate content source...": [
        ""
      ],
      "Schema version 1": [
        ""
      ],
      "Schema version 2": [
        ""
      ],
      "Search": [
        "Поиск"
      ],
      "Search Query": [
        ""
      ],
      "Search available Debian packages": [
        ""
      ],
      "Search available packages": [
        ""
      ],
      "Search host collections": [
        ""
      ],
      "Search pattern (defaults to '*')": [
        ""
      ],
      "Search string": [
        "Поиск строки"
      ],
      "Search string for erratum to perform an action on": [
        ""
      ],
      "Search string for host to perform an action on": [
        "Строка поиска для выбора узлов, над которыми будет выполняться действие"
      ],
      "Search string for hosts to perform an action on": [
        ""
      ],
      "Search string for versions to perform an action on": [
        ""
      ],
      "Security": [
        "Безопасность"
      ],
      "Security errata applicable": [
        "Доступны исправления системы безопасности"
      ],
      "Security errata installable": [
        ""
      ],
      "Select": [
        "Выбрать"
      ],
      "Select ...": [
        ""
      ],
      "Select All": [
        "Выбрать все"
      ],
      "Select Content View": [
        "Выберите представление"
      ],
      "Select None": [
        "Отменить выбор"
      ],
      "Select Organization": [
        "Выберите организацию"
      ],
      "Select Value": [
        ""
      ],
      "Select a CA certificate": [
        ""
      ],
      "Select a client certificate": [
        ""
      ],
      "Select a client key": [
        ""
      ],
      "Select a content source first": [
        ""
      ],
      "Select a content view": [
        ""
      ],
      "Select a lifecycle environment and a content view to move these hosts.": [
        ""
      ],
      "Select a lifecycle environment and a content view to move this host.": [
        ""
      ],
      "Select a lifecycle environment first": [
        ""
      ],
      "Select a lifecycle environment from the available promotion paths to promote new version.": [
        ""
      ],
      "Select a provider to install katello-host-tools-tracer": [
        ""
      ],
      "Select a source": [
        ""
      ],
      "Select add-ons": [
        ""
      ],
      "Select all": [
        ""
      ],
      "Select all rows": [
        ""
      ],
      "Select an Organization": [
        "Выберите организацию"
      ],
      "Select an environment": [
        ""
      ],
      "Select an option": [
        ""
      ],
      "Select an organization": [
        ""
      ],
      "Select attributes for ${akDetails.name}": [
        ""
      ],
      "Select available version of ${cvName} to use": [
        ""
      ],
      "Select available version of content views to use": [
        ""
      ],
      "Select content view": [
        ""
      ],
      "Select environment": [
        "Выберите окружение"
      ],
      "Select host collection(s) to associate with host {hostName}.": [
        ""
      ],
      "Select host collection(s) to remove from host {hostName}.": [
        ""
      ],
      "Select hosts to assign to %s": [
        "Выберите узлы для сопоставления %s"
      ],
      "Select lifecycle environment": [
        ""
      ],
      "Select none": [
        ""
      ],
      "Select one": [
        ""
      ],
      "Select packages to install to the host {hostName}.": [
        ""
      ],
      "Select page": [
        ""
      ],
      "Select products": [
        ""
      ],
      "Select products to associate to this source.": [
        ""
      ],
      "Select row": [
        ""
      ],
      "Select smart proxies to be used with this source.": [
        ""
      ],
      "Select smart proxy": [
        ""
      ],
      "Select source type": [
        ""
      ],
      "Select system purpose attributes for activation key {name}.": [
        ""
      ],
      "Select system purpose attributes for host {name}.": [
        ""
      ],
      "Select the installation media that will be used to provision this host. Choose 'Synced Content' for Synced Kickstart Repositories or 'All Media' for other media.": [
        "Выберите установочный носитель для этого узла. Выберите «Синхронизация содержимого», чтобы использовать репозитории для синхронизированного кикстарта, или «Все носители», чтобы настроить другие носители."
      ],
      "Selected environment ": [
        ""
      ],
      "Selected environments ": [
        ""
      ],
      "Sending a list of included IDs is not allowed when all items are being selected.": [
        ""
      ],
      "Service Level %s": [
        "Уровень обслуживания %s"
      ],
      "Service Level (SLA)": [
        ""
      ],
      "Service level of host": [
        ""
      ],
      "Service level to be used for autoheal": [
        ""
      ],
      "Set content overrides for the host": [
        "Настроить переопределения для содержимого узла"
      ],
      "Set content overrides to one or more hosts": [
        ""
      ],
      "Set true to override to enabled; Set false to override to disabled.'": [
        ""
      ],
      "Set true to remove an override and reset it to 'default'": [
        ""
      ],
      "Sets the system add-ons": [
        ""
      ],
      "Sets the system purpose usage": [
        ""
      ],
      "Sets whether the Host will autoheal subscriptions upon checkin": [
        ""
      ],
      "Setting 'default_location_subscribed_hosts' is not set to a valid location.": [
        ""
      ],
      "Severity": [
        "Степень"
      ],
      "Severity must be one of: %s": [
        ""
      ],
      "Show %s": [
        ""
      ],
      "Show :a_resource": [
        "Показать :a_resource"
      ],
      "Show a Content Credential": [
        ""
      ],
      "Show a content view": [
        "Показать представление"
      ],
      "Show a content view component": [
        ""
      ],
      "Show a content view's history": [
        "Показать журнал представления"
      ],
      "Show a host collection": [
        "Показать коллекцию узлов"
      ],
      "Show a product": [
        "Показать продукт"
      ],
      "Show a repository": [
        "Показать репозиторий"
      ],
      "Show a subscription": [
        "Показать подписку"
      ],
      "Show a sync plan": [
        "Показать план синхронизации"
      ],
      "Show affected activation keys": [
        ""
      ],
      "Show affected hosts": [
        ""
      ],
      "Show all": [
        ""
      ],
      "Show all repository sets": [
        ""
      ],
      "Show an activation key": [
        "Показать ключ активации"
      ],
      "Show an alternate content source.": [
        ""
      ],
      "Show an environment": [
        "Показать окружение"
      ],
      "Show content available for an activation key": [
        "Показать доступное содержимое для ключа активации"
      ],
      "Show content view version": [
        "Показать версию представления"
      ],
      "Show filter rule info": [
        "Показать информацию о правиле фильтрации"
      ],
      "Show full description": [
        ""
      ],
      "Show hosts associated to an activation key": [
        ""
      ],
      "Show organization": [
        "Показать организацию"
      ],
      "Show release versions available for an activation key": [
        "Показать версии для ключа активации"
      ],
      "Show releases available for the content host": [
        "Показать версии для узла содержимого"
      ],
      "Show repositories": [
        ""
      ],
      "Show repositories enabled on the host that are known to Katello": [
        ""
      ],
      "Show the available repository types": [
        "Показать доступные типы репозиториев"
      ],
      "Show whether each lifecycle environment is associated with the given Smart Proxy id.": [
        ""
      ],
      "Shows status of Katello system and it's subcomponents": [
        ""
      ],
      "Shows version information": [
        "Показывает версию"
      ],
      "Simple Content Access has been disabled for '%{subject}'.": [
        ""
      ],
      "Simple Content Access has been enabled for '%{subject}'.": [
        ""
      ],
      "Simple Content Access is the only supported content access mode": [
        ""
      ],
      "Simplified": [
        ""
      ],
      "Single content view consisting of e.g. repositories": [
        ""
      ],
      "Size of file to upload": [
        ""
      ],
      "Skip metadata check on each repository on the smart proxy": [
        ""
      ],
      "Skipped pulp_auth check after failed pulp check": [
        "Проверка pulp_auth была пропущена после неудачной проверки pulp"
      ],
      "Smart proxies": [
        "Капсулы"
      ],
      "Smart proxy ID": [
        ""
      ],
      "Smart proxy IDs": [
        "Идентификаторы капсул"
      ],
      "Smart proxy content count refresh has started in the background": [
        ""
      ],
      "Smart proxy content source not found!": [
        ""
      ],
      "Smart proxy name": [
        ""
      ],
      "Sockets": [
        "Сокеты"
      ],
      "Sockets: %s": [
        ""
      ],
      "Solution": [
        "Решение"
      ],
      "Solve RPM dependencies by default on Content View publish, defaults to false": [
        ""
      ],
      "Solve dependencies": [
        ""
      ],
      "Some environments are disabled because they are not associated with the host's content source.": [
        ""
      ],
      "Some environments are disabled because they are not associated with the selected content source.": [
        ""
      ],
      "Some hosts are not registered as content hosts and will be ignored.": [
        ""
      ],
      "Some of your inputs contain errors. Please update them and save your changes again.": [
        ""
      ],
      "Some services are not properly started. See the About page for more information.": [
        ""
      ],
      "Something went wrong while adding a bookmark: ${getBookmarkErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while adding a filter rule! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while adding component! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while adding filter rules! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while creating the filter! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while deleting alternate content sources: ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while deleting filter rules! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while deleting filters! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while deleting this filter! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while deleting versions ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while editing a filter rule! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while editing the filter! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while editing version details. ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while fetching ${lowerCase(pluralLabel)}! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while fetching files! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while fetching rpm packages! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while getting container manifest lists! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while getting container tags! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while getting deb packages! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while getting errata! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while getting module streams! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while getting repositories! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while getting the data. See the logs for more information": [
        ""
      ],
      "Something went wrong while getting version details. ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while loading the Smart Proxy. See the logs for more information": [
        ""
      ],
      "Something went wrong while loading the content views. See the logs for more information": [
        ""
      ],
      "Something went wrong while refreshing alternate content sources: ": [
        ""
      ],
      "Something went wrong while refreshing content counts: ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while removing a filter rule! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while removing component! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving package groups! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the activation keys! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the container tags! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the content view components! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the content view filter rules! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the content view filter! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the content view filters! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the content view history! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the content view versions! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the content! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the deb packages! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the errata! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the files! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the hosts! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the module streams! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the package groups! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the packages! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the repositories! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while retrieving the repository types! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while updating the content source. See the logs for more information": [
        ""
      ],
      "Something went wrong! Please check server logs!": [
        ""
      ],
      "Sort field and order, eg. 'id DESC'": [
        ""
      ],
      "Source RPM": [
        "Исходный код"
      ],
      "Source RPMs": [
        "Исходные RPM"
      ],
      "Source type": [
        ""
      ],
      "Specify an export chunk size less than 1_000_000 GB": [
        ""
      ],
      "Specify the list of units in each repo": [
        ""
      ],
      "Split the exported content into archives no greater than the specified size in gigabytes.": [
        ""
      ],
      "Stacking ID": [
        "Объединенный идентификатор"
      ],
      "Start Date": [
        "Дата начала"
      ],
      "Start Date and Time can't be blank": [
        "Дата и время начала не могут быть пустыми."
      ],
      "Start Time": [
        "Время начала"
      ],
      "Start date": [
        ""
      ],
      "Starts": [
        "Начало"
      ],
      "State": [
        "Состояние"
      ],
      "Status": [
        "Статус"
      ],
      "Status must be one of: %s": [
        ""
      ],
      "Storage": [
        "Хранение данных"
      ],
      "Stream": [
        ""
      ],
      "Streamed": [
        ""
      ],
      "Streams based on the host based on the installation status": [
        ""
      ],
      "Streams based on the host based on their status": [
        ""
      ],
      "Submit": [
        "Применить"
      ],
      "Subnet IDs": [
        "Идентификаторы подсетей"
      ],
      "Subpaths": [
        ""
      ],
      "Subscription": [
        "Подписка"
      ],
      "Subscription Details": [
        "Подписка"
      ],
      "Subscription ID": [
        "Идентификатор подписки"
      ],
      "Subscription Info": [
        "Сведения о подписке"
      ],
      "Subscription Manifest": [
        "Манифест подписки"
      ],
      "Subscription Manifest expiration date check": [
        ""
      ],
      "Subscription Manifest validity check": [
        ""
      ],
      "Subscription Name": [
        ""
      ],
      "Subscription Pool id": [
        "Идентификатор пула подписок"
      ],
      "Subscription Pool uuid": [
        "UUID пула подписок"
      ],
      "Subscription UUID": [
        ""
      ],
      "Subscription connection enabled": [
        ""
      ],
      "Subscription expiration notification": [
        ""
      ],
      "Subscription id is nil.": [
        "Идентификатор подписки не определен."
      ],
      "Subscription identifier": [
        "Идентификатор подписки"
      ],
      "Subscription manager name registration fact": [
        ""
      ],
      "Subscription manager name registration fact strict matching": [
        ""
      ],
      "Subscription manifest file": [
        "Файл манифеста подписок"
      ],
      "Subscription not found": [
        ""
      ],
      "Subscription was not persisted - %{error_message}": [
        ""
      ],
      "Subscriptions": [
        "Подписки"
      ],
      "Subscriptions expiring soon": [
        ""
      ],
      "Subscriptions have been saved and are being updated. ": [
        ""
      ],
      "Subscriptions service": [
        ""
      ],
      "Substitution Mismatch. Unable to update for content: (%{content}). From [%{content_url}] To [%{new_url}].": [
        ""
      ],
      "Success": [
        "Успешно"
      ],
      "Successfully added %s Host(s).": [
        "Добавлено узлов: %s"
      ],
      "Successfully added %{count} content host(s) to host collection %{host_collection}.": [
        "Узлы содержимого (всего %{count}) успешно добавлены в коллекцию %{host_collection}."
      ],
      "Successfully changed sync plan for %s product(s)": [
        "План синхронизации изменен для %s продукта(ов)."
      ],
      "Successfully initiated removal of %s product(s)": [
        "Продукты будут удалены (всего %s)."
      ],
      "Successfully refreshed.": [
        ""
      ],
      "Successfully removed %s Host(s).": [
        "Удалено узлов: %s"
      ],
      "Successfully removed %{count} content host(s) from host collection %{host_collection}.": [
        "Узлы (всего %{count}) были удалены из коллекции %{host_collection}."
      ],
      "Successfully synced capsule.": [
        ""
      ],
      "Successfully synchronized.": [
        ""
      ],
      "Summary": [
        "Краткая информация"
      ],
      "Support Type": [
        "Тип поддержки"
      ],
      "Support ended": [
        ""
      ],
      "Supported Content Types": [
        ""
      ],
      "Sync Canceled": [
        "Синхронизация отменена"
      ],
      "Sync Connect Timeout": [
        ""
      ],
      "Sync Content View on Smart Proxy(ies)": [
        ""
      ],
      "Sync Incomplete": [
        "Синхронизация не завершена"
      ],
      "Sync Overview": [
        "Синхронизация"
      ],
      "Sync Plan": [
        "План синхронизации"
      ],
      "Sync Plan: ": [
        ""
      ],
      "Sync Plans": [
        "План синхронизации"
      ],
      "Sync Repository on Smart Proxy(ies)": [
        ""
      ],
      "Sync Smart Proxies after content view promotion": [
        ""
      ],
      "Sync Sock Connect Timeout": [
        ""
      ],
      "Sync Sock Read Timeout": [
        ""
      ],
      "Sync Status": [
        "Статус синхронизации"
      ],
      "Sync Summary": [
        "Сводка синхронизации"
      ],
      "Sync Summary for %s": [
        "Сводка синхронизации для %s"
      ],
      "Sync Total Timeout": [
        ""
      ],
      "Sync a repository": [
        "Синхронизация репозитория"
      ],
      "Sync all repositories for a product": [
        "Синхронизировать все репозитории для указанного продукта"
      ],
      "Sync capsule": [
        ""
      ],
      "Sync complete.": [
        "Успешно."
      ],
      "Sync errata": [
        ""
      ],
      "Sync one or more products": [
        "Синхронизировать продукты"
      ],
      "Sync plan identifier to attach": [
        "Идентификатор плана синхронизации"
      ],
      "Sync smart proxy content directly from upstream repositories by selecting the desired products.": [
        ""
      ],
      "Sync state": [
        ""
      ],
      "Syncable export": [
        ""
      ],
      "Synced": [
        ""
      ],
      "Synced ": [
        ""
      ],
      "Synced Content": [
        "Синхронизация содержимого"
      ],
      "Synchronize": [
        "Синхронизировать"
      ],
      "Synchronize Now": [
        "Синхронизировать"
      ],
      "Synchronize repository": [
        "Синхронизировать репозиторий"
      ],
      "Synchronize smart proxy": [
        ""
      ],
      "Synchronize the content to the smart proxy": [
        ""
      ],
      "Synchronize: Skip Metadata Check": [
        ""
      ],
      "Synchronize: Validate Content": [
        ""
      ],
      "Syncing Complete.": [
        "Синхронизация завершена."
      ],
      "Synopsis": [
        ""
      ],
      "System Purpose": [
        ""
      ],
      "System Status": [
        "Состояние систем"
      ],
      "System purpose": [
        ""
      ],
      "System purpose attributes updated": [
        ""
      ],
      "System purpose enables you to set the system's intended use on your network and improves reporting accuracy in the Subscriptions service of the Red Hat Hybrid Cloud Console.": [
        ""
      ],
      "Tag name": [
        ""
      ],
      "Tags": [
        "Метки"
      ],
      "Task": [
        "Задача"
      ],
      "Task ${task.humanized.action} completed with a result of ${task.result}. ${task.errors ? getErrors(task) : ''}": [
        ""
      ],
      "Task ${task.humanized.action} has started.": [
        ""
      ],
      "Task ID": [
        ""
      ],
      "Task canceled": [
        "Задача отменена"
      ],
      "Task detail": [
        ""
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
        "Временные"
      ],
      "The '%s' environment cannot contain a changeset!": [
        "Окружение «%s» не может содержать набор изменений."
      ],
      "The Alternate Content Source type": [
        ""
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
        ""
      ],
      "The action requested on this composite view cannot be performed until all of the component content view versions have been promoted to the target environment: %{env}.  This restriction is optional and can be modified in the Administrator -> Settings -> Content page using the restrict_composite_view flag.": [
        ""
      ],
      "The actual file contents": [
        "Содержимое файла"
      ],
      "The content type for the Alternate Content Source": [
        ""
      ],
      "The current organization cannot be deleted. Please switch to a different organization before deleting.": [
        "Текущая организация не может быть удалена. Перейдите в другую организацию и повторите попытку."
      ],
      "The default content view cannot be edited, published, or deleted.": [
        "Исходное представление не может быть изменено, опубликовано или удалено."
      ],
      "The default content view cannot be promoted": [
        "Используемое по умолчанию представление не может переноситься."
      ],
      "The description for the content view version": [
        ""
      ],
      "The description for the content view version promotion": [
        ""
      ],
      "The description for the new generated Content View Versions": [
        "Описание новых версий представления"
      ],
      "The email notification will include subscriptions expiring in this number of days or fewer.": [
        ""
      ],
      "The erratum filter rule end date is in an invalid format or type.": [
        "Недействительный формат или тип даты окончания в правиле фильтрации."
      ],
      "The erratum filter rule start date is in an invalid format or type.": [
        "Недействительный формат или тип даты начала в правиле фильтрации."
      ],
      "The erratum type must be an array. Invalid value provided": [
        "Недопустимое значение: типы исправлений должны быть представлены в виде массивов. "
      ],
      "The field to sort the data by. Defaults to the created date.": [
        ""
      ],
      "The following hosts have errata that apply to them: ": [
        ""
      ],
      "The following repositories provided in the import metadata have an incorrect content type or provider type. Make sure the export and import repositories are of the same type before importing\\n %{repos}": [
        ""
      ],
      "The id of the content source": [
        ""
      ],
      "The id of the content view": [
        ""
      ],
      "The id of the host to alter": [
        "Идентификатор узла"
      ],
      "The id of the lifecycle environment": [
        ""
      ],
      "The ids of the hosts to alter. Hosts not managed by Katello are ignored": [
        ""
      ],
      "The list of environments to promote the specified Content View Version to (replacing the older version)": [
        ""
      ],
      "The manifest doesn't exist on console.redhat.com. Please create and import a new manifest.": [
        ""
      ],
      "The manifest imported within Organization %{subject} is no longer valid. Please import a new manifest.": [
        ""
      ],
      "The maximum number of second that Pulp can take to do a single sync operation, e.g., download a single metadata file.": [
        ""
      ],
      "The maximum number of seconds for Pulp to connect to a peer for a new connection not given from a pool.": [
        ""
      ],
      "The maximum number of seconds for Pulp to establish a new connection or for waiting for a free connection from a pool if pool connection limits are exceeded.": [
        ""
      ],
      "The maximum number of seconds that Pulp can take to download a file, not counting connection time.": [
        ""
      ],
      "The maximum number of versions of each package to keep.": [
        ""
      ],
      "The number of days remaining in a subscription before you will be reminded about renewing it. Also used for manifest expiration warnings.": [
        ""
      ],
      "The number of items fetched from a single paged Pulp API call.": [
        ""
      ],
      "The offset in the file where the content starts": [
        "Смещение содержимого в файле"
      ],
      "The order to sort the results in. ['asc', 'desc'] Defaults to 'desc'.": [
        ""
      ],
      "The organization's manifest does not contain the subscriptions required to enable the following repositories.\\n %{repos}": [
        ""
      ],
      "The page you are attempting to access requires selecting a specific organization.": [
        "Для доступа к этой странице надо выбрать организацию."
      ],
      "The path %{real_path} does not seem to be a valid repository. If you think this is an error, please try refreshing your manifest.": [
        ""
      ],
      "The promotion of %{content_view} to %{environment} has completed.  %{count} errata are available to your hosts.": [
        "%{content_view} перенесено в %{environment}.  Доступно исправлений: %{count}."
      ],
      "The promotion of %{content_view} to <b>%{environment}</b> has completed.  %{count} needed errata are installable on your hosts.": [
        "%{content_view} перенесено в  <b>%{environment}</b>. Обязательных исправлений, готовых к установке: %{count}."
      ],
      "The repository is already enabled": [
        "Репозиторий уже подключен"
      ],
      "The repository's publication is missing. Please run a 'complete sync' on %s.": [
        ""
      ],
      "The request did not contain any repository information.": [
        ""
      ],
      "The requested resource does not belong to the specified Organization": [
        ""
      ],
      "The requested resource does not belong to the specified organization": [
        ""
      ],
      "The requested traces were not found for this host": [
        ""
      ],
      "The selected kickstart repository is not part of the assigned content view, lifecycle environment, content source, operating system, and architecture": [
        ""
      ],
      "The selected lifecycle environment contains no activation keys": [
        ""
      ],
      "The selected/Inherited Content View is not available for this Lifecycle Environment": [
        ""
      ],
      "The specified organization is in Simple Content Access mode. Attaching subscriptions is disabled": [
        ""
      ],
      "The subscription cannot be found upstream": [
        ""
      ],
      "The subscription is no longer available": [
        ""
      ],
      "The synchronization of \\\"%s\\\" has completed.  Below is a summary of new errata.": [
        "Синхронизация «%s» завершена. Ниже приведен список новых исправлений."
      ],
      "The token key to use for authentication.": [
        ""
      ],
      "The type of content to remove (srpm, docker_manifest, etc.). Check removable types here: /katello/api/repositories/repository_types": [
        ""
      ],
      "The type of content to upload (srpm, file, etc.). Check uploadable types here: /katello/api/repositories/repository_types": [
        ""
      ],
      "The value will be available in templates as @host.params['kt_activation_keys']": [
        ""
      ],
      "There are no Manifests to display": [
        ""
      ],
      "There are no Subscriptions to display": [
        ""
      ],
      "There are no errata that need to be applied to registered content hosts.": [
        "Нет исправлений для зарегистрированных систем."
      ],
      "There are no host collections available to add.": [
        ""
      ],
      "There are no products or repositories enabled. Try enabling via %{custom} or %{redhat}.": [
        "Нет продуктов и репозиториев. Настройте их на странице %{custom} или %{redhat}."
      ],
      "There are {numberOfActivationKeys} activation keys that need to be reassigned.": [
        ""
      ],
      "There are {numberOfHosts} hosts that need to be reassigned.": [
        ""
      ],
      "There either were no environments nor versions specified or there were invalid environments/versions specified. Please check environment_ids and content_view_version_ids parameters.": [
        "Окружения и версии не заданы или определены неверно. Проверьте параметры environment_ids и content_view_version_ids."
      ],
      "There is no downloaded content to clean.": [
        ""
      ],
      "There is no manifest history to display.": [
        ""
      ],
      "There is no such HTTP proxy": [
        ""
      ],
      "There is nothing to see here": [
        ""
      ],
      "There is {numberOfActivationKeys} activation key that needs to be reassigned.": [
        ""
      ],
      "There is {numberOfHosts} host that needs to be reassigned.": [
        ""
      ],
      "There was a problem retrieving Activation Key data from the server.": [
        ""
      ],
      "There was an error retrieving data from the server. Check your connection and try again.": [
        ""
      ],
      "There was an issue with the backend service %s: ": [
        ""
      ],
      "There's no running synchronization for this smart proxy.": [
        ""
      ],
      "This Content View must be set to Import-only before performing an import": [
        ""
      ],
      "This Host is not currently registered with subscription-manager.": [
        ""
      ],
      "This Organization's subscription manifest has expired. Please import a new manifest.": [
        ""
      ],
      "This action doesn't support package groups": [
        "Это действие неприменимо к группам пакетов."
      ],
      "This action should only be taken for debugging purposes.": [
        ""
      ],
      "This action should only be taken in extreme circumstances or for debugging purposes.": [
        ""
      ],
      "This activation key is associated to one or more Hosts/Hostgroups. Search and unassociate Hosts/Hostgroups using params.kt_activation_keys ~ \\\"%{name}\\\" before deleting.": [
        ""
      ],
      "This certificate allows a user to view the repositories in any environment from a browser.": [
        "Сертификат позволяет обращаться к репозиториям в окружении из окна браузера."
      ],
      "This content view does not have any versions associated.": [
        ""
      ],
      "This content view version doesn't have a history.": [
        ""
      ],
      "This content view will be automatically updated to the latest version.": [
        ""
      ],
      "This content view will be deleted. Changes will be effective after clicking Delete.": [
        ""
      ],
      "This endpoint is deprecated and will be removed in an upcoming release. Simple Content Access is the only supported content access mode.": [
        ""
      ],
      "This erratum is not installable because it is not in this host's content view and lifecycle environment.": [
        ""
      ],
      "This host does not have any Module streams.": [
        ""
      ],
      "This host does not have any packages.": [
        ""
      ],
      "This host has errata that are applicable, but not installable. Adjust your filters and try again.": [
        ""
      ],
      "This host's organization is in Simple Content Access mode. Attaching subscriptions is disabled.": [
        ""
      ],
      "This host's organization is in Simple Content Access mode. Auto-attach is disabled": [
        ""
      ],
      "This is disabled because a manifest task is in progress": [
        ""
      ],
      "This is disabled because a manifest-related task is in progress.": [
        ""
      ],
      "This is disabled because no connection could be made to the upstream Manifest.": [
        ""
      ],
      "This is disabled because no manifest exists": [
        ""
      ],
      "This is disabled because no manifest has been uploaded.": [
        ""
      ],
      "This is disabled because no subscriptions are selected.": [
        ""
      ],
      "This is not a linked repository": [
        ""
      ],
      "This page shows the subscriptions available from this organization's subscription manifest. {br} Learn more about your overall subscription usage with the {subscriptionsService}.": [
        ""
      ],
      "This repository has pending tasks in associated content views. Please wait for the tasks: ": [
        ""
      ],
      "This repository is not suggested. Please see additional %(anchorBegin)sdocumentation%(anchorEnd)s prior to use.": [
        ""
      ],
      "This request may only be performed on a Smart proxy that has the Pulpcore feature with mirror=true.": [
        ""
      ],
      "This service is available for unauthenticated users": [
        "Эта услуга доступна анонимным пользователям."
      ],
      "This service is only available for authenticated users": [
        "Эта услуга доступна только авторизованным пользователям."
      ],
      "This shows repositories that are used in a typical setup.": [
        ""
      ],
      "This subscription is not relevant to the current organization.": [
        ""
      ],
      "This version has not been promoted to any environments.": [
        ""
      ],
      "This version is not promoted to any environments.": [
        ""
      ],
      "This version will be removed from:": [
        ""
      ],
      "This will create a copy of {cv}, including details, repositories, and filters. Generated data such as history, tasks and versions will not be copied.": [
        ""
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
        ""
      ],
      "Timestamp": [
        ""
      ],
      "Title": [
        "Заголовок"
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
        ""
      ],
      "To include or exclude specific content from the content view, create a filter. Without filters, the content view includes everything from the added repositories.": [
        ""
      ],
      "Total steps: ": [
        ""
      ],
      "Tracer": [
        ""
      ],
      "Tracer helps administrators identify applications that need to be restarted after a system is patched.": [
        ""
      ],
      "Tracer profile uploaded successfully": [
        ""
      ],
      "Traces": [
        ""
      ],
      "Traces are being enabled": [
        ""
      ],
      "Traces are not enabled": [
        ""
      ],
      "Traces help administrators identify applications that need to be restarted after a system is patched.": [
        ""
      ],
      "Traces may be enabled by a user with the appropriate permissions.": [
        ""
      ],
      "Traces may be listed here after {pkgLink}.": [
        ""
      ],
      "Traces not available": [
        ""
      ],
      "Traces that require logout cannot be restarted remotely": [
        ""
      ],
      "Traces will be shown here to a user with the appropriate permissions.": [
        ""
      ],
      "Traffic for all alternate content sources associated with this smart proxy will go through the chosen HTTP proxy.": [
        ""
      ],
      "Trigger an auto-attach of subscriptions": [
        "Разрешить автоматическое выделение подписок"
      ],
      "Trigger an auto-attach of subscriptions on one or more hosts": [
        ""
      ],
      "Try changing your search criteria.": [
        ""
      ],
      "Try changing your search query.": [
        ""
      ],
      "Try changing your search settings.": [
        ""
      ],
      "Trying to cancel the synchronization...": [
        "Попытка отмены синхронизации..."
      ],
      "Type": [
        "Тип"
      ],
      "Type must be one of: %s": [
        ""
      ],
      "Type of content": [
        ""
      ],
      "Type of content: \\\"cert\\\", \\\"gpg_key\\\"": [
        ""
      ],
      "Type of repository. Available types endpoint: /katello/api/repositories/repository_types": [
        ""
      ],
      "URL": [
        "URL"
      ],
      "URL and paths": [
        ""
      ],
      "URL and subpaths": [
        ""
      ],
      "URL needs to have a trailing /": [
        ""
      ],
      "URL of a PyPI content source such as https://pypi.org.": [
        ""
      ],
      "URL of an OSTree repository.": [
        ""
      ],
      "UUID": [
        "UUID"
      ],
      "UUID of the consumer": [
        ""
      ],
      "UUID of the content host": [
        "UUID узла содержимого"
      ],
      "UUID of the system": [
        "UUID системы"
      ],
      "UUID to use for registered host, random uuid is generated if not provided": [
        "UUID регистрируемого узла. Если не определен, будет сгенерирован случайный UUID."
      ],
      "UUIDs of the virtual guests from the host's hypervisor": [
        "Идентификаторы UUID виртуальных машин, находящихся под контролем гипервизора узла"
      ],
      "Unable to connect": [
        "Не удалось подключиться"
      ],
      "Unable to connect. Got: %s": [
        ""
      ],
      "Unable to create ContentViewEnvironment. Check the logs for more information.": [
        ""
      ],
      "Unable to delete any alternate content source. You either do not have the permission to delete, or none of the alternate content sources exist.": [
        ""
      ],
      "Unable to detect pulp storage": [
        "Хранилище Pulp не обнаружено"
      ],
      "Unable to detect puppet path": [
        ""
      ],
      "Unable to find product '%s' in organization '%s'": [
        ""
      ],
      "Unable to get users": [
        ""
      ],
      "Unable to import in to Content View specified in the metadata - '%{name}'. The 'import_only' attribute for the content view is set to false. To mark this Content View as importable, have your system administrator run the following command on the server. ": [
        ""
      ],
      "Unable to incrementally export. Do a Full Export on the library content before updating from the latest increment.": [
        ""
      ],
      "Unable to incrementally export. Do a Full Export on the repository content.": [
        ""
      ],
      "Unable to reassign activation_keys. Please check activation_key_content_view_id and activation_key_environment_id.": [
        "Не удалось переназначить ключи активации. Проверьте activation_key_content_view_id и activation_key_environment_id."
      ],
      "Unable to reassign activation_keys. Please provide key_content_view_id and key_environment_id.": [
        "Не удалось переназначить ключи активации. Необходимо указать key_content_view_id и key_environment_id."
      ],
      "Unable to reassign content hosts. Please provide system_content_view_id and system_environment_id.": [
        "Не удалось переназначить узлы. Необходимо указать system_content_view_id и system_environment_id."
      ],
      "Unable to reassign systems. Please check system_content_view_id and system_environment_id.": [
        "Не удалось переназначить системы. Проверьте system_content_view_id и system_environment_id."
      ],
      "Unable to refresh any alternate content source. You either do not have the permission to refresh, or no alternate content sources exist.": [
        ""
      ],
      "Unable to refresh any alternate content source. You either do not have the permission to refresh, or none of the alternate content sources exist.": [
        ""
      ],
      "Unable to send errata e-mail notification: %{error}": [
        ""
      ],
      "Unable to sync repo. This repository does not have a feed url.": [
        "Не удалось синхронизировать репозиторий: не задан URL источника синхронизации"
      ],
      "Unable to sync repo. This repository is not a library instance repository.": [
        ""
      ],
      "Unable to synchronize any repository. You either do not have the permission to synchronize or the selected repositories do not have a feed url.": [
        "Не удалось синхронизировать репозитории. Недостаточно разрешений или не определен URL репозитория."
      ],
      "Unable to update the repository list": [
        ""
      ],
      "Unable to update the user-repository mapping": [
        ""
      ],
      "Unapplied Errata": [
        "Несохраненные исправления"
      ],
      "Unattach a subscription": [
        "Отключить подписку"
      ],
      "Unfiltered params array: %s.": [
        ""
      ],
      "Uninstall and reset": [
        ""
      ],
      "Unknown": [
        "Неизвестно"
      ],
      "Unknown Action": [
        ""
      ],
      "Unknown errata status": [
        "Неизвестный статус исправлений"
      ],
      "Unknown traces status": [
        ""
      ],
      "Unlimited": [
        "∞"
      ],
      "Unregister host %s before assigning an organization": [
        ""
      ],
      "Unregister the host as a subscription consumer": [
        "Отменить регистрацию узла"
      ],
      "Unspecified": [
        ""
      ],
      "Unsupported CDN resource": [
        ""
      ],
      "Unsupported URL protocol %s.": [
        "Протокол %s не поддерживается."
      ],
      "Unsupported event type %{type}. Supported: %{types}": [
        ""
      ],
      "Up-to date": [
        ""
      ],
      "Update": [
        "Обновить"
      ],
      "Update Alternate Content Source": [
        ""
      ],
      "Update CDN Configuration": [
        ""
      ],
      "Update Content Counts": [
        ""
      ],
      "Update Content Overrides": [
        ""
      ],
      "Update Content Overrides to %s": [
        ""
      ],
      "Update Upstream Subscription": [
        ""
      ],
      "Update a Content Credential": [
        ""
      ],
      "Update a component associated with the content view": [
        ""
      ],
      "Update a content view": [
        "Обновить представление"
      ],
      "Update a content view version": [
        ""
      ],
      "Update a filter rule. The parameters included should be based upon the filter type.": [
        "Обновить правило фильтрации. Список параметров зависит от типа фильтра."
      ],
      "Update a host collection": [
        "Обновить коллекцию узлов"
      ],
      "Update a repository": [
        "Обновить репозиторий"
      ],
      "Update a sync plan": [
        "Обновить план синхронизации"
      ],
      "Update an activation key": [
        "Обновить ключ активации"
      ],
      "Update an alternate content source.": [
        ""
      ],
      "Update an environment": [
        "Обновить окружение"
      ],
      "Update an environment in an organization": [
        "Обновить окружение в организации"
      ],
      "Update content counts for the smart proxy": [
        ""
      ],
      "Update content urls": [
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
      "Update http proxy": [
        ""
      ],
      "Update http proxy details": [
        ""
      ],
      "Update installed packages, enabled repos, module inventory": [
        ""
      ],
      "Update organization": [
        "Обновить организацию"
      ],
      "Update package group via Katello interface": [
        "Обновить группу пакетов с помощью Katello"
      ],
      "Update package via Katello interface": [
        "Обновить пакеты с помощью Katello"
      ],
      "Update packages via Katello interface": [
        ""
      ],
      "Update redhat repository": [
        ""
      ],
      "Update release version for host": [
        ""
      ],
      "Update release version for host %s": [
        ""
      ],
      "Update services requiring restart": [
        ""
      ],
      "Update the CDN configuration": [
        ""
      ],
      "Update the HTTP proxy configuration on the repositories of one or more products.": [
        ""
      ],
      "Update the content source for specified hosts and generate the reconfiguration script": [
        ""
      ],
      "Update the host immediately via remote execution": [
        ""
      ],
      "Update the information about enabled repositories": [
        "Обновить информацию о подключенных репозиториях"
      ],
      "Update the quantity of one or more subscriptions on an upstream allocation": [
        ""
      ],
      "Update version": [
        ""
      ],
      "Updated": [
        "Обновлено"
      ],
      "Updated component details": [
        ""
      ],
      "Updated from": [
        ""
      ],
      "Updates": [
        "Обновления"
      ],
      "Updates a product": [
        "Обновить продукт"
      ],
      "Updates available: Component content view versions have been updated.": [
        ""
      ],
      "Updates available: Repositories and/or filters have changed.": [
        ""
      ],
      "Updating Package...": [
        "Обновление пакета..."
      ],
      "Updating System Purpose for host": [
        ""
      ],
      "Updating System Purpose for host %s": [
        ""
      ],
      "Updating package group...": [
        "Обновление группы пакетов..."
      ],
      "Updating repository authentication configuration": [
        ""
      ],
      "Upgradable": [
        ""
      ],
      "Upgradable to": [
        ""
      ],
      "Upgrade": [
        ""
      ],
      "Upgrade via customized remote execution": [
        ""
      ],
      "Upgrade via remote execution": [
        ""
      ],
      "Upload Content Credential contents": [
        ""
      ],
      "Upload a chunk of the file's content": [
        "Обновить содержимое файла частично"
      ],
      "Upload a subscription manifest": [
        "Отправить манифест подписки"
      ],
      "Upload content into the repository": [
        "Добавить содержимое в репозиторий"
      ],
      "Upload into": [
        "Добавить в"
      ],
      "Upload package / repos profile": [
        ""
      ],
      "Upload request id": [
        "Отправить ID запроса"
      ],
      "Upstream Candlepin": [
        ""
      ],
      "Upstream Content View Label, default: Default_Organization_View. Relevant only for 'upstream_server' type.": [
        ""
      ],
      "Upstream Lifecycle Environment, default: Library. Relevant only for 'upstream_server' type.": [
        ""
      ],
      "Upstream Name cannot be blank when Repository URL is provided.": [
        ""
      ],
      "Upstream authentication token string for yum repositories.": [
        ""
      ],
      "Upstream foreman server to sync CDN content from. Relevant only for 'upstream_server' type.": [
        ""
      ],
      "Upstream identity certificate not available": [
        "Официальный сертификат недоступен"
      ],
      "Upstream organization %s does not provide this content path": [
        ""
      ],
      "Upstream organization %{org_label} does not have a content view with the label %{cv_label}": [
        ""
      ],
      "Upstream organization %{org_label} does not have a lifecycle environment with the label %{lce_label}": [
        ""
      ],
      "Upstream organization to sync CDN content from. Relevant only for 'upstream_server' type.": [
        ""
      ],
      "Upstream password requires upstream username be set.": [
        ""
      ],
      "Upstream username and password may only be set on custom repositories.": [
        ""
      ],
      "Upstream username and upstream password cannot be blank for ULN repositories": [
        ""
      ],
      "Upstream username requires upstream password be set.": [
        ""
      ],
      "Usage": [
        ""
      ],
      "Usage Type": [
        ""
      ],
      "Usage of host": [
        ""
      ],
      "Usage type": [
        ""
      ],
      "Use HTTP Proxies": [
        ""
      ],
      "Use HTTP proxies": [
        ""
      ],
      "Used to determine download concurrency of the repository in pulp3. Use value less than 20. Defaults to 10": [
        ""
      ],
      "User": [
        "Пользователь"
      ],
      "User '%s' did not specify an organization ID and does not have a default organization.": [
        "Пользователь «%s» не задал идентификатор организации и не имеет исходной организации."
      ],
      "User '%{user}' does not belong to Organization '%{organization}'.": [
        "Пользователь «%{user}» не входит в организацию «%{organization}»."
      ],
      "User IDs": [
        "Идентификаторы пользователей"
      ],
      "User must be logged in.": [
        "Пользователь должен быть авторизован."
      ],
      "Username": [
        "Имя"
      ],
      "Username for authentication. Relevant only for 'upstream_server' type.": [
        ""
      ],
      "Username of the upstream repository user used for authentication": [
        ""
      ],
      "Username to access URL": [
        ""
      ],
      "Username, Password, Organization Label, and SSL CA Content Credential must be provided together.": [
        ""
      ],
      "Username, Password, Upstream Organization Label, and SSL CA Credential are required when using an upstream Foreman server.": [
        ""
      ],
      "Validate host/lifecycle environment/content source coherence": [
        ""
      ],
      "Validate that a host's assigned lifecycle environment is synced by the smart proxy from which the host will get its content. Applies only to API requests; does not affect web UI checks": [
        ""
      ],
      "Value must either be a boolean or 'default' for 'enabled'": [
        ""
      ],
      "Verify SSL": [
        "Проверить SSL"
      ],
      "Verify checksum": [
        ""
      ],
      "Verify checksum for content on smart proxy": [
        ""
      ],
      "Verify checksum for one or more products": [
        ""
      ],
      "Verify checksum of repositories in %{name} %{version}": [
        ""
      ],
      "Verify checksum of repository contents": [
        ""
      ],
      "Verify checksum of repository contents in the content view version": [
        ""
      ],
      "Verify checksum of version repositories": [
        ""
      ],
      "Version": [
        "Версия"
      ],
      "Version ": [
        ""
      ],
      "Version ${item.version}": [
        ""
      ],
      "Version ${version.version}": [
        ""
      ],
      "Version ${versionNameToRemove} will be deleted from all environments. It will no longer be available for promotion.": [
        ""
      ],
      "Version ${versionNameToRemove} will be deleted from the listed environments. It will no longer be available for promotion.": [
        ""
      ],
      "Version ${versionOne}": [
        ""
      ],
      "Version ${versionTwo}": [
        ""
      ],
      "Version details updated.": [
        ""
      ],
      "Version in use": [
        ""
      ],
      "Versions": [
        "Версия"
      ],
      "Versions ": [
        ""
      ],
      "Versions to compare": [
        ""
      ],
      "Versions to exclusively include in the action": [
        ""
      ],
      "Versions to explicitly exclude in the action. All other versions will be included in the action, unless an included parameter is passed as well.": [
        ""
      ],
      "Versions will appear here when the content view is published.": [
        ""
      ],
      "View %{view} has not been promoted to %{env}": [
        "Представление %{view} не было перенесено в %{env}"
      ],
      "View Filters": [
        ""
      ],
      "View Subscription Usage": [
        ""
      ],
      "View a report of the affected hosts": [
        ""
      ],
      "View applicable errata": [
        ""
      ],
      "View by": [
        ""
      ],
      "View content views": [
        ""
      ],
      "View documentation": [
        ""
      ],
      "View matching content": [
        ""
      ],
      "View sync status": [
        ""
      ],
      "View tasks ": [
        ""
      ],
      "View the Content Views page": [
        ""
      ],
      "View the job": [
        ""
      ],
      "Virtual": [
        "Виртуальный"
      ],
      "Virtual guests": [
        ""
      ],
      "Virtual host": [
        ""
      ],
      "WARNING: Simple Content Access will be required for all organizations in Katello 4.12.": [
        ""
      ],
      "Waiting to start.": [
        ""
      ],
      "Warning": [
        "Предупреждение"
      ],
      "When \\\"Releases/Distributions\\\" is set, \\\"Upstream URL\\\" must also be set!": [
        ""
      ],
      "When \\\"Upstream URL\\\" is set, \\\"Releases/Distributions\\\" must also be set!": [
        ""
      ],
      "When registering a host via subscription-manager, force use the specified fact (in the form of 'fact.fact')": [
        ""
      ],
      "When set to 'True' repository types that are creatable will be returned": [
        "Если «True», список будет ограничиваться только теми типами, которые доступны для создания новых репозиториев"
      ],
      "When unregistering a host via subscription-manager, also delete the host record. Managed resources linked to host such as virtual machines and DNS records may also be deleted.": [
        ""
      ],
      "Whether or not the host collection may have unlimited hosts": [
        "Позволяет снять ограничение на количество узлов в коллекции"
      ],
      "Whether or not to auto sync the Smart Proxies after a content view promotion.": [
        ""
      ],
      "Whether or not to check the status of backend services such as pulp and candlepin prior to performing some actions.": [
        "Проверять состояние базовых служб (pulp, candlepin и т.п.), прежде чем выполнить некоторые действия."
      ],
      "Whether or not to regenerate the repository on disk. Default: true": [
        ""
      ],
      "Whether or not to return filters applied to the content view version": [
        ""
      ],
      "Whether or not to show all results": [
        "Показывать все результаты"
      ],
      "Whether or not to sync an external capsule after upload. Default: true": [
        ""
      ],
      "Whether to include available content attribute in results": [
        "Включить/отключить атрибут доступного содержимого в результаты"
      ],
      "Workers": [
        "Обработчики"
      ],
      "Wrong content type submitted.": [
        ""
      ],
      "Yay empty state": [
        ""
      ],
      "Yes": [
        "Да"
      ],
      "You are not allowed to promote to Environments %s": [
        "Недостаточно разрешений для переноса в окружения %s"
      ],
      "You are not allowed to publish Content View %s": [
        "Недостаточно разрешений для публикации представления %s"
      ],
      "You can check sync status for repositories only in the library lifecycle environment.'": [
        "Статус синхронизации можно проверить только в окружении Library."
      ],
      "You cannot have more than %{max_hosts} host(s) associated with host collection '%{host_collection}'.": [
        "С коллекцией «%{host_collection}» может быть связано не больше %{max_hosts} узла(ов)."
      ],
      "You cannot set an organization's parent. This feature is disabled.": [
        "Вы не можете выбрать родителя организации. Эта функциональность отключена."
      ],
      "You cannot set an organization's parent_id. This feature is disabled.": [
        "Вы не можете настроить parent_id для организации. Эта функциональность отключена."
      ],
      "You currently don't have any ${selectedContentType}.": [
        ""
      ],
      "You currently don't have any alternate content sources.": [
        ""
      ],
      "You currently don't have any related content views.": [
        ""
      ],
      "You currently don't have any repositories associated with this content.": [
        ""
      ],
      "You currently don't have any repositories to add to this filter.": [
        ""
      ],
      "You currently have no content views to display": [
        ""
      ],
      "You do not have permissions to delete %s": [
        "Недостаточно разрешений для удаления %s"
      ],
      "You have not set a default organization on the user %s.": [
        "Вы не выбрали исходную организацию для пользователя %s."
      ],
      "You have subscriptions expiring within %s days": [
        ""
      ],
      "You have unsaved changes. Do you want to exit without saving your changes?": [
        ""
      ],
      "You were not allowed to add %s": [
        "Недостаточно разрешений для добавления %s"
      ],
      "You were not allowed to change sync plan for %s": [
        "Недостаточно разрешений для изменения плана синхронизации %s"
      ],
      "You were not allowed to delete %s": [
        "Недостаточно разрешений для удаления %s"
      ],
      "You were not allowed to sync %s": [
        "Недостаточно разрешений для синхронизации %s"
      ],
      "You're making changes to %(entitlementCount)s entitlement(s)": [
        ""
      ],
      "Your manifest expired on {expirationDate}. To continue using Red Hat content, import a new manifest.": [
        ""
      ],
      "Your manifest will expire in {daysMessage}. To extend the expiration date, refresh your manifest. Or, if your Foreman is disconnected, import a new manifest.": [
        ""
      ],
      "Your search query was invalid. Please revise it and try again. The full error has been sent to the application logs.": [
        ""
      ],
      "Your search returned no matching ": [
        ""
      ],
      "Your search returned no matching ${name}.": [
        ""
      ],
      "Your search returned no matching DEBs.": [
        ""
      ],
      "Your search returned no matching Module streams.": [
        ""
      ],
      "Your search returned no matching activation keys.": [
        ""
      ],
      "Your search returned no matching hosts.": [
        ""
      ],
      "Your search returned no matching non-modular RPMs.": [
        ""
      ],
      "Yum": [
        ""
      ],
      "a content unit": [
        ""
      ],
      "a custom CDN URL": [
        ""
      ],
      "a deb package": [
        ""
      ],
      "a docker manifest": [
        "манифест Docker"
      ],
      "a docker manifest list": [
        ""
      ],
      "a docker tag": [
        "тег Docker"
      ],
      "a file": [
        ""
      ],
      "a module stream": [
        ""
      ],
      "a package": [
        "пакет"
      ],
      "a package group": [
        "группа пакетов"
      ],
      "actions not found": [
        ""
      ],
      "activation key identifier": [
        "идентификатор ключа активации"
      ],
      "activation key name to filter by": [
        "фильтр по имени ключа активации"
      ],
      "activation keys": [
        "ключи активации"
      ],
      "add all module streams without errata to the included/excluded list. (module stream filter only)": [
        ""
      ],
      "add all packages without errata to the included/excluded list. (package filter only)": [
        "добавить все пакеты в список включенных/исключенных пакетов  за исключением исправлений (только для фильтра пакетов)"
      ],
      "all environments": [
        ""
      ],
      "all packages": [
        "все пакеты"
      ],
      "all packages update": [
        "обновление всех пакетов"
      ],
      "all packages update failed": [
        "не удалось обновить все пакеты"
      ],
      "allow unauthenticed pull of container images": [
        ""
      ],
      "already belongs to the content view": [
        ""
      ],
      "already taken": [
        "уже используется"
      ],
      "an ansible collection": [
        ""
      ],
      "an erratum": [
        "исправление"
      ],
      "an organization": [
        "организация"
      ],
      "are only allowed for Yum repositories.": [
        ""
      ],
      "attempted to sync a non-library repository.": [
        ""
      ],
      "attempted to sync without a feed URL": [
        "попытка синхронизации без указания URL-адреса источника"
      ],
      "auto attach subscriptions upon registration": [
        "автоматический выбор подписок при регистрации"
      ],
      "base url to perform repo discovery on": [
        "базовый адрес для поиска репозиториев"
      ],
      "bug fix": [
        ""
      ],
      "bug fixes": [
        ""
      ],
      "bulk add filter rules": [
        ""
      ],
      "bulk delete filter rules": [
        ""
      ],
      "can the activation key have unlimited hosts": [
        "снимает ограничение на число узлов, накладываемое ключом активации"
      ],
      "can't be blank": [
        "не может быть пустым"
      ],
      "cannot add filter to generated content views": [
        ""
      ],
      "cannot add filter to import-only view": [
        ""
      ],
      "cannot be a binary file.": [
        "не может быть двоичным файлом."
      ],
      "cannot be blank": [
        "не может быть пустым"
      ],
      "cannot be blank when Repository URL is provided.": [
        ""
      ],
      "cannot be changed.": [
        "не может меняться."
      ],
      "cannot be deleted if it has been promoted.": [
        "не может удаляться при продвижении"
      ],
      "cannot be less than one": [
        "не может быть меньше 1"
      ],
      "cannot be lower than current usage count (%s)": [
        "не может быть меньше текущего использования (%s)"
      ],
      "cannot be nil": [
        "не может быть пустым"
      ],
      "cannot be set because unlimited hosts is set": [
        "не настраивается, если не установлено ограничение на число узлов"
      ],
      "cannot be set for non-yum repositories.": [
        "может настраиваться только для репозиториев yum."
      ],
      "cannot contain characters other than ascii alpha numerals, '_', '-'. ": [
        "может содержать символы ASCII, цифры, пробелы, '_' и '-'. "
      ],
      "cannot contain commas": [
        ""
      ],
      "cannot contain filters if composite view": [
        "не может содержать фильтры сложного представления"
      ],
      "cannot contain filters whose repositories do not belong to this content view": [
        "не может содержать фильтры, если их репозитории не входят в это представление"
      ],
      "cannot contain more than %s characters": [
        "не может содержать больше %s знаков"
      ],
      "change the host's content source.": [
        ""
      ],
      "checking %s task status": [
        ""
      ],
      "checking Pulp task status": [
        "проверка состояния задачи Pulp"
      ],
      "click here": [
        ""
      ],
      "composite content view identifier": [
        ""
      ],
      "composite content view numeric identifier": [
        ""
      ],
      "content release version": [
        "версия содержимого"
      ],
      "content type ('deb', 'docker_manifest', 'file', 'ostree_ref', 'rpm', 'srpm')": [
        ""
      ],
      "content view component ID. Identifier of the component association": [
        ""
      ],
      "content view filter identifier": [
        "идентификатор фильтра представления"
      ],
      "content view filter rule identifier": [
        ""
      ],
      "content view id": [
        "ID представления"
      ],
      "content view identifier": [
        "идентификатор представления"
      ],
      "content view identifier of the component who's latest version is desired": [
        ""
      ],
      "content view node publish": [
        "публикация узла представления"
      ],
      "content view numeric identifier": [
        "числовой идентификатор представления"
      ],
      "content view publish": [
        "публикация представления"
      ],
      "content view refresh": [
        "обновление представления"
      ],
      "content view to reassign orphaned activation keys to": [
        "представление, с которым будут связаны потерянные ключи активации"
      ],
      "content view to reassign orphaned systems to": [
        "представление, с которым будут связаны потерянные системы"
      ],
      "content view version identifier": [
        "идентификатор версии представления"
      ],
      "content view version identifiers to be deleted": [
        "идентификаторы версий представлений для удаления"
      ],
      "content view versions to compare": [
        "версии представлений для сравнения"
      ],
      "create a custom product": [
        ""
      ],
      "create a filter for a content view": [
        "создать фильтр представления"
      ],
      "day": [
        ""
      ],
      "days": [
        ""
      ],
      "deb, package, package group, or docker tag names": [
        ""
      ],
      "deb_ids is not an array": [
        ""
      ],
      "deb_names_for_job_template: Action must be one of %s": [
        ""
      ],
      "delete a filter": [
        "удалить фильтр"
      ],
      "delete the content view with all the versions and environments": [
        ""
      ],
      "description": [
        "описание"
      ],
      "description of the environment": [
        "описание окружения"
      ],
      "description of the filter": [
        "описание фильтра"
      ],
      "description of the repository": [
        ""
      ],
      "disk": [
        ""
      ],
      "download policy for yum, deb, and docker repos (either 'immediate' or 'on_demand')": [
        ""
      ],
      "enables or disables synchronization": [
        "управляет синхронизацией"
      ],
      "enhancement": [
        ""
      ],
      "enhancements": [
        ""
      ],
      "environment": [
        "окружение"
      ],
      "environment id": [
        "ID окружения"
      ],
      "environment identifier": [
        "идентификатор окружения"
      ],
      "environment numeric identifier": [
        "числовой идентификатор окружения"
      ],
      "environment numeric identifiers to be removed": [
        "числовые идентификаторы окружений для удаления"
      ],
      "environment to reassign orphaned activation keys to": [
        "окружение, в которое будут добавлены потерянные ключи активации"
      ],
      "environment to reassign orphaned systems to": [
        "окружение, в которое будут добавлены потерянные системы"
      ],
      "environments": [
        "окружения"
      ],
      "errata_id of the content view filter rule": [
        ""
      ],
      "errata_ids is a required parameter": [
        ""
      ],
      "erratum: IDs or a select all object": [
        ""
      ],
      "erratum: end date (YYYY-MM-DD)": [
        ""
      ],
      "erratum: id": [
        ""
      ],
      "erratum: search using the 'Issued On' or 'Updated On' column of the errata. Values are 'issued'/'updated'": [
        ""
      ],
      "erratum: start date (YYYY-MM-DD)": [
        ""
      ],
      "erratum: types (enhancement, bugfix, security)": [
        ""
      ],
      "filter by interval": [
        "фильтр по интервалу"
      ],
      "filter by name": [
        "фильтр по имени"
      ],
      "filter by sync date": [
        "фильтр по дате синхронизации"
      ],
      "filter content view filters by name": [
        "выбор фильтра по имени"
      ],
      "filter identifier": [
        "идентификатор фильтра"
      ],
      "filter identifiers": [
        ""
      ],
      "filter only environments containing this label": [
        ""
      ],
      "filter only environments containing this name": [
        "выбрать окружения с заданным именем"
      ],
      "for repository '%{name}' is not unique and cannot be created in '%{env}'. Its Container Repository Name (%{container_name}) conflicts with an existing repository.  Consider changing the Lifecycle Environment's Registry Name Pattern to something more specific.": [
        ""
      ],
      "force content view promotion and bypass lifecycle environment restriction": [
        "принудительное продвижение в обход ограничений окружения"
      ],
      "foreman-tasks service not running or is not ready yet": [
        "сервис foreman-tasks не готов или не работает"
      ],
      "has already been taken": [
        "уже используется"
      ],
      "has already been taken for a product in this organization.": [
        "уже используется продуктом в этой организации."
      ],
      "has already been taken for this product.": [
        "уже используется для этого продукта."
      ],
      "here": [
        ""
      ],
      "host collection name to filter by": [
        "фильтр по имени коллекции"
      ],
      "hosts": [
        "узлу(ам)"
      ],
      "how often synchronization should run": [
        "частота синхронизации"
      ],
      "id of a host": [
        "Идентификатор узла"
      ],
      "id of host": [
        ""
      ],
      "id of the gpg key that will be assigned to the new repository": [
        "идентификатор ключа GPG для нового репозитория"
      ],
      "identifier of the version of the component content view": [
        ""
      ],
      "ids to filter content by": [
        "отфильтровать по идентификатору"
      ],
      "if true, Katello will verify the upstream url's SSL certifcates are signed by a trusted CA": [
        ""
      ],
      "initiating %s task": [
        ""
      ],
      "initiating Pulp task": [
        "инициализация задачи Pulp"
      ],
      "installing errata...": [
        "установка исправлений..."
      ],
      "installing erratum...": [
        "установка исправления..."
      ],
      "installing or updating packages": [
        ""
      ],
      "installing package group...": [
        "установка группы пакетов..."
      ],
      "installing package groups...": [
        "установка групп пакетов..."
      ],
      "installing package...": [
        "установка пакета..."
      ],
      "installing packages...": [
        "установка пакетов..."
      ],
      "interpret specified object to return only Repositories that can be associated with specified object.  Only 'content_view' & 'content_view_version' are supported.": [
        ""
      ],
      "invalid container image name": [
        ""
      ],
      "invalid: Repositories can only require one OS version.": [
        ""
      ],
      "invalid: The content source must sync the lifecycle environment assigned to the host. See the logs for more information.": [
        ""
      ],
      "is already attached to the capsule": [
        "уже связан с капсулой"
      ],
      "is invalid": [
        "неверно."
      ],
      "is not a valid type. Must be one of the following: %s": [
        ""
      ],
      "is not allowed for ACS. Must be one of the following: %s": [
        ""
      ],
      "is not enabled. must be one of the following: %s": [
        ""
      ],
      "is only allowed for Yum repositories.": [
        ""
      ],
      "label of the environment": [
        "метка окружения"
      ],
      "label of the repository": [
        ""
      ],
      "limit to only repositories with this download policy": [
        ""
      ],
      "list filters": [
        "возвращает список фильтров"
      ],
      "list of repository ids": [
        "список идентификаторов репозиториев"
      ],
      "list of rpm filename strings to include in published version": [
        ""
      ],
      "max_hosts must be given a value if this host collection is not unlimited.": [
        "если эта коллекция не является неограниченной, необходимо настроить число max_hosts"
      ],
      "maximum number of registered content hosts": [
        "максимальное число зарегистрированных узлов содержимого"
      ],
      "may not be less than the number of hosts associated with the host collection.": [
        "не может быть меньше числа узлов, ассоциированных с коллекцией."
      ],
      "module stream ids": [
        ""
      ],
      "module streams not found": [
        ""
      ],
      "must be %{gpg_key} or %{cert}": [
        ""
      ],
      "must be a positive integer value.": [
        "должно быть положительным целым числом."
      ],
      "must be one of the following: %s": [
        ""
      ],
      "must be one of: %s": [
        ""
      ],
      "must be true or false": [
        ""
      ],
      "must be unique within one organization": [
        "должно быть уникальным в пределах организации."
      ],
      "must contain '%s'": [
        "должно содержать «%s»"
      ],
      "must contain GPG Key": [
        "должен содержать ключ GPG"
      ],
      "must contain at least %s character": [
        "должно содержать как минимум %s знаков"
      ],
      "must contain valid  Public GPG Key": [
        "должен содержать действительный открытый ключ GPG"
      ],
      "must contain valid Public GPG Key": [
        "должен содержать действительный открытый ключ GPG"
      ],
      "must not be a negative value.": [
        ""
      ],
      "must not contain leading or trailing white spaces.": [
        "не может начинаться и заканчиваться пробелом."
      ],
      "name": [
        "имя"
      ],
      "name of organization": [
        "имя организации"
      ],
      "name of the content view filter rule": [
        ""
      ],
      "name of the environment": [
        "имя окружения"
      ],
      "name of the filter": [
        "имя фильтра"
      ],
      "name of the organization": [
        "имя организации"
      ],
      "name of the repository": [
        "имя репозитория"
      ],
      "name of the subscription": [
        ""
      ],
      "name: %s doesn't exist ": [
        ""
      ],
      "new name for the filter": [
        "новое имя фильтра"
      ],
      "new name to be given to the environment": [
        "новое имя окружения"
      ],
      "no": [
        "нет"
      ],
      "no global default": [
        ""
      ],
      "obtain manifest history for subscriptions": [
        "получить события манифеста подписок"
      ],
      "of environment must be unique within one organization": [
        "должно быть уникальным в пределах организации"
      ],
      "only show the repositories readable by this user with this username": [
        ""
      ],
      "organization ID": [
        "Код организации"
      ],
      "organization identifier": [
        "идентификатор организации"
      ],
      "package group: uuid": [
        ""
      ],
      "package, package group, or docker tag names": [
        ""
      ],
      "package, package group, or docker tag: name": [
        ""
      ],
      "package: architecture": [
        ""
      ],
      "package: maximum version": [
        ""
      ],
      "package: minimum version": [
        ""
      ],
      "package: version": [
        ""
      ],
      "package_ids is not an array": [
        "package_ids не содержит массив"
      ],
      "package_names_for_job_template: Action must be one of %s": [
        ""
      ],
      "params 'show_all_for' and 'available_for' must be used independently": [
        ""
      ],
      "pattern for container image names": [
        ""
      ],
      "perform an incremental import": [
        "разрешить инкрементный импорт"
      ],
      "policies for HTTP proxy for content sync": [
        ""
      ],
      "policy for HTTP proxy for content sync": [
        ""
      ],
      "prior environment can only have one child": [
        ""
      ],
      "product numeric identifier": [
        "числовой идентификатор продукта"
      ],
      "register_hostname_fact set for %s, but no fact found, or was localhost.": [
        ""
      ],
      "removing package group...": [
        "удаление группы пакетов..."
      ],
      "removing package groups...": [
        "удаление групп пакетов..."
      ],
      "removing package...": [
        "удаление пакета..."
      ],
      "removing packages...": [
        "удаление пакетов..."
      ],
      "repo label": [
        ""
      ],
      "repository ID": [
        "Идентификатор репозитория"
      ],
      "repository id": [
        "ID репозитория"
      ],
      "repository identifier": [
        "идентификатор репозитория"
      ],
      "repository source url": [
        "URL источника репозитория"
      ],
      "root-node of collection contained in responses (default: 'results')": [
        ""
      ],
      "root-node of single-resource responses (optional)": [
        "корневой элемент ответа с единственным ресурсом (дополнительно)"
      ],
      "rule identifier": [
        "идентификатор правила"
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
        "уровень обслуживания"
      ],
      "set true if you want to see only library environments": [
        "присвойте «True», чтобы показать только окружения Library"
      ],
      "sha256": [
        ""
      ],
      "show archived repositories": [
        ""
      ],
      "show filter info": [
        "показать информацию о фильтре"
      ],
      "show repositories in Library and the default content view": [
        "показать репозитории в Library и в выбранном по умолчанию представлении"
      ],
      "some executors are not responding, check %{status_url}": [
        "некоторые исполнители не отвечают; проверьте %{status_url}"
      ],
      "specifies if content should be included or excluded, default: inclusion=false": [
        ""
      ],
      "start datetime of synchronization": [
        "дата и время синхронизации"
      ],
      "subscriptions not specified": [
        "подписки не определены"
      ],
      "sync plan description": [
        "описание плана синхронизации"
      ],
      "sync plan name": [
        "имя плана синхронизации"
      ],
      "sync plan numeric identifier": [
        "числовой идентификатор плана синхронизации"
      ],
      "system registration": [
        ""
      ],
      "the following attributes can not be updated for the Red Hat provider: [ %s ]": [
        ""
      ],
      "the host": [
        ""
      ],
      "the hosts": [
        ""
      ],
      "to": [
        ""
      ],
      "true if the latest version of the component's content view is desired": [
        ""
      ],
      "true if the latest version of the components content view is desired": [
        ""
      ],
      "true if this repository can be published via HTTP": [
        "«true», если репозиторий может быть доступен по HTTP"
      ],
      "type of filter (e.g. deb, rpm, package_group, erratum, erratum_id, erratum_date, docker, modulemd)": [
        ""
      ],
      "types of filters": [
        ""
      ],
      "unknown permission for %s": [
        "неизвестное разрешение для %s"
      ],
      "unlimited": [
        ""
      ],
      "update a filter": [
        "изменить фильтр"
      ],
      "updating package group...": [
        "обновление группы пакетов..."
      ],
      "updating package groups...": [
        "обновление групп пакетов..."
      ],
      "updating package...": [
        "обновление пакета..."
      ],
      "updating packages...": [
        "обновление пакетов..."
      ],
      "upstream Foreman server": [
        ""
      ],
      "url not defined.": [
        "URL не задан."
      ],
      "via customized remote execution": [
        ""
      ],
      "via remote execution": [
        "удаленное выполнение"
      ],
      "view content view tabs.": [
        ""
      ],
      "waiting for %s to finish the task": [
        ""
      ],
      "waiting for Pulp to finish the task %s": [
        ""
      ],
      "waiting for Pulp to start the task %s": [
        ""
      ],
      "whitespace-separated list of architectures to be synced from deb-archive": [
        ""
      ],
      "whitespace-separated list of releases to be synced from deb-archive": [
        ""
      ],
      "whitespace-separated list of repo components to be synced from deb-archive": [
        ""
      ],
      "with": [
        "на"
      ],
      "yes": [
        "да"
      ],
      "{0} items selected": [
        ""
      ],
      "{enableRedHatRepos} or {createACustomProduct}.": [
        ""
      ],
      "{numberOfActivationKeys} activation key will be assigned to content view {cvName} in": [
        ""
      ],
      "{numberOfActivationKeys} activation keys will be assigned to content view {cvName} in": [
        ""
      ],
      "{numberOfHosts} host will be assigned to content view {cvName} in": [
        ""
      ],
      "{numberOfHosts} hosts will be assigned to content view {cvName} in": [
        ""
      ],
      "{versionOrVersions} {versionList} will be deleted and will no longer be available for promotion.": [
        ""
      ],
      "{versionOrVersions} {versionList} will be removed from the following environments:": [
        ""
      ],
      "{versionOrVersions} {versionList} will be removed from the listed environment and will no longer be available for promotion.": [
        ""
      ],
      "{versionOrVersions} {versionList} will be removed from the listed environments and will no longer be available for promotion.": [
        ""
      ],
      "{versionOrVersions} {versionList} will be removed from the {envLabel} environment.": [
        ""
      ]
    }
  }
};
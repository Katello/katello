 locales['katello'] = locales['katello'] || {}; locales['katello']['ja'] = {
  "domain": "katello",
  "locale_data": {
    "katello": {
      "": {
        "Project-Id-Version": "katello 2.4.0-RC1",
        "Report-Msgid-Bugs-To": "",
        "PO-Revision-Date": "2017-12-19 20:14+0000",
        "Last-Translator": "Amit Upadhye <aupadhye@redhat.com>, 2023",
        "Language-Team": "Japanese (https://www.transifex.com/foreman/teams/114/ja/)",
        "MIME-Version": "1.0",
        "Content-Type": "text/plain; charset=UTF-8",
        "Content-Transfer-Encoding": "8bit",
        "Language": "ja",
        "Plural-Forms": "nplurals=1; plural=0;",
        "lang": "ja",
        "domain": "katello",
        "plural_forms": "nplurals=1; plural=0;"
      },
      "\\n* Product = '%{product}', Repository = '%{repository}'": [
        "\\n* 製品 = '%%{product}'、リポジトリー = '%%{repository}'"
      ],
      " %{errata_count} Errata": [
        "エラータ %{errata_count} 件"
      ],
      " %{modulemd_count} Module Stream(s)": [
        "モジュールストリーム %{modulemd_count} 個"
      ],
      " %{package_count} Package(s)": [
        "パッケージ %{package_count} 個"
      ],
      " (${item.published_at_words} ago)": [
        ""
      ],
      " (${version.published_at_words} ago)": [
        ""
      ],
      " Content view updated": [
        " コンテンツビューが更新されました"
      ],
      " DEBs": [
        " DEBs"
      ],
      " Either select the latest content view or the content view version. Cannot set both.": [
        " 最新のコンテンツビューまたはコンテンツビューバージョンを選択します。両方設定することはできません。"
      ],
      " RPMs": [
        " RPM"
      ],
      " The base path can be a web address or a filesystem location.": [
        " ベースパスには Web アドレスまたはファイルシステムの場所を指定できます。"
      ],
      " The base path must be a web address pointing to the root RHUI content directory.": [
        " ベースパスは、ルート RHUI コンテンツディレクトリーを参照する Web アドレスである必要があります。"
      ],
      " View task details ": [
        " タスクの詳細を表示する "
      ],
      " ago": [
        " 前"
      ],
      " ago.": [
        "前。"
      ],
      " and": [
        " および"
      ],
      " are out of the environment path order. The recommended practice is to promote to the next environment in the path.": [
        " 環境パスの順序から外れています。推奨される方法は、パス内の次の環境にプロモートすることです。"
      ],
      " content view is used in listed composite content views.": [
        " コンテンツビューは、一覧表示された複合コンテンツビューで使用されます。"
      ],
      " content view is used in listed content views. For more information, ": [
        " コンテンツビューは、一覧表示されたコンテンツビューで使用されます。詳細は、 "
      ],
      " environment cannot be set to an environment already on its path": [
        " 環境はそのパスにある環境に設定できません"
      ],
      " found.": [
        "見つかりませんでした。"
      ],
      " is out of the environment path order. The recommended practice is to promote to the next environment in the path.": [
        " 環境パスの順序から外れています。推奨される方法は、パス内の次の環境にプロモートすることです。"
      ],
      " or any step on the left.": [
        " または、左側の任意のステップ。"
      ],
      " to manage and promote content views, or select a different environment.": [
        " コンテンツビューを管理およびプロモートするか、別の環境を選択します。"
      ],
      "${deleteFlow ? 'Deleting' : 'Removing'} version ${versionNameToRemove}": [
        "${deleteFlow ? 'Deleting' : 'Removing'} バージョン ${versionNameToRemove}"
      ],
      "${option}": [
        "${option}"
      ],
      "${pluralize(akResponse.length, 'activation key')} will be moved to content view ${selectedCVNameForAK} in ": [
        "${pluralize(akResponse.length, 'activation key')} はコンテンツビュー ${selectedCVNameForAK} に移動されます。"
      ],
      "${pluralize(hostResponse.length, 'host')} will be moved to content view ${selectedCVNameForHosts} in ": [
        "${pluralize(hostResponse.length, 'host')} はコンテンツビュー ${selectedCVNameForHosts} に移動されます。"
      ],
      "${pluralize(versionCount, 'content view version')} in the environments below will be removed when content view is deleted": [
        "コンテンツビューが削除されると、以下の環境の {pluralize(versionCount, 'content view version')}(versionCount, 'content view version')} は削除されます"
      ],
      "${selectedContentType}": [
        "{selectedContentType}"
      ],
      "${selectedContentType} will appear here when created.": [
        "{selectedContentType} が作成されると、ここに表示されます。"
      ],
      "%s %s has %s Hosts and %s Hostgroups that will need to be reassociated post deletion. Delete %s?": [
        "%s%s には、削除後にもう一度関連付けする必要があるホスト %s 台とホストグループ %s 個があります。%s を削除しますか？"
      ],
      "%s Available": [
        "利用可能 %s 件"
      ],
      "%s Errata": [
        "エラータ %s 件"
      ],
      "%s Host": [
        "ホスト %s 台"
      ],
      "%s Used": [
        "使用済み %s 件"
      ],
      "%s ago": [
        "%s 前"
      ],
      "%s content type is not enabled.": [
        ""
      ],
      "%s guests": [
        "%s ゲスト"
      ],
      "%s has already been deleted": [
        "%s は削除済みです"
      ],
      "%s is not a valid package name": [
        "%s は有効なパッケージ名ではありません"
      ],
      "%s is not a valid path": [
        "%s は有効なパスではありません"
      ],
      "%s is required": [
        "%s は必須です"
      ],
      "%s is unreachable. %s": [
        "%s に到達できません。%s"
      ],
      "%s was not found!": [
        ""
      ],
      "%{errata} (%{total} other errata)": [
        "%{errata} (他のエラータ: %{total})"
      ],
      "%{errata} (%{total} other errata) install canceled": [
        "%{errata} (他のエラータ: %{total}) のインストールが取り消されました"
      ],
      "%{errata} (%{total} other errata) install failed": [
        "%{errata} (他のエラータ: %{total}) のインストールに失敗しました"
      ],
      "%{errata} (%{total} other errata) install timed out": [
        "%{errata} (他のエラータ: %{total}) のインストールがタイムアウトになりました"
      ],
      "%{errata} (%{total} other errata) installed": [
        "%{errata} (他のエラータ: %{total}) がインストールされました"
      ],
      "%{errata} erratum install canceled": [
        "%{errata} エラータのインストールが取り消されました"
      ],
      "%{errata} erratum install failed": [
        "%{errata} エラータのインストールに失敗しました"
      ],
      "%{errata} erratum install timed out": [
        "%{errata} エラータのインストールがタイムアウトになりました"
      ],
      "%{errata} erratum installed": [
        "%{errata} エラータがインストールされました"
      ],
      "%{expiring_subs} subscriptions in %{subject} are going to expire in less than %{days} days. Please renew them before they expire to guarantee your hosts will continue receiving content.": [
        "%{subject} の %{expiring_subs} は、%{days} 日未満に有効期限が切れます。ホストがコンテンツを引き続き受信できるように、期限が切れる前に更新してください。"
      ],
      "%{group} (%{total} other package groups)": [
        "%{group} (他のパッケージ: %{total})"
      ],
      "%{group} (%{total} other package groups) install canceled": [
        "%{group} (他のパッケージ: %{total}) のインストールが取り消されました"
      ],
      "%{group} (%{total} other package groups) install failed": [
        "%{group} (他のパッケージ: %{total}) のインストールに失敗しました"
      ],
      "%{group} (%{total} other package groups) install timed out": [
        "%{group} (他のパッケージ: %{total}) のインストールがタイムアウトになりました"
      ],
      "%{group} (%{total} other package groups) installed": [
        "%{group} (他のパッケージ: %{total}) がインストールされました"
      ],
      "%{group} (%{total} other package groups) remove canceled": [
        "%{group} (他のパッケージ: %{total}) の削除が取り消されました"
      ],
      "%{group} (%{total} other package groups) remove failed": [
        "%{group} (他のパッケージ: %{total}) の削除に失敗しました"
      ],
      "%{group} (%{total} other package groups) remove timed out": [
        "%{group} (他のパッケージ: %{total}) の削除がタイムアウトになりました"
      ],
      "%{group} (%{total} other package groups) removed": [
        "%{group} (他のパッケージ: %{total}) が削除されました"
      ],
      "%{group} (%{total} other package groups) update canceled": [
        "%{group} (他のパッケージ: %{total}) の更新が取り消されました"
      ],
      "%{group} (%{total} other package groups) update failed": [
        "%{group} (他のパッケージ: %{total}) の更新に失敗しました"
      ],
      "%{group} (%{total} other package groups) update timed out": [
        "%{group} (他のパッケージ: %{total}) の更新がタイムアウトになりました"
      ],
      "%{group} (%{total} other package groups) updated": [
        "%{group} (他のパッケージ: %{total}) が更新されました"
      ],
      "%{group} package group install canceled": [
        "%{group} パッケージグループのインストールが取り消されました"
      ],
      "%{group} package group install failed": [
        "%{group} パッケージグループのインストールに失敗しました"
      ],
      "%{group} package group install timed out": [
        "%{group} パッケージグループのインストールがタイムアウトになりました"
      ],
      "%{group} package group installed": [
        "%{group} パッケージグループがインストールされました"
      ],
      "%{group} package group remove canceled": [
        "%{group} パッケージグループの削除が取り消されました"
      ],
      "%{group} package group remove failed": [
        "%{group} パッケージグループの削除が失敗しました"
      ],
      "%{group} package group remove timed out": [
        "%{group} パッケージグループの削除がタイムアウトになりました"
      ],
      "%{group} package group removed": [
        "%{group} パッケージグループの削除"
      ],
      "%{group} package group update canceled": [
        "%{group} パッケージグループの更新が取り消されました"
      ],
      "%{group} package group update failed": [
        "%{group} パッケージグループの更新に失敗しました"
      ],
      "%{group} package group update timed out": [
        "%{group} パッケージグループの更新がタイムアウトになりました"
      ],
      "%{group} package group updated": [
        "%{group} パッケージグループが更新されました"
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
        "%{package} (他のパッケージ: %{total})"
      ],
      "%{package} (%{total} other packages) install canceled": [
        "%{package} (他のパッケージ: %{total}) のインストールが取り消されました"
      ],
      "%{package} (%{total} other packages) install failed": [
        "%{package} (他のパッケージ: %{total}) のインストールに失敗しました"
      ],
      "%{package} (%{total} other packages) install timed out": [
        "%{package} (他のパッケージ: %{total}) のインストールがタイムアウトになりました"
      ],
      "%{package} (%{total} other packages) installed": [
        "%{package} (他のパッケージ: %{total}) がインストールされました"
      ],
      "%{package} (%{total} other packages) remove canceled": [
        "%{package} (他のパッケージ: %{total}) の削除が取り消されました"
      ],
      "%{package} (%{total} other packages) remove failed": [
        "%{package} (他のパッケージ: %{total}) の削除に失敗しました"
      ],
      "%{package} (%{total} other packages) remove timed out": [
        "%{package} (他のパッケージ: %{total}) の削除がタイムアウトになりました"
      ],
      "%{package} (%{total} other packages) removed": [
        "%{package} (他のパッケージ: %{total}) が削除されました"
      ],
      "%{package} (%{total} other packages) update canceled": [
        "%{package} (他のパッケージ: %{total}) の更新が取り消されました"
      ],
      "%{package} (%{total} other packages) update failed": [
        "%{package} (他のパッケージ: %{total}) の更新に失敗しました"
      ],
      "%{package} (%{total} other packages) update timed out": [
        "%{package} (他のパッケージ: %{total}) の更新がタイムアウトになりました"
      ],
      "%{package} (%{total} other packages) updated": [
        "%{package} (他のパッケージ: %{total}) が更新されました"
      ],
      "%{package} package install canceled": [
        "%{package} パッケージのインストールが取り消されました"
      ],
      "%{package} package install timed out": [
        "%{package} パッケージのインストールがタイムアウトになりました"
      ],
      "%{package} package remove canceled": [
        "%{package} パッケージの削除が取り消されました"
      ],
      "%{package} package remove failed": [
        "%{package} パッケージの削除が失敗しました"
      ],
      "%{package} package remove timed out": [
        "%{package} パッケージの削除がタイムアウトになりました"
      ],
      "%{package} package removed": [
        "%{package} パッケージが削除されました"
      ],
      "%{package} package update canceled": [
        "%{package} パッケージの更新が取り消されました"
      ],
      "%{package} package update failed": [
        "%{package} パッケージの更新に失敗しました"
      ],
      "%{package} package update timed out": [
        "%{package} パッケージの更新がタイムアウトになりました"
      ],
      "%{package} package updated": [
        "%{package} パッケージが更新されました。"
      ],
      "%{release}: %{number_of_hosts} hosts are approaching end of %{lifecycle} on %{end_date}. Please upgrade them before support expires. Check Report Host - Statuses for detail.": [
        ""
      ],
      "%{sla}": [
        "%{sla}"
      ],
      "%{subject}'s disk is %{percentage} full. Since this proxy is running Pulp, it needs disk space to publish content views. Please ensure the disk does not get full.": [
        "%{subject} のディスクは %{percentage} % 使用済みです。このプロキシーでは Pulp を実行しているので、コンテンツの表示にディスクの領域が必要です。ディスクがいっぱいにならないようにしてください。"
      ],
      "%{unused_substitutions} cannot be specified for %{content_name} as that information is not substitutable in %{content_url} ": [
        "%{unused_substitutions} は、%{content_url} と置き換えることができないので、 %{content_name} に指定できません。"
      ],
      "%{used} of %{total}": [
        "%{used} / %{total}"
      ],
      "%{value} can contain only lowercase letters, numbers, dashes and dots.": [
        ""
      ],
      "%{view_label} could not be promoted to %{environment_label} because the content view and the environment are not in the same organization!": [
        "コンテンツビューと環境が同じ組織内にないため、%{view_label} を %{environment_label} にプロモートできませんでした!"
      ],
      "'%{item}' does not exist in the backend system [ Candlepin ].  Either remove and re-enable the repository or try refreshing the manifest before synchronizing. ": [
        "'%{item}' はバックエンドシステム [Candlepin] に存在しません。リポジトリーを削除して再度有効にするか、同期する前にマニフェストの更新を試行します。 "
      ],
      "'%{item}' does not exist in the backend system [ Candlepin ].  Either remove the invalid repository or try refreshing the manifest before promoting. ": [
        "'%{item}' はバックエンドシステム [Candlepin] に存在しません。プロモートする前に、無効なリポジトリーを削除するか、マニフェストの更新を試行します。"
      ],
      "'%{item}' does not exist in the backend system [ Candlepin ].  Remove and recreate the repository before synchronizing. ": [
        "'%{item}' はバックエンドシステム [Candlepin ] に存在しません。同期する前にリポジトリーを削除し、再作成します。 "
      ],
      "'%{item}' does not exist in the backend system [ Candlepin ].  Remove the invalid repository before promoting. ": [
        "'%{item}' はバックエンドシステム [Candlepin ] に存在しません。プロモートする前に無効なリポジトリーを削除します。"
      ],
      "'%{item}' in this content view does not exist in the backend system [ Candlepin ].  Either remove the invalid repository or try refreshing the manifest before publishing again. ": [
        "このコンテンツビューの '%{item}' はバックエンドシステム [Candlepin ] に存在しません。無効なリポジトリーを削除するか、マニフェストを更新してから再度公開してください。 "
      ],
      "'%{item}' in this content view does not exist in the backend system [ Candlepin ].  Remove the invalid repository before publishing again. ": [
        "このコンテンツビューの '%{item}' はバックエンドシステム [Candlepin ] に存在しません。再度公開する前に無効なリポジトリーを削除します。 "
      ],
      "(Orphaned)": [
        "(単独)"
      ],
      "(unset)": [
        "(未設定)"
      ],
      ", and": [
        "、および"
      ],
      ", must be unique to major and version id version.": [
        "、メジャーバージョン ID と バージョン ID で一意である必要があります。"
      ],
      ": '%s' is a built-in environment": [
        ": '%s' はビルドインの環境です"
      ],
      ":a_resource identifier": [
        ":a_resource ID"
      ],
      "<b>PROMOTION</b> SUMMARY": [
        "<b>プロモート</b> 概要"
      ],
      "<b>SYNC</b> SUMMARY": [
        "<b>同期</b> の概要"
      ],
      "A CV version already exists with the same major and minor version (%{major}.%{minor})": [
        "同じメジャーおよびマイナーバージョンの CV バージョンが存在します (%{major}.%{minor})"
      ],
      "A Pool and its Subscription cannot belong to different organizations.": [
        ""
      ],
      "A backend service [ %s ] is unreachable": [
        "バックエンドサービス [ %s ] に到達できません"
      ],
      "A comma-separated list of refs to include during an ostree sync. The wildcards *, ? are recognized.": [
        ""
      ],
      "A comma-separated list of tags to exclude during an ostree sync. The wildcards *, ? are recognized. 'exclude_refs' is evaluated after 'include_refs'.": [
        ""
      ],
      "A large number of errata are unapplied in this content view, so only the first 100 are shown.": [
        "多数のエラータがこのコンテンツビューに適用されていません。そのため、最初の 100 件のみが表示されています。"
      ],
      "A large number of errata were synced for this repository, so only the first 100 are shown.": [
        "このリポジトリーでは、多数のエラータが同期されたため、最初の 100 件のみを表示しています。"
      ],
      "A list of subscriptions expiring soon": [
        "まもなく期限切れになるサブスクリプションの一覧"
      ],
      "A new version of ": [
        "新しいバージョン:"
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
        "ホストとインストール可能なエラータのプロモート後の概要"
      ],
      "A remote execution job is in progress": [
        "リモート実行ジョブが進行中です"
      ],
      "A remote execution job is in progress.": [
        "リモート実行ジョブが進行中です。"
      ],
      "A service level for auto-healing process, e.g. SELF-SUPPORT": [
        "自動修復プロセスのサービスレベル。例: SELF-SUPPORT"
      ],
      "A smart proxy seems to have been refreshed without pulpcore being running. Please refresh the smart proxy after ensuring that pulpcore services are running.": [
        "Smart Proxy は、pulpcore を実行せずに更新されたようです。Pulpcore サービスが実行されていることを確認してから、Smart Proxy を更新してください。"
      ],
      "A summary of available and applicable errata for your hosts": [
        "ホストに利用可能かつ適用可能なエラータの概要"
      ],
      "A summary of new errata after a repository is synchronized": [
        "リポジトリーが同期された後の新規エラータの概要"
      ],
      "ANY": [
        "任意"
      ],
      "About page": [
        "About ページ"
      ],
      "Access to Red Hat Subscription Management is prohibited. If you would like to change this, please update the content setting 'Subscription connection enabled'.": [
        "Red Hat Subcription Management へのアクセスは禁止されています。これを変更する場合は、コンテンツ設定の「サブスクリプション接続の有効化」を更新してください。"
      ],
      "Account Number": [
        "アカウント番号"
      ],
      "Action": [
        "アクション"
      ],
      "Action not allowed for the default smart proxy.": [
        "デフォルトの Smart Proxy で許可されないアクションです。"
      ],
      "Action unauthorized to be performed in this organization.": [
        "この組織で実行権限がないアクション"
      ],
      "Activation Key information": [
        ""
      ],
      "Activation Key will no longer be available for use. This operation cannot be undone.": [
        ""
      ],
      "Activation Keys": [
        "アクティベーションキー"
      ],
      "Activation key": [
        "アクティベーションキー"
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
        "アクティベーションキー ID"
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
        "CentOS および Red Hat Enterprise Linux に必要な subscription-manager クライアントのアクティベーションキー。複数のキーの場合は、代わりに `activation_keys` パラメーターを使用してください。"
      ],
      "Activation key identifier": [
        ""
      ],
      "Activation key(s) to use during registration": [
        ""
      ],
      "Activation keys": [
        "アクティベーションキー"
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
        "アクティベーションキー:"
      ],
      "Active only": [
        "実行中のみ"
      ],
      "Add": [
        "追加"
      ],
      "Add Bookmark": [
        "ブックマークの追加"
      ],
      "Add DEB rule": [
        "DEB ルールの追加"
      ],
      "Add RPM rule": [
        "RPM ルールの追加"
      ],
      "Add Subscriptions": [
        "サブスクリプションの追加"
      ],
      "Add a subscription to a host": [
        "ホストにサブスクリプションを追加します"
      ],
      "Add an alternate content source": [
        "代替コンテンツソースの追加"
      ],
      "Add components to the content view": [
        "コンテンツビューにコンポーネントを追加する"
      ],
      "Add content": [
        ""
      ],
      "Add content view": [
        "コンテンツビューの追加"
      ],
      "Add content views": [
        "コンテンツビューの追加"
      ],
      "Add custom cron logic for sync plan": [
        "同期プランのカスタム cron ロジックを追加します"
      ],
      "Add errata": [
        "エラータの追加"
      ],
      "Add filter rule": [
        "フィルタールールの追加"
      ],
      "Add host to collections": [
        "コレクションにホストを追加"
      ],
      "Add host to host collections": [
        "ホストコレクションにホストを追加"
      ],
      "Add host to the host collection": [
        "ホストコレクションにホストを追加する"
      ],
      "Add lifecycle environments to the smart proxy": [
        "Smart Proxy にライフサイクル環境を追加します"
      ],
      "Add new bookmark": [
        "新しいブックマークの追加"
      ],
      "Add one or more host collections to one or more hosts": [
        "1 つ以上のホストに 1 つ以上のホストコレクションを追加します"
      ],
      "Add products to sync plan": [
        "製品の同期プランへの追加"
      ],
      "Add repositories": [
        "リポジトリーの追加"
      ],
      "Add repositories with package groups to content view to select them here.": [
        ""
      ],
      "Add rule": [
        "ルールの追加"
      ],
      "Add source": [
        "ソースの追加"
      ],
      "Add subscriptions": [
        ""
      ],
      "Add subscriptions consumed by a manifest from Red Hat Subscription Management": [
        "Red Hat Subscription Management からマニフェストが使用するサブスクリプションを追加します"
      ],
      "Add subscriptions to one or more hosts": [
        "1 つ以上のホストにサブスクリプションを追加します"
      ],
      "Add subscriptions using the Add Subscriptions button.": [
        ""
      ],
      "Add to a host collection": [
        "ホストコレクションへの追加"
      ],
      "Added": [
        "追加されました"
      ],
      "Added %s": [
        "%s を追加しました"
      ],
      "Added Content:": [
        "追加されたコンテンツ:"
      ],
      "Added component to content view": [
        "コンテンツビューにコンポーネントを追加しました"
      ],
      "Additional content": [
        "追加のコンテンツ"
      ],
      "Affected Repositories": [
        "影響のあるリポジトリー"
      ],
      "Affected hosts": [
        ""
      ],
      "Affected repositories": [
        "影響を受けるリポジトリー"
      ],
      "After configuring Foreman, configuration must also be updated on {hosts}. Choose one of the following options to update {hosts}:": [
        ""
      ],
      "After generating the incremental update, apply the changes to the specified hosts.  Only Errata are supported currently.": [
        "指定のホストへの変更は、増分更新の生成後に適用します。現在、エラータのみがサポートされています。"
      ],
      "All": [
        "すべて"
      ],
      "All Media": [
        "すべてのメディア"
      ],
      "All Repositories": [
        "全リポジトリー"
      ],
      "All available architectures for this repo are enabled.": [
        "このリポジトリーで利用可能なすべてのアーキテクチャーが有効です。"
      ],
      "All errata applied": [
        "適用されたすべてのエラータ"
      ],
      "All errata up-to-date": [
        "すべてのエラータは最新の状態です"
      ],
      "All subpaths must have a slash at the end and none at the front": [
        "すべてのサブパスには、必ず末尾にスラッシュが必要で、先頭には不要です"
      ],
      "All up to date": [
        "すべて最新です"
      ],
      "All versions": [
        "全バージョン"
      ],
      "All versions will be removed from these environments": [
        "すべてのバージョンがこれらの環境から削除されます"
      ],
      "Allow deleting repositories in published content views": [
        "公開済みコンテンツビューでのリポジトリー削除を許可"
      ],
      "Allow host registrations to bypass 'Host Profile Assume' as long as the host is in build mode.": [
        "ホストがビルドモードである限り、ホスト登録が「ホストプロファイルの想定」をバイパスすることを許可します。"
      ],
      "Allow hosts or activation keys to be associated with multiple content view environments": [
        ""
      ],
      "Allow hosts to re-register themselves only when they are in build mode": [
        "ホストがビルドモードである場合にのみ、ホスト自体の再登録を許可します"
      ],
      "Allow multiple content views": [
        ""
      ],
      "Allow new host registrations to assume registered profiles with matching hostname as long as the registering DMI UUID is not used by another host.": [
        "登録する DMI UUID が別のホストで使用されていない限り、新規ホストの登録時には、登録されているプロファイルはホスト名が一致すると想定できるようにする"
      ],
      "Also include the latest upgradable package version for each host package": [
        "各ホストパッケージの最新のアップグレード可能なパッケージバージョンも含めます"
      ],
      "Alter a host's host collections": [
        "ホストのホストコレクションを変更"
      ],
      "Alternate Content Source HTTP Proxy": [
        "代替コンテンツソースの HTTP プロキシー"
      ],
      "Alternate Content Sources": [
        "代替コンテンツソース"
      ],
      "Alternate content source ${name} created": [
        "代替コンテンツソース ${name} が作成されました"
      ],
      "Alternate content source ID": [
        "代替コンテンツソース ID"
      ],
      "Alternate content source deleted": [
        "代替コンテンツソースが削除されました。"
      ],
      "Alternate content source edited": [
        "代替コンテンツソースが編集されました"
      ],
      "Alternate content sources define new locations to download content from at repository or smart proxy sync time.": [
        "別のコンテンツソースは、リポジトリーまたは Smart Proxy を同期する時にコンテンツをダウンロードする新しい場所を定義します。"
      ],
      "Alternate content sources use the HTTP proxy of their assigned smart proxy for communication.": [
        "代替コンテンツソースは、通信用に割り当てられたSmart Proxy の HTTP プロキシーを使用します。"
      ],
      "Always Use Latest (currently %{version})": [
        "常に最新のバージョンを使用する (現在は %{version})"
      ],
      "Always update to latest version": [
        "常に最新バージョンに更新"
      ],
      "Amount of workers in the pool to handle the execution of host-related tasks. When set to 0, the default queue will be used instead. Restart of the dynflowd/foreman-tasks service is required.": [
        "ホスト関連のタスクの実行を処理するプール内のワーカー数。0 に設定されている場合には、デフォルトのキューが代わりに使用されます。dynflowd/foreman-tasks サービスは再起動する必要があります。"
      ],
      "An alternate content source can be added by using the \\\\\\\"Add source\\\\\\\" button below.": [
        ""
      ],
      "An environment is missing a prior": [
        "環境には以前の内容がありません"
      ],
      "An error occurred during the sync \\n%{error_message}": [
        "同期中にエラーが発生しました \\n%{error_message}"
      ],
      "An error occurred during upload \\n%{error_message}": [
        "アップロード中にエラーが発生しました \\n%{error_message}"
      ],
      "An option to specify how many ostree commits to traverse.": [
        ""
      ],
      "Another component already includes content view with ID %s": [
        "別のコンポーネントに ID %s のコンテンツがすでに含まれています"
      ],
      "Ansible Collection": [
        "Ansible コレクション"
      ],
      "Ansible Collections": [
        "Ansible コレクション"
      ],
      "Ansible collection": [
        "Ansible コレクション"
      ],
      "Ansible collections": [
        "Ansible コレクション"
      ],
      "Applicability Batch Size": [
        "適用可能なバッチサイズ"
      ],
      "Applicable": [
        "適用可能"
      ],
      "Applicable Content Hosts": [
        "適用可能なコンテンツホスト"
      ],
      "Applicable bugfix/enhancement errata": [
        ""
      ],
      "Applicable errata apply to at least one package installed on the host.": [
        "適用可能なエラータは、ホストにインストールされている 1 つ以上のパッケージに適用されます。"
      ],
      "Applicable security errata": [
        ""
      ],
      "Application": [
        "アプリケーション"
      ],
      "Apply": [
        "適用"
      ],
      "Apply errata": [
        ""
      ],
      "Apply erratum": [
        ""
      ],
      "Apply to all repositories in the CV": [
        "CV のすべてのリポジトリーへの適用"
      ],
      "Apply to subset of repositories": [
        "リポジトリーのサブセットへの適用"
      ],
      "Apply via customized remote execution": [
        "カスタマイズされたリモート実行による適用"
      ],
      "Apply via remote execution": [
        "リモート実行による適用"
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
        "アーキテクチャー"
      ],
      "Architecture": [
        "アーキテクチャー"
      ],
      "Architecture of content in the repository": [
        "リポジトリー内のコンテンツのアーキテクチャー"
      ],
      "Architecture restricted to {archRestricted}. If host architecture does not match, the repository will not be available on this host.": [
        "アーキテクチャーが {archRestricted} に制限されています。ホストのアーキテクチャーが一致しない場合、リポジトリーはこのホストでは利用できません。"
      ],
      "Architecture(s)": [
        "アーキテクチャー"
      ],
      "Are you sure you want to delete %(entitlementCount)s subscription(s)? This action will remove the subscription(s) and refresh your manifest. All systems using these subscription(s) will lose them and also may lose access to updates and Errata.": [
        "%(entitlementCount)s 件のサブスクリプションを削除してもよろしいですか? この操作により、サブスクリプションが削除され、マニフェストが更新されます。これらのサブスクリプションを使用するすべてのシステムはサブスクリプションを失い、アップデートやエラータへのアクセスも失われる可能性があります。"
      ],
      "Are you sure you want to delete the manifest?": [
        "マニフェストを削除してもよろしいですか?"
      ],
      "Array of Content override parameters": [
        "コンテンツ上書きパラメーターの配列"
      ],
      "Array of Content override parameters to be added in bulk": [
        "一括で追加されるコンテンツ上書きパラメーターの配列"
      ],
      "Array of Pools to be updated. Only pools originating upstream are accepted.": [
        "更新するプールの配列。アップストリームからのプールのみを受け入れます。"
      ],
      "Array of Trace IDs": [
        "トレース ID の配列"
      ],
      "Array of components to add": [
        "追加するコンポーネントの配列"
      ],
      "Array of content view component IDs to remove. Identifier of the component association": [
        "削除するコンテンツビューコンポーネント ID の配列。コンポーネントの関連付けの ID"
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
        "ホスト ID の配列"
      ],
      "Array of local pool IDs. Only pools originating upstream are accepted.": [
        "ローカルプール ID の配列。アップストリームからのプールのみを受け入れます。"
      ],
      "Array of pools to add": [
        "追加するプールの配列"
      ],
      "Array of subscriptions to add": [
        "追加するサブスクリプションの配列"
      ],
      "Array of subscriptions to remove": [
        "削除するサブスクリプションの配列"
      ],
      "Array of uploads to import": [
        "インポートするアップロードの配列"
      ],
      "Artifact Id and relative path are needed to create content": [
        "コンテンツの作成には、アーティファクト ID と相対パスが必要です"
      ],
      "Artifacts": [
        "アーティファクト"
      ],
      "Assign system purpose attributes on one or more hosts": [
        "1 台以上のホストにシステム目的の属性を割り当てる"
      ],
      "Assign the %{count} host with no %{taxonomy_single} to %{taxonomy_name}": [
        "%{taxonomy_single} のないホスト %{count} 台に %{taxonomy_name} を割り当てる"
      ],
      "Assign the environment and content view to one or more hosts": [
        "1 台以上のホストに環境およびコンテンツビューを割り当てます"
      ],
      "Assign the release version to one or more hosts": [
        "1 台以上のホストにリリースバージョンを割り当てます"
      ],
      "Assigning a host to multiple content view environments is not enabled. To enable, set the allow_multiple_content_views setting.": [
        ""
      ],
      "Assigning an activation key to multiple content view environments is not enabled. To enable, set the allow_multiple_content_views setting.": [
        ""
      ],
      "Associated location IDs": [
        "関連するロケーション ID"
      ],
      "Associated version": [
        "関連付けられたバージョン"
      ],
      "Associations": [
        "関連付け"
      ],
      "At least one Content View Version must be specified": [
        "1 つ以上のコンテンツビューバージョンを指定する必要があります"
      ],
      "At least one activation key must be provided": [
        "1 つ以上のアクティベーションキーが必要です"
      ],
      "At least one activation key must have a lifecycle environment and content view assigned to it": [
        "1 つ以上のアクティベーションキーには、ライフサイクル環境の設定が必要であり、コンテンツビューをこれに割り当てる必要があります"
      ],
      "At least one errata type option needs to be selected.": [
        ""
      ],
      "At least one of the selected items requires the host to reboot": [
        ""
      ],
      "At least one organization must exist.": [
        "1 つ以上の組織が存在している必要があります。"
      ],
      "Attach a subscription": [
        "サブスクリプションを割り当てる"
      ],
      "Attach subscriptions": [
        "サブスクリプションの割り当て"
      ],
      "Attach subscriptions to %s": [
        "%s へのサブスクリプションの割り当て"
      ],
      "Attempted to destroy consumer %s from candlepin, but consumer does not exist in candlepin": [
        "Candlepin からコンシューマー %s を破棄しようとしましたが、コンシューマーが candlepin に存在しません"
      ],
      "Auth URL requires Auth token be set.": [
        "認証 URL には認証トークンを設定する必要があります。"
      ],
      "Authentication type": [
        "認証タイプ"
      ],
      "Author": [
        "作成者"
      ],
      "Auto Publish - Triggered by '%s'": [
        "自動公開 - '%s' によるトリガー"
      ],
      "Auto publish": [
        "自動公開"
      ],
      "Autopublish": [
        "自動公開"
      ],
      "Available": [
        "利用可能"
      ],
      "Available Entitlements": [
        "利用可能なエンタイトルメント"
      ],
      "Available Repositories": [
        "利用可能なリポジトリー"
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
        "戻る"
      ],
      "Backend System Status": [
        "バックエンドシステムのステータス"
      ],
      "Base URL": [
        "ベース URL"
      ],
      "Base URL for finding alternate content": [
        "代替コンテンツを検索するためのベース URL"
      ],
      "Base URL of the flatpak registry index, ex: https://flatpaks.redhat.io/rhel/ , https://registry.fedoraproject.org/.": [
        ""
      ],
      "Base URL to perform repo discovery on": [
        "リポジトリー検出を実行するベース URL"
      ],
      "Basearch to disable": [
        "無効にする Basearch"
      ],
      "Basearch to enable": [
        "有効にする Basearch"
      ],
      "Basic authentication password": [
        "Basic 認証パスワード"
      ],
      "Basic authentication username": [
        "Basic 認証ユーザー名"
      ],
      "Batch size to sync repositories in.": [
        "リポジトリーを同期するバッチサイズ。"
      ],
      "Before continuing, ensure that all of the following prerequisites are met:": [
        ""
      ],
      "Before removing versions you must move activation keys to an environment where the associated version is not in use.": [
        "バージョンを削除する前に、関連付けられたバージョンが使用されていない環境にアクティベーションキーを移動する必要があります。"
      ],
      "Before removing versions you must move hosts to an environment where the associated version is not in use. ": [
        "バージョンを削除する前に、関連付けられたバージョンが使用されていない環境にホストを移動する必要があります。 "
      ],
      "Below are the repository sets currently available for this content host. For Red Hat subscriptions, additional content can be made available through the {rhrp}. Changing default settings requires subscription-manager 1.10 or newer to be installed on this host.": [
        "以下は、このコンテンツホストで現在利用可能なリポジトリーセットです。Red Hat サブスクリプションの場合は、{rhrp} により追加のコンテンツを利用できる可能性があります。デフォルト設定を変更するには、subscription-manager 1.10 またはそれ以降をこのホストにインストールする必要があります。"
      ],
      "Beta": [
        "ベータ"
      ],
      "Bind an entitlement to an allocation": [
        "割り当てにエンタイトルメントをバインドします"
      ],
      "Bind entitlements to an allocation": [
        "割り当てにエンタイトルメントをバインドします"
      ],
      "Bookmark this search": [
        "この検索をブックマーク"
      ],
      "Bookmarks marked as public are available to all users": [
        "パブリックと識別されたブックマークは、すべてのユーザーが利用できます"
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
        "両方"
      ],
      "Both major and minor parameters have to be used to override a CV version": [
        "CV バージョンを上書きするには、メジャーパラメーターとマイナーパラメーターの両方を使用する必要があります"
      ],
      "Bug Fix": [
        "バグ修正"
      ],
      "Bugfix": [
        "バグ修正"
      ],
      "Bugs": [
        "バグ"
      ],
      "Bulk alternate content source delete has started.": [
        "代替コンテンツソースの一括削除が開始されました。"
      ],
      "Bulk alternate content source refresh has started.": [
        "代替コンテンツソースの一括更新が開始されました。"
      ],
      "Bulk generate applicability for host %s": [
        "ホスト %s に適用可能なエラータを一括生成します"
      ],
      "Bulk generate applicability for hosts": [
        "ホストに適用可能なエラータを一括生成します"
      ],
      "Bulk remove versions from a content view and reassign systems and keys": [
        "コンテンツビューからバージョンを一括削除し、システムおよびキーを再度割り当てます"
      ],
      "CDN Configuration": [
        "CDN 設定"
      ],
      "CDN Configuration for Red Hat Content": [
        "Red Hat コンテンツの CDN 設定"
      ],
      "CDN Configuration updated.": [
        "CDN 設定が更新されました。"
      ],
      "CDN configuration is set to Export Sync (disconnected). Repository enablement/disablement is not permitted on this page.": [
        "CDN 設定は エクスポートの同期の (切断) に設定されます。このページでは、リポジトリーの有効化/無効化は許可されていません。"
      ],
      "CDN configuration type. One of %s.": [
        "CDN 設定タイプ。%s のいずれか。"
      ],
      "CDN loading error: %s not found": [
        "CDN の読み込みエラー: %s が見つかりません"
      ],
      "CDN loading error: access denied to %s": [
        "CDN の読み込みエラー: %s へのアクセスが拒否されました"
      ],
      "CDN loading error: access forbidden to %s": [
        "CDN の読み込みエラー: %s へのアクセスは禁止されています"
      ],
      "CVE identifier": [
        "CVE ID"
      ],
      "CVEs": [
        "CVE"
      ],
      "Calculate Applicable Errata based on a particular Content View": [
        "特定のコンテンツビューに基づく適用可能なエラータの計算"
      ],
      "Calculate Applicable Errata based on a particular Environment": [
        "特定の環境に基づく適用可能なエラータの計算"
      ],
      "Calculate content counts on smart proxies automatically": [
        ""
      ],
      "Can communicate with the Red Hat Portal for subscriptions.": [
        "サブスクリプションでは、Red Hat ポータルと通信できます。"
      ],
      "Can only remove content from within the Default Content View": [
        "デフォルトコンテンツビューからコンテンツのみを削除できます"
      ],
      "Can't update the '%s' environment": [
        "'%s' 環境を更新できません"
      ],
      "Cancel": [
        "取り消し"
      ],
      "Cancel repository discovery": [
        "リポジトリー検出の取り消し"
      ],
      "Cancel running smart proxy synchronization": [
        "Smart Proxy の同期実行をキャンセルします"
      ],
      "Canceled": [
        "取り消されました"
      ],
      "Cancelled.": [
        "取り消し済み。"
      ],
      "Candlepin": [
        "Candlepin"
      ],
      "Candlepin Event": [
        "Candlepin イベント"
      ],
      "Candlepin ID of pool to add": [
        "追加するプールの Candlepin ID"
      ],
      "Candlepin consumer %s has already been removed": [
        "Candlepin コンシューマー %s はすでに削除されています"
      ],
      "Candlepin is not running properly": [
        "Candlepin が正しく実行されていません"
      ],
      "Candlepin returned different consumer uuid than requested (%s), updating uuid in subscription_facet.": [
        ""
      ],
      "Cannot add %s repositories to a content view.": [
        "コンテンツビューに %s リポジトリーを追加できません。"
      ],
      "Cannot add a repository from an Organization other than %s.": [
        "%s 以外に組織からリポジトリーを追加できません。"
      ],
      "Cannot add component versions to a non-composite content view": [
        "コンポーネントのバージョンを複合コンテンツビュー以外に追加できません"
      ],
      "Cannot add composite versions to a composite content view": [
        "複合バージョンを複合コンテンツビューに追加できません"
      ],
      "Cannot add composite versions to another composite content view": [
        "複合バージョンを別の複合コンテンツビューに追加できません"
      ],
      "Cannot add content view environments from a different organization": [
        ""
      ],
      "Cannot add default content view to composite content view": [
        "デフォルトのコンテンツビューを複合コンテンツビューに追加できません"
      ],
      "Cannot add disabled Red Hat product %s to sync plan!": [
        ""
      ],
      "Cannot add disabled products to sync plan!": [
        ""
      ],
      "Cannot add generated content view versions to composite content view": [
        "生成されたコンテンツビューを複合コンテンツビューに追加できません"
      ],
      "Cannot add product %s because it is disabled.": [
        ""
      ],
      "Cannot add repositories to a composite content view": [
        "リポジトリーを複合コンテンツビューに追加できません"
      ],
      "Cannot associate a Red Hat provider with a custom product": [
        ""
      ],
      "Cannot associate a component to a non composite content view": [
        "コンポーネントを複合コンテンツビュー以外に関連付けできません"
      ],
      "Cannot be disabled because it is part of a published content view": [
        ""
      ],
      "Cannot calculate name for custom repos": [
        "カスタムリポジトリーの名前を計算できません"
      ],
      "Cannot clone into the Default Content View": [
        "デフォルトのコンテンツビューにクローンを作成できません"
      ],
      "Cannot delete '%{view}' due to associated %{dependent}: %{names}.": [
        "%{dependent}: %{names} が関連付けられているので、 '%{view}' を削除できません。"
      ],
      "Cannot delete Red Hat product: %{product}": [
        "Red Hat 製品: %{product} を削除できません"
      ],
      "Cannot delete from %s, view does not exist there.": [
        "%s から削除できません。ビューが存在しません。"
      ],
      "Cannot delete product with repositories published in a content view.  Product: %{product}, %{view_versions}": [
        "コンテンツビューに公開リポジトリーが含まれている場合には、製品を削除できません。製品: %{product}、{view_versions}"
      ],
      "Cannot delete product: %{product} with repositories that are the last affected repository in content view filters. Delete these repositories before deleting product.": [
        ""
      ],
      "Cannot delete provider with attached products": [
        "製品が割り当てられたプロバイダーを削除できません"
      ],
      "Cannot delete redhat product content": [
        "Red Hat 製品コンテンツを削除できません"
      ],
      "Cannot delete the default Location for subscribed hosts. If you no longer want this Location, change the default Location for subscribed hosts under Administer > Settings, tab Content.": [
        "サブスクライブ済みホストのデフォルトのロケーションを削除できません。このロケーションが必要なくなった場合には、管理 > 設定のコンテンツタブにあるサブスクライブ済みホストのデフォルトのロケーションを変更してください。"
      ],
      "Cannot delete the last Location.": [
        "最終ロケーションを削除できません"
      ],
      "Cannot delete version while it is in environment %s": [
        "%s 環境にこのバージョンが存在するため、削除できません"
      ],
      "Cannot delete version while it is in environments: %s": [
        "環境内にバージョンが含まれる場合には削除できません: %s"
      ],
      "Cannot delete version while it is in use by composite content views: %s": [
        "複合コンテンツビューでバージョンが使用されているため、削除できません: %s"
      ],
      "Cannot delete view while it exists in environments": [
        "ビューは環境に存在するため、削除することができません"
      ],
      "Cannot import a composite content view": [
        "複合コンテンツビューをインポートできません"
      ],
      "Cannot import a custom subscription from a redhat product.": [
        "Red hat 製品からカスタムサブスクリプションをインポートできません。"
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
        "複合コンテンツビューバージョン (%{name} バージョン、バージョン %{version}) で増分更新を実行できません"
      ],
      "Cannot perform an incremental update on a Generated Content View Version (%{name} version version %{version}": [
        "生成コンテンツビューバージョン (%{name} バージョン、バージョン %{version}) で増分更新を実行できません"
      ],
      "Cannot promote environment out of sequence. Use force to bypass restriction.": [
        "順序の正しくない環境をプロモートできません。強制プロモートを使用して制限を無視してください。"
      ],
      "Cannot publish a composite with rpm filenames": [
        "rpm ファイル名の複合を公開できません"
      ],
      "Cannot publish a link repository if multiple component clones are specified": [
        "複数のコンポーネントのクローンが指定されている場合には、リンクリポジトリーを公開できません"
      ],
      "Cannot publish default content view": [
        "デフォルトのコンテンツビューを公開できません"
      ],
      "Cannot register a system to the '%s' environment": [
        "'%s' 環境にシステムを登録できません"
      ],
      "Cannot remove '%{view}' from environment '%{env}' due to associated %{dependent}: %{names}.": [
        "%{dependent}: %{names} が関連付けられているので、環境「%{env}」から「%{view}」を削除できません"
      ],
      "Cannot remove content from a non-custom repository": [
        "カスタムリポジトリーではないリポジトリーからコンテンツを削除できません"
      ],
      "Cannot remove content view from environment. Content view '%{view}' is not in lifecycle environment '%{env}'.": [
        "環境からコンテンツビューを削除できません。ライフサイクル環境 '%{env}' にはコンテンツビュー '%{view}' がありません。"
      ],
      "Cannot remove package(s): No installed packages found for search term '%s'.": [
        ""
      ],
      "Cannot set attribute %{attr} for content type %{type}": [
        "コンテンツタイプ %{type} に属性 %{attr} を設定できません"
      ],
      "Cannot set auto publish to a non-composite content view": [
        "複合コンテンツビュー以外には自動公開を設定できません"
      ],
      "Cannot skip metadata check on non-yum/deb repositories.": [
        ""
      ],
      "Cannot specify components for non-composite views": [
        "複合ビュー以外のコンポーネントを指定できません"
      ],
      "Cannot specify content for composite views": [
        "複合ビューのコンテンツを指定できません"
      ],
      "Cannot sync file:// repositories with the On Demand Download Policy": [
        "file:// リポジトリーをオンデマンドダウンロードポリシーと同期できません"
      ],
      "Cannot update properties of a container push repository": [
        ""
      ],
      "Cannot upgrade packages: No installed packages found for search term '%s'.": [
        ""
      ],
      "Cannot upload Ansible collections.": [
        "Ansible コレクションをアップロードできません。"
      ],
      "Cannot upload Container Image content.": [
        "コンテナーイメージのコンテンツをアップロードできません。"
      ],
      "Cannot upload container content via Hammer/API. Use podman push instead.": [
        ""
      ],
      "Capacity": [
        "容量"
      ],
      "Change Content Source": [
        "コンテンツソースの変更"
      ],
      "Change content source": [
        "コンテンツソースの変更"
      ],
      "Change content view environments": [
        ""
      ],
      "Change host content source": [
        "ホストコンテンツソースの変更"
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
        "Red Hat Subscription Management に接続できるかどうかを確認します。"
      ],
      "Check services before actions": [
        "アクションの前にサービスを確認します"
      ],
      "Checksum": [
        "チェックサム"
      ],
      "Checksum is a required parameter.": [
        "checksum は必須パラメーターです。"
      ],
      "Checksum of file to upload": [
        "アップロードするファイルのチェックサム"
      ],
      "Checksum type cannot be set for yum repositories with on demand download policy.": [
        "オンデマンドのダウンロードポリシーが指定された Yum リポジトリーにはチェックサムタイプを設定できません。"
      ],
      "Checksum used for published repository contents. Supported types: %s": [
        ""
      ],
      "Choose content credentials if required for this RHUI source.": [
        "この RHUI ソースに必要な場合は、コンテンツの認証情報を選択します。"
      ],
      "Clear any previous registration and run subscription-manager with --force.": [
        "以前の登録をすべてクリアし、--force を指定して subscription-manager を実行します。"
      ],
      "Clear filters": [
        "フィルターをクリア"
      ],
      "Clear search": [
        "検索のクリア"
      ],
      "Click here to go to the tasks page for the task.": [
        "タスクのタスクページに移動するには、ここをクリックしてください。"
      ],
      "Click to see repositories available to add.": [
        ""
      ],
      "Click {update} below to save changes.": [
        "{update} をクリックして変更を保存します。"
      ],
      "Clone": [
        "クローン"
      ],
      "Close": [
        "閉じる"
      ],
      "Collapse All": [
        "すべて折りたたむ"
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
        "コンマ区切りのサブパスの一覧。すべてのサブパスには、必ず末尾にスラッシュが必要で、先頭には不要です"
      ],
      "Comma-separated list of tags to exclude when syncing a container image repository. Default: any tag ending in \\\"-source\\\"": [
        "コンテナーイメージリポジトリーの同期時に除外するタグのコンマ区切りリスト。デフォルト: \\\"-source\\\" で終わるタグ"
      ],
      "Comma-separated list of tags to sync for a container image repository": [
        "コンテナーイメージリポジトリーに同期するコンマ区切りのタグ一覧"
      ],
      "Compare": [
        "比較"
      ],
      "Completed pulp task protection days": [
        ""
      ],
      "Component": [
        "コンポーネント"
      ],
      "Component Content View": [
        "コンポーネントコンテンツビュー"
      ],
      "Component Version: '%{cvv}', Product: '%{product}', Repository: '%{repo}' ": [
        "コンポーネントのバージョン: '%{cvv}'、製品: '%{product}'、リポジトリー: '%{repo}' "
      ],
      "Components": [
        "コンポーネント"
      ],
      "Composite": [
        "複合"
      ],
      "Composite Content View": [
        "複合コンテンツビュー"
      ],
      "Composite Content View '%{subject}' failed auto-publish": [
        "複合コンテンツビュー '%{subject}' は自動公開に失敗しました"
      ],
      "Composite content view": [
        "複合コンテンツビュー"
      ],
      "Composite content views": [
        "複合コンテンツビュー"
      ],
      "Compute resource IDs": [
        "コンピュートリソース ID"
      ],
      "Configuration still must be updated on {hosts}": [
        ""
      ],
      "Configuration updated on Foreman": [
        ""
      ],
      "Confirm Deletion": [
        "削除の確定"
      ],
      "Confirm delete manifest": [
        "マニフェスト削除の確定"
      ],
      "Consider changing the Lifecycle Environment's Registry Name Pattern to something more specific.": [
        "ライフサイクル環境のレジストリー名のパターンをより具体的な名前に変更することをご検討ください。"
      ],
      "Consisting of multiple content views": [
        "複数のコンテンツビューで構成されます"
      ],
      "Consists of content views": [
        "コンテンツビューで構成"
      ],
      "Consists of repositories": [
        "リポジトリーで構成"
      ],
      "Consumed": [
        "使用済み"
      ],
      "Container Image Manifest": [
        "コンテナーイメージマニフェスト"
      ],
      "Container Image Repositories are not protected at this time. They need to be published via http to be available to containers.": [
        "コンテナーイメージリポジトリーは現時点では保護されていません。コンテナーで使用できるようにするには、http を介して公開する必要があります。"
      ],
      "Container Image Tag": [
        "コンテナーイメージタグ"
      ],
      "Container Image Tags": [
        "コンテナーイメージタグ"
      ],
      "Container Image repo '%{repo}' is present in multiple component content views.": [
        "コンテナイメージリポジトリー '%{repo}' が複数のコンポーネントコンテンツビューに存在します。"
      ],
      "Container Images": [
        "コンテナーイメージ"
      ],
      "Container image tag": [
        "コンテナーイメージタグ"
      ],
      "Container image tags": [
        "コンテナーイメージタグ"
      ],
      "Container manifest lists": [
        "コンテナーマニフェストのリスト"
      ],
      "Container manifests": [
        "コンテナーマニフェスト"
      ],
      "Container tags": [
        "コンテナータグ"
      ],
      "Content": [
        "コンテンツ"
      ],
      "Content Count": [
        "コンテンツ数"
      ],
      "Content Credential ID": [
        "コンテンツ認証情報 ID"
      ],
      "Content Credential numeric identifier": [
        "コンテンツ認証情報の数値 ID"
      ],
      "Content Credential to use for SSL CA. Relevant only for 'upstream_server' type.": [
        "SSL CA に使用するコンテンツ認証情報。'upstream_server' タイプにのみ必要です。"
      ],
      "Content Credentials": [
        "コンテンツの認証情報"
      ],
      "Content Details": [
        "コンテンツの詳細"
      ],
      "Content Download URL": [
        "コンテンツのダウンロード URL"
      ],
      "Content Facet for host with id %s is non-existent. Skipping applicability calculation.": [
        "ID が %s のホストのコンテンツファセットが存在しません。適用性の計算をスキップします。"
      ],
      "Content Hosts": [
        "コンテンツホスト"
      ],
      "Content Source": [
        "コンテンツソース"
      ],
      "Content Sync": [
        "コンテンツの同期"
      ],
      "Content Types": [
        "コンテンツタイプ"
      ],
      "Content View": [
        "コンテンツビュー"
      ],
      "Content View %{view}: Versions: %{versions}": [
        "コンテンツビュー %{view}: バージョン: %{versions}"
      ],
      "Content View Details": [
        "コンテンツビューの詳細"
      ],
      "Content View Filter id": [
        "コンテンツビューフィルター ID"
      ],
      "Content View Filter identifier. Use to filter by ID": [
        ""
      ],
      "Content View ID": [
        "コンテンツビュー ID"
      ],
      "Content View Name": [
        "コンテンツビュー名"
      ],
      "Content View Version %{id} not in all specified environments %{envs}": [
        "指定の %{envs} すべてにコンテンツビューバージョン %{id} が含まれていません"
      ],
      "Content View Version Ids to perform an incremental update on.  May contain composites as well as one or more components to update.": [
        "増分更新を実行するためのコンテンツビューバージョン ID です。更新する複合および 1 つ以上のコンポーネントが含まれる場合があります。"
      ],
      "Content View Version identifier": [
        "コンテンツビューバージョン ID"
      ],
      "Content View Version not set": [
        "コンテンツビューバージョンが設定されていません"
      ],
      "Content View Version specified in the metadata - '%{name}' already exists. If you wish to replace the existing version, delete %{name} and try again. ": [
        "メタデータに指定のコンテンツビューバージョン ('%{name}') はすでに存在します。既存のバージョンを置き換えるには、%{name} を削除してもう一度お試しください。"
      ],
      "Content View Version: '%{cvv}', Product: '%{product}', Repository: '%{repo}' ": [
        "コンテンツビューバージョン: '%{cvv}'、製品: '%{product}'、リポジトリー: '%{repo}' "
      ],
      "Content View id": [
        "コンテンツビュー ID"
      ],
      "Content View label not provided.": [
        "コンテンツビューラベルが指定されていません。"
      ],
      "Content Views": [
        "コンテンツビュー"
      ],
      "Content cannot be imported into a Composite Content View. ": [
        "コンテンツを複合コンテンツビューにインポートできません。 "
      ],
      "Content credential": [
        "コンテンツの認証情報"
      ],
      "Content credentials": [
        "コンテンツの認証情報"
      ],
      "Content facet for host %s has more than one content view. Use #content_views instead.": [
        ""
      ],
      "Content facet for host %s has more than one lifecycle environment. Use #lifecycle_environments instead.": [
        ""
      ],
      "Content files to upload. Can be a single file or array of files.": [
        "アップロードするコンテンツファイルです。単一ファイルまたはファイルの配列を指定できます。"
      ],
      "Content host must be unregistered before performing this action.": [
        "このアクションを実行する前に、コンテンツホストの登録を解除する必要があります。"
      ],
      "Content hosts": [
        "コンテンツホスト"
      ],
      "Content imported by %{user} into content view '%{name}'": [
        "%{user} によって '%{name}' にインポートされたコンテンツ"
      ],
      "Content may come from {contentSourceName} or any other Smart Proxy behind the load balancer.": [
        ""
      ],
      "Content not uploaded to pulp": [
        "コンテンツが pulp にアップロードされませんでした"
      ],
      "Content override search parameters": [
        "コンテンツオーバーライドの検索パラメーター"
      ],
      "Content source": [
        "コンテンツソース"
      ],
      "Content source ID": [
        "コンテンツソース ID"
      ],
      "Content source was not set for host '%{host}'": [
        "コンテンツソースがホスト '%{host}' に設定されていませんでした"
      ],
      "Content type": [
        "コンテンツタイプ"
      ],
      "Content type %{content_type_string} does not belong to an enabled repo type.": [
        "コンテンツタイプ %{content_type_string} は、有効なリポジトリータイプに所属していません。"
      ],
      "Content type %{content_type} is incompatible with repositories of type %{repo_type}": [
        "コンテンツタイプ %{content_type} には、タイプ %{repo_type} のリポジトリーとの互換性がありません"
      ],
      "Content type does not support repo discovery": [
        ""
      ],
      "Content view": [
        "コンテンツビュー"
      ],
      "Content view ${name} created": [
        "コンテンツビュー {name} が作成されました"
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
        "コンテンツビュー '%{view}' は環境 '%{env}' にありません"
      ],
      "Content view '%{view}' is not in lifecycle environment '%{env}'.": [
        "ライフサイクル環境 '%{env}' には、コンテンツビュー '%{view}' がありません。"
      ],
      "Content view ID": [
        "コンテンツビュー ID"
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
        "コンテンツビューには '%s' のリポジトリーラベルが含まれていますが、このラベルは repos_units パラメーターで指定されていません。"
      ],
      "Content view identifier": [
        "コンテンツビュー ID"
      ],
      "Content view label": [
        "コンテンツビューラベル"
      ],
      "Content view must be specified": [
        ""
      ],
      "Content view name": [
        "コンテンツビュー名"
      ],
      "Content view not provided in the metadata": [
        "メタデータで提供されていないコンテンツビュー"
      ],
      "Content view numeric identifier": [
        "コンテンツビューの数値 ID"
      ],
      "Content view promote failure": [
        ""
      ],
      "Content view publish failure": [
        ""
      ],
      "Content view version export history identifier": [
        "コンテンツビューバージョンのエクスポート履歴 ID"
      ],
      "Content view version identifier": [
        "コンテンツビューのバージョン ID"
      ],
      "Content view version import history identifier": [
        "コンテンツビューバージョンのインポート履歴 ID"
      ],
      "Content view version is empty": [
        ""
      ],
      "Content view version is empty or content counts are not up to date": [
        ""
      ],
      "Content views": [
        "コンテンツビュー"
      ],
      "Content will be synced from the alternate content source first, then the original source if the ACS is not reachable.": [
        "コンテンツは最初に別のコンテンツソースから同期され、ACS に到達できない場合には元のソースが同期されます。"
      ],
      "Content_Host_Status": [
        "コンテンツホストのステータス"
      ],
      "Contents of requirement yaml file to sync from URL": [
        "URL から同期する要件 yaml ファイルのコンテンツ"
      ],
      "Context": [
        "コンテキスト"
      ],
      "Contract": [
        "コントラクト"
      ],
      "Contract Number": [
        "コントラクト番号"
      ],
      "Copied to clipboard": [
        "クリップボードにコピーしました"
      ],
      "Copy": [
        "コピー"
      ],
      "Copy an activation key": [
        "アクティベーションキーをコピーします"
      ],
      "Copy content view": [
        "コンテンツビューのコピー"
      ],
      "Copy to clipboard": [
        "クリップボードへのコピー"
      ],
      "Cores per socket": [
        "1 ソケットあたりのコア数"
      ],
      "Cores: %s": [
        "コア: %s 個"
      ],
      "Could not delete organization '%s'.": [
        "組織 '%s' を削除できませんでした。"
      ],
      "Could not find %{content} with id '%{id}' in repository.": [
        "リポジトリーで ID が '%{id}' の %{content} が見つかりませんでした"
      ],
      "Could not find %{count} errata.  Only found: %{found}": [
        "%{count} 件のエラータが見つかりませんでした。検索結果: %{found}"
      ],
      "Could not find %{name} resource with id %{id}. %{perms_message}": [
        "ID が %%{id} の %%{name} リソースが見つかりませんでした。%{perms_message}"
      ],
      "Could not find %{name} resources with ids %{ids}": [
        "ID が %%{ids} の %%{name} リソースが見つかりませんでした"
      ],
      "Could not find Environment with ids: %s": [
        "以下の ID の環境が見つかりませんでした: %s"
      ],
      "Could not find Lifecycle Environment with id '%{id}'.": [
        "ID '%{id}' のライフサイクル環境が見つかりませんでした。"
      ],
      "Could not find a host with id %s": [
        "id が %s のホストが見つかりませんでした"
      ],
      "Could not find a smart proxy with pulp feature.": [
        "Pulp 機能が搭載された Smart Proxy が見つかりませんでした"
      ],
      "Could not find all specified errata ids: %s": [
        "指定した全エラータ ID を見つけることができませんでした: %s"
      ],
      "Could not find environments for promotion": [
        "プロモート環境が見つかりませんでした"
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
        "Smart Proxy からライフサイクル環境を削除できませんでした"
      ],
      "Couldn't establish a connection to %s": [
        "%s への接続を確立できませんでした"
      ],
      "Couldn't find %{content_type} with id '%{id}'": [
        "ID が %{id} の %{content_type} が見つかりませんでした"
      ],
      "Couldn't find %{type} Filter with id %{id}": [
        "ID が %{id} の %{type} フィルターが見つかりませんでした"
      ],
      "Couldn't find ContentViewFilter with id=%s": [
        "id=%s のコンテンツビューフィルターが見つかりませんでした"
      ],
      "Couldn't find Organization '%s'.": [
        "組織 '%s' が見つかりませんでした"
      ],
      "Couldn't find activation key '%s'": [
        "アクティベーションキー '%s' が見つかりませんでした"
      ],
      "Couldn't find activation key content view id '%s'": [
        "アクティベーションキーのコンテンツビュー ID「%s」が見つかりませんでした"
      ],
      "Couldn't find activation key environment '%s'": [
        "アクティベーションキーの環境 '%s' が見つかりませんでした"
      ],
      "Couldn't find consumer '%s'": [
        "コンシューマー '%s' が見つかりませんでした"
      ],
      "Couldn't find content host content view id '%s'": [
        "コンテンツホストのコンテンツビュー ID「%s」が見つかりませんでした"
      ],
      "Couldn't find content host environment '%s'": [
        "コンテンツホストの環境 '%s' が見つかりませんでした"
      ],
      "Couldn't find content view environment with content view ID '%{cv}' and environment ID '%{env}'": [
        ""
      ],
      "Couldn't find content view version '%s'": [
        "コンテンツビューのバージョン '%s' が見つかりませんでした"
      ],
      "Couldn't find content view versions '%s'": [
        "コンテンツビューのバージョン '%s' が見つかりませんでした"
      ],
      "Couldn't find content view with id: '%s'": [
        "ID が '%s' のコンテンツビューが見つかりませんでした"
      ],
      "Couldn't find environment '%s'": [
        "環境 '%s' が見つかりませんでした"
      ],
      "Couldn't find errata ids '%s'": [
        "エラータ ID「%s」が見つかりませんでした"
      ],
      "Couldn't find host collection '%s'": [
        "ホストコレクション '%s' が見つかりませんでした"
      ],
      "Couldn't find host with host id '%s'": [
        "ホスト ID 「%s」のホストが見つかりませんでした"
      ],
      "Couldn't find organization '%s'": [
        "組織「%s」が見つかりませんでした"
      ],
      "Couldn't find prior-environment '%s'": [
        "以前の環境 '%s' が見つかりませんでした"
      ],
      "Couldn't find product with id '%s'": [
        "ID「%s」の製品が見つかりませんでした"
      ],
      "Couldn't find products with id '%s'": [
        "ID が '%s' の製品が見つかりませんでした"
      ],
      "Couldn't find repository '%s'": [
        "リポジトリー '%s' が見つかりませんでした"
      ],
      "Couldn't find smart proxies with id '%s'": [
        "id '%s' の Smart Proxy は見つかりませんでした"
      ],
      "Couldn't find smart proxies with name '%s'": [
        "名前が '%s' の Smart Proxy は見つかりませんでした"
      ],
      "Couldn't find specified content view and lifecycle environment.": [
        ""
      ],
      "Couldn't find subject of synchronization": [
        "同期の件名が見つかりませんでした"
      ],
      "Create": [
        "作成"
      ],
      "Create ACS": [
        "ACS の作成"
      ],
      "Create Alternate Content Source": [
        "代替コンテンツソースの作成"
      ],
      "Create Container Push Repository Root": [
        ""
      ],
      "Create Export History": [
        "エクスポート履歴の作成"
      ],
      "Create Import History": [
        "インポート履歴の作成"
      ],
      "Create Repositories": [
        "リポジトリーの作成"
      ],
      "Create Syncable Export History": [
        "同期可能なエクスポート履歴の作成"
      ],
      "Create a Content Credential": [
        "コンテンツ認証情報の作成"
      ],
      "Create a content view": [
        "コンテンツビューの作成"
      ],
      "Create a custom product": [
        "カスタム製品の作成"
      ],
      "Create a custom repository": [
        "カスタムリポジトリーの作成"
      ],
      "Create a filter rule. The parameters included should be based upon the filter type.": [
        "フィルタールールの作成。組み込まれるパラメーターはフィルタータイプに基づいている必要があります。"
      ],
      "Create a flatpak remote": [
        ""
      ],
      "Create a host collection": [
        "ホストコレクションの作成"
      ],
      "Create a product": [
        "製品の作成"
      ],
      "Create a sync plan": [
        "同期プランの作成"
      ],
      "Create an activation key": [
        "アクティベーションキーの作成"
      ],
      "Create an alternate content source to download content from during repository syncing.  Note: alternate content sources are global and affect ALL sync actions on their smart proxies regardless of organization.": [
        "リポジトリーの同期中にコンテンツをダウンロードする代替コンテンツソースを作成します。注: 代替コンテンツソースはグローバル設定であるため、組織に関係なく Smart Proxy のすべての同期アクションに影響します。"
      ],
      "Create an environment": [
        "環境の作成"
      ],
      "Create an environment in an organization": [
        "組織の環境を作成"
      ],
      "Create an upload request": [
        "アップロード要求の作成"
      ],
      "Create content credentials with the generated SSL certificate and key.": [
        "生成された SSL 証明書およびキーでコンテンツの認証情報を作成します。"
      ],
      "Create content view": [
        "コンテンツビューの作成"
      ],
      "Create filter": [
        "フィルターの作成"
      ],
      "Create host collection": [
        "ホストコレクションの作成"
      ],
      "Create new activation key": [
        ""
      ],
      "Create organization": [
        "組織の作成"
      ],
      "Create package filter rule": [
        "パッケージフィルタールールの作成"
      ],
      "Create rule": [
        "ルールの作成"
      ],
      "Credentials": [
        "認証情報"
      ],
      "Critical": [
        "重大"
      ],
      "Cron expression is not valid!": [
        "cron 式が無効です!"
      ],
      "Current organization does not have a manifest imported.": [
        "現在の組織にはインポートされたマニフェストはありまません。"
      ],
      "Current organization is not set.": [
        "現在の組織が設定されていません。"
      ],
      "Current organization not set.": [
        "現在の組織は設定されていません。"
      ],
      "Custom": [
        "カスタム"
      ],
      "Custom CDN": [
        "カスタム CDN"
      ],
      "Custom Content Repositories": [
        "カスタムコンテンツリポジトリー"
      ],
      "Custom cron expression only needs to be set for interval value of custom cron": [
        "カスタムの cron 式は、カスタム cronの間隔値に対してだけ設定する必要があります"
      ],
      "Custom repositories cannot be disabled.": [
        "カスタムリポジトリーを無効にできません。"
      ],
      "Customize with Rex": [
        "Rex でカスタマイズ"
      ],
      "DEB name": [
        "DEB 名"
      ],
      "DEB package updates": [
        "DEB パッケージの更新"
      ],
      "Database connection": [
        "データベース接続"
      ],
      "Date": [
        "日付"
      ],
      "Date format is incorrect.": [
        "日付の形式が正しくありません。"
      ],
      "Days Remaining": [
        "日 (残りの日数)"
      ],
      "Days from Now": [
        "日 (現在からの日数)"
      ],
      "Deb": [
        "Deb"
      ],
      "Deb Package": [
        "Deb パッケージ"
      ],
      "Deb Packages": [
        "Deb パッケージ"
      ],
      "Deb name": [
        "Deb 名"
      ],
      "Deb package identifiers to filter content by": [
        "コンテンツをフィルタリングするための deb パッケージ ID"
      ],
      "Deb packages": [
        "Deb パッケージ"
      ],
      "Debian packages": [
        ""
      ],
      "Debug Certificate": [
        "デバッグ証明書"
      ],
      "Debug RPM": [
        "RPM のデバッグ"
      ],
      "Default Custom Repository download policy": [
        "デフォルトのカスタムリポジトリーのダウンロードポリシー"
      ],
      "Default HTTP Proxy": [
        "デフォルト HTTP プロキシー"
      ],
      "Default HTTP proxy for syncing content": [
        "コンテンツ同期用のデフォルト HTTP プロキシー"
      ],
      "Default Location where new subscribed hosts will put upon registration": [
        "新規のサブスクライブ済みホストが登録時に配置されるデフォルトのロケーション"
      ],
      "Default PXEGrub template for new Operating Systems created from synced content": [
        "同期コンテンツから作成された新規オペレーティングシステムのデフォルトの PXEGrub テンプレート"
      ],
      "Default PXEGrub2 template for new Operating Systems created from synced content": [
        "同期コンテンツから作成された新規オペレーティングシステムのデフォルトの PXEGrub2 テンプレート"
      ],
      "Default PXELinux template for new Operating Systems created from synced content": [
        "同期コンテンツから作成された新規オペレーティングシステムのデフォルトの PXELinux テンプレート"
      ],
      "Default Red Hat Repository download policy": [
        "デフォルトの Red Hat リポジトリーダウンロードポリシー"
      ],
      "Default Smart Proxy download policy": [
        "デフォルトの Smart Proxy ダウンロードポリシー"
      ],
      "Default System SLA": [
        "デフォルトのシステム SLA"
      ],
      "Default content view versions cannot be promoted": [
        "デフォルトコンテンツビューのバージョンはプロモートできません"
      ],
      "Default download policy for Smart Proxy syncs (either 'inherit', immediate', or 'on_demand')": [
        "Smart Proxy 同期のデフォルトのダウンロードポリシー ('inherit'、'immediate'、または 'on_demand' のいずれか)"
      ],
      "Default download policy for custom repositories (either 'immediate' or 'on_demand')": [
        "カスタムリポジトリーのデフォルトのダウンロードポリシー ('immediate' または 'on_demand' のいずれか)"
      ],
      "Default download policy for enabled Red Hat repositories (either 'immediate' or 'on_demand')": [
        "有効な Red Hat リポジトリーのデフォルトのダウンロードポリシー ('immediate' または 'on_demand' のいずれか)"
      ],
      "Default export format": [
        ""
      ],
      "Default export format for content-exports(either 'syncable' or 'importable')": [
        ""
      ],
      "Default finish template for new Operating Systems created from synced content": [
        "同期コンテンツから作成された新規オペレーティングシステムのデフォルト完了テンプレート"
      ],
      "Default iPXE template for new Operating Systems created from synced content": [
        "同期コンテンツから作成された新規オペレーティングシステムのデフォルト iPXE テンプレート"
      ],
      "Default kexec template for new Operating Systems created from synced content": [
        "同期コンテンツから作成された新規オペレーティングシステムのデフォルト kexec テンプレート"
      ],
      "Default location for subscribed hosts": [
        "サブスクライブ済みホストのデフォルトの場所"
      ],
      "Default partitioning table for new Operating Systems created from synced content": [
        "同期コンテンツから作成された新規オペレーティングシステムのデフォルトのパーティションテーブル"
      ],
      "Default provisioning template for Operating Systems created from synced content": [
        "同期コンテンツから作成されたオペレーティングシステムのデフォルトのプロビジョニングテンプレート"
      ],
      "Default provisioning template for new Atomic Operating Systems created from synced content": [
        "同期コンテンツから作成された新規 Atomic オペレーティングシステムのデフォルトのプロビジョニングテンプレート"
      ],
      "Default synced OS Atomic template": [
        "デフォルトの同期 OS Atomic テンプレート"
      ],
      "Default synced OS PXEGrub template": [
        "デフォルトの同期 OS PXEGrub テンプレート"
      ],
      "Default synced OS PXEGrub2 template": [
        "デフォルトの同期 OS PXEGrub2 テンプレート"
      ],
      "Default synced OS PXELinux template": [
        "デフォルトの同期 OS PXELinux テンプレート"
      ],
      "Default synced OS finish template": [
        "デフォルトの同期 OS 完了テンプレート"
      ],
      "Default synced OS iPXE template": [
        "デフォルトの同期 OS iPXE テンプレート"
      ],
      "Default synced OS kexec template": [
        "デフォルトの同期 OS kexec テンプレート"
      ],
      "Default synced OS partition table": [
        "デフォルトの同期 OS パーティションテーブル"
      ],
      "Default synced OS provisioning template": [
        "デフォルトの同期 OS プロビジョニングテンプレート"
      ],
      "Default synced OS user-data": [
        "デフォルトの同期 OS ユーザーデータ"
      ],
      "Default user data for new Operating Systems created from synced content": [
        "同期コンテンツから作成された新規オペレーティングシステムのデフォルトユーザーデータ"
      ],
      "Define RHUI repository paths with guided steps.": [
        "ガイド付き手順で RHUI リポジトリーパスを定義します。"
      ],
      "Define repositories structured under a common web or filesystem path.": [
        "一般的な Web またはファイルシステムパスで設定されるリポジトリーを定義します。"
      ],
      "Delete": [
        "削除"
      ],
      "Delete Activation Key": [
        "アクティベーションキーの削除"
      ],
      "Delete Host upon unregister": [
        "登録解除時にホストを削除します"
      ],
      "Delete Lifecycle Environment": [
        "ライフサイクル環境の削除"
      ],
      "Delete Manifest": [
        "マニフェストの削除"
      ],
      "Delete Product": [
        "製品の削除"
      ],
      "Delete Upstream Subscription": [
        "アップストリームサブスクリプションの削除"
      ],
      "Delete Version": [
        "バージョンの削除"
      ],
      "Delete a content view": [
        "コンテンツビューの削除"
      ],
      "Delete a filter rule": [
        "フィルタールールの削除"
      ],
      "Delete a flatpak remote": [
        ""
      ],
      "Delete activation key?": [
        ""
      ],
      "Delete all subscriptions attached to activation keys.": [
        "アクティベーションキーにアタッチされている全サブスクリプションを削除します。"
      ],
      "Delete all subscriptions that are attached to running hosts.": [
        "実行中のホストにアタッチされている全サブスクリプションを削除します。"
      ],
      "Delete an organization": [
        "組織の削除"
      ],
      "Delete an upload request": [
        "アップロード要求の削除"
      ],
      "Delete content view": [
        "コンテンツビューの削除"
      ],
      "Delete content view filters that have this repository as the last associated repository. Defaults to true. If false, such filters will now apply to all repositories in the content view.": [
        ""
      ],
      "Delete manifest from Red Hat provider": [
        "Red Hat プロバイダーからマニフェストを削除"
      ],
      "Delete multiple filters from a content view": [
        "コンテンツビューから複数のフィルターを削除します"
      ],
      "Delete version": [
        "バージョンの削除"
      ],
      "Delete versions": [
        "バージョンの削除"
      ],
      "Deleted %{host_count} %{hosts}": [
        ""
      ],
      "Deleted consumer '%s'": [
        "コンシューマー '%s' を削除しました"
      ],
      "Deleted from ": [
        "削除元 "
      ],
      "Deleted from %{environment}": [
        "%{environment} から削除"
      ],
      "Deleting content view : ": [
        "コンテンツビューを削除中: "
      ],
      "Deleting manifest in '%{subject}' failed.": [
        "'%{subject}' のマニフェストの削除に失敗しました。"
      ],
      "Deleting version {versionList}": [
        "バージョン {versionList} を削除しています"
      ],
      "Deleting versions: {versionList}": [
        "バージョンを削除しています: {versionList}"
      ],
      "Depth": [
        ""
      ],
      "Description": [
        "説明"
      ],
      "Description for the alternate content source": [
        "代替コンテンツソースの説明"
      ],
      "Description for the content view": [
        "コンテンツビューについての説明"
      ],
      "Description for the new published content view version": [
        "新規に公開されたコンテンツビューバージョンの説明"
      ],
      "Description of the flatpak remote": [
        ""
      ],
      "Description of the repository": [
        "リポジトリーの説明"
      ],
      "Designate this Content View for importing from upstream servers only. Defaults to false": [
        "このコンテンツビューをアップストリームサーバーからのインポート専用に指定します。デフォルトは false に設定されています"
      ],
      "Desired quantity of the pool": [
        "必要なプール数"
      ],
      "Destination Server name": [
        "宛先サーバー名"
      ],
      "Destroy": [
        "破棄"
      ],
      "Destroy Alternate Content Source": [
        "大体コンテンツソースの破棄"
      ],
      "Destroy Content Host": [
        "コンテンツホストの破棄"
      ],
      "Destroy Content Host %s": [
        "コンテンツホスト %s の破棄"
      ],
      "Destroy a Content Credential": [
        "コンテンツ認証情報の破棄"
      ],
      "Destroy a custom repository": [
        "カスタムリポジトリーの破棄"
      ],
      "Destroy a host collection": [
        "ホストコレクションの破棄"
      ],
      "Destroy a product": [
        "製品の破棄"
      ],
      "Destroy a sync plan": [
        "同期プランの破棄"
      ],
      "Destroy an activation key": [
        "アクティベーションキーの破棄"
      ],
      "Destroy an alternate content source.": [
        "代替コンテンツソースを破棄します。"
      ],
      "Destroy an environment": [
        "環境の破棄"
      ],
      "Destroy an environment in an organization": [
        "組織の環境を破棄"
      ],
      "Destroy one or more alternate content sources": [
        "1 つ以上の代替コンテンツソースの破棄"
      ],
      "Destroy one or more hosts": [
        "1 つまたは複数のホストを破棄します"
      ],
      "Destroy one or more products": [
        "1 つ以上の製品の破棄"
      ],
      "Destroy one or more repositories": [
        "1 つ以上のリポジトリーを破棄します"
      ],
      "Details": [
        "詳細"
      ],
      "Determining settings for ${truncate(name)}": [
        ""
      ],
      "Digest": [
        ""
      ],
      "Directly setting package lists on composite content views is not allowed. Please update the components, then re-publish the composite.": [
        "複合コンテンツビューにパッケージリストを直接設定することはできません。コンポーネントを更新してから、複合を再公開してください。"
      ],
      "Directory containing the exported Content View Version": [
        "エクスポート済みのコンテンツビューバージョンを含むディレクトリー"
      ],
      "Disable": [
        "無効化"
      ],
      "Disable Red Hat Insights.": [
        "Red Hat Insights を無効にします。"
      ],
      "Disable Simple Content Access": [
        "シンプルコンテンツアクセスの無効化"
      ],
      "Disable a repository from the set": [
        "セットのリポジトリーの無効化"
      ],
      "Disable module stream": [
        "モジュールストリームの無効化"
      ],
      "Disabled": [
        "無効化済み"
      ],
      "Disabling Simple Content Access failed for '%{subject}'.": [
        "'%{subject}' のシンプルコンテンツアクセスの有効化に失敗しました。"
      ],
      "Discover Repositories": [
        "リポジトリーの検出"
      ],
      "Distribute archived content view versions": [
        "アーカイブされたコンテンツビューのバージョンを配布"
      ],
      "Do not include this array of content views": [
        "このコンテンツビューの配列を組み込まないでください"
      ],
      "Do not wait for the ImportUpload action to finish. Default: false": [
        "ImportUpload アクションが完了するまで待機しないでください。デフォルト: false"
      ],
      "Do not wait for the update action to finish. Default: true": [
        "更新アクションが完了するまで待機しないでください。デフォルト: True"
      ],
      "Domain IDs": [
        "ドメイン ID"
      ],
      "Download Policy of the capsule, must be one of %s": [
        "Capsule のダウンロードポリシー。%s のいずれかである必要があります"
      ],
      "Download a debug certificate": [
        "デバッグ証明書のダウンロード"
      ],
      "Download rate limit": [
        "レート制限のダウンロード"
      ],
      "Due to a change in your organizations, this container name has become ambiguous (org name '%{org_label}'). If you wish to continue using this container name, destroy the organization in conflict with '%{o_name} (id %{o_id}). If you wish to keep both orgs, destroy '%{o_label}/%{prod_label}/%{root_repo_label}' and retry your push using the id format.": [
        ""
      ],
      "Due to a change in your products, this container name has become ambiguous (product name '%{prod_label}'). If you wish to continue using this container name, destroy the product in conflict with '%{prod_name}' (id %{prod_id}). If you wish to keep both products, destroy '%{org_label}/%{prod_dot_label}/%{root_repo_label}' and retry your push using the id format.": [
        ""
      ],
      "Duplicate artifact detected": [
        "重複するアーティファクトが検出されました"
      ],
      "Duplicate repositories in content view versions": [
        ""
      ],
      "Duration": [
        "期間"
      ],
      "ERRATA ADVISORY": [
        "エラータアドバイザリー"
      ],
      "Edit": [
        "編集"
      ],
      "Edit RPM rule": [
        "RPM ルールの編集"
      ],
      "Edit URL and subpaths": [
        "URL およびサブパスの編集"
      ],
      "Edit activation key": [
        ""
      ],
      "Edit content view assignment": [
        "コンテンツビューの割り当てを編集"
      ],
      "Edit content view environments": [
        ""
      ],
      "Edit credentials": [
        "資格情報の編集"
      ],
      "Edit details": [
        "詳細の編集"
      ],
      "Edit filter rule": [
        "フィルタールールの編集"
      ],
      "Edit package filter rule": [
        "パッケージフィルタールールの編集"
      ],
      "Edit products": [
        "製品の編集"
      ],
      "Edit rule": [
        "ルールの編集"
      ],
      "Edit smart proxies": [
        "Smart Proxy の編集"
      ],
      "Edit system purpose attributes": [
        "システム目的の属性の編集"
      ],
      "Editing Entitlements": [
        "エンタイトルメントの編集"
      ],
      "Either both parameters 'content_view_id' and 'environment_id' should be specified or neither should be specified": [
        "「content_view_id」および「environment_id」パラメーターの両方を指定するか、どちらも指定しないかのいずれかにします。"
      ],
      "Either environments or versions must be specified.": [
        "環境またはバージョンのいずれかを指定する必要があります"
      ],
      "Either organization ID or environment ID needs to be specified": [
        "組織 ID または環境 ID のいずれかを指定する必要があります"
      ],
      "Either packages or groups must be provided": [
        "パッケージまたはグループのいずれかを指定する必要があります"
      ],
      "Either set the content view with the latest flag or set the content view version": [
        "コンテンツビューに最新のフラグを設定するか、コンテンツビューバージョンを設定してください。"
      ],
      "Either set the latest content view or the content view version. Cannot set both": [
        "最新のコンテンツビューまたはコンテンツビューバージョンを設定します。両方設定することはできません。"
      ],
      "Empty content view versions": [
        "空のコンテンツビューのバージョン"
      ],
      "Enable": [
        "有効化"
      ],
      "Enable Red Hat repositories": [
        "Red Hat リポジトリーの有効化"
      ],
      "Enable Simple Content Access": [
        "シンプルコンテンツアクセスの有効化"
      ],
      "Enable Tracer": [
        "トレーサーの有効化"
      ],
      "Enable Traces": [
        "トレースの有効化"
      ],
      "Enable a repository from the set": [
        "セットのリポジトリーを有効化します"
      ],
      "Enable repository sets": [
        "リポジトリーセットの有効化"
      ],
      "Enable structured APT for deb content": [
        ""
      ],
      "Enable/Disable auto publish of composite view": [
        "複合ビューの自動公開を有効/無効にします"
      ],
      "Enabled": [
        "有効化済み"
      ],
      "Enabled Repositories": [
        "有効化されたリポジトリー"
      ],
      "Enabling Simple Content Access failed for '%{subject}'.": [
        "'%{subject}' のシンプルコンテンツアクセスの有効化に失敗しました。"
      ],
      "Enabling Tracer requires installing the katello-host-tools-tracer package on the host.": [
        ""
      ],
      "End Date": [
        "終了日"
      ],
      "End date": [
        "終了日"
      ],
      "Ends": [
        "終了"
      ],
      "Enhancement": [
        "機能強化"
      ],
      "Enter a name": [
        "名前の入力"
      ],
      "Enter a name for your source.": [
        "ソースの名前を入力します。"
      ],
      "Enter a valid date: MM/DD/YYYY": [
        "有効な日付を入力してください: MM/DD/YYYY"
      ],
      "Enter basic authentication information or choose content credentials if required for this source.": [
        "Basic 認証情報を入力するか、またはこのソースに必要な場合にコンテンツの認証情報を選択します。"
      ],
      "Enter in the base path and any subpaths that should be searched for alternate content.": [
        "ベースパスと、代替コンテンツを検索する必要があるサブパスを入力します。"
      ],
      "Entitlements": [
        "エンタイトルメント"
      ],
      "Environment": [
        "環境"
      ],
      "Environment ID": [
        ""
      ],
      "Environment ID and content view ID must be provided together": [
        ""
      ],
      "Environment IDs": [
        "環境 ID"
      ],
      "Environment cannot be in its own promotion path": [
        "同じ環境内のプロモートパスに環境を存在させることはできません。"
      ],
      "Environment identifier": [
        "環境 ID"
      ],
      "Environment name": [
        ""
      ],
      "Environments": [
        "環境"
      ],
      "Epoch": [
        "Epoch"
      ],
      "Equal to": [
        "="
      ],
      "Errata": [
        "エラータ"
      ],
      "Errata - by date range": [
        "エラータ: 日付範囲による"
      ],
      "Errata ID": [
        "エラータ ID"
      ],
      "Errata Install": [
        "エラータのインストール"
      ],
      "Errata Install scheduled by %s": [
        "%s によりエラータのインストールがスケジュールされました"
      ],
      "Errata and package information will be updated at the next host check-in or package action.": [
        ""
      ],
      "Errata and package information will be updated immediately.": [
        ""
      ],
      "Errata id of the erratum (RHSA-2012:108)": [
        "エラータのエラータ ID (RHSA-2012:108)"
      ],
      "Errata statuses not updated for deleted content facet with UUID %s": [
        ""
      ],
      "Errata to apply": [
        ""
      ],
      "Errata to exclusively include in the action": [
        "アクションにだけ含めるエラータ"
      ],
      "Errata to explicitly exclude in the action. All other applicable errata will be included in the action, unless an included parameter is passed as well.": [
        "アクションから明示的に除外するエラータ。包含パラメーターが指定されていない限り、それ以外で該当するエラータはすべてアクションに追加されます。"
      ],
      "Errata type": [
        "エラータタイプ"
      ],
      "Erratum": [
        "エラータ"
      ],
      "Erratum Install Canceled": [
        "エラータのインストールが取り消されました"
      ],
      "Erratum Install Complete": [
        "エラータのインストールが完了しました"
      ],
      "Erratum Install Failed": [
        "エラータのインストールが失敗しました"
      ],
      "Erratum Install Timed Out": [
        "エラータのインストールがタイムアウトになりました"
      ],
      "Error": [
        "エラー"
      ],
      "Error connecting to Pulp service": [
        "Pulp サービスへの接続時にエラーが発生しました"
      ],
      "Error connecting. Got: %s": [
        "接続エラー。結果: %s"
      ],
      "Error loading content views": [
        "コンテンツビューのロード中にエラーが発生しました"
      ],
      "Error refreshing status for %s: ": [
        "%s のステータスの更新エラー: "
      ],
      "Error retrieving Pulp storage": [
        "Pulp ストレージの取得時にエラーが発生しました"
      ],
      "Exceeds available quantity": [
        "利用可能な数を超えています"
      ],
      "Exclude": [
        "除外"
      ],
      "Exclude Refs": [
        ""
      ],
      "Exclude all RPMs not associated to any errata": [
        "エラータに関連付けられていないすべての RPM を除外する"
      ],
      "Exclude all module streams not associated to any errata": [
        "エラータに関連付けられていないモジュールストリームをすべて除外する"
      ],
      "Exclude filter": [
        "除外フィルター"
      ],
      "Excluded": [
        "除外済み"
      ],
      "Excluded errata": [
        "除外されるエラータ"
      ],
      "Excludes": [
        "除外"
      ],
      "Exit": [
        "終了"
      ],
      "Expand All": [
        "すべて展開"
      ],
      "Expire soon days": [
        "日 (期限切れまでの日数)"
      ],
      "Expired ": [
        ""
      ],
      "Expires ": [
        ""
      ],
      "Export": [
        "エクスポート"
      ],
      "Export CSV": [
        "CSV のエクスポート"
      ],
      "Export Library": [
        "ライブラリーのエクスポート"
      ],
      "Export Repository": [
        "リポジトリーのエクスポート"
      ],
      "Export Sync": [
        "エクスポートの同期"
      ],
      "Export Types": [
        "エクスポートタイプ"
      ],
      "Export as CSV": [
        "CSVとしてエクスポート"
      ],
      "Export failed: One or more repositories needs to be synced (with Immediate download policy.)": [
        ""
      ],
      "Export formats.Choose syncable if the exported content needs to be in a yum format. This option is only available for %{syncable_repos} repositories. Choose importable if the importing server uses the same version  and exported content needs to be one of %{importable_repos} repositories.": [
        ""
      ],
      "Export history identifier used for incremental export. If not provided the most recent export history will be used.": [
        "増分エクスポートに使用されるエクスポート履歴識別子。指定されていない場合は、最新のエクスポート履歴が使用されます。"
      ],
      "Exported content view": [
        "エクスポート済みのコンテンツビュー"
      ],
      "Exported version": [
        "エクスポートされたバージョン"
      ],
      "Extended support": [
        ""
      ],
      "Facts successfully updated.": [
        "ファクトが正常に更新されました。"
      ],
      "Failed": [
        "失敗"
      ],
      "Failed to delete %{host}: %{errors}": [
        "%{host} の削除に失敗しました: %{errors}"
      ],
      "Failed to delete latest content view version of Content View '%{subject}'.": [
        "コンテンツビュー '%{subject}' で最新のコンテンツビューバージョンを削除できませんでした。"
      ],
      "Failed to find %{content} with id '%{id}'.": [
        "ID が「%{id}」の %{content} が見つかりませんでした"
      ],
      "Fails if any of the repositories belonging to this organization are unexportable. False by default.": [
        "この組織に属するリポジトリーのいずれかがエクスポートできない場合は失敗します。デフォルトは False です。"
      ],
      "Fails if any of the repositories belonging to this version are unexportable. False by default.": [
        "このバージョンに属するリポジトリーのいずれかがエクスポートできない場合は失敗します。デフォルトは False です。"
      ],
      "Fetch applicable errata for one or more hosts.": [
        "1 つ以上のホストに該当するエラータを取得します。"
      ],
      "Fetch available module streams for hosts.": [
        "ホストで利用可能なモジュールストリームを取得します。"
      ],
      "Fetch installable errata for one or more hosts.": [
        "1 つまたは複数のホストにインストール可能なエラータを取得します。"
      ],
      "Fetch traces for one or more hosts": [
        "1 台以上のホストのトレースを取得します"
      ],
      "Fetching content credentials": [
        "コンテンツの認証情報を一覧表示する"
      ],
      "Field to sort the results on": [
        "結果をソートするフィールド"
      ],
      "File": [
        "ファイル"
      ],
      "File contents": [
        "ファイルのコンテンツ"
      ],
      "Filename": [
        "ファイル名"
      ],
      "Files": [
        "ファイル"
      ],
      "Filter by Product": [
        "製品別に絞り込む"
      ],
      "Filter by type": [
        "タイプ別に絞り込む"
      ],
      "Filter composite versions whose publish was triggered by the specified component version": [
        "指定したコンポーネントバージョンで公開がトリガーされた複合バージョンをフィルタリングする"
      ],
      "Filter content view versions that contain the file": [
        ""
      ],
      "Filter created": [
        "フィルターが作成されました"
      ],
      "Filter deleted": [
        "フィルターが削除されました"
      ],
      "Filter edited": [
        "フィルターが編集されました"
      ],
      "Filter only composite content views": [
        "複合コンテンツビューのみをフィルターにかける"
      ],
      "Filter out composite content views": [
        "複合コンテンツビューをフィルターにかける"
      ],
      "Filter out default content views": [
        "デフォルトコンテンツビューをフィルターにかける"
      ],
      "Filter products by host id": [
        "ホスト ID で製品をフィルター"
      ],
      "Filter products by name": [
        "名前別に製品を絞り込む"
      ],
      "Filter products by organization": [
        "組織別に製品を絞り込む"
      ],
      "Filter products by subscription": [
        "サブスクリプション別に製品を絞り込む"
      ],
      "Filter products by sync plan id": [
        "同期プラン ID 別に製品を絞り込む"
      ],
      "Filter repositories by content unit type (erratum, docker_tag, etc.). Check the \\\"Indexed?\\\" types here: /katello/api/repositories/repository_types": [
        "コンテンツユニットタイプ (erratum、docker_tag など)でリポジトリーをフィルターします。/katello/api/repositories/repository_types で \\\"Indexed?\\\" タイプを確認してください。"
      ],
      "Filter rule added": [
        "フィルタールールが追加されました"
      ],
      "Filter rule edited": [
        "フィルタールールが編集されました"
      ],
      "Filter rule removed": [
        "フィルタールールが削除されました"
      ],
      "Filter rules added": [
        "フィルタールールが追加されました"
      ],
      "Filter rules deleted": [
        "フィルタールールが削除されました"
      ],
      "Filter versions by environment": [
        "環境別にバージョンを絞り込む"
      ],
      "Filter versions by version number": [
        "バージョン番号別にバージョンを絞り込む"
      ],
      "Filter versions that are components in the specified composite version": [
        "指定した複合バージョンに含まれるコンポーネントのバージョンを絞り込む"
      ],
      "Filters": [
        "フィルター"
      ],
      "Filters deleted": [
        "フィルターが削除されました"
      ],
      "Filters were applied to this version.": [
        ""
      ],
      "Filters will be applied to this content view version.": [
        ""
      ],
      "Find the relative path for each RHUI repository and combine them in a comma-separated list.": [
        "各 RHUI リポジトリーの相対パスを見つけ、それらをコンマ区切りリストで組み合わせます。"
      ],
      "Finish": [
        "終了"
      ],
      "Finished": [
        "終了"
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
        "強制"
      ],
      "Force a sync and validate the checksums of all content. Non-yum repositories (or those with \\\\\\n                                                     On Demand download policy) are skipped.": [
        "強制的に同期し、全コンテンツのチェックサムを検証します。yum 以外のリポジトリー (またはオンデマンド \\\\\\n                                                     ダウンロードポリシーが指定されたリポジトリー) はスキップされます。"
      ],
      "Force a sync and validate the checksums of all content. Only used with yum repositories.": [
        "強制的に同期し、全コンテンツのチェックサムを検証します。Yum リポジトリーでのみ使用されます。"
      ],
      "Force content view promotion and bypass lifecycle environment restriction": [
        ""
      ],
      "Force delete the repository by removing it from all content view versions": [
        "すべてのコンテンツビューバージョンからリポジトリーを削除して、リポジトリーを強制的に削除します"
      ],
      "Force metadata regeneration to proceed. Dangerous operation when version has repositories with the 'Complete Mirroring' mirroring policy": [
        ""
      ],
      "Force metadata regeneration to proceed. Dangerous when repositories use the 'Complete Mirroring' mirroring policy": [
        ""
      ],
      "Force promotion": [
        "プロモーションの強制"
      ],
      "Force regenerate applicability.": [
        "適用可能なエラータを強制的に再生成します。"
      ],
      "Force sync even if no upstream changes are detected. Non-yum repositories are skipped.": [
        "アップストリームの変更が検出されない場合でも、強制的に同期します。yum 以外のリポジトリーはスキップされます。"
      ],
      "Force sync even if no upstream changes are detected. Only used with yum or deb repositories.": [
        ""
      ],
      "Forces a republish of the specified repository, regenerating metadata and symlinks on the filesystem. Not allowed for repositories with the 'Complete Mirroring' mirroring policy.": [
        ""
      ],
      "Forces a republish of the version's repositories' metadata": [
        "バージョンのリポジトリーのメタデータを強制的に再公開します"
      ],
      "Full description": [
        "説明全文"
      ],
      "Full support": [
        ""
      ],
      "GPG Key URL": [
        "GPG キー URL"
      ],
      "Generate RHUI certificates for the desired repositories as necessary.": [
        "必要に応じて、必要なリポジトリーの RHUI 証明書を生成します。"
      ],
      "Generate and Download": [
        "生成してダウンロード"
      ],
      "Generate errata status from directly-installable content": [
        ""
      ],
      "Generate host applicability": [
        "ホストに適用可能なエラータを生成します"
      ],
      "Generate repository applicability": [
        "リポジトリーに適用可能なエラータを生成します"
      ],
      "Generated": [
        "生成済み"
      ],
      "Generated content views cannot be assigned to hosts or activation keys": [
        ""
      ],
      "Generated content views cannot be directly published. They can updated only via export.": [
        "生成されたコンテンツビューは直接公開できません。コンテンツビューは、エクスポートしなければ更新されません。"
      ],
      "Get all content available, not just that provided by subscriptions": [
        "サブスクリプションが提供するコンテンツだけでなく、全コンテンツを利用可能にする"
      ],
      "Get all content available, not just that provided by subscriptions.": [
        "サブスクリプションが提供するコンテンツだけでなく、すべてのコンテンツを利用可能にします。"
      ],
      "Get content and overrides for the host": [
        "ホストのコンテンツと上書きを取得"
      ],
      "Get current smart proxy synchronization status": [
        "現在の Smart Proxy の同期ステータスを取得します"
      ],
      "Get info about a repository set": [
        "リポジトリーセットの情報取得"
      ],
      "Get list of available repositories for the repository set": [
        "リポジトリーセットの利用可能なリポジトリーの一覧を取得します"
      ],
      "Get status of synchronisation for given repository": [
        "指定リポジトリーの同期状態を取得"
      ],
      "Given a set of hosts and errata, lists the content view versions and environments that need updating.": [
        "ホストおよびエラータのセットに基づいて、更新の必要なコンテンツビューのバージョンおよび環境を一覧表示します。"
      ],
      "Given criteria doesn't match any DEBs. Try changing your rule.": [
        "指定された条件はどの DEB とも一致しません。ルールを変更してみてください。"
      ],
      "Given criteria doesn't match any activation keys. Try changing your rule.": [
        "指定された条件はどのアクティベーションキーともマッチしません。ルールを変更してみてください。"
      ],
      "Given criteria doesn't match any hosts. Try changing your rule.": [
        "指定された条件はどのホストともマッチしません。ルールを変更してみてください。"
      ],
      "Given criteria doesn't match any non-modular RPMs. Try changing your rule.": [
        ""
      ],
      "Go to job details": [
        "ジョブの詳細に移動"
      ],
      "Go to task page": [
        "タスクページに移動"
      ],
      "Greater than": [
        ">"
      ],
      "Guests of": [
        "ゲスト:"
      ],
      "HTTP Proxies": [
        "HTTP プロキシー"
      ],
      "HTTP Proxy identifier to associated": [
        "関連する HTTP プロキシー ID"
      ],
      "HW properties": [
        "HW プロパティー"
      ],
      "Has to be > 0": [
        "0 より大きい必要があります"
      ],
      "Hash containing the Id of the single lifecycle environment to be associated with the activation key.": [
        ""
      ],
      "Help": [
        ""
      ],
      "Helper": [
        "ヘルパー"
      ],
      "Hide Reclaim Space Warning": [
        ""
      ],
      "Hide affected activation keys": [
        "影響のあるアクティベーションキーを非表示"
      ],
      "Hide affected hosts": [
        "影響を受けるホストを非表示"
      ],
      "Hide description": [
        "説明の非表示"
      ],
      "History": [
        "履歴"
      ],
      "History will appear here when the content view is published or promoted.": [
        "コンテンツビューが公開またはプロモートされると、履歴がここに表示されます。"
      ],
      "Host": [
        "ホスト"
      ],
      "Host %s has not been registered with subscription-manager.": [
        "ホスト %s は subscription-manager で登録されていません。"
      ],
      "Host %{hostname}: Cannot add content view environment to content facet. The host's content source '%{content_source}' does not sync lifecycle environment '%{lce}'.": [
        ""
      ],
      "Host %{name} cannot be assigned release version %{release_version}.": [
        "ホスト %{name} は、リリースバージョン %{release_version} に割り当てることができません。"
      ],
      "Host '%{name}' does not belong to an organization": [
        "ホスト '%{name}' は組織に所属していません"
      ],
      "Host Can Re-Register Only In Build": [
        "ホストはビルドでのみ再登録が可能"
      ],
      "Host Collection name": [
        "ホストコレクション名"
      ],
      "Host Collections": [
        "ホストコレクション"
      ],
      "Host Duplicate DMI UUIDs": [
        "ホストの重複 DMI UUID"
      ],
      "Host Errata Advisory": [
        "ホストのエラータアドバイザリー"
      ],
      "Host ID": [
        "ホスト ID"
      ],
      "Host Limit": [
        ""
      ],
      "Host Profile Assume": [
        "ホストプロファイルの想定"
      ],
      "Host Profile Can Change In Build": [
        "ホストプロファイルはビルドでの変更が可能"
      ],
      "Host Tasks Workers Pool Size": [
        "ホストタスクワーカーのプールサイズ"
      ],
      "Host collection": [
        "ホストコレクション"
      ],
      "Host collection '%{name}' exceeds maximum usage limit of '%{limit}'": [
        "ホストコレクション '%{name}' は最大使用限度の '%{limit}' を超えています"
      ],
      "Host collection is empty.": [
        "ホストコレクションは空です。"
      ],
      "Host collections": [
        "ホストコレクション"
      ],
      "Host collections updated": [
        "ホストコレクションが更新されました"
      ],
      "Host content and subscription details": [
        "ホストコレクションおよびサブスクリプションの詳細"
      ],
      "Host content source will remain the same. Click Save below to update the host's content view environment.": [
        ""
      ],
      "Host content view and environment updated": [
        "ホストコンテンツビューと環境が更新されました"
      ],
      "Host content view environment(s) updated": [
        ""
      ],
      "Host content view environments updating.": [
        ""
      ],
      "Host creation was skipped for %s because it shares a BIOS UUID with %s. To report this hypervisor, override its dmi.system.uuid fact or set 'candlepin.use_system_uuid_for_matching' to 'true' in the Candlepin configuration.": [
        "%s と BIOS UUID を共有するため、%s のホスト作成は省略されました。このハイパーバイザーをレポートするには、dmi.system.uuid ファクトを上書きするか、Candlepin 設定の 'candlepin.use_system_uuid_for_matching' を「true」に設定してください。"
      ],
      "Host errata advisory": [
        "ホストエラータアドバイザリー"
      ],
      "Host group IDs": [
        "ホストグループ ID"
      ],
      "Host has not been registered with subscription-manager": [
        "ホストは subscription-manager で登録されていません。"
      ],
      "Host has not been registered with subscription-manager.": [
        "ホストは subscription-manager で登録されていません。"
      ],
      "Host id to list applicable deb packages for": [
        "適用可能な deb パッケージをリストするためのホスト ID"
      ],
      "Host id to list applicable errata for": [
        "該当するエラータをリストするホスト ID"
      ],
      "Host id to list applicable packages for": [
        "該当するパッケージをリストするホスト ID"
      ],
      "Host identifier": [
        ""
      ],
      "Host lifecycle support expiration notification": [
        ""
      ],
      "Host was not found by the subscription UUID: '%s', this can happen if the host is registered already, but not to this instance": [
        "サブスクリプション UUID: '%s' でホストが見つかりませんでした。これは、ホストがすでに登録されているけれども、このインスタンスには登録されていない場合に発生する可能性があります。"
      ],
      "Host with ID %s already exists in the host collection.": [
        "ID が %s のホストがすでにホストコレクションに存在します。"
      ],
      "Host with ID %s does not exist in the host collection.": [
        "ID が %s のホストはホストコレクションにありません。"
      ],
      "Host with ID %s not found.": [
        "id が %s のポリシーが見つかりません"
      ],
      "Hosts": [
        "ホスト"
      ],
      "Hosts to update": [
        "更新するホスト"
      ],
      "Hosts with Installable Errata": [
        "インストール可能なエラータのあるホスト"
      ],
      "Hosts: ": [
        "ホスト: "
      ],
      "How many days before a completed Pulp task is purged by Orphan Cleanup.": [
        ""
      ],
      "How many repositories should be synced concurrently on the capsule. A smaller number may lead to longer sync times. A larger number will increase dynflow load.": [
        "Capsule で同時に同期する必要があるリポジトリ数。数値が小さいほど、同期時間が長くなる可能性があり、数値が大きいほど、dynflow の負荷が増加します。"
      ],
      "How to order the sorted results (e.g. ASC for ascending)": [
        "結果のソート順 (例: ascending (昇順) の ASC)"
      ],
      "ID of a HTTP Proxy": [
        "HTTP プロキシ ー ID"
      ],
      "ID of a content view to show repositories in": [
        "リポジトリーを表示させるコンテンツビューの ID"
      ],
      "ID of a content view version to show repositories in": [
        "リポジトリーを表示させるコンテンツビューバージョン ID"
      ],
      "ID of a product to list repository sets from": [
        "一覧表示するリポジトリーセットの対象となる製品の ID"
      ],
      "ID of a product to show repositories of": [
        "表示するリポジトリーの対象となる製品の ID"
      ],
      "ID of an environment to show repositories in": [
        "リポジトリーを表示させる環境の ID"
      ],
      "ID of an organization to show repositories in": [
        "リポジトリーを表示させる組織の ID"
      ],
      "ID of flatpak remote to show repositories of": [
        ""
      ],
      "ID of the Organization": [
        "組織 ID"
      ],
      "ID of the activation key": [
        "アクティベーションキーの ID"
      ],
      "ID of the environment": [
        "環境の ID"
      ],
      "ID of the host": [
        "ホストの ID"
      ],
      "ID of the host collection": [
        "ホストコレクションの ID"
      ],
      "ID of the organization": [
        "組織の ID"
      ],
      "ID of the product containing the repository set": [
        "リポジトリーセットが含まれる製品の ID"
      ],
      "ID of the repository set": [
        "リポジトリーセットの ID"
      ],
      "ID of the repository set to disable": [
        "無効にするリポジトリーセットの ID"
      ],
      "ID of the repository set to enable": [
        "有効にするリポジトリーセットの ID"
      ],
      "ID of the repository within the set to disable": [
        "無効にするセットに含まれるリポジトリーの ID"
      ],
      "ID of the sync plan": [
        "同期プランの ID"
      ],
      "IDs of products to copy repository information from into a Simplified Alternate Content Source. Products must include at least one repository of the chosen content type.": [
        "リポジトリー情報を Simplified Alternate Content Source にコピーする製品の ID。製品には、選択したコンテンツタイプのリポジトリーが少なくとも 1 つ含まれている必要があります。"
      ],
      "Id of a deb package to find repositories that contain the deb": [
        "deb を含むリポジトリーを検索するための deb パッケージ ID"
      ],
      "Id of a file to find repositories that contain the file": [
        "ファイルを含むリポジトリーを検索するためのファイル ID"
      ],
      "Id of a rpm package to find repositories that contain the rpm": [
        "rpm を含むリポジトリーを検索するための rpm パッケージ ID"
      ],
      "Id of an ansible collection to find repositories that contain the ansible collection": [
        "ansible コレクションを含むリポジトリーを検索するための ansible コレクション ID"
      ],
      "Id of an erratum to find repositories that contain the erratum": [
        "エラータを含むリポジトリーを検索するためのエラータ ID"
      ],
      "Id of the HTTP proxy to use with alternate content sources": [
        "代替コンテンツソースで使用する HTTP プロキシーの ID"
      ],
      "Id of the content host": [
        "コンテンツホストの ID"
      ],
      "Id of the content view to limit the content counting on": [
        ""
      ],
      "Id of the content view to limit the synchronization on": [
        "同期を制限するコンテンツビューの ID"
      ],
      "Id of the content view to limit verifying checksum on": [
        ""
      ],
      "Id of the environment to limit the content counting on": [
        ""
      ],
      "Id of the environment to limit the synchronization on": [
        "同期を制限する環境の ID"
      ],
      "Id of the environment to limit verifying checksum on": [
        ""
      ],
      "Id of the host": [
        "ホストの ID"
      ],
      "Id of the host collection": [
        "ホストコレクションの ID"
      ],
      "Id of the lifecycle environment": [
        "ライフサイクル環境の ID"
      ],
      "Id of the organization to get the status for": [
        "ステータスを取得する組織の ID"
      ],
      "Id of the organization to limit environments on": [
        "環境を制限する組織の ID"
      ],
      "Id of the repository to limit the content counting on": [
        ""
      ],
      "Id of the repository to limit the synchronization on": [
        "同期を制限するリポジトリーの ID"
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
        "Smart Proxy の ID"
      ],
      "Id of the smart proxy from which the host consumes content.": [
        ""
      ],
      "Idenifier of the SSL CA Cert": [
        "SSL CA 証明書の ID"
      ],
      "Identifier of the GPG key": [
        "GPG キーの ID"
      ],
      "Identifier of the SSL Client Cert": [
        "SSL クライアント証明書の ID"
      ],
      "Identifier of the SSL Client Key": [
        "SSL クライアントキーの ID"
      ],
      "Identifier of the content credential containing the SSL CA Cert": [
        "SSL CA 証明書を含むコンテンツ認証情報の ID"
      ],
      "Identifier of the content credential containing the SSL Client Cert": [
        "SSL クライアント証明書を含むコンテンツ資格情報の ID"
      ],
      "Identifier of the content credential containing the SSL Client Key": [
        "SSL クライアントキーを含むコンテンツ認証情報の ID"
      ],
      "Identifiers for Lifecycle Environment": [
        "ライフサイクル環境の ID"
      ],
      "Identifies whether the repository should be unavailable on a client with a non-matching OS version.\\nPass [] to make repo available for clients regardless of OS version. Maximum length 1; allowed tags are: %s": [
        ""
      ],
      "Ids of smart proxies to associate": [
        "関連付ける Smart Proxy の ID"
      ],
      "If SSL should be verified for the upstream URL": [
        "アップストリーム URL に対して SSL を検証する必要がある場合"
      ],
      "If hosts fail to register because of duplicate DMI UUIDs, add their comma-separated values here. Subsequent registrations will generate a unique DMI UUID for the affected hosts.": [
        "DMI UUID が重複しているためにホストの登録に失敗した場合は、ここにコンマ区切りの値を追加します。今後の登録では、影響を受けるホストに対して一意の DMI UUID が生成されます。"
      ],
      "If product certificates should be used to authenticate to a custom CDN.": [
        ""
      ],
      "If set, newly created APT repos in Katello will use the same repo structure as the remote repos they are synchronized from. You may migrate existing APT repos to match the setting, by running 'foreman-rake katello:migrate_structure_content_for_deb'.": [
        ""
      ],
      "If specified, remove the first instance of a subscription with matching id and quantity": [
        "指定された場合、ID と数量が一致するサブスクリプションの最初のインスタンスを削除します"
      ],
      "If the smart proxies' assigned HTTP proxies should be used": [
        "Smart Proxy に割り当てられた HTTP プロキシーを使用する場合"
      ],
      "If this is enabled, a composite content view may not be published or promoted unless the component content view versions that it includes exist in the target environment.": [
        "これが有効な場合は、複合コンテンツビューを公開またはプロモートできません (ビューに含まれるコンポーネントコンテンツビューバージョンがターゲット環境に存在する場合を除く)。"
      ],
      "If this is enabled, and register_hostname_fact is set and provided, registration will look for a new host by name only using that fact, and will skip all hostname matching": [
        "これが有効で、register_hostname_fact が設定および指定されている場合には、登録時に、そのファクトだけを使用して名前で新規ホストを検索し、ホスト名の照合をすべてスキップします"
      ],
      "If this is enabled, content counts on smart proxies will be updated automatically after content sync.": [
        ""
      ],
      "If this is enabled, repositories can be deleted even when they belong to published content views. The deleted repository will be removed from all content view versions.": [
        "有効の場合、公開済みコンテンツビューに属する場合でもリポジトリーを削除できます。削除されたリポジトリーは、すべてのコンテンツビューバージョンから削除されます。"
      ],
      "If this is enabled, repositories of content view versions without environments (\\\"archived\\\") will be distributed at '/pulp/content/<organization>/content_views/<content view>/X.Y/...'.": [
        "これが有効な場合には、環境 (\\\"archived\\\") がないコンテンツビューバージョンのリポジトリーが '/pulp/content/<organization>/content_views/<content view>/X.Y/...' で配布されます。"
      ],
      "If this is enabled, the Smart Proxy page will suppress the warning message about reclaiming space.": [
        ""
      ],
      "If true, only errata that can be installed without an incremental update will affect the host's errata status. Also affects the Host Collections dashboard widget.": [
        ""
      ],
      "If true, only return repository sets that are associated with an active subscriptions": [
        "true の場合には、アクティブなサブスクリプションに関連付けられているリポジトリーセットのみを返します"
      ],
      "If true, only return repository sets that have been enabled. Defaults to false": [
        "true の場合には、有効なリポジトリーセットのみを返します。デフォルトは false です"
      ],
      "If true, return custom repository sets along with redhat repos. Will be ignored if repository_type is supplied.": [
        ""
      ],
      "If true, when adding the specified errata or packages, any needed dependencies will be copied as well. Defaults to true": [
        "true の場合には、指定されたエラータまたはパッケージを追加すると、必要な依存関係もコピーされます。デフォルトは True です。"
      ],
      "If true, will publish a new composite version using any specified content_view_version_id that has been promoted to a lifecycle environment": [
        "true の場合には、ライフサイクル環境にプロモートされている指定の content_view_version_id を使用して新規の複合バージョンが公開されます。"
      ],
      "If you would prefer to move some of these hosts to different content views or environments then {clickHere} to manage these hosts individually.": [
        "これらのホストの一部を別のコンテンツビューまたは環境に移動する場合、{clickHere} してホストを個別に管理します。"
      ],
      "Ignorable content can be only set for Yum repositories.": [
        "無視できるコンテンツは、Yum リポジトリーにのみ設定できます。"
      ],
      "Ignore %s cannot be set in combination with the 'Complete Mirroring' mirroring policy.": [
        ""
      ],
      "Ignore errors": [
        "エラーを無視する"
      ],
      "Ignore subscription manager errors": [
        "サブスクリプションマネージャーのエラーを無視します"
      ],
      "Ignore subscription-manager errors for `subscription-manager register` command": [
        "`subscription-manager register` コマンドの subscription-manager エラーを無視する"
      ],
      "Ignore subscriptions that are unavailable to the specified host": [
        "指定されたホストに使用できないサブスクリプションを無視します"
      ],
      "Ignored hosts": [
        "無視するホスト"
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
        "即時"
      ],
      "Import": [
        "インポート"
      ],
      "Import Content View Version": [
        "コンテンツビューバージョンのインポート"
      ],
      "Import Default Content View": [
        "デフォルトのコンテンツビューのインポート"
      ],
      "Import Manifest": [
        "マニフェストのインポート"
      ],
      "Import Repository": [
        "リポジトリーのインポート"
      ],
      "Import Types": [
        "インポートタイプ"
      ],
      "Import a Manifest": [
        "マニフェストのインポート"
      ],
      "Import a Manifest to Begin": [
        "開始するマニフェストのインポート"
      ],
      "Import a content view version": [
        "コンテンツビューバージョンのインポート"
      ],
      "Import a content view version to the library": [
        "コンテンツビューバージョンをライブラリーにインポートします"
      ],
      "Import a manifest using the Manifest tab above.": [
        ""
      ],
      "Import a repository": [
        "リポジトリーのインポート"
      ],
      "Import a subscription manifest to give hosts access to Red Hat content.": [
        ""
      ],
      "Import new manifest": [
        ""
      ],
      "Import only": [
        "インポートのみ"
      ],
      "Import only Content Views cannot be directly publsihed. Content can only be updated by importing into the view.": [
        "インポートのみのコンテンツビューは直接公開できません。コンテンツは、ビューにインポートしなければ更新されません。"
      ],
      "Import uploads into a repository": [
        "アップロードのリポジトリーへのインポート"
      ],
      "Import-only can not be changed after creation": [
        "インポートのみは、作成後に変更することはできません"
      ],
      "Import-only content views can not be published directly": [
        "インポートのみのコンテンツビューを直接公開することはできません"
      ],
      "Import/Export": [
        "インポート/エクスポート"
      ],
      "Important": [
        "重要"
      ],
      "Importing manifest into '%{subject}' failed.": [
        "'%{subject}' へのマニフェストのインポートに失敗しました。"
      ],
      "In Progress": [
        "処理中"
      ],
      "In progress": [
        "処理中"
      ],
      "Include": [
        "追加"
      ],
      "Include Refs": [
        ""
      ],
      "Include all RPMs not associated to any errata": [
        "エラータに関連付けられていないすべての RPM を含める"
      ],
      "Include all module streams not associated to any errata": [
        "エラータに関連付けられていないモジュールストリームをすべて含める"
      ],
      "Include content views generated by imports/exports. Defaults to false": [
        "インポート/エクスポートにより生成されるコンテンツビューが含まれます。デフォルトは false です"
      ],
      "Include filter": [
        "追加フィルター"
      ],
      "Include manifests": [
        ""
      ],
      "Included": [
        "包含済み"
      ],
      "Included errata": [
        "追加されるエラータ"
      ],
      "Includes": [
        "追加"
      ],
      "Includes associated content view filter ids in response": [
        "関連するコンテンツビューフィルター ID が応答に含まれています"
      ],
      "Inclusion type": [
        "追加タイプ"
      ],
      "Incremental Update": [
        "増分更新"
      ],
      "Incremental Update incomplete.": [
        "増分更新が完了していません。"
      ],
      "Incremental Update of %{content_view_count} Content View Version(s) ": [
        "%{content_view_count} 件のコンテンツビューバージョンの増分更新"
      ],
      "Incremental update": [
        "増分更新"
      ],
      "Incremental update requires at least one content unit": [
        "増分更新には少なくとも 1 つのコンテンツユニットが必要です"
      ],
      "Incremental update specified for composite %{name} version %{version}, but no components updated.": [
        "複合コンテンツ %{name} のバージョン %{version} に増分更新が指定されましたが、コンポーネントは更新されていません。"
      ],
      "Informable Type must be one of the following [ %{list} ]": [
        "情報タイプは以下のいずれかでなければなりません [ %{list} ]"
      ],
      "Inherit from Repository": [
        "リポジトリーから継承"
      ],
      "Initiate a sync of the products attached to the sync plan": [
        "同期プランに割り当てられた製品の同期を開始します"
      ],
      "Install": [
        "インストール"
      ],
      "Install errata using scoped search query": [
        "スコープ限定検索クエリーでのエラータのインストール"
      ],
      "Install errata via Katello interface": [
        "Katello インターフェイスでのエラータのインストール"
      ],
      "Install package group via Katello interface": [
        "Katello インターフェイスでのパッケージグループのインストール"
      ],
      "Install package via Katello interface": [
        "Katello インターフェイスでのパッケージのインストール"
      ],
      "Install packages": [
        "パッケージのインストール"
      ],
      "Install packages via Katello interface": [
        "Katello インターフェイスでのパッケージのインストール"
      ],
      "Install via customized remote execution": [
        "カスタマイズされたリモート実行によるインストール"
      ],
      "Install via remote execution": [
        "リモート実行によるインストール"
      ],
      "Installable": [
        "インストール可能"
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
        "インストール可能な更新"
      ],
      "Installation status": [
        "インストールの状態"
      ],
      "Installed": [
        "インストール済み"
      ],
      "Installed Packages": [
        "インストール済みパッケージ"
      ],
      "Installed module profiles will be removed. Additionally, all packages whose names are provided by specific modules will be removed. Packages required by other installed modules profiles and packages whose names are also provided by other modules are not removed.": [
        "インストールされたモジュールプロファイルは削除されます。特定のモジュールで名前を指定されたパッケージもすべて削除されます。他のインストール済みモジュールプロファイルで必要なパッケージと、他のモジュールで名前を指定されたパッケージは削除されません。"
      ],
      "Installed products": [
        "インストール済み製品"
      ],
      "Installed profile": [
        "インストール済みプロファイル"
      ],
      "Installed version": [
        "インストールされたバージョン"
      ],
      "Installing Erratum...": [
        "エラータをインストールしています..."
      ],
      "Installing Package Group...": [
        "パッケージグループをインストールしています..."
      ],
      "Installing Package...": [
        "パッケージのインストール中..."
      ],
      "Instance-based": [
        "インスタンスベース"
      ],
      "Interpret specified object to return only Host Collections that can be associated with specified object. The value 'host' is supported.": [
        "指定済みオブジェクトに関連付けることができるホストコレクションのみを返す指定済みオブジェクトを解釈します。値 'host' がサポートされます。"
      ],
      "Interpret specified object to return only Products that can be associated with specified object.  Only 'sync_plan' is supported.": [
        "指定済みオブジェクトに関連付けることができる製品のみを返す指定済みオブジェクトを解釈します。'sync_plan' のみがサポートされます。"
      ],
      "Interval cannot be nil": [
        "間隔を nil にすることはできません"
      ],
      "Interval not set correctly": [
        "間隔が正しく設定されていません"
      ],
      "Invalid association of the content view id. Content View must match the content view version being saved": [
        "コンテンツビュー ID の関連付けが無効です。コンテンツビューは、保存されているコンテンツビューのバージョンと一致する必要があります"
      ],
      "Invalid content label: %s": [
        "無効なコンテンツラベル: %s"
      ],
      "Invalid content type '%{content_type}' provided. Content types can be one of %{content_types}": [
        "無効なコンテンツタイプ '{content_type}' が指定されています。コンテンツタイプには {content_types} のいずれかを指定できます。"
      ],
      "Invalid date range. The erratum filter rule start date must come before the end date": [
        "無効な日付の範囲です。エラータフィルタールールの開始日は終了日の前でなくてはなりません。"
      ],
      "Invalid erratum filter rule specified, 'errata_id' cannot be specified in the same tuple as 'start_date', 'end_date' or 'types'": [
        "無効なエラータフィルタールールが指定されました。'errata_id' を 'start_date'、'end_date' または 'types' と同じ組で指定することはできません"
      ],
      "Invalid erratum filter rule specified, Must specify at least one of the following: 'errata_id', 'start_date', 'end_date', 'types', or 'allow_other_types'": [
        ""
      ],
      "Invalid erratum types %{invalid_types} provided. Erratum type can be any of %{valid_types}": [
        "無効なエラータタイプ %{invalid_types} が指定されました。エラータタイプは %{valid_types} のいずれかに指定できます"
      ],
      "Invalid event_type %s": [
        "無効な event_type %s"
      ],
      "Invalid export format provided. Format must be one of  %s ": [
        "無効なエクスポート形式が指定されました。形式は %s のいずれかである必要があります。"
      ],
      "Invalid filter rule specified, 'version' cannot be specified in the same tuple as 'min_version' or 'max_version'": [
        "無効なフィルタールールが指定されました。'version' を 'min_version' または 'max_version' と同じタプルで指定することはできません"
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
        "リポジトリータイプ %%{type} には無効なミラーリングポリシーです。%%{policies} だけが有効です。"
      ],
      "Invalid parameters sent in the request for this operation. Please contact a system administrator.": [
        "この操作に対する要求で送信されたパラメーターが無効です。システム管理者に連絡してください。"
      ],
      "Invalid parameters sent. You may have mistyped the address. If you continue having trouble with this, please contact an Administrator.": [
        "無効なパラメーターが送信されました。アドレスの入力間違いの可能性があります。問題が引き続き発生する場合は、管理者に連絡してください。"
      ],
      "Invalid params provided - content_type must be one of %s": [
        "指定されたパラメーターは無効です。content_type は %s のいずれかでなければなりません。"
      ],
      "Invalid params provided - date_type must be one of %s": [
        "指定されたパラメーターは無効です。date_type は %s のいずれかでなければなりません。"
      ],
      "Invalid params provided - with_content must be one of %s": [
        "指定されたパラメーターは無効です。with_content は %s のいずれかでなければなりません。"
      ],
      "Invalid path provided. Content can be only imported from file system. ": [
        "無効なパスが指定されました。コンテンツはファイルシステムからのみインポートできます。 "
      ],
      "Invalid release version: [%s]": [
        "無効なリリースバージョン: [%s]"
      ],
      "Invalid repository in the metadata %{repo} error=%{error}": [
        "メタデータのリポジトリー %{repo} が無効です。エラー=%{error}"
      ],
      "Invalid value specified for Container Image repositories.": [
        "コンテナーイメージリポジトリーに無効な値が指定されています。"
      ],
      "Invalid value specified for ignorable content.": [
        "無視できるコンテンツに無効な値が指定されています。"
      ],
      "Invalid value specified for ignorable content. Permissible values %s": [
        "無視できるコンテンツに無効な値が指定されています。許容値 %s"
      ],
      "Issued": [
        "発行済み"
      ],
      "Issued from": [
        "発行元"
      ],
      "It is only allowed for Non-Redhat Yum repositories.": [
        ""
      ],
      "Job '${description}' completed": [
        "ジョブ '${description}' が完了しました"
      ],
      "Job '${description}' has started.": [
        "ジョブ '${description}' が開始されました。"
      ],
      "Katello Bootc interface": [
        ""
      ],
      "Katello ID of local pool to update": [
        "更新するローカルプールの Katello ID"
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
        "Katello: エラータのインストール"
      ],
      "Katello: Install Package": [
        "Katello: パッケージのインストール"
      ],
      "Katello: Install Package Group": [
        "Katello: パッケージグループのインストール"
      ],
      "Katello: Install errata by search query": [
        "Katello: 検索クエリーでのエラータのインストール"
      ],
      "Katello: Install packages by search query": [
        "Katello: 検索クエリーでパッケージをインストール"
      ],
      "Katello: Module Stream Actions": [
        "Katello: モジュールストリームアクション"
      ],
      "Katello: Remove Package": [
        "Katello: パッケージの削除"
      ],
      "Katello: Remove Package Group": [
        "Katello: パッケージグループの削除"
      ],
      "Katello: Remove Packages by search query": [
        "Katello: 検索クエリーでパッケージの削除"
      ],
      "Katello: Resolve Traces": [
        "Katello: トレースの解決"
      ],
      "Katello: Service Restart": [
        "Katello: サービスの再起動"
      ],
      "Katello: Update Package": [
        "Katello: パッケージの更新"
      ],
      "Katello: Update Package Group": [
        "Katello: パッケージグループの更新"
      ],
      "Katello: Update Packages by search query": [
        "Katello: 検索クエリーでのパッケージの更新"
      ],
      "Katello: Upload Profile": [
        ""
      ],
      "Keep latest packages": [
        ""
      ],
      "Key-value hash of subscription-manager facts, nesting uses a period delimiter (.)": [
        "subscription-manager ファクトの Key-Value ハッシュ。ネスト化には、ピリオド (.) で区切ります。"
      ],
      "Kickstart": [
        "キックスタート"
      ],
      "Kickstart repositories can only be assigned to hosts in the Red Hat family": [
        "Kickstart リポジトリーは、Red Hat ファミリーのホストにのみ割り当てることができます"
      ],
      "Kickstart repository ID": [
        "Kickstart リポジトリー ID"
      ],
      "Kickstart repository was not set for host '%{host}'": [
        "ホスト '%{host}' に Kickstart リポジトリーが設定されていません"
      ],
      "Label": [
        "ラベル"
      ],
      "Label of the content": [
        "コンテンツのラベル"
      ],
      "Label of the content view": [
        "コンテンツビューのラベル"
      ],
      "Label of the flatpak remote": [
        ""
      ],
      "Last check-in:": [
        "最終チェックイン"
      ],
      "Last checkin": [
        "最終チェックイン"
      ],
      "Last published": [
        "最終公開日"
      ],
      "Last refresh": [
        "最終更新"
      ],
      "Last refresh :": [
        "最終更新 :"
      ],
      "Last seen": [
        ""
      ],
      "Last sync": [
        ""
      ],
      "Last task": [
        "最後のタスク"
      ],
      "Latest (automatically updates)": [
        "最新 (自動更新)"
      ],
      "Latest Errata": [
        "最新のエラータ"
      ],
      "Latest version": [
        "最新バージョン"
      ],
      "Learn more about adding subscription manifests in ": [
        ""
      ],
      "Legacy UI": [
        ""
      ],
      "Legacy content host UI": [
        "レガシーコンテンツホストの UI"
      ],
      "Less than": [
        "<"
      ],
      "Library": [
        "ライブラリー"
      ],
      "Library lifecycle environments may not be deleted.": [
        "ライブラリーのライフサイクル環境は削除できません。"
      ],
      "Library repository id to restrict comparisons to": [
        "比較を制限するためのライブラリーのリポジトリー ID"
      ],
      "Lifecycle": [
        "ライフサイクル"
      ],
      "Lifecycle Environment": [
        "ライフサイクル環境"
      ],
      "Lifecycle Environment %s has associated Activation Keys. Please change or remove the associated Activation Keys before trying to delete this lifecycle environment.": [
        "ライフサイクル環境 %s には関連付けられたアクティベーションキーがあります。このライフサイクル環境を削除する前に、関連付けられたアクティベーションキーを変更または削除してください。"
      ],
      "Lifecycle Environment %s has associated Hosts. Please unregister or move the associated Hosts before trying to delete this lifecycle environment.": [
        "ライフサイクル環境 %s には関連付けられたホストがあります。ライフサイクル環境を削除する前に、関連付けられたホストの登録を解除するか、移動してください。"
      ],
      "Lifecycle Environment ID": [
        "ライフサイクル環境 ID"
      ],
      "Lifecycle Environment Label": [
        "ライフサイクル環境ラベル"
      ],
      "Lifecycle Environments": [
        "ライフサイクル環境"
      ],
      "Lifecycle environment": [
        "ライフサイクル環境"
      ],
      "Lifecycle environment '%{environment}' is not attached to this capsule.": [
        "ライフサイクル環境 '%{environment}' はこの Capsule に割り当てられていません。"
      ],
      "Lifecycle environment '%{env}' cannot be used with content view '%{view}'": [
        ""
      ],
      "Lifecycle environment ID": [
        "ライフサイクル環境 ID"
      ],
      "Lifecycle environment must be specified": [
        ""
      ],
      "Lifecycle environment was not attached to the smart proxy; therefore, no changes were made.": [
        "ライフサイクル環境が Smart Proxy に割り当てられていないため、変更は行われませんでした。"
      ],
      "Lifecycle environment: {lce}": [
        "ライフサイクル環境: {lce}"
      ],
      "Lifecycle environments cannot be modifed on the default Smart proxy.  The content from all Lifecycle Environments will exist on this Smart proxy.": [
        "ライフサイクル環境をデフォルトの Smart Proxy で変更できません。すべてのライフサイクル環境のコンテンツはこの Smart Proxy 上に存在します。"
      ],
      "Limit actions to content in the host's environment.": [
        ""
      ],
      "Limit content to Red Hat / custom": [
        ""
      ],
      "Limit content to enabled / disabled / overridden": [
        "コンテンツの有効/無効/上書きを制限します。"
      ],
      "Limit content to just that available in the activation key's content view version": [
        "アクティベーションキーのコンテンツビューバージョンで利用可能なコンテンツだけに制限する"
      ],
      "Limit content to just that available in the host's content view version": [
        "ホストのコンテンツビューバージョンで利用可能なコンテンツだけに制限します"
      ],
      "Limit content to just that available in the host's or activation key's content view version and lifecycle environment.": [
        "ホストまたはアクティベーションキーのコンテンツビューバージョンおよびライフサイクル環境で利用可能なコンテンツだけに制限します。"
      ],
      "Limit the repository type. Available types endpoint: /katello/api/repositories/repository_types": [
        "リポジトリータイプを制限します。利用可能なタイプエンドポイント: /katello/api/repositories/repository_types"
      ],
      "Limit to environment": [
        "環境に制限"
      ],
      "Limits": [
        "制限"
      ],
      "List %s": [
        "%s の一覧表示"
      ],
      "List :resource": [
        ":resource の一覧表示"
      ],
      "List :resource_id": [
        ":resource_id を一覧表示します"
      ],
      "List Content Credentials": [
        "コンテンツの認証情報を一覧表示します"
      ],
      "List a host's subscriptions": [
        "ホストのサブスクリプションの一覧表示"
      ],
      "List activation keys": [
        "アクティベーションキーを一覧表示"
      ],
      "List all :resource_id": [
        "すべての :resource_id を一覧表示します"
      ],
      "List all organizations": [
        "すべての組織を一覧表示します"
      ],
      "List all packages unique by name": [
        ""
      ],
      "List alternate content sources.": [
        "代替コンテンツソースを一覧表示します。"
      ],
      "List an activation key's subscriptions": [
        "アクティベーションキーのサブスクリプションの表示"
      ],
      "List available releases in the organization": [
        "組織で利用可能なリリースを一覧表示します"
      ],
      "List available subscriptions from Red Hat Subscription Management": [
        "Red Hat Subscription Management から利用可能なサブスクリプションを一覧表示します"
      ],
      "List booted bootc container images for hosts": [
        ""
      ],
      "List components attached to this content view": [
        "このコンテンツビューに割り当てられたコンポーネントの一覧を表示します"
      ],
      "List content counts for the smart proxy": [
        ""
      ],
      "List content view environments": [
        ""
      ],
      "List content view versions": [
        "コンテンツビューのバージョンを一覧表示"
      ],
      "List content views": [
        "コンテンツビューを一覧表示します"
      ],
      "List deb packages": [
        "deb パッケージの一覧表示"
      ],
      "List deb packages installed on the host": [
        "ホストにインストールされている deb パッケージの一覧を表示します"
      ],
      "List environment paths": [
        "環境パスを一覧表示します"
      ],
      "List environments in an organization": [
        "組織の環境の一覧を表示します"
      ],
      "List errata": [
        "エラータを一覧表示します"
      ],
      "List errata available for the content host": [
        "コンテンツホストで利用可能なエラータを一覧表示します"
      ],
      "List export histories": [
        "エクスポート履歴を一覧表示します"
      ],
      "List filter rules": [
        "フィルタールールを一覧表示"
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
        "ホストコレクションを一覧表示"
      ],
      "List host collections in an activation key": [
        "アクティベーションキー内のホストコレクションを一覧表示します"
      ],
      "List host collections the activation key does not belong to": [
        "アクティベーションキーが属さないホストコレクションを一覧表示"
      ],
      "List host collections within an organization": [
        "組織内のホストコレクションを一覧表示"
      ],
      "List import histories": [
        "インポート履歴を一覧表示します"
      ],
      "List module streams available to the host": [
        "ホストで利用可能なモジュールストリームを一覧表示します"
      ],
      "List of Errata ids": [
        "エラータ ID の一覧"
      ],
      "List of Products for sync plan": [
        "同期プランの製品の一覧"
      ],
      "List of alternate content source IDs": [
        "代替コンテンツソース ID のリスト"
      ],
      "List of component content view version ids for composite views": [
        "複合ビューのコンポーネントコンテンツビューのバージョン ID の一覧"
      ],
      "List of content units to ignore while syncing a yum repository. Must be subset of %s": [
        "Yum リポジトリーの同期中に無視するコンテンツユニットの一覧。%s のサブセットである必要があります"
      ],
      "List of enabled repo urls for the repo (Only first is used.)": [
        "対象のリポジトリーで有効なリポジトリー URL の一覧 (最初のものだけを使用)"
      ],
      "List of enabled repositories": [
        "有効にされたリポジトリーの一覧"
      ],
      "List of errata ids to exclude and not run an action on, (ex: RHSA-2019:1168)": [
        "除外してアクションを実行しないエラータ ID の一覧 (例: RHSA-2019:1168)"
      ],
      "List of errata ids to perform an action on, (ex: RHSA-2019:1168)": [
        "アクションを実行するエラータ ID の一覧 (例: RHSA-2019:1168)"
      ],
      "List of host collection IDs to associate with activation key": [
        "アクティベーションキーに関連付けるホストコレクション ID の一覧"
      ],
      "List of host collection IDs to disassociate from the activation key": [
        "アクティベーションキーから関連付けを解除するホストコレクション ID の一覧"
      ],
      "List of host collection ids": [
        "ホストコレクション ID の一覧"
      ],
      "List of host collection ids to update": [
        "更新するホストコレクション ID の一覧"
      ],
      "List of host id to list available module streams for": [
        "使用可能なモジュールストリームを一覧表示するホスト ID の一覧"
      ],
      "List of host ids to exclude and not run an action on": [
        "除外してアクションを実行しないホスト ID の一覧"
      ],
      "List of host ids to perform an action on": [
        "アクションを実行するホスト ID の一覧"
      ],
      "List of host ids to replace the hosts in host collection": [
        "ホストコレクションのホストを置き換えるホスト ID の一覧"
      ],
      "List of hypervisor guest uuids": [
        "ハイパーバイザーゲストの UUID 一覧"
      ],
      "List of package group names (Deprecated)": [
        "パッケージグループ名の一覧 (非推奨)"
      ],
      "List of package names": [
        "パッケージ名の一覧"
      ],
      "List of product ids": [
        "製品 ID の一覧"
      ],
      "List of product ids to add to the sync plan": [
        "同期プランに追加する製品 ID の一覧"
      ],
      "List of product ids to remove from the sync plan": [
        "同期プランから削除する製品 ID の一覧"
      ],
      "List of products in an organization": [
        "組織内の製品の一覧"
      ],
      "List of products installed on the host": [
        "ホストにインストールされている製品の一覧"
      ],
      "List of repositories belonging to a product in an environment": [
        "環境内の製品に所属するリポジトリーの一覧"
      ],
      "List of repositories for a content view": [
        "コンテンツビューのリポジトリーの一覧"
      ],
      "List of repositories for a docker meta tag": [
        "docker メタタグのリポジトリーの一覧"
      ],
      "List of repositories for a product": [
        "製品のリポジトリーの一覧"
      ],
      "List of repositories in an organization": [
        "組織のリポジトリーの一覧"
      ],
      "List of repository ids": [
        "リポジトリー ID の一覧"
      ],
      "List of resources types that will be automatically associated": [
        "自動的に関連付けられるリソースタイプの一覧"
      ],
      "List of subscription products in a subscription": [
        "サブスクリプション内のサブスクリプション製品の一覧"
      ],
      "List of subscription products in an activation key": [
        "アクティベーションキー内のサブスクリプション製品の一覧"
      ],
      "List of versions to exclude and not run an action on": [
        "除外してアクションを実行しないバージョンの一覧"
      ],
      "List of versions to perform an action on": [
        "アクションを実行するバージョンの一覧"
      ],
      "List organization subscriptions": [
        "組織サブスクリプションの一覧表示"
      ],
      "List packages": [
        "パッケージを一覧表示します"
      ],
      "List packages installed on the host": [
        "ホストにインストールされているパッケージの一覧表示"
      ],
      "List products": [
        "製品の一覧表示"
      ],
      "List repositories in the environment": [
        "環境内のリポジトリーを一覧表示します"
      ],
      "List repository sets for a product.": [
        "製品のリポジトリーセットを一覧表示します。"
      ],
      "List repository sets.": [
        "リポジトリーセットの一覧表示"
      ],
      "List services that need restarting on the host": [
        "ホストで再起動が必要なサービスを一覧表示します"
      ],
      "List srpms": [
        "srpm の一覧表示"
      ],
      "List subscriptions": [
        "サブスクリプションの表示"
      ],
      "List sync plans": [
        "同期プランの一覧表示"
      ],
      "List the lifecycle environments attached to the smart proxy": [
        "Smart Proxy に割り当てられたライフサイクル環境を一覧表示します"
      ],
      "List the lifecycle environments not attached to the smart proxy": [
        "Smart Proxy に割り当てられていないライフサイクル環境を一覧表示します"
      ],
      "Load balancer": [
        ""
      ],
      "Loading": [
        "ロード中"
      ],
      "Loading versions": [
        "バージョンの読み込み中"
      ],
      "Loading...": [
        "読み込み中..."
      ],
      "Low": [
        "低"
      ],
      "Maintenance support": [
        ""
      ],
      "Make copy of a content view": [
        "コンテンツビューのコピー作成"
      ],
      "Make copy of a host collection": [
        "ホストコレクションのコピー作成"
      ],
      "Make sure all the component content views are published before publishing/promoting the composite content view. This restriction is optional and can be modified in the Administrator -> Settings -> Content page using the restrict_composite_view flag.": [
        "複合コンテンツビューの公開/プロモート前に、コンポーネントのコンテンツビューがすべて公開されていることを確認します。この制限は任意で、管理 -> 設定 -> コンテンツページで、restrict_composite_view フラグを使用して変更できます。"
      ],
      "Manage Manifest": [
        "マニフェストの管理"
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
        "Manifest (マニフェスト)"
      ],
      "Manifest History": [
        "マニフェストの履歴"
      ],
      "Manifest deleted": [
        "マニフェストを削除しました"
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
        "マニフェストをインポートしました"
      ],
      "Manifest in '%{subject}' deleted.": [
        "'%{subject}' のマニフェストが削除されました。"
      ],
      "Manifest in '%{subject}' failed to refresh.": [
        "'%{subject}' のマニフェストを更新できませんでした。"
      ],
      "Manifest in '%{subject}' imported.": [
        "'%{subject}' のマニフェストをインポートしました。"
      ],
      "Manifest in '%{subject}' refreshed.": [
        "'%{subject}' のマニフェストが更新されました。"
      ],
      "Manifest in organization %{subject} has an identity certificate that will expire in %{days_remaining} days, on %{manifest_expire_date}. To extend the expiration date, please refresh your manifest.": [
        ""
      ],
      "Manifest refresh timeout": [
        "マニフェストの更新のタイムアウト"
      ],
      "Manifest refreshed": [
        "マニフェストが更新されました"
      ],
      "Manual": [
        "手動"
      ],
      "Manual authentication": [
        "手動認証"
      ],
      "Mark Content Host Statuses as Unknown for %s": [
        "%s のコンテンツホストステータスを不明としてマーク"
      ],
      "Matching RPMs based on your created filter rule. Remember, RPM filters don't apply to modular RPMs.": [
        ""
      ],
      "Matching content": [
        "マッチするコンテンツ"
      ],
      "Max %(maxQuantity)s": [
        "最大 %(maxQuantity)s 件"
      ],
      "Max Hosts (%{limit}) reached for activation key '%{name}'": [
        "アクティベーションキー '%{name}' でホストの最大数 (%{limit}) に達しました"
      ],
      "Maximum download rate when syncing a repository (requests per second). Use 0 for no limit.": [
        "リポジトリーを同期する際の最大ダウンロードレート (1 秒あたりの要求数)。制限なしの場合は 0 を使用します。"
      ],
      "Maximum number of content hosts exceeded for host collection(s): %s": [
        "ホストコレクションの最大コンテンツホスト数を超えました: %s"
      ],
      "Maximum number of hosts in the host collection": [
        "ホストコレクションのホストの最大数"
      ],
      "Maximum version": [
        "最大のバージョン"
      ],
      "May not add a type or date range rule to a filter that has existing rules.": [
        "タイプまたはデータ範囲ルールを、既存ルールのあるフィルターに追加することはできません。"
      ],
      "May not add an id rule to a filter that has an existing type or date range rule.": [
        "ID ルールを、既存のタイプまたはデータ範囲ルールのあるフィルターに追加することはできません。"
      ],
      "Media Selection": [
        "メディアの選択"
      ],
      "Medium IDs": [
        "メディア ID"
      ],
      "Message": [
        "メッセージ"
      ],
      "Messaging connection": [
        "メッセージング接続"
      ],
      "Metadata republishing is risky on 'Complete Mirroring' repositories. Change the mirroring policy and try again.\\nAlternatively, use the 'force' parameter to regenerate metadata locally. On the next sync, the upstream repository's metadata will overwrite local metadata for 'Complete Mirroring' repositories.": [
        ""
      ],
      "Metadata taken from the upstream export history for this Content View Version": [
        "このコンテンツビューバージョンのアップストリームエクスポート履歴から取得したメタデータ"
      ],
      "Minimum version": [
        "最小のバージョン"
      ],
      "Mirror Remote Repository": [
        ""
      ],
      "Mirror a flatpak remote repository": [
        ""
      ],
      "Missing activation key!": [
        "アクティベーションキーがありません!"
      ],
      "Missing arguments %{substitutions} for %{content_url}": [
        "%{content_url} の引数 %{substitutions} がありません"
      ],
      "Model": [
        "モデル"
      ],
      "Moderate": [
        "中"
      ],
      "Modify via remote execution": [
        ""
      ],
      "Modular": [
        "モジュラー"
      ],
      "Module Stream": [
        "モジュールストリーム"
      ],
      "Module Stream Details": [
        "モジュールストリームの詳細"
      ],
      "Module Streams": [
        "モジュールストリーム"
      ],
      "Module stream": [
        "モジュールストリーム"
      ],
      "Module streams": [
        "モジュールストリーム"
      ],
      "Module streams will appear here after enabling Red Hat repositories or creating custom products.": [
        "Red Hat リポジトリーを有効にしたり、カスタム製品を作成したりすると、モジュールストリームがここに表示されます。"
      ],
      "Multi Content View Environment": [
        ""
      ],
      "Multi-entitlement": [
        "マルチエンタイトルメント"
      ],
      "N/A": [
        "N/A"
      ],
      "NA": [
        "NA"
      ],
      "NOTE: Content view version '%{content_view} %{current}' does not have any exportable repositories. At least one repository with any of the following types is required to be able to export: '%{exportable_types}'.": [
        ""
      ],
      "NOTE: Unable to export repository '%{repository}' because it does not have an exportable content type.": [
        "注: エクスポート可能なコンテンツタイプがないので '%{repository}' リポジトリーをエクスポートできません。"
      ],
      "NOTE: Unable to export repository '%{repository}' because it does not have an syncably exportable content type.": [
        ""
      ],
      "NOTE: Unable to fully export '%{organization}' organization's library because it contains repositories without the 'immediate' download policy. Update the download policy and sync affected repositories to include them in the export. \\n %{repos}": [
        "注記: 「即時」ダウンロードポリシーのないリポジトリーが含まれているため、'%%{organization}' 組織のライブラリーを完全にエクスポートすることはできません。ダウンロードポリシーを更新し、影響を受けるリポジトリーを同期して、エクスポートに含めます。\\n ％%{repos}"
      ],
      "NOTE: Unable to fully export Content View Version '%{content_view} %{current}' it contains repositories with un-exportable content types. \\n %{repos}": [
        "注: コンテンツビューバージョン '%{content_view} %{current}' をすべてエクスポートできません。エクスポートできない。コンテンツタイプを使用するリポジトリーが含まれています。\\n %{repos}"
      ],
      "NOTE: Unable to fully export Content View Version '%{content_view} %{current}' it contains repositories without the 'immediate' download policy. Update the download policy and sync affected repositories. Once synced republish the content view and export the generated version. \\n %{repos}": [
        "注記: コンテンツビューバージョン '%{content_view} %%{current}' を完全にエクスポートすることができません。これには、「即時」ダウンロードポリシーのないリポジトリーが含まれています。ダウンロードポリシーを更新し、影響を受けるリポジトリーを同期します。同期したら、コンテンツビューを再公開し、生成されたバージョンをエクスポートします。 \\n ％%{repos}"
      ],
      "NOTE: Unable to fully export repository '%{repository}' because it does not have the 'immediate' download policy. Update the download policy and sync the affected repository to include them in the export.": [
        "注記: 「即時」ダウンロードポリシーがないため、リポジトリー '%{repository}' を完全にエクスポートすることはできません。ダウンロードポリシーを更新し、影響を受けるリポジトリーを同期して、エクスポートに含めます。"
      ],
      "Name": [
        "名前"
      ],
      "Name and label of default content view should not be changed": [
        "デフォルトのコンテンツビューの名前とラベルは変更しないでください。"
      ],
      "Name is a required parameter.": [
        "name は必須パラメーターです。"
      ],
      "Name of new activation key": [
        "新規アクティベーションキーの名前"
      ],
      "Name of the Content Credential": [
        "コンテンツ認証情報の名前"
      ],
      "Name of the alternate content source": [
        "代替コンテンツソースの名前"
      ],
      "Name of the content view": [
        "コンテンツビューの名前"
      ],
      "Name of the flatpak remote": [
        ""
      ],
      "Name of the flatpak remote repository": [
        ""
      ],
      "Name of the host": [
        "ホスト名"
      ],
      "Name of the repository": [
        "リポジトリー名"
      ],
      "Name of the upstream docker repository": [
        "アップストリーム Docker リポジトリー名"
      ],
      "Name source": [
        "名前ソース"
      ],
      "Names of smart proxies to associate": [
        "関連付ける Smart Proxy の 名前"
      ],
      "Needs to only be set for docker tags": [
        "Docker タグにだけ設定する必要があります"
      ],
      "Needs to only be set for file repositories or docker tags": [
        "ファイルリポジトリーまたは Docker タグに対してだけ設定する必要があります"
      ],
      "Nest": [
        "ネスト"
      ],
      "Network Sync": [
        "ネットワークの同期"
      ],
      "Never": [
        "なし"
      ],
      "Never Synced": [
        "一度も同期されていません"
      ],
      "New Errata": [
        "新規エラータ"
      ],
      "New content view name": [
        "新規コンテンツビューの名前"
      ],
      "New host collection name": [
        "新規ホストコレクションの名前"
      ],
      "New name cannot be blank": [
        "新規の名前を空白にすることはできません"
      ],
      "New name for the content view": [
        "コンテンツビューの新規の名前"
      ],
      "New version is available: Version ${latestVersion}": [
        "新しいバージョンが利用可能です: バージョン {latestVersion}"
      ],
      "Newly published": [
        "最新公開日"
      ],
      "Newly published version will be the same as the previous version.": [
        ""
      ],
      "No": [
        "いいえ"
      ],
      "No Activation Keys selected": [
        "アクティベーションキーが選択されていません"
      ],
      "No Activation keys to select": [
        "選択するアクティベーションキーがありません"
      ],
      "No Content View": [
        "コンテンツビューがありません"
      ],
      "No Content found": [
        "コンテンツが見つかりません"
      ],
      "No Red Hat products currently exist, please import a manifest %(anchorBegin)s here %(anchorEnd)s to receive Red Hat content. No repository sets available.": [
        "Red Hat 製品がありません。%(anchorBegin)s ここ %(anchorEnd)s にマニフェストをインポートして Red Hat コンテンツを受信してください。利用可能なリポジトリーセットがありません。"
      ],
      "No Service Level Preference": [
        "サービスレベルの設定がありません"
      ],
      "No URL found for a container registry. Please check the configuration.": [
        "コンテナーレジストリーの URL が見つかりません。設定を確認してください。"
      ],
      "No Version of Content View %{component} already exists as a component of the composite Content View %{composite} version %{version}": [
        "複合コンテンツビュー %{composite} のバージョン %{version} のコンポーネントとして存在するコンテンツビュー %{component} のバージョンはありません。"
      ],
      "No action is needed because there are no applicable errata for this host.": [
        "このホストに適用可能なエラータがないため、アクションは必要ありません。"
      ],
      "No action required": [
        "アクションは必要ありません"
      ],
      "No applicable errata": [
        "適用可能なエラータがありません"
      ],
      "No applications to restart": [
        "再起動するアプリケーションはありません"
      ],
      "No artifacts to show": [
        "表示するアーティファクトはありません"
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
        "コンテンツがありません"
      ],
      "No content added.": [
        "コンテンツが追加されていません。"
      ],
      "No content ids provided": [
        "コンテンツ ID が提供されていません"
      ],
      "No content in selected versions.": [
        "選択したバージョンにコンテンツがありません。"
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
        "コンテンビューの履歴イベントが見つかりません。"
      ],
      "No content views available": [
        "利用できるコンテンツビューがありません"
      ],
      "No content views available for the selected environment": [
        "選択した環境に利用可能なコンテンツビューはありません"
      ],
      "No content views to add yet": [
        ""
      ],
      "No content views yet": [
        ""
      ],
      "No content_view_version_ids provided": [
        "content_view_version_ids が指定されていません"
      ],
      "No description": [
        "説明なし"
      ],
      "No description provided": [
        "説明はありません"
      ],
      "No docker manifests to delete after ignoring manifests with tags or manifest lists": [
        ""
      ],
      "No enabled repositories match your search criteria.": [
        "検索条件に一致する有効なリポジトリーはありません。"
      ],
      "No environments": [
        "環境なし"
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
        "エラーなし"
      ],
      "No existing export history was found to perform an incremental export. A full export must be performed": [
        "増分エクスポートを実行する既存のエクスポート履歴は見つかりませんでした。完全なエクスポートを実行する必要があります"
      ],
      "No file uploaded": [
        "ファイルがアップロードされていません"
      ],
      "No filters yet": [
        ""
      ],
      "No history yet": [
        ""
      ],
      "No host collections": [
        "ホストコレクションはありません"
      ],
      "No host collections found.": [
        "ホストコレクションが見つかりません"
      ],
      "No host collections yet": [
        "ホストコレクションはまだありません"
      ],
      "No hosts found": [
        ""
      ],
      "No hosts registered with subscription-manager found in selection.": [
        "subscription-manager に登録されているホストが選択肢に含まれていません。"
      ],
      "No hosts were specified": [
        ""
      ],
      "No installed debs found for search term '%s'": [
        ""
      ],
      "No installed packages and/or enabled repositories have been reported by %s.": [
        "%s でレポートされたインストール済みパッケージや有効なリポジトリーはありません。"
      ],
      "No items have been specified.": [
        "項目が指定されていません。"
      ],
      "No manifest file uploaded": [
        "マニフェストファイルがアップロードされていません"
      ],
      "No manifest found. Import a manifest with the appropriate subscriptions before importing content.": [
        "マニフェストが見つかりません。コンテンツをインポートする前に、適切なサブスクリプションでマニフェストをインポートしてください。"
      ],
      "No manifest imported": [
        ""
      ],
      "No matching ": [
        "マッチする項目が"
      ],
      "No matching ${name} found.": [
        "マッチする {name} が見つかりませんでした"
      ],
      "No matching ${selectedContentType} found": [
        "マッチする {selectedContentType} が見つかりませんでした"
      ],
      "No matching DEB found.": [
        "一致する DEB が見つかりませんでした。"
      ],
      "No matching activation keys found.": [
        "マッチするアクティベーションキーが見つかりませんでした。"
      ],
      "No matching alternate content sources found": [
        "一致する代替コンテンツソースが見つかりません"
      ],
      "No matching content views found": [
        "一致するコンテンツビューが見つかりません"
      ],
      "No matching errata found": [
        "マッチするエラータが見つかりませんでした"
      ],
      "No matching filter rules found.": [
        "マッチするフィルタールールが見つかりませんでした。"
      ],
      "No matching filters found": [
        "一致するフィルターが見つかりません"
      ],
      "No matching history record found": [
        "一致する履歴レコードが見つかりません"
      ],
      "No matching host collections found": [
        "一致するホストコレクションが見つかりません"
      ],
      "No matching hosts found.": [
        "マッチするホストが見つかりませんでした。"
      ],
      "No matching non-modular RPM found.": [
        ""
      ],
      "No matching packages found": [
        "マッチするパッケージが見つかりませんでした"
      ],
      "No matching repositories found": [
        "一致するリポジトリーが見つかりません"
      ],
      "No matching repository sets found": [
        "マッチするリポジトリーセットが見つかりませんでした"
      ],
      "No matching traces found": [
        "マッチするトレースが見つかりませんでした"
      ],
      "No matching version found": [
        "一致するバージョンが見つかりません"
      ],
      "No module stream filter rules yet": [
        ""
      ],
      "No module streams to add yet.": [
        ""
      ],
      "No new packages installed": [
        "インストール済みの新規パッケージはありません"
      ],
      "No package groups yet": [
        ""
      ],
      "No packages": [
        "パッケージがありません"
      ],
      "No packages available to install": [
        "インストール可能なパッケージはありません"
      ],
      "No packages available to install on this host. Please check the host's content view and lifecycle environment.": [
        ""
      ],
      "No packages removed": [
        "削除済みのパッケージはありません"
      ],
      "No packages updated": [
        "更新済みのパッケージはありません"
      ],
      "No pool IDs were provided.": [
        "プール ID は指定されませんでした。"
      ],
      "No pools available": [
        "利用可能なプールがありません"
      ],
      "No pools were provided.": [
        "プールは指定されませんでした。"
      ],
      "No processes require restarting": [
        "プロセスを再起動する必要はありません"
      ],
      "No products are enabled.": [
        "有効な製品はありません。"
      ],
      "No profiles to show": [
        "表示するプロファイルはありません"
      ],
      "No pulp workers running.": [
        "Pulp ワーカーが実行されていません。"
      ],
      "No pulpcore content apps are running at %s.": [
        "%s で実行中の pulpcore コンテンツアプリケーションはありません。"
      ],
      "No pulpcore workers are running at %s.": [
        "%s で実行中の pulpcore ワーカーはありません。"
      ],
      "No recently synced products": [
        "最近同期された製品はありません"
      ],
      "No recurring logic tied to the sync plan.": [
        "同期プランに関連付けられた再帰論理はありません。"
      ],
      "No repositories added yet": [
        ""
      ],
      "No repositories available to add": [
        ""
      ],
      "No repositories available.": [
        "利用可能なリポジトリーがありません。"
      ],
      "No repositories enabled.": [
        "有効なリポジトリーがありません。"
      ],
      "No repositories selected.": [
        "リポジトリーが選択されていません。"
      ],
      "No repositories to show": [
        "表示するリポジトリーはありません"
      ],
      "No repository sets match your search criteria.": [
        "検索条件に一致するリポジトリーセットはありません。"
      ],
      "No repository sets to show.": [
        "表示するリポジトリーセットはありません。"
      ],
      "No rules yet": [
        ""
      ],
      "No services defined, is this class extended?": [
        "サービスが定義されていません。このクラスは拡張されましたか?"
      ],
      "No start time currently available.": [
        "現在選択できる開始時刻はありません。"
      ],
      "No subscriptions match your search criteria.": [
        "検索条件に一致するサブスクリプションはありません。"
      ],
      "No syncable repositories found for selected products and options.": [
        "選択した製品およびオプションに同期可能なリポジトリーが見つかりません。"
      ],
      "No upgradable packages found for search term '%s'.": [
        ""
      ],
      "No upgradable packages found.": [
        ""
      ],
      "No uploads param specified. An array of uploads to import is required.": [
        "アップロードパラメータが指定されていません。インポートするアップロードパラメーターの配列が必要です。"
      ],
      "No versions yet": [
        ""
      ],
      "Non-security errata applicable": [
        "適用可能なセキュリティー以外のエラータ"
      ],
      "Non-security errata installable": [
        "インストール可能なセキュリティー以外のエラータ"
      ],
      "Non-system event": [
        "システム以外のイベント"
      ],
      "None": [
        "なし"
      ],
      "None provided": [
        "指定なし"
      ],
      "Not a number": [
        "数ではない"
      ],
      "Not added": [
        "追加されていません"
      ],
      "Not all necessary pulp workers running at %s.": [
        "必要な Pulp ワーカーすべてが %s で実行されているわけではありません。"
      ],
      "Not installed": [
        "未インストール"
      ],
      "Not running": [
        "実行されていません"
      ],
      "Not yet published": [
        "公開前"
      ],
      "Note: Deleting a subscription manifest is STRONGLY discouraged.": [
        ""
      ],
      "Note: Deleting a subscription manifest is STRONGLY discouraged. Deleting a manifest will:": [
        "注記: サブスクリプションマニフェストを削除することは、決して推奨されません。マニフェストを削除すると、以下のようになります。"
      ],
      "Note: The number in parentheses reflects all applicable errata from the Library environment that are unavailable to the host. You will need to promote this content to the relevant content view in order to make it available.": [
        "注意: カッコ内の数字は、ホストで利用できないライブラリー環境からの適用可能なエラータすべてを反映しています。このコンテンツを適切なコンテンツビューにプロモートして公開できるようにする必要があります。"
      ],
      "Nothing selected": [
        "何も選択されていません"
      ],
      "Number of CPU(s)": [
        "CPU 数"
      ],
      "Number of host applicability calculations to process per task.": [
        "1 回のタスクで処理できるホストに適用可能なエラータ数。"
      ],
      "Number of results per page to return": [
        "ページごとに返される結果数"
      ],
      "Number of results per page to return.": [
        "ページごとに返される結果数"
      ],
      "Number to Allocate": [
        "割り当て数"
      ],
      "OS": [
        ""
      ],
      "OS restricted to {osRestricted}. If host OS does not match, the repository will not be available on this host.": [
        "OS は {osRestricted} に制限されています。ホスト OS が一致しない場合は、このホストでリポジトリーは利用できません。"
      ],
      "OSTree Branch": [
        "OSTree ブランチ"
      ],
      "OSTree Ref": [
        "OSTree 参照"
      ],
      "OSTree Refs": [
        "OSTree 参照"
      ],
      "OSTree ref": [
        "OSTree 参照"
      ],
      "OSTree refs": [
        "OSTree 参照"
      ],
      "Object to show subscriptions available for, either 'host' or 'activation_key'": [
        "'host' または 'activation_key' で使用可能なサブスクリプションを表示するオブジェクト"
      ],
      "On Demand": [
        "オンデマンド"
      ],
      "On the RHUA Instance, check the available repositories.": [
        "RHUA インスタンスで、利用可能なリポジトリーを確認します。"
      ],
      "On-disk location for pulp 3 exported repositories": [
        "Pulp 3 でエクスポートされたリポジトリーのディスク上のロケーション"
      ],
      "Once the prerequisites are met, select a provider to install katello-host-tools-tracer": [
        ""
      ],
      "One of parameters [ %s ] required but not specified.": [
        "[ %s ] パラメーターのいずれかが必要ですが、指定されていません。"
      ],
      "One of yum or docker": [
        "yum または docker のいずれか"
      ],
      "One or more hosts not found": [
        "1 つ以上のホストが見つかりません"
      ],
      "One or more ids (%{ids}) were not found for %{assoc}.  You may not have permissions to see them.": [
        "%{assoc} の (%{ids}) ID 1 つまたは複数が見つかりませんでした。表示する権限がない可能性があります。"
      ],
      "One or more processes require restarting": [
        "1 つ以上のプロセスを再起動する必要があります"
      ],
      "Only On Demand repositories may have space reclaimed.": [
        "オンデマンドリポジトリーにしか再利用する領域がありません。"
      ],
      "Only On Demand smart proxies may have space reclaimed.": [
        "オンデマンド Smart Proxy にしか再利用する領域がありません。"
      ],
      "Only one Red Hat provider permitted for an Organization": [
        "1 つの組織で許容できるのは、Red Hat プロバイダー 1 つのみです"
      ],
      "Only repositories not published in a content view can be disabled. Published repositories must be deleted from the repository details page.": [
        ""
      ],
      "Only returns id and quantity fields": [
        "ID と数量のフィールドのみを返します"
      ],
      "Operators": [
        "演算子"
      ],
      "Organization": [
        "組織"
      ],
      "Organization %s is being deleted.": [
        "組織 %s を削除しています。"
      ],
      "Organization ID": [
        "組織 ID"
      ],
      "Organization ID is required": [
        "組織 ID は必須です"
      ],
      "Organization Information not provided.": [
        "組織情報が提供されていません。"
      ],
      "Organization cannot be blank.": [
        "組織を空白にしないでください。"
      ],
      "Organization id": [
        "組織 ID"
      ],
      "Organization id not found: '%s'": [
        ""
      ],
      "Organization identifier": [
        "組織 ID"
      ],
      "Organization label": [
        "組織ラベル"
      ],
      "Organization label '%s' is ambiguous. Try using an id-based container name.": [
        ""
      ],
      "Organization not found": [
        "組織が見つかりません"
      ],
      "Organization not found: '%s'": [
        ""
      ],
      "Organization required": [
        "必要な組織"
      ],
      "Orphaned Content Protection Time": [
        "単独コンテンツの保護時間"
      ],
      "Orphaned content facets for deleted hosts exist for the content view and environment. Please run rake task : katello:clean_orphaned_facets and try again!": [
        ""
      ],
      "Other": [
        "その他"
      ],
      "Other Content Types": [
        "その他のコンテンツタイプ"
      ],
      "Overridden": [
        "上書き済み"
      ],
      "Override content for activation_key": [
        "activation_key のコンテンツの上書き"
      ],
      "Override key or name. Note if name is not provided the default name will be 'enabled'": [
        "キーまたは名前を上書きします。名前を指定しない場合には、デフォルトの名前が「有効」になる点に留意してください"
      ],
      "Override parameter key or name. Note if name is not provided the default name will be 'enabled'": [
        "パラメーターキーまたは名前を上書きします。名前を指定しない場合には、デフォルトの名前が「有効」になる点に留意してください"
      ],
      "Override the major version number": [
        "メジャーバージョン番号の上書き"
      ],
      "Override the minor version number": [
        "マイナーバージョン番号の上書き"
      ],
      "Override to a boolean value or 'default'": [
        "ブール値またはデフォルトに上書き"
      ],
      "Override to disabled": [
        "無効に上書き"
      ],
      "Override to enabled": [
        "有効に上書き"
      ],
      "Override value. Provide a boolean value if name is 'enabled'": [
        "値を上書きします。名前が「有効」な場合にはブール値を指定します"
      ],
      "Package": [
        "パッケージ"
      ],
      "Package Group": [
        "パッケージグループ"
      ],
      "Package Group Install": [
        "パッケージグループのインストール"
      ],
      "Package Group Install Canceled": [
        "パッケージグループのインストールが取り消されました"
      ],
      "Package Group Install Complete": [
        "パッケージグループのインストールが完了しました"
      ],
      "Package Group Install Failed": [
        "パッケージグループのインストールが失敗しました"
      ],
      "Package Group Install Timed Out": [
        "パッケージグループのインストールがタイムアウトになりました"
      ],
      "Package Group Install scheduled by %s": [
        "%s によりパッケージグループのインストールがスケジュールされました"
      ],
      "Package Group Remove": [
        "パッケージグループの削除"
      ],
      "Package Group Remove Canceled": [
        "パッケージグループの削除が取り消されました"
      ],
      "Package Group Remove Complete": [
        "パッケージグループの削除が完了しました"
      ],
      "Package Group Remove Failed": [
        "パッケージグループの削除が失敗しました"
      ],
      "Package Group Remove Timed Out": [
        "パッケージグループの削除がタイムアウトになりました"
      ],
      "Package Group Remove scheduled by %s": [
        "%s によりパッケージグループの削除がスケジュールされました"
      ],
      "Package Group Update": [
        "パッケージグループの更新"
      ],
      "Package Group Update scheduled by %s": [
        "%s によりパッケージグループの更新がスケジュールされました"
      ],
      "Package Groups": [
        "パッケージグループ"
      ],
      "Package Install": [
        "パッケージのインストール"
      ],
      "Package Install Canceled": [
        "パッケージのインストールが取り消されました"
      ],
      "Package Install Complete": [
        "パッケージのインストールが完了しました"
      ],
      "Package Install Failed": [
        "パッケージのインストールが失敗しました"
      ],
      "Package Install Timed Out": [
        "パッケージのインストールがタイムアウトになりました"
      ],
      "Package Install scheduled by %s": [
        "%s によりパッケージのインストールがスケジュールされました"
      ],
      "Package Remove": [
        "パッケージの削除"
      ],
      "Package Remove Canceled": [
        "パッケージの削除が取り消されました"
      ],
      "Package Remove Complete": [
        "パッケージの削除が完了しました"
      ],
      "Package Remove Failed": [
        "パッケージの削除が失敗しました"
      ],
      "Package Remove Timed Out": [
        "パッケージの削除がタイムアウトになりました"
      ],
      "Package Remove scheduled by %s": [
        "%s によりパッケージの削除がスケジュールされました"
      ],
      "Package Type": [
        "パッケージタイプ"
      ],
      "Package Types": [
        "パッケージタイプ"
      ],
      "Package Update": [
        "パッケージの更新"
      ],
      "Package Update Canceled": [
        "パッケージの更新が取り消されました"
      ],
      "Package Update Complete": [
        "パッケージの更新が完了しました"
      ],
      "Package Update Failed": [
        "パッケージの更新が失敗しました"
      ],
      "Package Update Timed Out": [
        "パッケージの更新がタイムアウトになりました"
      ],
      "Package Update scheduled by %s": [
        "%s によりパッケージの更新がスケジュールされました"
      ],
      "Package group update canceled": [
        "パッケージグループの更新が取り消されました"
      ],
      "Package group update complete": [
        "パッケージグループの更新が完了しました"
      ],
      "Package group update failed": [
        "パッケージグループの更新が失敗しました"
      ],
      "Package group update timed out": [
        "パッケージグループの更新がタイムアウトになりました"
      ],
      "Package groups": [
        "パッケージグループ"
      ],
      "Package identifiers to filter content by": [
        "コンテンツをフィルタリングするためのパッケージ ID"
      ],
      "Package install failed: \\\"%{package}\\\"": [
        "パッケージのインストールが失敗しました: \\\"%{package}\\\""
      ],
      "Package installation: \\\"%{package}\\\" ": [
        "パッケージのインストール: \\\"%{package}\\\" "
      ],
      "Package mode": [
        ""
      ],
      "Package types to sync for Python content, separated by comma. Leave empty to get every package type. Package types are: bdist_dmg,bdist_dumb,bdist_egg,bdist_msi,bdist_rpm,bdist_wheel,bdist_wininst,sdist.": [
        ""
      ],
      "Packages": [
        "パッケージ"
      ],
      "Packages must be provided": [
        "パッケージを指定してください"
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
        "パッケージが利用可能になると、ここに表示されます。"
      ],
      "Page number, starting at 1": [
        "1 から始まるページ番号"
      ],
      "Partition template IDs": [
        "パーティションテンプレート ID"
      ],
      "Password": [
        "パスワード"
      ],
      "Password for authentication. Relevant only for 'upstream_server' type.": [
        "認証用のパスワード。'upstream_server' タイプにのみ必要です。"
      ],
      "Password of the upstream repository user used for authentication": [
        "認証に使用するアップストリームリポジトリーユーザーのパスワード"
      ],
      "Password to access URL": [
        "URL にアクセスするためのパスワード"
      ],
      "Path": [
        "パス"
      ],
      "Path suffixes for finding alternate content": [
        "代替コンテンツを検索するためのパス接尾辞"
      ],
      "Paused": [
        "一時停止中"
      ],
      "Pending tasks detected in repositories of this content view. Please wait for the tasks: ": [
        ""
      ],
      "Perform a module stream action via Katello interface": [
        "Katello インターフェイスでのモジュールストリームアクションの実行"
      ],
      "Perform an Incremental Update on one or more Content View Versions": [
        "1 つ以上のコンテンツビューバージョンで増分更新を実行"
      ],
      "Performs a full-export of a content view version.": [
        "コンテンツビューバージョンの完全なエクスポートを実行します。"
      ],
      "Performs a full-export of the repositories in library.": [
        "ライブラリー内のリポジトリーの完全なエクスポートを実行します。"
      ],
      "Performs a full-export of the repository in library.": [
        "ライブラリー内のリポジトリーの完全なエクスポートを実行します。"
      ],
      "Performs a incremental-export of the repository in library.": [
        "ライブラリー内のリポジトリーの増分エクスポートを実行します。"
      ],
      "Performs an incremental-export of a content view version.": [
        "コンテンツビューバージョンの増分エクスポートを実行します。"
      ],
      "Performs an incremental-export of the repositories in library.": [
        "ライブラリー内のリポジトリーの増分エクスポートを実行します。"
      ],
      "Permission Denied. User '%{user}' does not have permissions to access organization '%{org}'.": [
        "アクセスが拒否されました。ユーザー '%{user}' には組織 '%{org}' にアクセスする権限がありません。"
      ],
      "Physical": [
        "物理"
      ],
      "Plan numeric identifier": [
        "プランの数値 ID"
      ],
      "Please add some repositories.": [
        "リポジトリーを追加してください。"
      ],
      "Please create some content views.": [
        ""
      ],
      "Please enter a positive number above zero": [
        "0 より大きい正の数を入力してください"
      ],
      "Please enter digits only": [
        "数字のみを入力してください"
      ],
      "Please limit number to 10 digits": [
        "数字を 10 桁に制限してください"
      ],
      "Please select a content source before assigning a kickstart repository": [
        "Kickstart リポジトリーを割り当てる前にコンテンツソースを選択してください"
      ],
      "Please select a lifecycle environment and a content view to move these activation keys.": [
        "これらのアクティベーションキーを移動するには、ライフサイクル環境とコンテンツビューを選択してください。"
      ],
      "Please select a lifecycle environment and a content view to move this activation key.": [
        "このアクティベーションキーを移動するには、ライフサイクル環境とコンテンツビューを選択してください。"
      ],
      "Please select a lifecycle environment and content view to view activation keys.": [
        ""
      ],
      "Please select an architecture before assigning a kickstart repository": [
        "Kickstart リポジトリーを割り当てる前にアーキテクチャーを選択してください"
      ],
      "Please select an operating system before assigning a kickstart repository": [
        "Kickstart リポジトリーを割り当てる前にオペレーティングシステムを選択してください"
      ],
      "Please select one from the list below and you will be redirected.": [
        "以下のリストから 1 つ選択してください。リダイレクトされます。"
      ],
      "Please wait while the task starts..": [
        "タスクが開始されるまでお持ちください.."
      ],
      "Please wait...": [
        "お待ちください..."
      ],
      "Policy to set for mirroring content.  Must be one of %s.": [
        "コンテンツのミラーリングに設定するポリシー。%s のいずれかでなければなりません。"
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
        "今後の更新を回避"
      ],
      "Prior Content View Version specified in the metadata - '%{name}' does not exist. Please import the metadata for '%{name}' before importing '%{current}' ": [
        "メタデータ '%%{name}' で指定された以前のコンテンツビューバージョンは存在しません。'%%{current}' をインポートする前に、'%%{name}' のメタデータをインポートしてください。 "
      ],
      "Problem searching": [
        "検索中に問題が発生しました"
      ],
      "Problem searching errata": [
        "エラータの検索中に問題が発生しました"
      ],
      "Problem searching host collections": [
        "ホストコレクションの検索中に問題が発生しました"
      ],
      "Problem searching module streams": [
        "モジュールストリームの検索中に問題が発生しました"
      ],
      "Problem searching packages": [
        "パッケージの検索中に問題が発生しました"
      ],
      "Problem searching repository sets": [
        "リポジトリーセットの検索中に問題が発生しました"
      ],
      "Problem searching traces": [
        "トレースの検索中に問題が発生しました"
      ],
      "Product": [
        "製品"
      ],
      "Product Content": [
        "製品コンテンツ"
      ],
      "Product Create": [
        "製品の作成"
      ],
      "Product Host Count": [
        ""
      ],
      "Product ID": [
        "製品 ID"
      ],
      "Product ID to mirror the remote repository to": [
        ""
      ],
      "Product and Repositories": [
        "製品およびリポジトリー"
      ],
      "Product architecture": [
        "製品アーキテクチャー"
      ],
      "Product description": [
        "製品の説明"
      ],
      "Product id as listed from a host's installed products, \\\\\\n        this is not the same product id as the products api returns": [
        "ホストのインストール済み製品からリストされた製品 ID。\\\\\\n        製品 API が返した製品 ID とは異なります。"
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
        "製品名"
      ],
      "Product name as listed from a host's installed products": [
        "ホストのインストール済み製品からリストされた製品名"
      ],
      "Product not found: '%s'": [
        ""
      ],
      "Product the repository belongs to": [
        "リポジトリーが属する製品"
      ],
      "Product version": [
        "製品バージョン"
      ],
      "Product with ID %s not found in Candlepin. Skipping content import for it.": [
        "Candlepin で、ID が %s の製品が見つかりません。コンテンツのインポートをスキップします。"
      ],
      "Product: '%{product}', Repository: '%{repository}'": [
        "* 製品 = '%%{product}'、リポジトリー = '%%{repository}'"
      ],
      "Product: '%{product}', Repository: '%{repo}' ": [
        "製品: '%%{product}'、リポジトリー: '%%{repo}' "
      ],
      "Products": [
        "製品"
      ],
      "Products updated.": [
        "製品が更新されました。"
      ],
      "Profiles": [
        "プロファイル"
      ],
      "Promote": [
        "プロモート"
      ],
      "Promote a content view version": [
        "コンテンツビューバージョンのプロモート"
      ],
      "Promote errata": [
        "エラータのプロモート"
      ],
      "Promote version ${versionNameToPromote}": [
        "バージョン {versionNameToPromote} のプロモート"
      ],
      "Promoted to ": [
        "プロモート先 "
      ],
      "Promoted to %{environment}": [
        "%{environment} にプロモート"
      ],
      "Promotion Summary": [
        "プロモートの概要"
      ],
      "Promotion Summary for %{content_view}": [
        "{content_view} のプロモートの概要"
      ],
      "Promotion to Environment": [
        "環境へのプロモート"
      ],
      "Provide the required information and click {update} below to save changes.": [
        "必要な情報を指定し、{update} をクリックして変更を保存します。"
      ],
      "Provided Products": [
        "指定の製品"
      ],
      "Provided pool with id %s has no upstream entitlement": [
        "ID が %s の指定のプールには、アップストリームのエンタイトルメントがありません"
      ],
      "Provisioning template IDs": [
        "プロビジョニングテンプレート ID"
      ],
      "Proxies": [
        "プロキシー"
      ],
      "Proxy sync failure": [
        ""
      ],
      "Public": [
        "公開"
      ],
      "Public key block in DER encoding or certificate content": [
        "DER エンコードまたは証明書コンテンツの公開鍵ブロック"
      ],
      "Publish": [
        "公開"
      ],
      "Publish Lifecycle Environment Container Repositories": [
        ""
      ],
      "Publish a content view": [
        "コンテンツビューの公開"
      ],
      "Publish new version": [
        "新規バージョンの公開"
      ],
      "Publish new version - ": [
        "新規バージョンの公開 - "
      ],
      "Published date": [
        "公開日"
      ],
      "Published new version": [
        "新規バージョンを公開しました"
      ],
      "Publishing ${truncate(name)}": [
        ""
      ],
      "Publishing content view": [
        "コンテンツビューの公開"
      ],
      "Pulp": [
        "Pulp"
      ],
      "Pulp 3 export destination filepath": [
        "Pulp 3 のエクスポート先のファイルパス"
      ],
      "Pulp 3 is not enabled on Smart proxy!": [
        "Pulp 3 は Smart Proxy で有効になっていません!"
      ],
      "Pulp bulk load size": [
        "Pulp 一括読み込みサイズ"
      ],
      "Pulp database connection issue at %s.": [
        "%s で Pulp データベース接続の問題が発生しています。"
      ],
      "Pulp database connection issue.": [
        "Pulp データベース接続の問題。"
      ],
      "Pulp disk space notification": [
        "Pulp ディスク容量の通知"
      ],
      "Pulp does not appear to be running at %s.": [
        "Pulp が %s で実行されていないようです。"
      ],
      "Pulp does not appear to be running.": [
        "Pulp が実行されていないようです。"
      ],
      "Pulp message bus connection issue at %s.": [
        "%s で Pulp メッセージバス接続の問題が発生しています。"
      ],
      "Pulp message bus connection issue.": [
        "Pulp メッセージバス接続の問題。"
      ],
      "Pulp node": [
        "Pulp ノード"
      ],
      "Pulp redis connection issue at %s.": [
        "%s で Pulp redis 接続の問題が発生しています。"
      ],
      "Pulp server version": [
        "Pulp サーバーバージョン"
      ],
      "Pulp storage": [
        "Pulp ストレージ"
      ],
      "Pulp task error": [
        "Pulp タスクのエラー"
      ],
      "Python Package": [
        "Python パッケージ"
      ],
      "Python Packages": [
        "Python パッケージ"
      ],
      "Python package": [
        "Python パッケージ"
      ],
      "Python packages": [
        "Python パッケージ"
      ],
      "Python packages to exclude from the upstream URL, names separated by newline. You may also specify versions, for example: django~=2.0.": [
        "アップストリームの URLから除外する Python パッケージ (1 行ごとに名前を指定)。バージョンを指定することもできます (例: django~=2.0)。"
      ],
      "Python packages to include from the upstream URL, names separated by newline. You may also specify versions, for example: django~=2.0. Leave empty to include every package.": [
        "アップストリームの URLから追加する Python パッケージ (1 行ごとに名前を指定)。バージョンを指定することもできます (例: django~=2.0)。すべてのパッケージを含めるには空白のままにします。"
      ],
      "Quantity": [
        "数量"
      ],
      "Quantity must not be above ${pool.available}": [
        "数量は ${pool.available} を超えてはいけません"
      ],
      "Quantity of entitlements to bind": [
        "バインドするエンタイトルメント数"
      ],
      "Quantity of specified subscription to remove": [
        "削除する指定のサブスクリプションの数"
      ],
      "Quantity of this subscription to add": [
        "追加するこのサブスクリプションの数量"
      ],
      "Quantity of this subscriptions to add": [
        "追加するこのサブスクリプションの数量"
      ],
      "Quantity to Allocate": [
        "割り当て数"
      ],
      "RAM": [
        "RAM"
      ],
      "RAM: %s GB": [
        "メモリー: %s GB"
      ],
      "RH Repos": [
        "RH レポジトリー"
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
        "RPM パッケージグループ"
      ],
      "RPM Packages": [
        "RPM パッケージ"
      ],
      "RPM name": [
        "RPM 名"
      ],
      "RPM package groups": [
        "RPM パッケージグループ"
      ],
      "RPM package updates": [
        "RPM パッケージの更新"
      ],
      "RPM packages": [
        "RPM パッケージ"
      ],
      "RPMs": [
        "RPM"
      ],
      "Range": [
        "範囲"
      ],
      "Realm IDs": [
        "レルム ID"
      ],
      "Reassign affected activation key": [
        "影響を受けるアクティベーションキーの再割り当て"
      ],
      "Reassign affected activation keys": [
        "影響を受けるアクティベーションキーの再割り当て"
      ],
      "Reassign affected host": [
        "影響を受けるホストの再割り当て"
      ],
      "Reassign affected hosts": [
        "影響を受けるホストの再割り当て"
      ],
      "Reboot host": [
        ""
      ],
      "Reboot required": [
        "再起動が必要です"
      ],
      "Reclaim Space": [
        "領域の再利用"
      ],
      "Reclaim space from On Demand repositories": [
        "オンデマンドリポジトリーからの領域の再利用"
      ],
      "Reclaim space from all On Demand repositories on a smart proxy": [
        "Smart Proxy の全オンデマンドリポジトリーからの領域の再利用"
      ],
      "Reclaim space from an On Demand repository": [
        "オンデマンドリポジトリーからの領域の再利用"
      ],
      "Recommended Repositories": [
        "推奨リポジトリー"
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
        "Red Hat リポジトリー"
      ],
      "Red Hat Repositories page": [
        "Red Hat リポジトリーページ"
      ],
      "Red Hat content will be consumed from an {type}.": [
        "Red Hat コンテンツは、{type} から使用されます。"
      ],
      "Red Hat content will be consumed from the {type}.": [
        "Red Hat コンテンツは、{type} から使用されます。"
      ],
      "Red Hat content will be consumed from {type}.": [
        "Red Hat コンテンツは、{type} から使用されます。"
      ],
      "Red Hat content will be enabled and consumed via the {type} process.": [
        "Red Hat コンテンツは有効化され、{type} プロセスを介して使用されます。"
      ],
      "Red Hat products cannot be manipulated.": [
        "Red Hat 製品を操作することはできません。"
      ],
      "Red Hat provider can not be deleted": [
        "Red Hat プロバイダーは削除できません"
      ],
      "Red Hat repositories cannot be manipulated.": [
        "Red Hat リポジトリーを操作することはできません。"
      ],
      "Refresh": [
        "更新"
      ],
      "Refresh Alternate Content Source": [
        "代替コンテンツソースの更新"
      ],
      "Refresh Content Host Statuses for %s": [
        "%s のコンテンツホストステータスのリフレッシュ"
      ],
      "Refresh Manifest": [
        "マニフェストの更新"
      ],
      "Refresh all alternate content sources": [
        ""
      ],
      "Refresh alternate content sources": [
        "代替コンテンツソースの更新"
      ],
      "Refresh an alternate content source. Refreshing, like repository syncing, is required before using an alternate content source.": [
        "代替コンテンツソースを更新します。代替コンテンツソースを使用する前に、リポジトリーの同期などの更新が必要になります。"
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
        "Red Hat プロバイダーの以前にインポートされたマニフェストを更新"
      ],
      "Refresh source": [
        "ソースの更新"
      ],
      "Refresh_Content_Host_Status": [
        "コンテンツホストステータスのリフレッシュ"
      ],
      "Register a host with subscription and information": [
        "サブスクリプションと情報を使用したホスト登録"
      ],
      "Register host '%s' before attaching subscriptions": [
        "サブスクリプションをアタッチする前にホスト '%s' を登録してください"
      ],
      "Registered": [
        "登録済み"
      ],
      "Registered at": [
        ""
      ],
      "Registered by": [
        "以下で登録済み:"
      ],
      "Registered on": [
        "登録先"
      ],
      "Registered to": [
        ""
      ],
      "Registering to multiple environments is not enabled.": [
        ""
      ],
      "Registration details": [
        "登録の詳細"
      ],
      "Registry name pattern results in duplicate container image names for these repositories: %s.": [
        "レジストリー名のパターンが原因で、以下のリポジトリーのコンテナーイメージ名が重複します: %s。"
      ],
      "Registry name pattern results in invalid container image name of member repository '%{name}'": [
        "レジストリー名のパターンが原因で、メンバーリポジトリー '%{name}' のコンテナーイメージ名が無効です"
      ],
      "Registry name pattern will result in invalid container image name of member repositories": [
        "レジストリー名のパターンが原因で、メンバーリポジトリーのコンテナーイメージ名が無効になります"
      ],
      "Related composite content views": [
        "関連する複合コンテンツビュー"
      ],
      "Related composite content views: ": [
        "関連する複合コンテンツビュー:"
      ],
      "Related content views": [
        "関連するコンテンツビュー"
      ],
      "Related content views will appear here when created.": [
        "関連するコンテンツビューが作成されると、ここに表示されます。"
      ],
      "Related content views: ": [
        "関連するコンテンツビュー:"
      ],
      "Release": [
        "リリース"
      ],
      "Release version": [
        "リリースバージョン"
      ],
      "Release version for this Host to use (7Server, 7.1, etc)": [
        "このホストが使用するリリースバージョン (7Server、7.1 など)"
      ],
      "Release version of the content host": [
        "コンテンツホストのリリースバージョン"
      ],
      "Releasever to disable": [
        "無効にする Releasever"
      ],
      "Releasever to enable": [
        "有効にする Releasever"
      ],
      "Reload data": [
        "データの再読み込み"
      ],
      "Remote execution is enabled.": [
        ""
      ],
      "Remote execution job '${description}' failed.": [
        "リモート実行ジョブ '${description}' が失敗しました。"
      ],
      "Remove": [
        "削除"
      ],
      "Remove Content": [
        "コンテンツの削除"
      ],
      "Remove Version": [
        "バージョンの削除"
      ],
      "Remove Versions and Associations": [
        "バージョンおよび関連付けの削除"
      ],
      "Remove a content view from an environment": [
        "環境からコンテンツビューを削除します"
      ],
      "Remove any `katello-ca-consumer` rpms before registration and run subscription-manager with `--force` argument.": [
        "登録前に `katello-ca-consumer` rpm を削除し、`--force` 引数を指定して subscription-manager を実行します。"
      ],
      "Remove components from the content view": [
        "コンテンツビューからコンポーネントを削除します"
      ],
      "Remove content view version": [
        "コンテンツビューバージョンの削除"
      ],
      "Remove from Environment": [
        "環境からの削除"
      ],
      "Remove from environment": [
        "環境からの削除"
      ],
      "Remove from environments": [
        "環境からの削除"
      ],
      "Remove host from collections": [
        "コレクションからホストを削除"
      ],
      "Remove host from host collections": [
        "ホストコレクションからホストを削除"
      ],
      "Remove hosts from the host collection": [
        "ホストコレクションからホストを削除します"
      ],
      "Remove lifecycle environments from the smart proxy": [
        "ライフサイクル環境を Smart Proxy から削除します"
      ],
      "Remove module stream": [
        "モジュールストリームの削除"
      ],
      "Remove one or more host collections from one or more hosts": [
        "1 つ以上のホストから 1 つ以上のコンテンツコレクションを削除します"
      ],
      "Remove one or more subscriptions from an upstream manifest": [
        "アップストリームマニフェストから 1 つ以上のサブスクリプションを削除します"
      ],
      "Remove package group via Katello interface": [
        "Katello インターフェイスでのパッケージグループの削除"
      ],
      "Remove package via Katello interface": [
        "Katello インターフェイスでのパッケージの削除"
      ],
      "Remove packages": [
        ""
      ],
      "Remove packages via Katello interface": [
        "Katello インターフェイスでのパッケージの削除"
      ],
      "Remove products from sync plan": [
        "同期プランから製品を削除"
      ],
      "Remove subscriptions": [
        "サブスクリプションの削除"
      ],
      "Remove subscriptions from %s": [
        "%s からのサブスクリプション削除"
      ],
      "Remove subscriptions from a host": [
        ""
      ],
      "Remove subscriptions from one or more hosts": [
        "1 つ以上のホストからサブスクリプションを削除します"
      ],
      "Remove versions and/or environments from a content view and reassign systems and keys": [
        "コンテンツビューからバージョンおよび/または環境を削除し、システムおよびキーを再度割り当てます"
      ],
      "Remove versions from environments": [
        "環境からのバージョンの削除"
      ],
      "Removed component from content view": [
        "コンテンツビューからコンポーネントを削除しました"
      ],
      "Removed components from content view": [
        "コンテンツビューからコンポーネントを削除しました"
      ],
      "Removing Package Group...": [
        "パッケージグループを削除しています..."
      ],
      "Removing Package...": [
        "パッケージを削除しています..."
      ],
      "Removing product %{prod_name} with ID %{prod_id} from ACS %{acs_name} with ID %{acs_id}": [
        "ID が %{acs_id} の ACS %{acs_name} から ID が %{prod_id} の製品 %{prod_name} を削除します"
      ],
      "Removing this version from all environments will not delete the version. Version will still be available for later promotion.": [
        "すべての環境からこのバージョンを削除しても、バージョンは削除されません。バージョンは引き続き以降のプロモーションの対象になります。"
      ],
      "Replace content source on the target machine": [
        ""
      ],
      "Repo ID": [
        ""
      ],
      "Repo Type": [
        "リポジトリータイプ"
      ],
      "Repo label": [
        ""
      ],
      "Repositories": [
        "リポジトリー"
      ],
      "Repositories are not available for enablement while CDN configuration is set to Air-gapped (disconnected).": [
        "CDN 設定がエアギャップ (切断) に設定されている間、リポジトリーは有効にできません。"
      ],
      "Repositories common to the selected content view versions will merge, resulting in a composite content view that is a union of all content from each of the content view versions.": [
        ""
      ],
      "Repositories from published Content Views are not allowed.": [
        "公開されたコンテンツビューからのリポジトリーは許可されません。"
      ],
      "Repository": [
        "リポジトリー"
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
        "リポジトリー '%(repoName)s' が無効化されました。"
      ],
      "Repository '%(repoName)s' has been enabled.": [
        "リポジトリー '%(repoName)s' が有効化されました"
      ],
      "Repository ID": [
        ""
      ],
      "Repository Id associated with the kickstart repo used for provisioning": [
        "プロビジョニングに使用する Kickstart リポジトリーに関連付けられたリポジトリー ID"
      ],
      "Repository cannot be deleted since it has already been included in a published Content View. Please delete all Content View versions containing this repository before attempting to delete it or use --remove-from-content-view-versions flag to automatically remove the repository from all published versions.": [
        ""
      ],
      "Repository cannot be disabled since it has already been promoted.": [
        "リポジトリーはすでにプロモート済みのため無効にできません。"
      ],
      "Repository has already been cloned to %{cv_name} in environment %{to_env}": [
        "リポジトリーのクローンはすでに環境 %{to_env} の %{cv_name} に作成されています。"
      ],
      "Repository id": [
        "リポジトリー ID"
      ],
      "Repository identifier": [
        "リポジトリー ID"
      ],
      "Repository label '%s' is not associated with content view.": [
        "コンテンツビューには、リポジトリーラベル '%s' が関連付けられていません。"
      ],
      "Repository name": [
        ""
      ],
      "Repository name '%{container_name}' already exists in this product using a different naming scheme. Please retry your request with the %{root_repo_container_push_name} format or destroy and recreate the repository using your preferred schema.": [
        ""
      ],
      "Repository not found": [
        "リポジトリーが見つかりません"
      ],
      "Repository path": [
        "リポジトリーのパス"
      ],
      "Repository set disabled": [
        "リポジトリーセットが無効です"
      ],
      "Repository set enabled": [
        "リポジトリーセットが有効です"
      ],
      "Repository set name to search on": [
        "検索するリポジトリーセット名"
      ],
      "Repository set reset to default": [
        "リポジトリーセットがデフォルトにリセットされました"
      ],
      "Repository sets": [
        "リポジトリーセット"
      ],
      "Repository sets are not available for custom products.": [
        "リポジトリーセットはカスタム製品で利用できません。"
      ],
      "Repository sets disabled": [
        "リポジトリーセットが無効です"
      ],
      "Repository sets enabled": [
        "リポジトリーセットが有効です"
      ],
      "Repository sets reset to default": [
        "リポジトリーセットがデフォルトにリセットされました"
      ],
      "Repository sets will appear here after enabling Red Hat repositories or creating custom products.": [
        "リポジトリーセットは、Red Hat リポジトリーを有効にしたり、カスタム製品を作成したりすると、ここに表示されます。"
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
        "%{name}%{version} のリポジトリーの再公開"
      ],
      "Republish Version Repositories": [
        "バージョンリポジトリーの再公開"
      ],
      "Republish repository metadata": [
        ""
      ],
      "Requested access to '%s' is denied": [
        ""
      ],
      "Require you to upload the subscription-manifest and re-attach subscriptions to hosts and activation keys.": [
        "subscription-manifest をアップロードし、サブスクリプションをホストおよびアクティベーションキーに再度アタッチする必要があります。"
      ],
      "Requirements is not valid yaml.": [
        "要件は有効な yaml ではありません。"
      ],
      "Requirements yaml should be a key-value pair structure.": [
        "要件 yaml はキー/値のペアの構成でなければなりません。"
      ],
      "Requirements yaml should have a 'collections' key": [
        "要件 yaml には「collections」キーが必要です"
      ],
      "Requires Virt-Who": [
        "Virt-Who が必要です"
      ],
      "Reset": [
        "リセット"
      ],
      "Reset filters": [
        "フィルターのリセット"
      ],
      "Reset module stream": [
        "モジュールストリームのリセット"
      ],
      "Reset to default": [
        "デフォルトにリセット"
      ],
      "Reset to the default state": [
        "デフォルト状態にリセット"
      ],
      "Resolve traces": [
        "トレースの解決"
      ],
      "Resolve traces for one or more hosts": [
        "1 台以上のホストのトレースを解決する"
      ],
      "Resolve traces via Katello interface": [
        "Katello インターフェイスでのトレースの解決"
      ],
      "Resource": [
        "リソース"
      ],
      "Restart Services via Katello interface": [
        "Katello インターフェイスでのサービスの再起動"
      ],
      "Restart app": [
        "アプリケーションの再起動"
      ],
      "Restart via customized remote execution": [
        "カスタマイズされたリモート実行による再起動"
      ],
      "Restart via remote execution": [
        "リモート実行による再起動"
      ],
      "Restrict composite content view promotion": [
        "複合コンテンツビューのプロモートの制限"
      ],
      "Result": [
        "結果"
      ],
      "Retrieve a single errata for a host": [
        "ホストに関するエラータを 1 つ取得する"
      ],
      "Return Red Hat (non-custom) products only": [
        "Red Hat (カスタム以外) 製品のみを返します"
      ],
      "Return a list of installed packages distinct by name": [
        ""
      ],
      "Return content that can be added to the specified object.  The values 'content_view_version' and 'content_view_filter are supported.": [
        "指定のオブジェクトに追加可能なコンテンツを返します。'content_view_version' と 'content_view_filter' の値がサポートされます。"
      ],
      "Return custom products only": [
        "カスタム製品のみを返します"
      ],
      "Return deb packages that are applicable to one or more hosts (defaults to true if host_id is specified)": [
        "1 つまたは複数のホストに適用可能な deb パッケージを返します (host_id が指定されている場合のデフォルトは True です)"
      ],
      "Return deb packages that are upgradable on one or more hosts": [
        "1 つまたは複数のホストでアップグレード可能な deb パッケージを返します"
      ],
      "Return deb packages that can be added to the specified object.  Only the value 'content_view_version' is supported.": [
        "指定のオブジェクトに追加可能な deb パッケージを返します。'content_view_version' の値のみがサポートされます。"
      ],
      "Return enabled products only": [
        "有効な製品のみを返します"
      ],
      "Return errata that are applicable to one or more hosts (defaults to true if host_id is specified)": [
        "1 つ以上のホストに適用可能なエラータを返します (host_id が指定されている場合のデフォルトは True です)"
      ],
      "Return errata that are applicable to this host. Defaults to false)": [
        "このホストに適用可能なエラータを返します。デフォルトは false です。"
      ],
      "Return errata that are upgradable on one or more hosts": [
        "1 つ以上のホストでアップグレード可能なエラータを返します"
      ],
      "Return errata that can be added to the specified object.  The values 'content_view_version' and 'content_view_filter are supported.": [
        "指定のオブジェクトに追加可能なエラータを返します。'content_view_version' と 'content_view_filter' の値がサポートされます。"
      ],
      "Return name and stream information only)": [
        "名前とストリーム情報のみを返します)"
      ],
      "Return only errata of a particular severity (None, Low, Moderate, Important, Critical)": [
        "特定の重大度 (影響なし、低、中程度、重要、重大) のエラータのみを返します"
      ],
      "Return only errata of a particular type (security, bugfix, enhancement)": [
        "特定タイプ (セキュリティー、バグ修正、機能拡張) のエラータのみを返します"
      ],
      "Return only packages of a particular status (upgradable or up-to-date)": [
        "特定ステータス (アップグレード可能または最新) のパッケージのみを返します"
      ],
      "Return only subscriptions which can be attached to the upstream allocation": [
        "アップストリーム割り当てにアタッチ可能なサブスクリプションのみを返します"
      ],
      "Return only the latest version of each package": [
        "各パッケージの最新バージョンのみを返します"
      ],
      "Return only the upstream pools which map to the given Katello pool IDs": [
        "指定の Katello プール ID にマッピングするアップストリームプールのみを返します"
      ],
      "Return packages that are applicable to one or more hosts (defaults to true if host_id is specified)": [
        "1 つ以上のホストに適用可能なパッケージを返します (host_id が指定されている場合のデフォルトは True です)"
      ],
      "Return packages that are upgradable on one or more hosts": [
        "1 つ以上のホストでアップグレード可能なパッケージを返します"
      ],
      "Return packages that can be added to the specified object.  Only the value 'content_view_version' is supported.": [
        "指定のオブジェクトに追加可能なパッケージを返します。'content_view_version' の値のみがサポートされます。"
      ],
      "Return same, different or all results": [
        "同じ結果、異なる結果またはすべての結果を返します"
      ],
      "Return subscriptions that match installed products of the specified host": [
        "指定されたホストのインストール済み製品に一致するサブスクリプションを返します"
      ],
      "Return subscriptions which do not overlap with a currently-attached subscription": [
        "現在割り当てられているサブスクリプションと重複しないサブスクリプションを返します"
      ],
      "Return the content of a Content Credential, used directly by yum": [
        "yum で直接使用されるコンテンツ認証情報のコンテンツを返します"
      ],
      "Return the content of a repo gpg key, used directly by yum": [
        "yum で直接使用されるリポジトリー GPG キーのコンテンツを返します"
      ],
      "Return the enabled content types": [
        "有効なコンテンツタイプを返します"
      ],
      "Returns content that can be both added and is currently added to the object. The value 'content_view_filter' is supported": [
        "両方とも追加可能で、現在オブジェクトに追加されているコンテンツを返します。値 'content_view_filter' がサポートされています"
      ],
      "Review": [
        ""
      ],
      "Review affected environment": [
        "影響を受ける環境の確認"
      ],
      "Review affected environments": [
        "影響を受ける環境を確認"
      ],
      "Review and optionally exclude hosts from your selection.": [
        ""
      ],
      "Review and then click {submitBtnText}.": [
        ""
      ],
      "Review details": [
        "詳細を確認"
      ],
      "Review hosts": [
        ""
      ],
      "Review the information below and click ": [
        "以下の情報を確認して、次をクリック: "
      ],
      "Review your currently selected changes for ": [
        "現在選択されている変更内容の確認 "
      ],
      "Role": [
        "ロール"
      ],
      "Role of host": [
        "ホストのロール"
      ],
      "Roles": [
        "ロール"
      ],
      "Rollback image": [
        ""
      ],
      "Rollback image digest": [
        ""
      ],
      "Rules to be added": [
        "追加するルール"
      ],
      "Run Sync Plan:": [
        "同期プランの実行:"
      ],
      "Run job invocation": [
        ""
      ],
      "Running": [
        "実行中"
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
        "SRPM の詳細"
      ],
      "SSL CA Content Credential": [
        "SSL CA コンテンツ認証情報"
      ],
      "SSL CA certificate": [
        "SSL CA 証明書"
      ],
      "SSL client certificate": [
        "SSL クライアント証明書"
      ],
      "SSL client key": [
        "SSL クライアントキー"
      ],
      "SUBSCRIPTIONS EXPIRING SOON": [
        "まもなく期限切れになるサブスクリプション"
      ],
      "Save": [
        "保存"
      ],
      "Saving alternate content source...": [
        "代替コンテンツソースの保存"
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
        "検索"
      ],
      "Search Query": [
        "検索クエリー"
      ],
      "Search available Debian packages": [
        ""
      ],
      "Search available packages": [
        "利用可能なパッケージの検索"
      ],
      "Search host collections": [
        "ホストコレクションの検索"
      ],
      "Search pattern (defaults to '*')": [
        "検索パターン (デフォルトは '*')"
      ],
      "Search string": [
        "検索文字列"
      ],
      "Search string for erratum to perform an action on": [
        "アクションを実行するエラータの検索文字列"
      ],
      "Search string for host to perform an action on": [
        "アクションを実行するホストの検索文字列"
      ],
      "Search string for hosts to perform an action on": [
        "アクションを実行するホストの検索文字列"
      ],
      "Search string for versions to perform an action on": [
        "アクションを実行するバージョンの検索文字列"
      ],
      "Security": [
        "セキュリティー"
      ],
      "Security errata applicable": [
        "適用可能なセキュリティーエラータ"
      ],
      "Security errata installable": [
        "インストール可能なセキュリティーエラータ"
      ],
      "Select": [
        "選択"
      ],
      "Select ...": [
        "選択..."
      ],
      "Select All": [
        "すべてを選択"
      ],
      "Select Content View": [
        "コンテンツビューの選択"
      ],
      "Select None": [
        "すべてを選択解除"
      ],
      "Select Organization": [
        "組織の選択"
      ],
      "Select Value": [
        "値の選択"
      ],
      "Select a CA certificate": [
        "CA 証明書の選択"
      ],
      "Select a client certificate": [
        "クライアント証明書の選択"
      ],
      "Select a client key": [
        "クライアントキーの選択"
      ],
      "Select a content source first": [
        ""
      ],
      "Select a content view": [
        "コンテンツビューの選択"
      ],
      "Select a lifecycle environment and a content view to move these hosts.": [
        "これらのホストを移動するには、ライフサイクル環境とコンテンツビューを選択してください。"
      ],
      "Select a lifecycle environment and a content view to move this host.": [
        "このホストを移動するには、ライフサイクル環境とコンテンツビューを選択してください。"
      ],
      "Select a lifecycle environment first": [
        ""
      ],
      "Select a lifecycle environment from the available promotion paths to promote new version.": [
        "利用可能なプロモーションパスからライフサイクル環境を選択し、新しいバージョンをプロモートします。"
      ],
      "Select a provider to install katello-host-tools-tracer": [
        "katello-host-tools-tracer をインストールするプロバイダーの選択"
      ],
      "Select a source": [
        ""
      ],
      "Select action": [
        ""
      ],
      "Select all": [
        "すべてを選択"
      ],
      "Select all rows": [
        "すべての行を選択"
      ],
      "Select an Organization": [
        "組織の選択"
      ],
      "Select an environment": [
        "環境の選択"
      ],
      "Select an option": [
        "オプションの選択"
      ],
      "Select an organization": [
        "組織の選択"
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
        "使用するコンテンツビューの利用可能なバージョンの選択"
      ],
      "Select content view": [
        "コンテンツビューの選択"
      ],
      "Select environment": [
        "環境の選択"
      ],
      "Select errata": [
        ""
      ],
      "Select errata to apply on the selected hosts. Some errata may already be applied on some hosts.": [
        ""
      ],
      "Select host collection(s) to associate with host {hostName}.": [
        "ホスト {hostName} に関連付けるホストコレクションを選択します。"
      ],
      "Select host collection(s) to remove from host {hostName}.": [
        "ホスト {hostName} から削除するホストコレクションを選択します。"
      ],
      "Select hosts to assign to %s": [
        "ホストを選択して %s に割り当てます"
      ],
      "Select lifecycle environment": [
        "ライフサイクル環境の選択"
      ],
      "Select none": [
        "すべての選択を解除"
      ],
      "Select one": [
        "1 つを選択"
      ],
      "Select packages to install on the selected hosts. Some packages may already be installed on some hosts.": [
        ""
      ],
      "Select packages to install to the host {hostName}.": [
        "ホスト {hostName} にインストールするパッケージを選択します。"
      ],
      "Select packages to remove on the selected hosts.": [
        ""
      ],
      "Select packages to upgrade to the latest version. Packages may have different versions on different hosts.": [
        ""
      ],
      "Select page": [
        "ページの選択"
      ],
      "Select products": [
        "製品の選択"
      ],
      "Select products to associate to this source.": [
        "このソースに関連付ける製品を選択します。"
      ],
      "Select row": [
        "行の選択"
      ],
      "Select smart proxies to be used with this source.": [
        "このソースで使用する Smart Proxy を選択します。"
      ],
      "Select smart proxy": [
        "Smart Proxy の選択"
      ],
      "Select source type": [
        "ソースタイプの選択"
      ],
      "Select system purpose attributes for activation key {name}.": [
        ""
      ],
      "Select system purpose attributes for host {name}.": [
        ""
      ],
      "Select the installation media that will be used to provision this host. Choose 'Synced Content' for Synced Kickstart Repositories or 'All Media' for other media.": [
        "このホストのプロビジョニングに使用するインストールメディアを選択してください。同期済みの Kickstart リポジトリーには「同期済みコンテンツ」を、他のメディアには「全メディア」を選択してください。"
      ],
      "Selected environment ": [
        "選択済みの環境 "
      ],
      "Selected environments ": [
        "選択済みの環境 "
      ],
      "Selected errata will be applied on {hostCount} hosts": [
        ""
      ],
      "Selected packages will be {submitAction} on {hostCount} hosts": [
        ""
      ],
      "Sending a list of included IDs is not allowed when all items are being selected.": [
        "すべての項目が選択されている場合、含まれる ID の一覧を送信することはできません。"
      ],
      "Service Level %s": [
        "サービスレベル %s"
      ],
      "Service Level (SLA)": [
        "サービスレベル (SLA)"
      ],
      "Service level of host": [
        "ホストのサービスレベル"
      ],
      "Service level to be used for autoheal": [
        "自動修復に使用されるサービスレベル"
      ],
      "Set content overrides for the host": [
        "ホストのコンテンツ上書きの設定"
      ],
      "Set content overrides to one or more hosts": [
        "1 台以上のホストにコンテンツ上書きを設定します"
      ],
      "Set this HTTP proxy as the default content HTTP proxy": [
        ""
      ],
      "Set true to override to enabled; Set false to override to disabled.'": [
        "true に設定するとオーバーライドが有効になり、false に設定するとオーバーライドが無効になります。"
      ],
      "Set true to remove an override and reset it to 'default'": [
        "上書きを削除して「デフォルト」にリセットするには True に設定します"
      ],
      "Sets the system purpose usage": [
        "システム目的の使用率を設定します"
      ],
      "Sets whether the Host will autoheal subscriptions upon checkin": [
        "ホストがチェックイン時にサブスクリプションを自動修復するかどうかを設定します"
      ],
      "Setting 'default_location_subscribed_hosts' is not set to a valid location.": [
        "'default_location_subscribed_hosts' 設定は、有効なロケーションに設定されていません。"
      ],
      "Severity": [
        "重要度"
      ],
      "Severity must be one of: %s": [
        "重大度は %s のいずれかに指定する必要があります"
      ],
      "Show %s": [
        "%s の表示"
      ],
      "Show :a_resource": [
        ":a_resource の表示"
      ],
      "Show a Content Credential": [
        "コンテンツ認証情報の表示"
      ],
      "Show a content view": [
        "コンテンツビューの表示"
      ],
      "Show a content view component": [
        "コンテンツビューのコンポーネントの表示"
      ],
      "Show a content view's history": [
        "コンテンツビューの履歴を表示"
      ],
      "Show a flatpak remote": [
        ""
      ],
      "Show a flatpak remote repository": [
        ""
      ],
      "Show a host collection": [
        "ホストコレクションの表示"
      ],
      "Show a product": [
        "製品の表示"
      ],
      "Show a repository": [
        "リポジトリーの表示"
      ],
      "Show a subscription": [
        "サブスクリプションを表示します"
      ],
      "Show a sync plan": [
        "同期プランの表示"
      ],
      "Show affected activation keys": [
        "影響のあるアクティベーションキーを表示"
      ],
      "Show affected hosts": [
        "影響を受けるホストを表示"
      ],
      "Show all": [
        "すべて表示"
      ],
      "Show all repository sets": [
        ""
      ],
      "Show an activation key": [
        "アクティベーションキーの表示"
      ],
      "Show an alternate content source.": [
        "代替コンテンツソースを表示します。"
      ],
      "Show an environment": [
        "環境の表示"
      ],
      "Show content available for an activation key": [
        "アクティベーションキーに利用可能なコンテンツの表示"
      ],
      "Show content view version": [
        "コンテンツビューバージョンの表示"
      ],
      "Show filter rule info": [
        "フィルタールール情報の表示"
      ],
      "Show full description": [
        "説明全文の表示"
      ],
      "Show hosts associated to an activation key": [
        ""
      ],
      "Show organization": [
        "組織の表示"
      ],
      "Show release versions available for an activation key": [
        "アクティベーションキーに利用可能なリリースバージョンを表示"
      ],
      "Show releases available for the content host": [
        "コンテンツホストで利用可能なリリースを表示します"
      ],
      "Show repositories": [
        ""
      ],
      "Show repositories enabled on the host that are known to Katello": [
        "Katello に認識されているホストで有効化になっているリポジトリーを表示します。"
      ],
      "Show the available repository types": [
        "使用可能なリポジトリータイプの表示"
      ],
      "Show whether each lifecycle environment is associated with the given Smart Proxy id.": [
        ""
      ],
      "Shows status of Katello system and it's subcomponents": [
        "Katello システムとそのサブコンポーネントのステータスを表示します"
      ],
      "Shows version information": [
        "バージョン情報の表示"
      ],
      "Simple Content Access has been disabled for '%{subject}'.": [
        "'%{subject}' のシンプルコンテンツアクセスが無効になりました。"
      ],
      "Simple Content Access has been enabled for '%{subject}'.": [
        "'%{subject}' のシンプルコンテンツアクセスが有効になりました。"
      ],
      "Simple Content Access is the only supported content access mode": [
        ""
      ],
      "Simplified": [
        "簡易"
      ],
      "Single content view consisting of e.g. repositories": [
        "リポジトリー (例) で構成される単一コンテンツビュー"
      ],
      "Size of file to upload": [
        "アップロードするファイルのサイズ"
      ],
      "Skip metadata check on each repository on the smart proxy": [
        "Smart Proxy の各リポジトリーでのメタデータチェックをスキップします"
      ],
      "Skipped pulp_auth check after failed pulp check": [
        "pulp チェックの失敗後に pulp_auth チェックが省略されました"
      ],
      "Smart proxies": [
        "Smart Proxy"
      ],
      "Smart proxy ID": [
        ""
      ],
      "Smart proxy IDs": [
        "Smart Proxy ID"
      ],
      "Smart proxy content count refresh has started in the background": [
        ""
      ],
      "Smart proxy content source not found!": [
        "Smart Proxy コンテンツソースが見つかりません!"
      ],
      "Smart proxy name": [
        ""
      ],
      "Sockets": [
        "ソケット"
      ],
      "Sockets: %s": [
        "ソケット: %s 個"
      ],
      "Solution": [
        "解決"
      ],
      "Solve RPM dependencies by default on Content View publish, defaults to false": [
        "コンテンツビューの公開時にデフォルトでは RPM 依存関係を解決します。デフォルトは false に設定されています"
      ],
      "Solve dependencies": [
        "依存関係の解決"
      ],
      "Some environments are disabled because they are not associated with the host's content source.": [
        ""
      ],
      "Some environments are disabled because they are not associated with the selected content source.": [
        ""
      ],
      "Some hosts are not registered as content hosts and will be ignored.": [
        "ホストによってはコンテンツホストとして登録されていないため、無視されます。"
      ],
      "Some of your inputs contain errors. Please update them and save your changes again.": [
        "入力の一部にエラーが含まれています。入力内容を更新して、変更を保存し直してください。"
      ],
      "Some services are not properly started. See the About page for more information.": [
        "一部のサービスが適切に開始されていません。詳細は、About ページを参照してください。"
      ],
      "Something went wrong while adding a bookmark: ${getBookmarkErrorMsgs(error.response)}": [
        "コンポーネントの追加中に問題が発生しました! ${getBookmarkErrorMsgs(error.response)}"
      ],
      "Something went wrong while adding a filter rule! ${getResponseErrorMsgs(error.response)}": [
        "フィルタールールの追加中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while adding component! ${getResponseErrorMsgs(error.response)}": [
        "コンポーネントの追加中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while adding filter rules! ${getResponseErrorMsgs(error.response)}": [
        "フィルタールールの追加中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while creating the filter! ${getResponseErrorMsgs(error.response)}": [
        "フィルターの作成中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while deleting alternate content sources: ${getResponseErrorMsgs(error.response)}": [
        "代替コンテンツソースの削除中に問題が発生しました: ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while deleting filter rules! ${getResponseErrorMsgs(error.response)}": [
        "フィルタールールの削除中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while deleting filters! ${getResponseErrorMsgs(error.response)}": [
        "フィルタールールの削除中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while deleting this filter! ${getResponseErrorMsgs(error.response)}": [
        "このフィルターの削除中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while deleting versions ${getResponseErrorMsgs(error.response)}": [
        "バージョンの削除中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while editing a filter rule! ${getResponseErrorMsgs(error.response)}": [
        "フィルタールールの編集中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while editing the filter! ${getResponseErrorMsgs(error.response)}": [
        "フィルターの編集中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while editing version details. ${getResponseErrorMsgs(error.response)}": [
        "バージョン情報の編集中に問題が発生しました。 ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while fetching ${lowerCase(pluralLabel)}! ${getResponseErrorMsgs(error.response)}": [
        "${lowerCase(pluralLabel)} の取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while fetching files! ${getResponseErrorMsgs(error.response)}": [
        "ファイルの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while fetching rpm packages! ${getResponseErrorMsgs(error.response)}": [
        "rpm パッケージの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while getting container manifest lists! ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while getting container tags! ${getResponseErrorMsgs(error.response)}": [
        "コンテナータグの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while getting deb packages! ${getResponseErrorMsgs(error.response)}": [
        "deb パッケージの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while getting errata! ${getResponseErrorMsgs(error.response)}": [
        "エラータの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while getting module streams! ${getResponseErrorMsgs(error.response)}": [
        "モジュールストリームの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while getting repositories! ${getResponseErrorMsgs(error.response)}": [
        "リポジトリーの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while getting the data. See the logs for more information": [
        "データの取得中に問題が発生しました。詳細についてはログを参照してください。"
      ],
      "Something went wrong while getting version details. ${getResponseErrorMsgs(error.response)}": [
        "バージョン情報の取得中に問題が発生しました。 ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while loading the Smart Proxy. See the logs for more information": [
        "Smart Proxy のロード中に問題が発生しました。詳細はログを参照してください。"
      ],
      "Something went wrong while loading the content views. See the logs for more information": [
        "コンテンツビューのロード中に問題が発生しました。詳細についてはログを参照してください。"
      ],
      "Something went wrong while refreshing alternate content sources: ": [
        "代替コンテンツソースの更新中に問題が発生しました:"
      ],
      "Something went wrong while refreshing content counts: ${getResponseErrorMsgs(error.response)}": [
        ""
      ],
      "Something went wrong while removing a filter rule! ${getResponseErrorMsgs(error.response)}": [
        "フィルタールールの削除中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while removing component! ${getResponseErrorMsgs(error.response)}": [
        "コンポーネントの削除中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving package groups! ${getResponseErrorMsgs(error.response)}": [
        "パッケージグループの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the activation keys! ${getResponseErrorMsgs(error.response)}": [
        "アクティベーションキーの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the container tags! ${getResponseErrorMsgs(error.response)}": [
        "コンテナータグの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the content view components! ${getResponseErrorMsgs(error.response)}": [
        "コンテンツビューコンポーネントの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the content view filter rules! ${getResponseErrorMsgs(error.response)}": [
        "コンテンツビューフィルターの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the content view filter! ${getResponseErrorMsgs(error.response)}": [
        "コンテンツビューフィルターの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the content view filters! ${getResponseErrorMsgs(error.response)}": [
        "コンテンツビューフィルターの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the content view history! ${getResponseErrorMsgs(error.response)}": [
        "コンテンツビューの履歴の取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the content view versions! ${getResponseErrorMsgs(error.response)}": [
        "コンテンツビューバージョンの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the content! ${getResponseErrorMsgs(error.response)}": [
        "コンテンツの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the deb packages! ${getResponseErrorMsgs(error.response)}": [
        "Deb パッケージの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the errata! ${getResponseErrorMsgs(error.response)}": [
        "エラータの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the files! ${getResponseErrorMsgs(error.response)}": [
        "ファイルの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the hosts! ${getResponseErrorMsgs(error.response)}": [
        "ホストの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the module streams! ${getResponseErrorMsgs(error.response)}": [
        "モジュールストリームの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the package groups! ${getResponseErrorMsgs(error.response)}": [
        "パッケージグループの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the packages! ${getResponseErrorMsgs(error.response)}": [
        "パッケージの取得中に問題が発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the repositories! ${getResponseErrorMsgs(error.response)}": [
        "リポジトリーの取得時にエラーが発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while retrieving the repository types! ${getResponseErrorMsgs(error.response)}": [
        "リポジトリータイプの取得時にエラーが発生しました! ${getResponseErrorMsgs(error.response)}"
      ],
      "Something went wrong while updating the content source. See the logs for more information": [
        "コンテンツソースの更新中に問題が発生しました。詳細についてはログを参照してください。"
      ],
      "Something went wrong! Please check server logs!": [
        "問題が発生しました! サーバーログを確認してください!"
      ],
      "Sort field and order, eg. 'id DESC'": [
        "フィールドと順序のソート (例: ‘id DESC’)"
      ],
      "Source RPM": [
        "ソース RPM"
      ],
      "Source RPMs": [
        "ソース RPM"
      ],
      "Source type": [
        "リソースタイプ"
      ],
      "Specify an export chunk size less than 1_000_000 GB": [
        "1_000_000 GB 未満のエクスポートチャンクサイズを指定します"
      ],
      "Specify the list of units in each repo": [
        "各リポジトリーのユニットの一覧を指定します"
      ],
      "Split the exported content into archives no greater than the specified size in gigabytes.": [
        "エクスポートされたコンテンツを、ギガバイト単位で指定されたサイズ以下のアーカイブに分割します。"
      ],
      "Stacking ID": [
        "スタッキング ID"
      ],
      "Staged image": [
        ""
      ],
      "Staged image digest": [
        ""
      ],
      "Start Date": [
        "開始日"
      ],
      "Start Date and Time can't be blank": [
        "開始日時を空白にしないでください。"
      ],
      "Start Time": [
        "開始時刻"
      ],
      "Start date": [
        "開始日"
      ],
      "Starts": [
        "開始"
      ],
      "State": [
        "状態"
      ],
      "Status": [
        "状態"
      ],
      "Status must be one of: %s": [
        "ステータスは %s のいずれかに指定する必要があります"
      ],
      "Storage": [
        "ストレージ"
      ],
      "Stream": [
        "ストリーム"
      ],
      "Streamed": [
        "ストリーミング済み"
      ],
      "Streams based on the host based on the installation status": [
        "インストールステータスに基づくホストに基づいたストリーム"
      ],
      "Streams based on the host based on their status": [
        "ステータスに基づくホストに基づいたストリーム"
      ],
      "Submit": [
        "送信"
      ],
      "Subnet IDs": [
        "サブネット ID"
      ],
      "Subpaths": [
        "サブパス"
      ],
      "Subscription": [
        "サブスクリプション"
      ],
      "Subscription Details": [
        "サブスクリプションの詳細"
      ],
      "Subscription ID": [
        "サブスクリプション ID"
      ],
      "Subscription Info": [
        "サブスクリプションの情報"
      ],
      "Subscription Manifest": [
        "サブスクリプションマニフェスト"
      ],
      "Subscription Manifest expiration date check": [
        ""
      ],
      "Subscription Manifest validity check": [
        "サブスクリプションマニフェストの有効性チェック"
      ],
      "Subscription Name": [
        "サブスクリプション名"
      ],
      "Subscription Pool id": [
        "サブスクリプションプール ID"
      ],
      "Subscription Pool uuid": [
        "サブスクリプションプール UUID"
      ],
      "Subscription UUID": [
        "サブスクリプション UUID"
      ],
      "Subscription connection enabled": [
        "サブスクリプション接続の有効化"
      ],
      "Subscription expiration notification": [
        "サブスクリプションの有効期限通知"
      ],
      "Subscription id is nil.": [
        "サブスクリプション ID は nil です。"
      ],
      "Subscription identifier": [
        "サブスクリプション ID"
      ],
      "Subscription manager name registration fact": [
        "サブスクリプションマネージャー名の登録ファクト"
      ],
      "Subscription manager name registration fact strict matching": [
        "サブスクリプションマネージャー名の登録ファクトの完全一致"
      ],
      "Subscription manifest file": [
        "サブスクリプションのマニフェストファイル"
      ],
      "Subscription not found": [
        "サブスクリプションが見つかりません"
      ],
      "Subscription was not persisted - %{error_message}": [
        "サブスクリプションが永続化されませんでした: {error_message}"
      ],
      "Subscriptions": [
        "サブスクリプション"
      ],
      "Subscriptions expiring soon": [
        "まもなく期限切れになるサブスクリプション"
      ],
      "Subscriptions have been saved and are being updated. ": [
        "サブスクリプションが保存され、更新されています。 "
      ],
      "Subscriptions service": [
        "サブスクリプションサービス"
      ],
      "Substitution Mismatch. Unable to update for content: (%{content}). From [%{content_url}] To [%{new_url}].": [
        "置き換える項目が一致しません。コンテンツを更新できません: (%{content})。[%{content_url}] から [%{new_url}]。"
      ],
      "Success": [
        "成功"
      ],
      "Successfully added %s Host(s).": [
        "%s 台のホストが正常に追加されました。"
      ],
      "Successfully added %{count} content host(s) to host collection %{host_collection}.": [
        "コンテンツホスト%{count} 台がホストコレクション {host_collection} に正常に追加されました。"
      ],
      "Successfully changed sync plan for %s product(s)": [
        "%s 製品の同期プランが正常に変更されました"
      ],
      "Successfully initiated removal of %s product(s)": [
        "%s 製品 の削除が正常に開始されました"
      ],
      "Successfully refreshed.": [
        "正常に更新されました。"
      ],
      "Successfully removed %s Host(s).": [
        "%s 台のホストが正常に削除されました。"
      ],
      "Successfully removed %{count} content host(s) from host collection %{host_collection}.": [
        "ホストコレクション {host_collection} から %{count} 台のコンテンツホストが正常に削除されました。"
      ],
      "Successfully synced capsule.": [
        "Capsule が正常に同期されました。"
      ],
      "Successfully synchronized.": [
        "正常に同期しました。"
      ],
      "Summary": [
        "要約"
      ],
      "Support Type": [
        "サポートタイプ"
      ],
      "Support ended": [
        ""
      ],
      "Supported Content Types": [
        "サポート対象のコンテンツタイプ"
      ],
      "Sync Canceled": [
        "同期が取り消されました"
      ],
      "Sync Connect Timeout": [
        "同期接続タイムアウト"
      ],
      "Sync Content View on Smart Proxy(ies)": [
        "Smart Proxy でコンテンツビューの同期"
      ],
      "Sync Incomplete": [
        "同期が完了していません"
      ],
      "Sync Overview": [
        "同期の概要"
      ],
      "Sync Plan": [
        "同期プラン"
      ],
      "Sync Plan: ": [
        "同期プラン: "
      ],
      "Sync Plans": [
        "同期プラン"
      ],
      "Sync Repository on Smart Proxy(ies)": [
        "Smart Proxy でのリポジトリーの同期"
      ],
      "Sync Smart Proxies after content view promotion": [
        "コンテンツビューのプロモート後に Smart Proxy を同期する"
      ],
      "Sync Sock Connect Timeout": [
        "同期 Sock 接続タイムアウト"
      ],
      "Sync Sock Read Timeout": [
        "同期 Sock 読み取りタイムアウト"
      ],
      "Sync Status": [
        "同期のステータス"
      ],
      "Sync Summary": [
        "同期の概要"
      ],
      "Sync Summary for %s": [
        "%s の 同期の概要"
      ],
      "Sync Total Timeout": [
        "同期合計タイムアウト"
      ],
      "Sync a repository": [
        "リポジトリーの同期"
      ],
      "Sync all repositories for a product": [
        "製品のすべてのリポジトリーを同期します"
      ],
      "Sync complete.": [
        "同期が完了しました。"
      ],
      "Sync errata": [
        "エラータの同期"
      ],
      "Sync one or more products": [
        "1 つ以上の製品の同期"
      ],
      "Sync plan identifier to attach": [
        "割り当てる同期プラン ID"
      ],
      "Sync smart proxy content directly from upstream repositories by selecting the desired products.": [
        "目的の製品を選択して、アップストリームリポジトリーから Smart Proxy コンテンツを直接同期します。"
      ],
      "Sync state": [
        "同期の状態"
      ],
      "Synced": [
        ""
      ],
      "Synced ": [
        "同期されています "
      ],
      "Synced Content": [
        "同期されたコンテンツ"
      ],
      "Synchronize": [
        "同期"
      ],
      "Synchronize Now": [
        "今すぐ同期"
      ],
      "Synchronize repository": [
        "リポジトリーの同期"
      ],
      "Synchronize smart proxy": [
        "Smart Proxy の同期"
      ],
      "Synchronize the content to the smart proxy": [
        "コンテンツと Smart Proxy の同期"
      ],
      "Synchronize: Skip Metadata Check": [
        "同期: メタデータチェックをスキップします"
      ],
      "Synchronize: Validate Content": [
        "同期: コンテンツを検証します"
      ],
      "Syncing Complete.": [
        "同期が完了しました。"
      ],
      "Synopsis": [
        "概要"
      ],
      "System Purpose": [
        "システム目的"
      ],
      "System Status": [
        "システムステータス"
      ],
      "System purpose": [
        "システム目的"
      ],
      "System purpose attributes updated": [
        "システム目的の属性の更新"
      ],
      "System purpose enables you to set the system's intended use on your network and improves reporting accuracy in the Subscriptions service of the Red Hat Hybrid Cloud Console.": [
        ""
      ],
      "Tag name": [
        "タグ名"
      ],
      "Tags": [
        "タグ"
      ],
      "Task": [
        "タスク"
      ],
      "Task ${task.humanized.action} completed with a result of ${task.result}. ${task.errors ? getErrors(task) : ''}": [
        "${task.humanized.action} completed with a result of ${task.result}. ${task.errors ? getErrors(task) : ''}"
      ],
      "Task ${task.humanized.action} has started.": [
        "タスク${task.humanized.action} が開始されました。"
      ],
      "Task ID": [
        ""
      ],
      "Task canceled": [
        "タスクが取り消されました"
      ],
      "Task detail": [
        "タスクの詳細"
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
        "一時的"
      ],
      "The '%s' environment cannot contain a changeset!": [
        "'%s' 環境には変更セットを含めることができません!"
      ],
      "The Alternate Content Source type": [
        "代替コンテンツソースのタイプ"
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
        "セッショントークンを受信するためのURL (例: Automation Hub で使用)。"
      ],
      "The action requested on this composite view cannot be performed until all of the component content view versions have been promoted to the target environment: %{env}.  This restriction is optional and can be modified in the Administrator -> Settings -> Content page using the restrict_composite_view flag.": [
        "この複合ビューで要求されたアクションは、すべてのコンポーネントコンテンツビューがターゲット環境: %{env} にプロモートされるまで実行できません。この制限はオプションであり、管理 -> 設定  -> コンテンツページで restrict_composite_view フラグを使用して変更できます。"
      ],
      "The actual file contents": [
        "実際のコンテンツファイル"
      ],
      "The amount of latest versions of a package to keep on sync, includes pre-releases if synced. Default 0 keeps all versions.": [
        ""
      ],
      "The content type for the Alternate Content Source": [
        "代替コンテンツソースのコンテンツタイプ"
      ],
      "The current organization cannot be deleted. Please switch to a different organization before deleting.": [
        "現在の組織を削除できません。別の組織に切り替えてから削除してください。"
      ],
      "The default content view cannot be edited, published, or deleted.": [
        "デフォルトコンテンツビューの編集、公開、または削除を実行することはできません。"
      ],
      "The default content view cannot be promoted": [
        "デフォルトのコンテンツビューはプロモートできません"
      ],
      "The description for the content view version": [
        "コンテンツビューバージョンの説明"
      ],
      "The description for the content view version promotion": [
        "コンテンツビューバージョンのプロモートの説明"
      ],
      "The description for the new generated Content View Versions": [
        "新規に生成されたコンテンツビューバージョンの説明"
      ],
      "The email notification will include subscriptions expiring in this number of days or fewer.": [
        "メール通知には、この日数以内に期限が切れるサブスクリプションが含まれます。"
      ],
      "The erratum filter rule end date is in an invalid format or type.": [
        "エラータフィルタールールの終了日は無効な形式またはタイプになっています。"
      ],
      "The erratum filter rule start date is in an invalid format or type.": [
        "エラータフィルタールールの開始日は無効な形式またはタイプになっています。"
      ],
      "The erratum type must be an array. Invalid value provided": [
        "エラータタイプは配列でなくてはなりません。無効な値が指定されました"
      ],
      "The field to sort the data by. Defaults to the created date.": [
        "データを並べ替えるフィールド。デフォルトは作成日に設定されています。"
      ],
      "The following hosts have errata that apply to them: ": [
        "以下のホストには、適用するエラータがあります: "
      ],
      "The following repositories provided in the import metadata have an incorrect content type or provider type. Make sure the export and import repositories are of the same type before importing\\n %{repos}": [
        "インポートメタデータで提供されている以下のリポジトリーのコンテンツタイプまたはプロバイダータイプが正しくありません。インポートする前に、エクスポートリポジトリーとインポートリポジトリーが同じタイプであることを確認してください\\n %%{repos}"
      ],
      "The id of the content source": [
        "コンテンツソースの ID"
      ],
      "The id of the content view": [
        "コンテンツビューの ID"
      ],
      "The id of the host to alter": [
        "変更するホストの ID"
      ],
      "The id of the lifecycle environment": [
        "ライフサイクル環境の ID"
      ],
      "The ids of the hosts to alter. Hosts not managed by Katello are ignored": [
        "変更するホストの ID。Katello が管理していないホストは無視されます"
      ],
      "The list of environments to promote the specified Content View Version to (replacing the older version)": [
        "指定されたコンテンツビューバージョンをプロモートする (古いバージョンに置き換わる) 環境の一覧です。"
      ],
      "The manifest doesn't exist on console.redhat.com. Please create and import a new manifest.": [
        "マニフェストは console.redhat.com にはありません。新しいマニフェストを作成してインポートしてください。"
      ],
      "The manifest imported within Organization %{subject} is no longer valid. Please import a new manifest.": [
        "組織 %{subject} 内にインポートされていたマニフェストは無効になりました。新しいマニフェストをインポートしてください。"
      ],
      "The maximum number of second that Pulp can take to do a single sync operation, e.g., download a single metadata file.": [
        "Pulp が 1 回の同期操作 (例: 1 つのメタデータファイルのダウンロード) に使用できる最大秒数"
      ],
      "The maximum number of seconds for Pulp to connect to a peer for a new connection not given from a pool.": [
        "Pulp がプールから指定されていない新しい接続のピアに接続するための最大秒数。"
      ],
      "The maximum number of seconds for Pulp to establish a new connection or for waiting for a free connection from a pool if pool connection limits are exceeded.": [
        "Pulp が新しい接続を確立するか、プール接続の制限を超えた場合にプールの空き接続を待機するための最大秒数。"
      ],
      "The maximum number of seconds that Pulp can take to download a file, not counting connection time.": [
        "Pulp がファイルのダウンロードに使用できる最大秒数 (接続時間は除く)。"
      ],
      "The maximum number of versions of each package to keep.": [
        "保持する各パッケージのバージョンの最大数。"
      ],
      "The number of days remaining in a subscription before you will be reminded about renewing it. Also used for manifest expiration warnings.": [
        ""
      ],
      "The number of items fetched from a single paged Pulp API call.": [
        "1 ページの Pulp API 呼び出しからフェッチされたアイテムの数。"
      ],
      "The offset in the file where the content starts": [
        "コンテンツが開始するファイル内のオフセット"
      ],
      "The order to sort the results in. ['asc', 'desc'] Defaults to 'desc'.": [
        "結果を並べ替える順序。['asc'、'desc']。デフォルトは 'desc' です。"
      ],
      "The organization's manifest does not contain the subscriptions required to enable the following repositories.\\n %{repos}": [
        "組織のマニフェストには、以下のリポジトリーの有効化に必要なサブスクリプションが含まれていません。\\n %%{repos}"
      ],
      "The page you are attempting to access requires selecting a specific organization.": [
        "アクセス先のページには、特定の組織を選択する必要があります。"
      ],
      "The path %{real_path} does not seem to be a valid repository. If you think this is an error, please try refreshing your manifest.": [
        "パス %{real_path} は、有効なリポジトリーではないようです。これがエラーだと思われる場合には、マニフェストを更新してみてください。"
      ],
      "The promotion of %{content_view} to %{environment} has completed.  %{count} errata are available to your hosts.": [
        "%{content_view} から %{environment} のプロモートが完了しました。エラータ %{count} 件がホストで利用できます。"
      ],
      "The promotion of %{content_view} to <b>%{environment}</b> has completed.  %{count} needed errata are installable on your hosts.": [
        "%{content_view} から <b>%{environment}</b> へのプロモートが完了しました。必要なエラータ %{count} 件をホストにインストールできます。"
      ],
      "The repository is already enabled": [
        "リポジトリー がすでに有効にされています"
      ],
      "The repository's publication is missing. Please run a 'complete sync' on %s.": [
        "リポジトリーの公開がありません。%s で 'complete sync' を実行してください。"
      ],
      "The request did not contain any repository information.": [
        "要求には、リポジトリーの情報が含まれていませんでした。"
      ],
      "The requested resource does not belong to the specified Organization": [
        "要求されたリソースは、指定の組織に所属しません。"
      ],
      "The requested resource does not belong to the specified organization": [
        "要求されたリソースは、指定の組織に所属していません"
      ],
      "The requested traces were not found for this host": [
        "このホストには、要求されたトレースが見つかりませんでした"
      ],
      "The selected kickstart repository is not part of the assigned content view, lifecycle environment, content source, operating system, and architecture": [
        "選択したキックスタートリポジトリーは、割り当てられたコンテンツビュー、ライフサイクル環境、コンテンツソース、オペレーティングシステム、アーキテクチャーに含まれていません。"
      ],
      "The selected lifecycle environment contains no activation keys": [
        ""
      ],
      "The selected/Inherited Content View is not available for this Lifecycle Environment": [
        "このライフサイクル環境では、選択したコンテンツビュー/継承したコンテンツビューは利用できません"
      ],
      "The specified organization is in Simple Content Access mode. Attaching subscriptions is disabled": [
        "指定の組織はシンプルコンテンツアクセスモードです。サブスクリプションのアタッチが無効になっています"
      ],
      "The subscription cannot be found upstream": [
        "サブスクリプションがアップストリームにありません"
      ],
      "The subscription is no longer available": [
        "サブスクリプションは利用できなくなりました"
      ],
      "The synchronization of \\\"%s\\\" has completed.  Below is a summary of new errata.": [
        "\\\"%s\\\" の同期が完了しました。以下は新規エラータの要約です。"
      ],
      "The token key to use for authentication.": [
        "認証に使用するトークンキー。"
      ],
      "The type of content to remove (srpm, docker_manifest, etc.). Check removable types here: /katello/api/repositories/repository_types": [
        "削除するコンテンツタイプ (srpm、docker_manifest など)。/katello/api/repositories/repository_types でリムーバブルタイプを確認します。"
      ],
      "The type of content to upload (srpm, file, etc.). Check uploadable types here: /katello/api/repositories/repository_types": [
        "アップロードするコンテンツのタイプ (srpm、file など)。アップロード可能なタイプは、/katello/api/repositories/repository_types で確認できます。"
      ],
      "The value will be available in templates as @host.params['kt_activation_keys']": [
        ""
      ],
      "There are no Manifests to display": [
        "表示するマニフェストはありません。"
      ],
      "There are no Subscriptions to display": [
        "表示するサブスクリプションはありません"
      ],
      "There are no errata that need to be applied to registered content hosts.": [
        "登録済みコンテンツホストへの適用が必要なエラータはありません。"
      ],
      "There are no host collections available to add.": [
        "追加可能なホストコレクションはありません。"
      ],
      "There are no products or repositories enabled. Try enabling via %{custom} or %{redhat}.": [
        "有効な製品またはリポジトリーはありません。%{custom} または %{redhat} から有効化してみてください。"
      ],
      "There are {numberOfActivationKeys} activation keys that need to be reassigned.": [
        "再割り当てが必要なアクティベーションキーは {numberOfActivationKeys} 個です。"
      ],
      "There are {numberOfHosts} hosts that need to be reassigned.": [
        "再割り当てが必要なホストは {numberOfHosts} 個です。"
      ],
      "There either were no environments nor versions specified or there were invalid environments/versions specified. Please check environment_ids and content_view_version_ids parameters.": [
        "いずれの環境またはバージョンも指定されていないか、または無効な環境/バージョンが指定されています。environment_ids と content_view_version_ids パラメーターを確認してください。"
      ],
      "There is no downloaded content to clean.": [
        "クリーンアップするダウンロード済みのコンテンツはありません。"
      ],
      "There is no manifest history to display.": [
        ""
      ],
      "There is no such HTTP proxy": [
        "そのような HTTP プロキシーはありません"
      ],
      "There is nothing to see here": [
        "こちらに表示できるものはありません"
      ],
      "There is {numberOfActivationKeys} activation key that needs to be reassigned.": [
        "再割り当てが必要なアクティベーションキーは {numberOfActivationKeys} 個です。"
      ],
      "There is {numberOfHosts} host that needs to be reassigned.": [
        "再割り当てが必要なホストは {numberOfHosts} 個です。"
      ],
      "There was a problem retrieving Activation Key data from the server.": [
        "サーバーからアクティベーションキーデータを取得する時に問題が発生しました。"
      ],
      "There was an error retrieving data from the server. Check your connection and try again.": [
        "サーバーからデータを取得する際にエラーが発生しました。接続を確認して再度取得してみてください。"
      ],
      "There was an issue with the backend service %s: ": [
        "バックエンドサービス %s で問題が発生しました: "
      ],
      "There's no running synchronization for this smart proxy.": [
        "この Smart Proxy に対して実行中の同期はありません。"
      ],
      "This Content View must be set to Import-only before performing an import": [
        "インポートを実行する前に、このコンテンツビューをインポートのみに設定する必要があります"
      ],
      "This Host is not currently registered with subscription-manager.": [
        "このホストは現在、subscription-manager に登録されていません。"
      ],
      "This Organization's subscription manifest has expired. Please import a new manifest.": [
        "この組織のサブスクリプションマニフェストは期限切れです。新しいマニフェストをインポートしてください。"
      ],
      "This action doesn't support package groups": [
        "このアクションはパッケージグループに対応していません"
      ],
      "This action should only be taken for debugging purposes.": [
        ""
      ],
      "This action should only be taken in extreme circumstances or for debugging purposes.": [
        "この操作は、特殊な状況またはデバッグの目的でのみ実行する必要があります。"
      ],
      "This activation key is associated to one or more Hosts/Hostgroups. Search and unassociate Hosts/Hostgroups using params.kt_activation_keys ~ \\\"%{name}\\\" before deleting.": [
        "このアクティべーションキーは 1 つ以上のホスト/ホストグループに関連付けられます。削除前に params.kt_activation_keys ~ \\\"%{name}\\\" を使用してホスト/ホストグループを検索し、関連付け解除します。"
      ],
      "This certificate allows a user to view the repositories in any environment from a browser.": [
        "この証明書により、ユーザーはすべての環境のリポジトリーをブラウザーから閲覧できます。"
      ],
      "This content view does not have any versions associated.": [
        "このコンテンツビューには、バージョンが関連付けられていません。"
      ],
      "This content view version doesn't have a history.": [
        "このコンテンツビューバージョンには履歴がありません。"
      ],
      "This content view version is used in one or more multi-environment hosts. The version will simply be removed from the multi-environment hosts. The content view and lifecycle environment you select here will only apply to single-environment hosts. See hammer activation-key --help for more details.": [
        ""
      ],
      "This content view will be automatically updated to the latest version.": [
        "このコンテンツビューは、最新バージョンに自動的に更新されます。"
      ],
      "This content view will be deleted. Changes will be effective after clicking Delete.": [
        "このコンテンツビューは削除されます。変更は、削除 をクリックした後に有効になります。"
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
        "このホストのコンテンツビューおよびライフサイクル環境に含まれていないため、このエラータはインストール可能ではありません。"
      ],
      "This host does not have any Module streams.": [
        "このホストにはモジュールストリームがありません。"
      ],
      "This host does not have any packages.": [
        "このホストにはパッケージがありません。"
      ],
      "This host has errata that are applicable, but not installable. Adjust your filters and try again.": [
        ""
      ],
      "This host is associated with multiple content view environments. If you assign a lifecycle environment and content view here, the host will be removed from the other environments.": [
        ""
      ],
      "This host's organization is in Simple Content Access mode. Attaching subscriptions is disabled.": [
        "このホストの組織はシンプルコンテンツアクセスモードです。サブスクリプションのアタッチが無効になっています。"
      ],
      "This host's organization is in Simple Content Access mode. Auto-attach is disabled": [
        "このホストの組織はシンプルコンテンツアクセスモードです。自動アタッチが無効になっています"
      ],
      "This is disabled because a manifest task is in progress": [
        "マニフェストのタスクが実行中であるため、これは無効になっています"
      ],
      "This is disabled because a manifest-related task is in progress.": [
        "マニフェスト関連のタスクが実行中であるため、これは無効になっています。"
      ],
      "This is disabled because no connection could be made to the upstream Manifest.": [
        "アップストリームマニフェストに接続できないため、これは無効になっています。"
      ],
      "This is disabled because no manifest exists": [
        "マニフェストが存在しないため、これは無効になっています"
      ],
      "This is disabled because no manifest has been uploaded.": [
        "マニフェストがアップロードされていないため、これは無効になっています。"
      ],
      "This is disabled because no subscriptions are selected.": [
        "サブスクリプションが選択されていないため、これは無効になっています。"
      ],
      "This is not a linked repository": [
        "これは、リンクされたリポジトリーではありません"
      ],
      "This page shows the subscriptions available from this organization's subscription manifest. {br} Learn more about your overall subscription usage with the {subscriptionsService}.": [
        ""
      ],
      "This repository has pending tasks in associated content views. Please wait for the tasks: ": [
        ""
      ],
      "This repository is not suggested. Please see additional %(anchorBegin)sdocumentation%(anchorEnd)s prior to use.": [
        "このリポジトリーは推奨されていません。使用する前に、 %(anchorBegin)sドキュメント%(anchorEnd)s を追加で参照してください。"
      ],
      "This request may only be performed on a Smart proxy that has the Pulpcore feature with mirror=true.": [
        "この要求は、mirror=true 設定で Pulpcore 機能を持つ Smart Proxy でのみ実行できます。"
      ],
      "This service is available for unauthenticated users": [
        "このサービスは未認証ユーザーが使用できます"
      ],
      "This service is only available for authenticated users": [
        "このサービスは認証ユーザーのみが使用できます"
      ],
      "This shows repositories that are used in a typical setup.": [
        "これは、一般的なセットアップで使用されるリポジトリーを示しています。"
      ],
      "This subscription is not relevant to the current organization.": [
        "このサブスクリプションは現在の組織には関係ありません。"
      ],
      "This version has not been promoted to any environments.": [
        "このバージョンはいずれの環境にもプロモートされていません。"
      ],
      "This version is not promoted to any environments.": [
        "このバージョンはいずれの環境にもプロモートされません。"
      ],
      "This version will be removed from:": [
        "このバージョンは以下から削除されます:"
      ],
      "This will create a copy of {cv}, including details, repositories, and filters. Generated data such as history, tasks and versions will not be copied.": [
        "これにより、詳細、リポジトリー、およびフィルターを含め {cv} のコピーが作成されます。履歴、タスク、およびバージョン等の生成されたデータはコピーされません。"
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
        "マニフェストの更新時のタイムアウト (秒単位)"
      ],
      "Timestamp": [
        "タイムスタンプ"
      ],
      "Title": [
        "タイトル"
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
        "まず、このホストをホストコレクションに追加します。"
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
        "ステップ合計数: "
      ],
      "Tracer": [
        "トレーサー"
      ],
      "Tracer helps administrators identify applications that need to be restarted after a system is patched.": [
        "トレーサーを使用することで、管理者はシステムにパッチ修正を適用した後に再起動する必要のあるアプリケーションを特定しやすくなります。"
      ],
      "Tracer profile uploaded successfully": [
        "トレーサープロファイルが正常にアップロードされました"
      ],
      "Traces": [
        "トレース"
      ],
      "Traces are being enabled": [
        "トレースが有効になっています"
      ],
      "Traces are not enabled": [
        "トレースは有効ではありません"
      ],
      "Traces help administrators identify applications that need to be restarted after a system is patched.": [
        "トレースを使用することで、管理者はシステムにパッチ修正を適用した後に再起動する必要のあるアプリケーションを特定しやすくなります。"
      ],
      "Traces may be enabled by a user with the appropriate permissions.": [
        "トレースは、適切なパーミッションを持つユーザーによって有効にできます。"
      ],
      "Traces may be listed here after {pkgLink}.": [
        "トレースは {pkgLink} の後に一覧表示される場合があります。"
      ],
      "Traces not available": [
        "トレースは利用できません"
      ],
      "Traces that require logout cannot be restarted remotely": [
        "ログアウトが必要なトレースをリモートで再起動することはできません"
      ],
      "Traces will be shown here to a user with the appropriate permissions.": [
        "トレースは、適切なパーミッションを持つユーザーに対してここで表示されます。"
      ],
      "Traffic for all alternate content sources associated with this smart proxy will go through the chosen HTTP proxy.": [
        "このSmart Proxy に関連付けられた代替コンテンツソースのトラフィックは、選択した HTTP プロキシーを通過します。"
      ],
      "Trigger an auto-attach of subscriptions": [
        "サブスクリプションの自動割り当てのトリガー"
      ],
      "Trigger an auto-attach of subscriptions on one or more hosts": [
        "1 つ以上のホストに、サブスクリプションの自動割り当てをトリガーします"
      ],
      "Try changing your search criteria.": [
        "検索条件を変更してみてください。"
      ],
      "Try changing your search query.": [
        "検索クエリーを変更してみてください。"
      ],
      "Try changing your search settings.": [
        "検索設定を変更してみてください。"
      ],
      "Trying to cancel the synchronization...": [
        "同期をキャンセルしようとしています..."
      ],
      "Type": [
        "タイプ"
      ],
      "Type must be one of: %s": [
        "タイプは %s のいずれかに指定する必要があります"
      ],
      "Type of content": [
        "コンテンツのタイプ"
      ],
      "Type of content: \\\"cert\\\", \\\"gpg_key\\\"": [
        "コンテンツの種類: \\\"cert\\\"、\\\"gpg_key\\\""
      ],
      "Type of repository. Available types endpoint: /katello/api/repositories/repository_types": [
        "リポジトリーのタイプ。利用可能なタイプエンドポイント: /katello/api/repositories/repository_types"
      ],
      "URL": [
        "URL"
      ],
      "URL and paths": [
        "URL およびパス"
      ],
      "URL and subpaths": [
        "URL およびサブパス"
      ],
      "URL needs to have a trailing /": [
        "URL には末尾の / が必要です"
      ],
      "URL of a PyPI content source such as https://pypi.org.": [
        "PyPI コンテンツソースの URL (例: https://pypi.org)。"
      ],
      "URL of an OSTree repository.": [
        "OSTree リポジトリーの URL。"
      ],
      "UUID": [
        "UUID"
      ],
      "UUID of the consumer": [
        "コンシューマー UUID"
      ],
      "UUID of the content host": [
        "コンテンツホスト UUID"
      ],
      "UUID of the system": [
        "システム UUID"
      ],
      "UUID to use for registered host, random uuid is generated if not provided": [
        "登録済みホストに使用するUUID。指定されていない場合には、無作為に UUID が生成されます。"
      ],
      "UUIDs of the virtual guests from the host's hypervisor": [
        "ホストのハイパーバイザーからの仮想ゲスト UUID"
      ],
      "Unable to connect": [
        "接続できません"
      ],
      "Unable to connect. Got: %s": [
        "接続できません。結果: %s"
      ],
      "Unable to create ContentViewEnvironment. Check the logs for more information.": [
        ""
      ],
      "Unable to delete any alternate content source. You either do not have the permission to delete, or none of the alternate content sources exist.": [
        "代替コンテンツソースを削除できません。削除するパーミッションがないか、代替コンテンツソースが存在しません。"
      ],
      "Unable to detect pulp storage": [
        "Pulp ストレージを検出できません"
      ],
      "Unable to detect puppet path": [
        "Puppet パスを検出できません"
      ],
      "Unable to find product '%s' in organization '%s'": [
        "組織 '%s' で製品 '%s' が見つかりません"
      ],
      "Unable to get users": [
        "ユーザーを取得できません"
      ],
      "Unable to import in to Content View specified in the metadata - '%{name}'. The 'import_only' attribute for the content view is set to false. To mark this Content View as importable, have your system administrator run the following command on the server. ": [
        "メタデータで指定されたコンテンツビュー '%{name}' にインポートできません。コンテンツビューの 'import_only' 属性は false に設定されています。このコンテンツビューをインポート可能としてマークするには、システム管理者がサーバーで以下のコマンドを実行する必要があります。 "
      ],
      "Unable to incrementally export. Do a Full Export on the library content before updating from the latest increment.": [
        "増分エクスポートできません。最新の増分から更新する前に、ライブラリーコンテンツを完全にエクスポートします。"
      ],
      "Unable to incrementally export. Do a Full Export on the repository content.": [
        "増分エクスポートできません。リポジトリーコンテンツでの完全なエクスポートを実行してください。"
      ],
      "Unable to reassign activation_keys. Please check activation_key_content_view_id and activation_key_environment_id.": [
        "activation_keys の再割り当てを実行できません。activation_key_content_view_id と activation_key_environment_id を確認してください。"
      ],
      "Unable to reassign activation_keys. Please provide key_content_view_id and key_environment_id.": [
        "activation_keys の再割り当てを実行できません。key_content_view_id と key_environment_id を指定してください。"
      ],
      "Unable to reassign content hosts. Please provide system_content_view_id and system_environment_id.": [
        "コンテンツホストの再割り当てを実行できません。system_content_view_id と system_environment_id を指定してください。"
      ],
      "Unable to reassign systems. Please check system_content_view_id and system_environment_id.": [
        "システムの再割り当てを実行できません。system_content_view_id と system_environment_id を確認してください。"
      ],
      "Unable to refresh any alternate content source. You either do not have the permission to refresh, or no alternate content sources exist.": [
        ""
      ],
      "Unable to refresh any alternate content source. You either do not have the permission to refresh, or none of the alternate content sources exist.": [
        "代替コンテンツソースを更新できません。更新するパーミッションがないか、代替コンテンツソースが存在しません。"
      ],
      "Unable to send errata e-mail notification: %{error}": [
        "エラータのメール通知を送信できません: %{error}"
      ],
      "Unable to sync repo. This repository does not have a feed url.": [
        "リポジトリーを同期できません。このリポジトリーにはフィード URL がありません。"
      ],
      "Unable to sync repo. This repository is not a library instance repository.": [
        ""
      ],
      "Unable to synchronize any repository. You either do not have the permission to synchronize or the selected repositories do not have a feed url.": [
        "リポジトリーを同期できません。同期する権限がないか、または選択されたリポジトリーにフィード URL がないかのいずれかです。"
      ],
      "Unable to update the repository list": [
        "リポジトリー一覧を更新できません"
      ],
      "Unable to update the user-repository mapping": [
        "user-repository マッピングを更新できません"
      ],
      "Unapplied Errata": [
        "適用されないエラータ"
      ],
      "Unattach a subscription": [
        "サブスクリプションの割り当て解除"
      ],
      "Unfiltered params array: %s.": [
        "フィルタリングされていないパラメーター配列: %s。"
      ],
      "Uninstall and reset": [
        "アンインストールとリセット"
      ],
      "Unknown": [
        "不明"
      ],
      "Unknown Action": [
        "不明なアクション"
      ],
      "Unknown errata status": [
        "不明なエラータステータス"
      ],
      "Unknown traces status": [
        "不明なトレースステータス"
      ],
      "Unlimited": [
        "無制限"
      ],
      "Unregister host %s before assigning an organization": [
        "組織を割り当てる前にホスト %s の登録を解除してください"
      ],
      "Unregister the host as a subscription consumer": [
        "ホストからサブスクリプション登録の解除"
      ],
      "Unspecified": [
        "指定されていません"
      ],
      "Unsupported CDN resource": [
        "サポートされない CDN リソース"
      ],
      "Unsupported event type %{type}. Supported: %{types}": [
        "サポートされていないイベントタイプ %{type}。サポート: %{types}"
      ],
      "Up-to date": [
        "最新"
      ],
      "Update": [
        "更新"
      ],
      "Update Alternate Content Source": [
        "代替コンテンツソースの更新"
      ],
      "Update CDN Configuration": [
        "CDN 設定の更新"
      ],
      "Update Content Counts": [
        ""
      ],
      "Update Content Overrides": [
        "コンテンツ上書きの更新"
      ],
      "Update Content Overrides to %s": [
        "%s へのコンテンツ上書きの更新"
      ],
      "Update Upstream Subscription": [
        "アップストリームサブスクリプションの更新"
      ],
      "Update a Content Credential": [
        "コンテンツ認証情報の更新"
      ],
      "Update a component associated with the content view": [
        "コンテンツビューに関連付けられたコンポーネントを更新します"
      ],
      "Update a content view": [
        "コンテンツビューの更新"
      ],
      "Update a content view version": [
        "コンテンツビューのバージョンを更新します。"
      ],
      "Update a filter rule. The parameters included should be based upon the filter type.": [
        "フィルタールールの更新。組み込まれるパラメーターはフィルタータイプに基づくものでなければなりません。"
      ],
      "Update a flatpak remote": [
        ""
      ],
      "Update a host collection": [
        "ホストコレクションの更新"
      ],
      "Update a repository": [
        "リポジトリーの更新"
      ],
      "Update a sync plan": [
        "同期プランの更新"
      ],
      "Update an activation key": [
        "アクティベーションキーの更新"
      ],
      "Update an alternate content source.": [
        "代替コンテンツソースを更新します。"
      ],
      "Update an environment": [
        "環境の更新"
      ],
      "Update an environment in an organization": [
        "組織内の環境を更新"
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
        "インストール済みパッケージ、有効なリポジトリー、モジュールインベントリーの更新"
      ],
      "Update organization": [
        "組織の更新"
      ],
      "Update package group via Katello interface": [
        "Katello インターフェイスでのパッケージグループの更新"
      ],
      "Update package via Katello interface": [
        "Katello インターフェイスでのパッケージの更新"
      ],
      "Update packages via Katello interface": [
        "Katello インターフェイスでのパッケージの更新"
      ],
      "Update release version for host": [
        "ホストのリリースバージョンの更新"
      ],
      "Update release version for host %s": [
        "ホスト %s のリリースバージョンの更新"
      ],
      "Update services requiring restart": [
        "再起動が必要なサービスの更新"
      ],
      "Update the CDN configuration": [
        "CDN 設定の更新"
      ],
      "Update the HTTP proxy configuration on the repositories of one or more products.": [
        "1 つ以上の製品のリポジトリーで HTTP Proxy 設定を更新します。"
      ],
      "Update the content source for specified hosts and generate the reconfiguration script": [
        "指定されたホストのコンテンツソースを更新し、再設定スクリプトを生成します"
      ],
      "Update the host immediately via remote execution": [
        ""
      ],
      "Update the information about enabled repositories": [
        "有効なリポジトリーの情報を更新する"
      ],
      "Update the quantity of one or more subscriptions on an upstream allocation": [
        "アップストリームの割り当てに含まれる 1 つ以上のサブスクリプションの数量を更新します"
      ],
      "Update version": [
        "バージョンの更新"
      ],
      "Updated": [
        "更新済み"
      ],
      "Updated component details": [
        "更新されたコンポーネントの詳細"
      ],
      "Updated from": [
        "更新元"
      ],
      "Updates": [
        "更新"
      ],
      "Updates a product": [
        "製品の更新"
      ],
      "Updates available: Component content view versions have been updated.": [
        ""
      ],
      "Updates available: Repositories and/or filters have changed.": [
        ""
      ],
      "Updating Package...": [
        "パッケージを更新しています..."
      ],
      "Updating System Purpose for host": [
        "ホストのシステム目的を更新中"
      ],
      "Updating System Purpose for host %s": [
        "ホスト %s のシステム目的を更新中"
      ],
      "Updating package group...": [
        "パッケージグループを更新しています..."
      ],
      "Updating repository authentication configuration": [
        "リポジトリー認証設定の更新"
      ],
      "Upgradable": [
        "アップグレード可能"
      ],
      "Upgradable to": [
        "以下にアップグレード可能:"
      ],
      "Upgrade": [
        "アップグレード"
      ],
      "Upgrade all packages": [
        ""
      ],
      "Upgrade packages": [
        ""
      ],
      "Upgrade via customized remote execution": [
        "カスタマイズされたリモート実行によるアップグレード"
      ],
      "Upgrade via remote execution": [
        "リモート実行によるアップグレード"
      ],
      "Upload Content Credential contents": [
        "コンテンツ認証情報のコンテンツのアップロード"
      ],
      "Upload a chunk of the file's content": [
        "ファイルのコンテンツのチャンクをアップロード"
      ],
      "Upload a subscription manifest": [
        "サブスクリプションマニフェストのアップロード"
      ],
      "Upload into": [
        "アップロード先"
      ],
      "Upload package / repos profile": [
        ""
      ],
      "Upload request id": [
        "要求 ID のアップロード"
      ],
      "Upstream Candlepin": [
        "アップストリーム Candlepin"
      ],
      "Upstream Content View Label, default: Default_Organization_View. Relevant only for 'upstream_server' type.": [
        "アップストリームコンテンツビューラベル。デフォルト: Default_Organization_View。'upstream_server' タイプにのみ必要です。"
      ],
      "Upstream Lifecycle Environment, default: Library. Relevant only for 'upstream_server' type.": [
        "アップストリームライフサイクル環境。デフォルト: Library。'upstream_server' タイプにのみ必要です。"
      ],
      "Upstream Name cannot be blank when Repository URL is provided.": [
        "リポジトリー URL を指定する場合には、アップストリーム名を空白にすることはできません。"
      ],
      "Upstream authentication token string for yum repositories.": [
        ""
      ],
      "Upstream foreman server to sync CDN content from. Relevant only for 'upstream_server' type.": [
        "CDN コンテンツの同期元となるアップストリームの Foreman サーバーです。'upstream_server' タイプにのみ必要です。"
      ],
      "Upstream identity certificate not available": [
        "アップストリームの ID 証明書を利用できません"
      ],
      "Upstream organization %s does not provide this content path": [
        "アップストリーム組織 %s はこのコンテンツパスを提供していません"
      ],
      "Upstream organization %{org_label} does not have a content view with the label %{cv_label}": [
        "アップストリーム組織 %{org_label} には、ラベルが %{cv_label} のコンテンツビューがありません"
      ],
      "Upstream organization %{org_label} does not have a lifecycle environment with the label %{lce_label}": [
        "アップストリーム組織 %{org_label} には、ラベルが %{lce_label} のライフサイクル環境がありません"
      ],
      "Upstream organization to sync CDN content from. Relevant only for 'upstream_server' type.": [
        "CDN コンテンツの同期元となるアップストリームの組織。'upstream_server' タイプにのみ必要です。"
      ],
      "Upstream password requires upstream username be set.": [
        "アップストリームのパスワードには、アップストリームのユーザー名を設定する必要があります。"
      ],
      "Upstream username and password may only be set on custom repositories.": [
        "アップストリームのユーザー名とパスワードは、カスタムリポジトリーでのみ設定できます。"
      ],
      "Upstream username and upstream password cannot be blank for ULN repositories": [
        "ULN リポジトリーでは、アップストリームのユーザー名およびパスワードを空白にすることはできません"
      ],
      "Upstream username requires upstream password be set.": [
        "アップストリームのユーザー名には、アップストリームのパスワードを設定する必要があります。"
      ],
      "Usage": [
        "使用状況"
      ],
      "Usage Type": [
        "使用タイプ"
      ],
      "Usage of host": [
        "ホストの使用状況"
      ],
      "Usage type": [
        "使用タイプ"
      ],
      "Use HTTP Proxies": [
        "HTTP プロキシーの使用"
      ],
      "Use HTTP proxies": [
        "HTTP プロキシーの使用"
      ],
      "Used to determine download concurrency of the repository in pulp3. Use value less than 20. Defaults to 10": [
        "pulp3 のリポジトリーの同時ダウンロード数を判断するのに使用します。値は 20 未満を使用してください。デフォルト値は 10 です。"
      ],
      "User": [
        "ユーザー"
      ],
      "User '%s' did not specify an organization ID and does not have a default organization.": [
        "ユーザー '%s' に組織 ID が指定されていないので、デフォルトの組織がありません。"
      ],
      "User '%{user}' does not belong to Organization '%{organization}'.": [
        "ユーザー '%{user}' は組織 '%{organization}' に所属していません。"
      ],
      "User IDs": [
        "ユーザー ID"
      ],
      "User must be logged in.": [
        "ユーザーはログインしている必要があります。"
      ],
      "Username": [
        "ユーザー名"
      ],
      "Username for authentication. Relevant only for 'upstream_server' type.": [
        "認証用のユーザー名。'upstream_server' タイプにのみ必要です。"
      ],
      "Username for the flatpak remote": [
        ""
      ],
      "Username of the upstream repository user used for authentication": [
        "認証に使用するアップストリームリポジトリーユーザーのユーザー名"
      ],
      "Username to access URL": [
        "URL にアクセスするためのユーザー名"
      ],
      "Username, Password, Organization Label, and SSL CA Content Credential must be provided together.": [
        "ユーザー名、パスワード、組織ラベル、および SSL CA コンテンツ認証情報は、一緒に指定する必要があります。"
      ],
      "Username, Password, Upstream Organization Label, and SSL CA Credential are required when using an upstream Foreman server.": [
        "アップストリームの Foreman サーバーを使用する場合は、ユーザー名、パスワード、アップストリーム組織ラベル、および SSL CA 認証情報が必要です。"
      ],
      "Validate host/lifecycle environment/content source coherence": [
        ""
      ],
      "Validate that a host's assigned lifecycle environment is synced by the smart proxy from which the host will get its content. Applies only to API requests; does not affect web UI checks": [
        ""
      ],
      "Value must either be a boolean or 'default' for 'enabled'": [
        "値は、ブール値またはデフォルト (「有効」) のいずれかである必要があります"
      ],
      "Verify SSL": [
        "SSL の確認"
      ],
      "Verify checksum for content on smart proxy": [
        ""
      ],
      "Verify checksum for one or more products": [
        "1 つ以上の製品のチェックサムを確認します"
      ],
      "Verify checksum of repositories in %{name} %{version}": [
        ""
      ],
      "Verify checksum of repository contents": [
        "リポジトリーの内容のチェックサムを確認する"
      ],
      "Verify checksum of repository contents in the content view version": [
        ""
      ],
      "Verify checksum of version repositories": [
        ""
      ],
      "Version": [
        "バージョン"
      ],
      "Version ": [
        "バージョン "
      ],
      "Version ${item.version}": [
        "バージョン ${item.version}"
      ],
      "Version ${version.version}": [
        "${version.version} バージョン $"
      ],
      "Version ${versionNameToRemove} will be deleted from all environments. It will no longer be available for promotion.": [
        "バージョン {versionNameToRemove} は、すべての環境から削除されます。プロモーションの対象ではなくなります。"
      ],
      "Version ${versionNameToRemove} will be deleted from the listed environments. It will no longer be available for promotion.": [
        "バージョン {versionNameToRemove} は、一覧表示された環境から削除されます。プロモーションの対象ではなくなります。"
      ],
      "Version ${versionOne}": [
        "バージョン ${versionOne}"
      ],
      "Version ${versionTwo}": [
        "バージョン ${versionTwo}"
      ],
      "Version details updated.": [
        "バージョン情報が更新されました。"
      ],
      "Versions": [
        "バージョン"
      ],
      "Versions ": [
        "バージョン "
      ],
      "Versions to compare": [
        "比較するバージョン"
      ],
      "Versions to exclusively include in the action": [
        "アクションにだけ含めるバージョン"
      ],
      "Versions to explicitly exclude in the action. All other versions will be included in the action, unless an included parameter is passed as well.": [
        "アクションから明示的に除外するバージョン。包含パラメーターが指定されていない限り、それ以外のバージョンはすべてアクションに追加されます。"
      ],
      "Versions will appear here when the content view is published.": [
        "コンテンツビューが公開されると、バージョンがここに表示されます。"
      ],
      "View %{view} has not been promoted to %{env}": [
        "ビュー %{view} は %{env} にプロモートされていません。"
      ],
      "View Filters": [
        ""
      ],
      "View Subscription Usage": [
        "サブスクリプションの使用状況の表示"
      ],
      "View a report of the affected hosts": [
        "影響を受けるホストのレポートを表示します"
      ],
      "View applicable errata": [
        ""
      ],
      "View by": [
        "表示"
      ],
      "View content views": [
        ""
      ],
      "View documentation": [
        ""
      ],
      "View matching content": [
        "マッチするコンテンツの表示"
      ],
      "View sync status": [
        ""
      ],
      "View tasks ": [
        "タスクの表示 "
      ],
      "View the Content Views page": [
        "コンテンツビューページの表示"
      ],
      "View the job": [
        "ジョブの表示"
      ],
      "Virtual": [
        "仮想"
      ],
      "Virtual guests": [
        "仮想ゲスト"
      ],
      "Virtual host": [
        "仮想ホスト"
      ],
      "WARNING: Simple Content Access will be required for all organizations in Katello 4.12.": [
        ""
      ],
      "Waiting to start.": [
        "開始を待機中です。"
      ],
      "Warning": [
        "警告"
      ],
      "When \\\"Releases/Distributions\\\" is set, \\\"Upstream URL\\\" must also be set!": [
        "「リリース/ディストリビューション」を設定した場合は、「アップストリームの URL」も設定する必要があります!"
      ],
      "When \\\"Upstream URL\\\" is set, \\\"Releases/Distributions\\\" must also be set!": [
        "「アップストリームの URL」を設定した場合は、「リリース/ディストリビューション」も設定する必要があります!"
      ],
      "When registering a host via subscription-manager, force use the specified fact (in the form of 'fact.fact')": [
        "subscription-manager でホストを登録すると、指定のファクトを強制的に使用します ('fact.fact' の形式)"
      ],
      "When set to 'True' repository types that are creatable will be returned": [
        "「True」に設定すると、作成可能なリポジトリータイプが返されます"
      ],
      "When unregistering a host via subscription-manager, also delete the host record. Managed resources linked to host such as virtual machines and DNS records may also be deleted.": [
        "subscription-manager でホストの登録を解除すると、ホストの記録も削除されます。仮想マシンや DNS レコードなど、ホストに関連付けられている管理対象のリソースも削除される可能性があります。"
      ],
      "Whether or not the host collection may have unlimited hosts": [
        "ホストコレクションに無制限のホストが設定された可能性があるかどうか"
      ],
      "Whether or not to auto sync the Smart Proxies after a content view promotion.": [
        "コンテンツビューのプロモート後に Smart Proxy を自動同期するかどうか。"
      ],
      "Whether or not to check the status of backend services such as pulp and candlepin prior to performing some actions.": [
        "一部のアクションを実行する前に pulp や candlepin などのバックエンドサービスのステータスを確認するかどうか。"
      ],
      "Whether or not to regenerate the repository on disk. Default: true": [
        "ディスクにリポジトリーを再生成するかどうか。デフォルト: true"
      ],
      "Whether or not to return filters applied to the content view version": [
        ""
      ],
      "Whether or not to show all results": [
        "すべての結果を表示するかどうか"
      ],
      "Whether or not to sync an external capsule after upload. Default: true": [
        "アップロード後に外部 Capsule を同期するかどうか。デフォルト: True"
      ],
      "Whether to include available content attribute in results": [
        "使用可能なコンテンツ属性を結果に含めるかどうか"
      ],
      "Workers": [
        "ワーカー"
      ],
      "Wrong content type submitted.": [
        "誤ったコンテンツタイプが送信されました。"
      ],
      "Yay empty state": [
        "Yay 空の状態"
      ],
      "Yes": [
        "はい"
      ],
      "You are not allowed to promote to Environments %s": [
        "環境 %s にプロモートできません"
      ],
      "You are not allowed to publish Content View %s": [
        "コンテンツビュー %s を公開できません"
      ],
      "You can check sync status for repositories only in the library lifecycle environment.'": [
        "ライブラリーのライフサイクル環境でのみリポジトリーの同期状態を確認できます。"
      ],
      "You cannot have more than %{max_hosts} host(s) associated with host collection '%{host_collection}'.": [
        "%{max_hosts} を超えるホストをホストコレクション '%{host_collection}' に関連付けることはできません。\\\""
      ],
      "You cannot set an organization's parent. This feature is disabled.": [
        "組織の親を設定することはできません。この機能は無効にされています。"
      ],
      "You cannot set an organization's parent_id. This feature is disabled.": [
        "組織の parent_id を設定できません。この機能は無効にされています。"
      ],
      "You currently don't have any ${selectedContentType}.": [
        "現在、{selectedContentType} はありません。"
      ],
      "You currently don't have any alternate content sources.": [
        "現時点で、代替コンテンツソースはありません。"
      ],
      "You currently don't have any related content views.": [
        ""
      ],
      "You currently don't have any repositories associated with this content.": [
        "現在、このコンテンツに関連付けられているリポジトリーはありません。"
      ],
      "You currently don't have any repositories to add to this filter.": [
        "現在、このフィルターに追加するリポジトリーはありません。"
      ],
      "You currently have no content views to display": [
        ""
      ],
      "You do not have permissions to delete %s": [
        "%s を削除する権限がありません。"
      ],
      "You have not set a default organization on the user %s.": [
        "ユーザー %s には、デフォルト組織が設定されていません。"
      ],
      "You have subscriptions expiring within %s days": [
        "%s 日以内に期限切れになるサブスクリプションがあります"
      ],
      "You have unsaved changes. Do you want to exit without saving your changes?": [
        "保存されていない変更があります。変更を保存せずに終了しますか?"
      ],
      "You must select at least one host.": [
        ""
      ],
      "You were not allowed to add %s": [
        "%s を追加できません"
      ],
      "You were not allowed to change sync plan for %s": [
        "%s の同期プランを変更できません"
      ],
      "You were not allowed to delete %s": [
        "%s を削除できません"
      ],
      "You were not allowed to sync %s": [
        "%s を同期できません"
      ],
      "You're making changes to %(entitlementCount)s entitlement(s)": [
        "%(entitlementCount)s 件のエンタイトルメントに変更を加えています"
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
        "検索クエリーが無効でした。確認してからもう一度お試しください。このエラーの詳細はアプリケーションログに送信されました。"
      ],
      "Your search returned no matching ": [
        "検索条件にマッチする項目はありませんでした "
      ],
      "Your search returned no matching ${name}.": [
        "検索条件にマッチする ${name} はありませんでした"
      ],
      "Your search returned no matching DEBs.": [
        "検索条件で一致する DEB が返されませんでした。"
      ],
      "Your search returned no matching Module streams.": [
        "検索条件にマッチするモジュールストリームはありませんでした。"
      ],
      "Your search returned no matching activation keys.": [
        "検索条件にマッチするアクティベーションキーはありませんでした。"
      ],
      "Your search returned no matching hosts.": [
        "検索条件にマッチするホストはありませんでした。"
      ],
      "Your search returned no matching non-modular RPMs.": [
        ""
      ],
      "Yum": [
        "Yum"
      ],
      "a content unit": [
        "コンテンツユニット"
      ],
      "a custom CDN URL": [
        "カスタム CDN URL"
      ],
      "a deb package": [
        "deb パッケージ"
      ],
      "a docker manifest": [
        "Docker マニフェスト"
      ],
      "a docker manifest list": [
        "docker マニフェスト一覧"
      ],
      "a docker tag": [
        "Docker タグ"
      ],
      "a file": [
        "ファイル"
      ],
      "a module stream": [
        "モジュールストリーム"
      ],
      "a package": [
        "パッケージ"
      ],
      "a package group": [
        "パッケージグループ"
      ],
      "actions not found": [
        "アクションが見つかりません"
      ],
      "activation key": [
        ""
      ],
      "activation key identifier": [
        "アクティベーションキー ID"
      ],
      "activation key name to filter by": [
        "フィルターするアクティベーションキー名"
      ],
      "activation keys": [
        "アクティベーションキー"
      ],
      "add all module streams without errata to the included/excluded list. (module stream filter only)": [
        "エラータなしのすべてのモジュールストリームを組み込み/除外一覧に追加。(モジュールストリームフィルターのみ)"
      ],
      "add all packages without errata to the included/excluded list. (package filter only)": [
        "エラータなしのすべてのパッケージを組み込み/除外一覧に追加。(パッケージフィルターのみ)"
      ],
      "all environments": [
        "すべての環境"
      ],
      "all packages": [
        "すべてのパッケージ"
      ],
      "all packages update": [
        "すべてのパッケージの更新"
      ],
      "all packages update failed": [
        "すべてのパッケージの更新が失敗しました。"
      ],
      "allow unauthenticed pull of container images": [
        "コンテナーイメージを認証なしでプルすることを許可します"
      ],
      "already belongs to the content view": [
        "すでにコンテンツビューに属しています"
      ],
      "already taken": [
        "すでに使用されています"
      ],
      "an ansible collection": [
        "ansible コレクション"
      ],
      "an erratum": [
        "エラータ"
      ],
      "an organization": [
        "組織"
      ],
      "are only allowed for Yum repositories.": [
        "Yum リポジトリーでのみ許可されています。"
      ],
      "attempted to sync a non-library repository.": [
        ""
      ],
      "attempted to sync without a feed URL": [
        "フィード URL なしで同期が試行されました"
      ],
      "auto attach subscriptions upon registration": [
        "登録時のサブスクリプションの自動割り当て"
      ],
      "base url to perform repo discovery on": [
        "リポジトリー検出を実行するベース URL"
      ],
      "bug fix": [
        ""
      ],
      "bug fixes": [
        ""
      ],
      "bulk add filter rules": [
        "フィルタールールの一括追加"
      ],
      "bulk delete filter rules": [
        "フィルタールールの一括削除"
      ],
      "can the activation key have unlimited hosts": [
        "アクティベーションキーにホストを無制限に設定可能かどうか"
      ],
      "can't be blank": [
        "空白にしないでください"
      ],
      "cannot add filter to generated content views": [
        "生成コンテンツビューにフィルターを追加できません"
      ],
      "cannot add filter to import-only view": [
        "インポート専用ビューにフィルターを追加できません"
      ],
      "cannot be a binary file.": [
        "バイナリーファイルは指定できません。"
      ],
      "cannot be blank": [
        "空白にしないでください。"
      ],
      "cannot be blank when Repository URL is provided.": [
        "リポジトリー URL が指定されている場合には、空白にすることはできません。"
      ],
      "cannot be changed.": [
        "変更できません。"
      ],
      "cannot be deleted if it has been promoted.": [
        "プロモート済みの場合は削除できません。"
      ],
      "cannot be less than one": [
        "1 未満を指定できません"
      ],
      "cannot be lower than current usage count (%s)": [
        "現在の使用数 (%s) より少ない値を指定できません"
      ],
      "cannot be nil": [
        "Nill にしないでください"
      ],
      "cannot be set because unlimited hosts is set": [
        "ホストが無制限に設定されているため設定できません"
      ],
      "cannot be set for repositories without 'Additive' mirroring policy.": [
        ""
      ],
      "cannot contain characters other than ascii alpha numerals, '_', '-'. ": [
        "ASCII 英数字、アンダースコア (_)、ハイフン (-) 以外の文字を含めることはできません。 "
      ],
      "cannot contain commas": [
        "コンマを含めることはできません"
      ],
      "cannot contain filters if composite view": [
        "複合ビューの場合、フィルターを含めることはできません"
      ],
      "cannot contain filters whose repositories do not belong to this content view": [
        "リポジトリーがこのコンテンツビューに属さないフィルターを含めることはできません"
      ],
      "cannot contain more than %s characters": [
        "%s 文字以下にしてください"
      ],
      "change the host's content source.": [
        ""
      ],
      "checking %s task status": [
        "%s タスクステータスの確認"
      ],
      "checking Pulp task status": [
        "Pulp タスクステータスの確認"
      ],
      "click here": [
        "こちらをクリック"
      ],
      "composite content view identifier": [
        "複合コンテンツビュー ID"
      ],
      "composite content view numeric identifier": [
        "複合コンテンツビューの数値 ID"
      ],
      "content release version": [
        "コンテンツリリースバージョン"
      ],
      "content type ('deb', 'docker_manifest', 'file', 'ostree_ref', 'rpm', 'srpm')": [
        "コンテンツタイプ ('deb'、'docker_manifest'、'file'、'ostree_ref'、'rpm'、'srpm')"
      ],
      "content type ('deb', 'file', 'ostree_ref', 'rpm', 'srpm')": [
        ""
      ],
      "content view component ID. Identifier of the component association": [
        "コンテンツビューコンポーネント ID。コンポーネントの関連付けの ID"
      ],
      "content view filter identifier": [
        "コンテンツビューフィルター ID"
      ],
      "content view filter rule identifier": [
        "コンテンツビューフィルタールール ID"
      ],
      "content view identifier": [
        "コンテンツビュー ID"
      ],
      "content view identifier of the component who's latest version is desired": [
        "最新バージョンが必要なコンポーネントのコンテンツビュー ID"
      ],
      "content view node publish": [
        "コンテンツビューノードの公開"
      ],
      "content view numeric identifier": [
        "コンテンツビュー数値 ID"
      ],
      "content view publish": [
        "コンテンツビューの公開"
      ],
      "content view refresh": [
        "コンテンツビューの更新"
      ],
      "content view to reassign orphaned activation keys to": [
        "単独のアクティベーションキーを再度割り当てるコンテンツビュー"
      ],
      "content view to reassign orphaned systems to": [
        "単独のシステムを再度割り当てるコンテンツビュー"
      ],
      "content view version identifier": [
        "コンテンツビューバージョン ID"
      ],
      "content view version identifiers to be deleted": [
        "削除するコンテンツビューバージョン ID"
      ],
      "content view versions to compare": [
        "比較するコンテンツビューバージョン"
      ],
      "create a custom product": [
        ""
      ],
      "create a filter for a content view": [
        "コンテンツビューのフィルターを作成します"
      ],
      "day": [
        ""
      ],
      "days": [
        ""
      ],
      "deb, package, package group, or docker tag names": [
        "deb、パッケージ、パッケージグループ、または Docker タグ名"
      ],
      "deb_ids is not an array": [
        "deb_ids は配列ではありません"
      ],
      "deb_names_for_job_template: Action must be one of %s": [
        ""
      ],
      "delete a filter": [
        "フィルターを削除します。"
      ],
      "delete the content view with all the versions and environments": [
        "すべてのバージョンおよび環境のコンテンツビューの削除"
      ],
      "description": [
        "説明"
      ],
      "description of the environment": [
        "環境の説明"
      ],
      "description of the filter": [
        "フィルターの説明"
      ],
      "description of the repository": [
        "リポジトリーの説明"
      ],
      "disk": [
        "ディスク"
      ],
      "download policy for deb, docker, file and yum repos (either 'immediate' or 'on_demand')": [
        ""
      ],
      "enables or disables synchronization": [
        "同期の有効化または無効化"
      ],
      "enhancement": [
        ""
      ],
      "enhancements": [
        ""
      ],
      "environment identifier": [
        "環境 ID"
      ],
      "environment numeric identifier": [
        "環境の数値 ID"
      ],
      "environment numeric identifiers to be removed": [
        "削除する環境の数値 ID"
      ],
      "environment to reassign orphaned activation keys to": [
        "単独のアクティベーションキーを再度割り当てる環境"
      ],
      "environment to reassign orphaned systems to": [
        "単独のシステムを再度割り当てる環境"
      ],
      "environments": [
        "環境"
      ],
      "errata_id of the content view filter rule": [
        "コンテンツビューフィルタールールの errata_id"
      ],
      "errata_ids is a required parameter": [
        "errata_ids は必須パラメーターです"
      ],
      "erratum: IDs or a select all object": [
        "エラータ: ID またはすべてのオブジェクトを選択"
      ],
      "erratum: allow types not matching a valid errata type": [
        ""
      ],
      "erratum: end date (YYYY-MM-DD)": [
        "エラータ: 終了日 (YYYY-MM-DD)"
      ],
      "erratum: id": [
        "エラータ: ID"
      ],
      "erratum: search using the 'Issued On' or 'Updated On' column of the errata. Values are 'issued'/'updated'": [
        "エラータ: エラータの「発行日」または「更新日」の列を使用した検索。値は 'issued'/'updated' です"
      ],
      "erratum: start date (YYYY-MM-DD)": [
        "エラータ: 開始日 (YYYY-MM-DD)"
      ],
      "erratum: types (enhancement, bugfix, security)": [
        "エラータ: タイプ (機能強化、バグ修正、セキュリティー)"
      ],
      "filter by interval": [
        "間隔別に絞り込む"
      ],
      "filter by name": [
        "名前別に絞り込む"
      ],
      "filter by sync date": [
        "同期日時別に絞り込む"
      ],
      "filter content view filters by name": [
        "名前でコンテンツビューフィルターを絞り込む"
      ],
      "filter identifier": [
        "フィルター ID"
      ],
      "filter identifiers": [
        "フィルター ID"
      ],
      "filter only environments containing this label": [
        "このラベルを含む環境のみをフィルター"
      ],
      "filter only environments containing this name": [
        "この名前を含む環境のみをフィルター"
      ],
      "for repository '%{name}' is not unique and cannot be created in '%{env}'. Its Container Repository Name (%{container_name}) conflicts with an existing repository.  Consider changing the Lifecycle Environment's Registry Name Pattern to something more specific.": [
        "リポジトリーの場合には、'%{name}' は一意ではなく、'%{env}' で作成できません。コンテナーリポジトリー名 (%{{container_name}) が既存のリポジトリーと競合します。ライフサイクル環境のレジストリー名パターンをより具体的なパターンに変更することを検討してください。"
      ],
      "force content view promotion and bypass lifecycle environment restriction": [
        "コンテンツビューを強制的にプロモートしてライフサイクル環境の制限を無視する"
      ],
      "foreman-tasks service not running or is not ready yet": [
        "foreman-tasks サービスが実行されていないか、まだ準備が整っていません"
      ],
      "has already been taken": [
        "すでに使用されています"
      ],
      "has already been taken for a product in this organization.": [
        "この組織の製品に対してすでに使用されています。"
      ],
      "has already been taken for this product.": [
        "この製品に対してすでに使用されています。"
      ],
      "here": [
        ""
      ],
      "host": [
        ""
      ],
      "host collection name to filter by": [
        "フィルターに使用するホストコレクション名"
      ],
      "hosts": [
        "ホスト"
      ],
      "how often synchronization should run": [
        "同期の実行頻度"
      ],
      "id of a host": [
        "ホストの ID"
      ],
      "id of host": [
        "ホストの ID"
      ],
      "id of the gpg key that will be assigned to the new repository": [
        "新規リポジトリーに割り当てられる GPG キーの ID"
      ],
      "identifier of the version of the component content view": [
        "コンポーネントコンテンツビューのバージョンの ID"
      ],
      "ids to filter content by": [
        "コンテンツのフィルターに使用する ID"
      ],
      "if true, Katello will verify the upstream url's SSL certifcates are signed by a trusted CA": [
        "True の場合には、アップストリームの URL の SSL 証明書が信頼できる CA により署名されているかを Katello が検証します"
      ],
      "initiating %s task": [
        "%s タスクの開始"
      ],
      "initiating Pulp task": [
        "Pulp タスクの開始"
      ],
      "installed": [
        ""
      ],
      "installing errata...": [
        "エラータをインストールしています..."
      ],
      "installing erratum...": [
        "エラータをインストールしています..."
      ],
      "installing or updating packages": [
        "パッケージをインストール/更新しています"
      ],
      "installing package group...": [
        "パッケージグループをインストールしています..."
      ],
      "installing package groups...": [
        "パッケージグループをインストールしています..."
      ],
      "installing package...": [
        "パッケージをインストールしています..."
      ],
      "installing packages...": [
        "パッケージをインストールしています..."
      ],
      "interpret specified object to return only Repositories that can be associated with specified object.  Only 'content_view' & 'content_view_version' are supported.": [
        "指定のオブジェクトを解釈して、指定のオブジェクトに関連付け可能なリポジトリーのみを返します。'content_view' と 'content_view_version' のみがサポートされます。"
      ],
      "invalid container image name": [
        "無効なコンテナーイメージ名"
      ],
      "invalid: Repositories can only require one OS version.": [
        "無効: リポジトリーに必要な OS バージョンは 1 つだけです。"
      ],
      "invalid: The content source must sync the lifecycle environment assigned to the host. See the logs for more information.": [
        ""
      ],
      "is already attached to the capsule": [
        "Capsule にすでに割り当て済みです"
      ],
      "is invalid": [
        "無効です"
      ],
      "is not a valid type. Must be one of the following: %s": [
        "有効なタイプではありません。次のいずれかである必要があります: %s"
      ],
      "is not allowed for ACS. Must be one of the following: %s": [
        "ACS では許可されていません。次のいずれかである必要があります: %s"
      ],
      "is not enabled. must be one of the following: %s": [
        "有効になっていません。次のいずれかである必要があります: %s"
      ],
      "is only allowed for Yum repositories.": [
        "Yum リポジトリーでのみ許可されています。"
      ],
      "label of the environment": [
        "環境のラベル"
      ],
      "label of the repository": [
        "リポジトリーのラベル"
      ],
      "limit to only repositories with this download policy": [
        "このダウンロードポリシーのあるリポジトリーのみに制限します"
      ],
      "list filters": [
        "フィルターの一覧を表示します。"
      ],
      "list of repository ids": [
        "リポジトリー ID の一覧"
      ],
      "list of rpm filename strings to include in published version": [
        "公開バージョンに含める rmp ファイル名文字列の一覧"
      ],
      "max_hosts must be given a value if this host collection is not unlimited.": [
        "このホストコレクションが無制限でない場合は、max_hosts に値を提供する必要があります。"
      ],
      "maximum number of registered content hosts": [
        "登録されたコンテンツホストの最大数"
      ],
      "may not be less than the number of hosts associated with the host collection.": [
        "ホストコレクションに関連付けられているホストの数以上にする必要があります。"
      ],
      "module stream ids": [
        "モジュールストリーム ID"
      ],
      "module streams not found": [
        "モジュールストリームが見つかりません"
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
        "%{gpg_key} または %{cert} でなければなりません。"
      ],
      "must be a positive integer value.": [
        "正の整数値でなければなりません。"
      ],
      "must be one of the following: %s": [
        "以下のいずれかでなければなりません: %s"
      ],
      "must be one of: %s": [
        "%s のいずれかでなければなりません"
      ],
      "must be true or false": [
        ""
      ],
      "must be unique within one organization": [
        "1 つの組織内で一意である必要があります"
      ],
      "must contain '%s'": [
        "'%s' を含めてください"
      ],
      "must contain GPG Key": [
        "GPG キーを含む必要があります"
      ],
      "must contain at least %s character": [
        "少なくとも %s 文字以上にしてください"
      ],
      "must contain valid  Public GPG Key": [
        "有効な公開 GPG キーを含む必要があります"
      ],
      "must contain valid Public GPG Key": [
        "有効な公開 GPG キーを含む必要があります"
      ],
      "must not be a negative value.": [
        "負の値は使用できません"
      ],
      "must not contain leading or trailing white spaces.": [
        "先頭または末尾に空白を含めることはできません。"
      ],
      "name": [
        "名前"
      ],
      "name of organization": [
        "組織の名前"
      ],
      "name of the content view filter rule": [
        "コンテンツビューのフィルタールール名"
      ],
      "name of the environment": [
        "環境の名前"
      ],
      "name of the filter": [
        "フィルターの名前"
      ],
      "name of the organization": [
        "組織の名前"
      ],
      "name of the repository": [
        "リポジトリーの名前"
      ],
      "name of the subscription": [
        "サブスクリプションの名前"
      ],
      "new name for the filter": [
        "フィルターの新規の名前"
      ],
      "new name to be given to the environment": [
        "環境に付与される新規の名前"
      ],
      "no": [
        "no"
      ],
      "no global default": [
        "グローバルデフォルトなし"
      ],
      "obtain manifest history for subscriptions": [
        "サブスクリプションのマニフェスト履歴の取得"
      ],
      "of environment must be unique within one organization": [
        "環境名は 1 つの組織内で一意である必要があります"
      ],
      "only show the repositories readable by this user with this username": [
        "このユーザー名を持つこのユーザーで読み取り可能なリポジトリーのみを表示する"
      ],
      "organization ID": [
        "組織 ID"
      ],
      "organization identifier": [
        "組織 ID"
      ],
      "package group: uuid": [
        "パッケージグループ: uuid"
      ],
      "package, package group, or docker tag names": [
        "パッケージ、パッケージグループ、または Docker タグ名"
      ],
      "package, package group, or docker tag: name": [
        "パッケージ、パッケージグループ、または Docker タグ: 名前"
      ],
      "package: architecture": [
        "パッケージ: アーキテクチャー"
      ],
      "package: maximum version": [
        "パッケージ: 最大のバージョン"
      ],
      "package: minimum version": [
        "パッケージ: 最小のバージョン"
      ],
      "package: version": [
        "パッケージ: バージョン"
      ],
      "package_ids is not an array": [
        "package_ids は配列ではありません"
      ],
      "package_names_for_job_template: Action must be one of %s": [
        "package_names_for_job_template: アクションは %s のいずれかでなければなりません。"
      ],
      "params 'show_all_for' and 'available_for' must be used independently": [
        "パラメーター 'show_all_for 'と' available_for 'は個別に使用する必要があります"
      ],
      "pattern for container image names": [
        "コンテナーイメージ名のパターン"
      ],
      "perform an incremental import": [
        "増分インポートの実行"
      ],
      "policies for HTTP proxy for content sync": [
        "コンテンツ同期の HTTP プロキシーのポリシー"
      ],
      "policy for HTTP proxy for content sync": [
        "コンテンツ同期の HTTP プロキシーのポリシー"
      ],
      "prior environment can only have one child": [
        "以前の環境が所有できる子は 1 つのみです"
      ],
      "product numeric identifier": [
        "製品の数値 ID"
      ],
      "register_hostname_fact set for %s, but no fact found, or was localhost.": [
        "%s に register_hostname_fact が設定されていますが、ファクトが見つからないか、ローカルホストが使用されています。"
      ],
      "removing package group...": [
        "パッケージグループを削除しています..."
      ],
      "removing package groups...": [
        "パッケージグループを削除しています..."
      ],
      "removing package...": [
        "パッケージを削除しています..."
      ],
      "removing packages...": [
        "パッケージを削除しています..."
      ],
      "repo label": [
        "リポジトリーラベル"
      ],
      "repository ID": [
        "リポジトリー ID"
      ],
      "repository id": [
        "リポジトリー ID"
      ],
      "repository identifier": [
        "リポジトリー ID"
      ],
      "repository source url": [
        "リポジトリーソース URL"
      ],
      "root-node of collection contained in responses (default: 'results')": [
        "応答に含まれるコレクションの root ノード (デフォルト: 'results')"
      ],
      "root-node of single-resource responses (optional)": [
        "単一リソース応答の root ノード (オプション)"
      ],
      "rule identifier": [
        "ルール ID"
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
        "サービスレベル"
      ],
      "set true if you want to see only library environments": [
        "ライブラリー環境のみを表示する場合 true に設定"
      ],
      "sha256": [
        "sha256"
      ],
      "show archived repositories": [
        "アーカイブされたリポジトリーの表示"
      ],
      "show filter info": [
        "フィルター情報の表示"
      ],
      "show repositories in Library and the default content view": [
        "ライブラリーのリポジトリーおよびデフォルトコンテンツビューの表示"
      ],
      "some executors are not responding, check %{status_url}": [
        "一部のエグゼキューターが応答していません。{status_url} を確認してください"
      ],
      "specifies if content should be included or excluded, default: inclusion=false": [
        "コンテンツの組み込みまたは除外の指定。デフォルト: inclusion=false"
      ],
      "start datetime of synchronization": [
        "同期の開始日時"
      ],
      "subscriptions not specified": [
        "サブスクリプションが指定されていません"
      ],
      "sync plan description": [
        "同期プランの説明"
      ],
      "sync plan name": [
        "同期プラン名"
      ],
      "sync plan numeric identifier": [
        "同期プランの数値 ID"
      ],
      "system registration": [
        ""
      ],
      "the documentation.": [
        ""
      ],
      "the following attributes can not be updated for the Red Hat provider: [ %s ]": [
        "Red Hat プロバイダーの次の属性は更新できません: [ %s ]"
      ],
      "the host": [
        ""
      ],
      "the hosts": [
        ""
      ],
      "to": [
        "から"
      ],
      "true if the latest version of the component's content view is desired": [
        "コンポーネントのコンテンツビューの最新版が必要な場合には True を指定します"
      ],
      "true if the latest version of the components content view is desired": [
        "コンポーネントのコンテンツビューの最新版が必要な場合には True を指定します"
      ],
      "true if this repository can be published via HTTP": [
        "このリポジトリーが HHTP 経由で公開できる場合は true"
      ],
      "type of filter (e.g. deb, rpm, package_group, erratum, erratum_id, erratum_date, docker, modulemd)": [
        "フィルターのタイプ (例: deb、rpm、package_group、erratum、erratum_id、erratum_date、docker、modulemd)"
      ],
      "types of filters": [
        "フィルターの種類"
      ],
      "unknown permission for %s": [
        "%s の権限が不明です"
      ],
      "unlimited": [
        "無制限"
      ],
      "update a filter": [
        "フィルターの更新"
      ],
      "updated": [
        ""
      ],
      "updating package group...": [
        "パッケージグループを更新しています..."
      ],
      "updating package groups...": [
        "パッケージグループを更新しています..."
      ],
      "updating package...": [
        "パッケージを更新しています..."
      ],
      "updating packages...": [
        "パッケージを更新しています..."
      ],
      "upstream Foreman server": [
        "アップストリーム Foreman サーバー"
      ],
      "url not defined.": [
        "URL は定義されていません。"
      ],
      "via customized remote execution": [
        "カスタマイズされたリモート実行経由"
      ],
      "via remote execution": [
        "リモート実行経由"
      ],
      "view content view tabs.": [
        "コンテンツビュータブを確認してください。"
      ],
      "waiting for %s to finish the task": [
        "%s がタスクを終了するまで待機"
      ],
      "waiting for Pulp to finish the task %s": [
        "Pulp がタスク %s を終了するまで待機"
      ],
      "waiting for Pulp to start the task %s": [
        "Pulp がタスク %s を開始するまで待機"
      ],
      "whitespace-separated list of architectures to be synced from deb-archive": [
        "deb-archive から同期されるアーキテクチャーの空白で区切られたリスト"
      ],
      "whitespace-separated list of releases to be synced from deb-archive": [
        "deb-archive から同期されるリリースの空白で区切られたリスト"
      ],
      "whitespace-separated list of repo components to be synced from deb-archive": [
        "deb-archive から同期される repo コンポーネントの空白で区切られたリスト"
      ],
      "with": [
        " / "
      ],
      "yes": [
        "yes"
      ],
      "{0} items selected": [
        "選択項目 {0} 件"
      ],
      "{enableRedHatRepos} or {createACustomProduct}.": [
        ""
      ],
      "{numberOfActivationKeys} activation key will be assigned to content view {cvName} in": [
        "{numberOfActivationKeys} アクティベーションキーは、以下のコンテンツビュー {cvName} に割り当てられます:"
      ],
      "{numberOfActivationKeys} activation keys will be assigned to content view {cvName} in": [
        "{numberOfActivationKeys} アクティベーションキーは、以下のコンテンツビュー {cvName} に割り当てられます:"
      ],
      "{numberOfHosts} host will be assigned to content view {cvName} in": [
        "{numberOfHosts} ホストは以下のコンテンツビュー {cvName} に割り当てられます:"
      ],
      "{numberOfHosts} hosts will be assigned to content view {cvName} in": [
        "{numberOfHosts} ホストは以下のコンテンツビュー {cvName} に割り当てられます:"
      ],
      "{versionOrVersions} {versionList} will be deleted and will no longer be available for promotion.": [
        "{versionOrVersions} {versionList} は削除され、プロモーションに利用できなくなります。"
      ],
      "{versionOrVersions} {versionList} will be removed from the following environments:": [
        "{versionOrVersions} {versionList} は次の環境から削除されます:"
      ],
      "{versionOrVersions} {versionList} will be removed from the listed environment and will no longer be available for promotion.": [
        "{versionOrVersions} {versionList} は、一覧表示された環境から削除され、プロモーションの対象ではなくなります。"
      ],
      "{versionOrVersions} {versionList} will be removed from the listed environments and will no longer be available for promotion.": [
        "{versionOrVersions} {versionList} は、一覧表示された環境から削除され、プロモーションの対象ではなくなります。"
      ],
      "{versionOrVersions} {versionList} will be removed from the {envLabel} environment.": [
        "{versionOrVersions} {versionList} は {envLabel} 環境から削除されます。"
      ]
    }
  }
};
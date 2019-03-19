(function () {
    'use strict';

    /**
     * @ngdoc directive
     * @name Bastion.components.directive:bstResourceSwitcher
     *
     * @description
     *   Allows switching between resources on the same level.
     */
    function bstResourceSwitcher($breadcrumb, $location, $state, TableCache) {
        function getTableName(url) {
            var tableName = url.split('/');

            if (isFinite(parseInt(tableName[tableName.length - 1], 10))) {
                tableName.pop();
            }

            return tableName.join('-').slice(1);
        }

        return {
            templateUrl: 'components/views/bst-resource-switcher.html',
            link: function (scope) {
                var breadcrumbs = $breadcrumb.getStatesChain(), listUrl, unregisterWatcher;
                scope.table = {rows: []};

                if (breadcrumbs.length > 0) {
                    listUrl = breadcrumbs[breadcrumbs.length - 2].ncyBreadcrumbLink;
                    scope.table = TableCache.getTable(getTableName(listUrl));
                }

                scope.showSwitcher = function () {
                    var tableHasRows, isNewPage, hideSwitcher;
                    // Must have at least two items to switch between them
                    tableHasRows = scope.table && scope.table.rows.length > 1;
                    hideSwitcher = scope.hideSwitcher;
                    // Don't show the switcher when creating a new product
                    isNewPage = /new$/.test($location.path());

                    return tableHasRows && !isNewPage && !hideSwitcher;
                };

                scope.changeResource = function (id) {
                    var currentUrl, nextUrl;
                    currentUrl = $location.path();
                    nextUrl = currentUrl.replace(/\d+([^\d+]*)$/, id + '$1');
                    $location.path(nextUrl);
                };

                unregisterWatcher = scope.$watch('table.rows', function (rows) {
                    var currentId = $location.path().match(/\d+/) ? parseInt($location.path().match(/\d+/)[0], 10) : null;

                    angular.forEach(rows, function (row) {
                        if (row.id === currentId) {
                            row.selected = true;
                        } else {
                            row.selected = false;
                        }
                    });

                    unregisterWatcher();
                });
            }
        };
    }

    angular.module('Bastion.components').directive('bstResourceSwitcher', bstResourceSwitcher);

    bstResourceSwitcher.$inject = ['$breadcrumb', '$location', '$state', 'TableCache'];

})();

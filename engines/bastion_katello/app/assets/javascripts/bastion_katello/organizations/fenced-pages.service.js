/**
 *@ngdoc service
 *@name Bastion.organizations.service:FencedPages
 *
 *@descriptions
 * Service that keeps track of pages that require an organization to be selected
 */

angular.module('Bastion.organizations').service('FencedPages', ['$state',
    function ($state) {
        var fencedPages = [
            'activation-keys',
            'content-hosts',
            'content-views',
            'docker-tags',
            'errata',
            'content-credentials',
            'host-collections',
            'lifecycle-environments',
            'packages',
            'products',
            'puppet-modules',
            'subscriptions',
            'sync-plans'
        ];

        function getRootPath(path) {
            var rootPath = null;

            if (path && angular.isString(path)) {
                rootPath = path.replace('_', '-').split('/')[1];
            }
            return rootPath;
        }

        this.addPages = function (pages) {
            fencedPages = _.uniq(fencedPages.concat(pages));
        };

        this.list = function () {
            return fencedPages;
        };

        this.isFenced = function (toState) {
            var stateUrl = $state.href(toState);
            return fencedPages.indexOf(getRootPath(stateUrl)) !== -1;
        };
    }
]);

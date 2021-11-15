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
            'subscriptions',
            'sync-plans',
            'files',
            'debs'
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
            var rootPath;
            if (_.isEmpty(stateUrl)) {
                rootPath = toState.templateUrl.replace('_', '-').split('/')[0];
            } else {
                rootPath = getRootPath(stateUrl);
            }
            return fencedPages.indexOf(rootPath) !== -1;
        };
    }
]);

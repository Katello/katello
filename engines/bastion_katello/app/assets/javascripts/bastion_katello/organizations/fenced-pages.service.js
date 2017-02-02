/**
 *@ngdoc service
 *@name Bastion.organizations.service:FencedPages
 *
 *@descriptions
 * Service that keeps track of pages that require an organization to be selected
 */

angular.module('Bastion.organizations').service('FencedPages',
    [function () {
        var fencedPages = [
            'products',
            'activation-keys',
            'environments',
            'subscriptions',
            'gpg-keys',
            'sync-plans',
            'docker-tags',
            'sync-plan',
            'content-views',
            'errata',
            'content-hosts',
            'host-collections',
            'puppet-modules',
            'packages'
        ];

        this.addPages = function (pages) {
            fencedPages = _.uniq(fencedPages.concat(pages));
        };

        this.list = function () {
            return fencedPages.slice();
        };

        this.isFenced = function (toState) {
            return this.list().indexOf(toState.name.split('.')[0]) !== -1;
        };
    }]
);

/**
 * @ngdoc service
 * @name  Bastion.hosts.factory:Host
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for one or more hosts.
 */
angular.module('Bastion.hosts').factory('Host',
    ['BastionResource', function (BastionResource) {
        var resource = BastionResource('api/v2/hosts/:id/:action', {id: '@id'}, {
            postIndex: {method: 'POST', params: {action: 'post_index'}},
            update: {method: 'PUT'},
            updateHostCollections: {method: 'PUT', params: {action: 'host_collections'}},
            autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
        });
        resource.prototype.hasContent = function () {
            return angular.isDefined(this.content_facet_attributes) && angular.isDefined(this.content_facet_attributes.uuid);
        };
        resource.prototype.hasSubscription = function () {
            return angular.isDefined(this.subscription_facet_attributes) && angular.isDefined(this.subscription_facet_attributes.uuid);
        };

        resource.prototype.isRpmEnabled = function() {
            return !this.isDebEnabled();
        };

        resource.prototype.isDebEnabled = function() {
            return _.isString(this.operatingsystem_name) && (this.operatingsystem_name.indexOf("Debian") >= 0 || this.operatingsystem_name.indexOf("Ubuntu") >= 0);
        };

        return resource;
    }]
);

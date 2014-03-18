/**
 * Copyright 2014 Red Hat, Inc.
 *
 * This software is licensed to you under the GNU General Public
 * License as published by the Free Software Foundation; either version
 * 2 of the License (GPLv2) or (at your option) any later version.
 * There is NO WARRANTY for this software, express or implied,
 * including the implied warranties of MERCHANTABILITY,
 * NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 * have received a copy of GPLv2 along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

/**
 * @ngdoc service
 * @name  Bastion.content-views.factory:ContentView
 *
 * @requires $resource
 * @requires gettext
 * @requires CurrentOrganization
 *
 * @description
 *   Provides a $resource for interacting with environments.
 */
angular.module('Bastion.content-views').factory('ContentView',
    ['$resource', 'gettext', 'CurrentOrganization',
    function ($resource, gettext, CurrentOrganization) {
        return $resource('/api/v2/content_views/:id/:action',
            {id: '@id', 'organization_id': CurrentOrganization},
            {
                query:  {method: 'GET', isArray: false},
                update: {method: 'PUT'},
                publish: {method: 'POST', params: {action: 'publish'}},
                history: {method: 'GET', params: {action: 'history'}},
                versions: {method: 'GET', isArray: false, params: {action: 'content_view_versions'}},
                components: {method: 'GET', transformResponse: function (data) {
                    var contentView = angular.fromJson(data);
                    return {results: contentView.components};
                }},
                compositeEligible: {method: 'GET', transformResponse: function (data) {
                    var contentViews = angular.fromJson(data).results;
                    contentViews = _.filter(contentViews, function (contentView) {
                        return !contentView.composite && contentView.versions.length > 0;
                    });
                    return {results: contentViews};
                }},
                availablePuppetModules: {method: 'GET', params: {action: 'available_puppet_modules'},
                    transformResponse: function (data) {
                        var response = angular.fromJson(data);

                        angular.forEach(_.groupBy(response.results, 'author'), function (puppetModules) {
                            var latest = angular.copy(puppetModules[puppetModules.length - 1]);
                            latest.version = gettext('Use Latest (currently %s)').replace('%s', latest.version);
                            latest.useLatest = true;
                            response.results.unshift(latest);
                        });

                        return response;
                    }
                },
                availablePuppetModuleNames: {method: 'GET', params: {action: 'available_puppet_module_names'}}
            }
        );

    }]
);

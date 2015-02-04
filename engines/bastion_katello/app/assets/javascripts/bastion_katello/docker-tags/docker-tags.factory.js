/**
 * Copyright 2015 Red Hat, Inc.
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
 * @name  Bastion.docker-tags.factory:DockerTag
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for Docker Tags
 */
angular.module('Bastion.docker-tags').factory('DockerTag',
    ['BastionResource', function (BastionResource) {

        return BastionResource('/katello/api/v2/docker_tags/:id/',
            {id: '@id'},
            {
                autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
            }
        );

    }]
);

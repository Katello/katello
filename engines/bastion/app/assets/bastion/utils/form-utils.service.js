/**
 * Copyright 2013 Red Hat, Inc.
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
 * @name Bastion.service.directive:FormUtils
 *
 * @requires $http
 *
 * @description
 *   A set of utilities that are useful when using forms.
 */
angular.module('Bastion.utils').service('FormUtils', ['$http', function($http) {

  /**
   * @ngdoc function
   * @name Bastion.service.FormUtils#labelize
   * @methodOf Bastion.service.FormUtils
   * @function
   *
   * @description
   *   Turns a resource's name attribute into a labelized value that is calculated on the server.
   *
   * @param {Resource} resource An object representing a resource entity with a name property
   * @param {ngForm} form An angular form object used to set error status on for the label property.
   * @returns {Bastion.service.FormUtils} Self for chaining.
   */
    this.labelize = function(resource, form) {
        $http.get(
            '/katello/organizations/default_label', {
            params: {'name': resource.name}
        })
        .success(function(response) {
            resource.label = response;
        })
        .error(function(response) {
            form.label.$setValidity('', false);
            form.label.$error.messages = response.errors;
        });

        return this;
    };

}]);

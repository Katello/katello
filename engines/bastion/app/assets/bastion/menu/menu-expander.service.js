/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 **/

/**
 * @ngdoc service
 * @name  Bastion.menu.service:menuExpander
 *
 * @description
 *   Provides a way to add additional menu items from other modules.
 *
 *   Expects menus to be an array of objects of the form:
 *      {url: 'http://redhat.com', label: 'Red Hat'}
 *
 * @usage
 *   angular.module('SomeOtherModule', ['Bastion.menu']);
 *
 *   angular.module('SomeOtherModule').run(['MenuExpander', function(menuExpander) {
 *       menuExpander.setMenu('system', [{'url': 'http://redhat.com', 'label': 'Red Hat'}]);
 *   }]);
 */
angular.module('Bastion.menu').service('MenuExpander', [function() {
    this.menu = {};

    this.getMenu = function(menuName) {
        if (this.menu.hasOwnProperty(menuName)) {
            return this.menu[menuName];
        } else {
            return [];
        }
    };

    this.setMenu = function(menuName, items) {
        if (this.menu.hasOwnProperty(menuName)) {
            this.menu[menuName] = _.uniq(_.union(this.menu[menuName], items), false, function(item) {
                return item.url;
            }, this);
        } else {
            this.menu[menuName] = items;
        }
    };
}]);

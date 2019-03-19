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
 *   angular.module('SomeOtherModule').run(['MenuExpander', function (menuExpander) {
 *       menuExpander.setMenu('system', [{'url': 'http://redhat.com', 'label': 'Red Hat'}]);
 *   }]);
 */
angular.module('Bastion.menu').service('MenuExpander', [function () {
    this.menu = {};

    this.getMenu = function (menuName) {
        if (this.menu.hasOwnProperty(menuName)) {
            return this.menu[menuName];
        }

        return [];
    };

    this.setMenu = function (menuName, items) {
        if (this.menu.hasOwnProperty(menuName)) {
            this.menu[menuName] = _.uniqBy(_.union(this.menu[menuName], items), function (item) {
                return item.url;
            });
        } else {
            this.menu[menuName] = items;
        }
    };
}]);

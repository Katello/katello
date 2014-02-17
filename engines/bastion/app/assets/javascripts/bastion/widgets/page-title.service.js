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
 */

/**
 * @ngdoc service
 * @name  Bastion.widgets.service:PageTitle
 *
 * @requires $window
 * @requires $interpolate
 *
 * @description
 *  Service to set the title of the page and maintain a
 */
angular.module('Bastion.widgets').service('PageTitle', ['$window', '$interpolate',
    function ($window, $interpolate) {
        this.titles = [];

        this.setTitle = function (title, locals) {
            if (title) {
                var interpolated = $interpolate(title);

                $window.document.title = interpolated(locals);
                this.titles.push($window.document.title);
            }
        };

        this.resetToFirst = function () {
            this.titles = this.titles.slice(0, 1);
            $window.document.title = this.titles[0];
        };
    }]
);

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
 * @ngdoc object
 * @name  Bastion.content-views.controller:ContentViewPublishController
 *
 * @requires $scope
 * @requires gettext
 * @requires ContentView
 *
 * @description
 *   Provides the functionality specific to ContentViews for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('Bastion.content-views').controller('ContentViewPublishController',
    ['$scope', 'gettext', 'ContentView',  function ($scope, gettext, ContentView) {

        $scope.version = {};

        $scope.publish = function (contentView) {
            ContentView.publish(contentView, function (task) {
                $scope.transitionTo('content-views.details.tasks.details', {contentViewId: contentView.id, taskId: task.id});
            });
        };
    }]
);

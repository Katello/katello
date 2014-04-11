/**
 Copyright 2014 Red Hat, Inc.

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
 * @ngdoc filter
 * @name  Bastion.content-views.filter:availableForComposite
 *
 * @description
 *   Filter out content views that are already used in a composite.
 *
 * @example
 *   <tr alch-table-row
 *       ng-repeat="contentView in contentViewTable.rows | availableForComposite:compsiteView"
 *       row-select="contentView">...</tr>
 */
angular.module('Bastion.content-views').filter('availableForComposite', [function () {
    return function (contentViews, compositeView) {
        var usedContentViews;
        contentViews = contentViews || [];
        compositeView = compositeView || {};

        usedContentViews = _.pluck(compositeView.components, 'content_view_id');
        return _.filter(contentViews, function (contentView) {
            return usedContentViews.indexOf(contentView.id) === -1 && !contentView.default;
        });
    };
}]);

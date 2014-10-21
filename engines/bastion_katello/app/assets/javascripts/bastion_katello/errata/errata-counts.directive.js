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
 * @ngdoc directive
 * @name bastion.errata:errataCounts
 *
 * @description
 *   Directive for displaying the counts of the various types of errata.
 *
 * @example
 * <div errata-counts="contentViewVersion.errata_counts"></div>
 */
angular.module('Bastion.errata').directive('errataCounts', function () {
    return {
        restrict: 'AE',
        replace: true,
        templateUrl: 'errata/views/errata-counts.html',
        scope: {
            errataCounts: '='
        }
    };
});

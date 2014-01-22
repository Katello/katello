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
 * @ngdoc filter
 * @name  Bastion.tasks.filter:taskInputReduce
 *
 * @description
 *   Omits the parts of task humanized input that are not necessary to
 *   show (such as repository name in tasks list or a repository)
 */
angular.module('Bastion.tasks')
    .filter('taskInputReduce', function () {
        return function (humanizedTaskInput, skippedParts) {
            if (typeof(humanizedTaskInput) === 'string' || !skippedParts) {
                return humanizedTaskInput;
            }
            if (typeof skippedParts === 'string') {
                skippedParts = skippedParts.split(',');
            }
            return _.reject(humanizedTaskInput, function (part) {
                if (part.length === 2) {
                    return _.contains(skippedParts, part[0]);
                } else {
                    return false;
                }
            });
        };
    });

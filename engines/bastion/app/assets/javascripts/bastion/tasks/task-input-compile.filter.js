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
 * @name  Bastion.tasks.filter:taskInputCompile
 *
 * @description
 *   Converts the task humanized structure into a flat string
 */
angular.module('Bastion.tasks')
    .filter('taskInputCompile', function () {
        return function (humanizedTaskInput) {
            if (_.isString(humanizedTaskInput)) {
                return humanizedTaskInput;
            }
            var parts = _.map(humanizedTaskInput, function (part) {
                if (part.length === 2) {
                    return part[1].text;
                } else {
                    return part;
                }
            });

            return parts.join('; ');
        };
    });

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
*/

/**
 * @ngdoc filter
 * @name  Katello.filter:arrayObjectValue
 *
 * @description
 * Find the first object in an array with a matching field and return a value from it.
 *
 * @param {Array} input Array to search
 * @param {string} nameField Field to compare
 * @param {string} name Value to compare nameField against
 * @param {string} valueField Field to return value of
 * @returns {Object|undefined} Return the value for valueField or undefined if no match found
 * @example
   <doc:example>
     <doc:source>
       <script>
         function Ctrl($scope) {
           $scope.states = [
               {'name':'Colorado', 'capital':'Denver'},
               {'name':'California', 'capital':'Sacramento'}
               ];
           $scope.state = 'California';
         }
       </script>
       <div ng-controller="Ctrl">
         <p>Capital of {{state}}: {{ states | arrayObjectValue:'name',state,'capital'}}</p>
       </div>
     </doc:source>
   </doc:example>
 */
angular.module('Katello').
    filter('arrayObjectValue', function() {
            return function(input, nameField, name, valueField) {
                for (var i = 0; i < input.length; i += 1) {
                    if (input[i][nameField] === name) {
                        return input[i][valueField];
                    }
                }
            };
        });

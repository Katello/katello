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

/*jshint camelcase:false*/

/**
 * @ngdoc directive
 * @name Bastion.widgets.directive:pathSelector
 *
 * @description
 *   Provides an angular wrapper for the path selector widget.
 *
 * @example
 */
angular.module('Bastion.widgets').directive('pathSelector',
    ['$document', '$http', 'Routes', function($document, $http, Routes) {
    return {
        restrict: 'AE',
        scope: {
            pathSelector: '=',
            readonly: '=',
            organization: '&',
            onChange: '&'
        },
        link: function(scope) {
            var pathSelect;

            scope.$watch('pathSelector', function(selected) {
                if (selected !== undefined && pathSelect) {
                    pathSelect.set_selected(selected);
                }
            });

            scope.$parent.setupSelector = function() {
                $http.get(Routes.organizationEnvironmentsPath(scope.organization) + '/registerable_paths')
                .success(function(paths) {
                    var options = {
                            inline: true,
                            'select_mode': 'single',
                            expand: false,
                            selected: scope.pathSelector,
                            readonly: scope.readonly
                        };

                    pathSelect = KT.path_select(
                        'environment_path_selector',
                        'system_details_path_selector',
                        paths,
                        options
                    );

                    $document.bind(pathSelect.get_select_event(), function(){
                        var environments = pathSelect.get_selected();

                        scope.pathSelector = Object.keys(environments)[0];
                        scope.onChange({ environment_id: scope.pathSelector });
                    });

                    scope.$parent.pathSelector = pathSelect;
                });
            };
        },
    };
}]);

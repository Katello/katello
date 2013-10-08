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
 * @ngdoc directive
 * @name alchemy.directive:alchConfirm
 * @restrict A
 *
 * @description
 *   Provides a set of inline editable elements for various form elements. The
 *   alch-edit directive is the base for all input types to take advantage of
 *   and should never be used directly. The current list of supported types are:
 *
 *   - input (alch-edit-text)
 *   - textarea (alch-edit-textarea)
 *
 * @example
 */
angular.module('alchemy')
    .directive('alchConfirm', function() {
        return {
            templateUrl: 'incubator/views/alch-confirm.html',
            replace: true,
            transclude: true,
            scope: {
                action: '&alchConfirm',
                showConfirm: '=showConfirm'
            }
        };
    })
    .directive('alchConfirmModal', ['$document', function($document) {
        return {
            templateUrl: 'incubator/views/alch-confirm-modal.html',
            replace: true,
            // Note that this causes an error in angular-gettext but that should be fixed when
            // this commit https://github.com/angular/angular.js/commit/bf79bd4194eca2118ae1c492c08dbd217f5ae810
            // makes it into a release.
            transclude: 'element',
            scope: {
                action: '&alchConfirmModal',
                showConfirm: '=showConfirm'
            },
            link: function(scope) {
                scope.$watch('showConfirm', function(confirm) {
                    if (confirm) {
                        $document.on('keydown', function(event) {
                            if (event.which === 13) {
                                scope.action();
                            } else {
                                scope.showConfirm = false;
                                scope.$apply();
                            }
                        });
                    } else {
                        $document.off('keypress');
                    }
                });
            }
        };
    }])
;

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


describe('Directive: alchFormButtons', function() {
    var $scope, $compile, element;

    beforeEach(module(
        'alchemy',
        'incubator/views/alch-save-control.html',
        'incubator/views/alch-form-buttons.html'
    ));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        $compile = _$compile_;
        $scope = _$rootScope_;
    }));

    beforeEach(function() {
        element = '<form name="testForm">' +
                    '<input name="name" ng-model="fake.name" required>' +
                    '<div alch-form-buttons ' +
                        'on-cancel="transitionTo(\'product.index\')" ' +
                        'on-save="save(product)" ' +
                        'working="working"> ' +
                   '</div>' +
                 '</form>';

        element = $compile(element)($scope);
        $scope.$digest();
    });

    it("should set create button to disabled if no server validator is set but the form is invalid", function() {
        var disabled = angular.element(element).find('.btn-primary').attr('disabled');
        expect(disabled).toBe('disabled');
    });

    it("should set create button to enabled if a server validator is set", function() {
        $scope.testForm.name.$error.server = true;
        $scope.$digest();
        var disabled = angular.element(element).find('.btn-primary').attr('disabled');
        expect(disabled).toBe(undefined);
    });

});

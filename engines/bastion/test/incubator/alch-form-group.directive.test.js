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


describe('Directive: alchFormGroup', function() {
    var $scope, $compile, element;

    beforeEach(module(
        'alchemy',
        'incubator/views/alch-form-group.html'
    ));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        $compile = _$compile_;
        $scope = _$rootScope_;
    }));

    beforeEach(function() {
        element = '<form name="testForm">' +
                    '<div alch-form-group label="Name" required>' +
                        '<input id="name" ' +
                               'name="name" ' +
                               'ng-model="fake.name" ' +
                               'type="text" ' +
                               'tabindex="1" ' +
                               'required/>' +
                    '</div>' +
                 '</form>';

        $scope.fake = {name: ''};
        element = $compile(element)($scope);
        $scope.$digest();
    });

    it("should add a 'form-control' class to the input", function() {
        expect(element.find('input').hasClass('form-control')).toBe(true);
    });

    it("should display validation error messages if they exist", function() {
        $scope.testForm.name.$error.messages = ['Error message']
        $scope.$digest();

        expect(element.find('.help-block').hasClass('ng-hide')).toBe(false);
        expect(element.find('li').length).toBeGreaterThan(0);
    });

    it("should set the form group to an error state if the form is invalid and dirty", function() {
        $scope.testForm.name.$dirty = true;
        $scope.$digest();

        expect($scope.testForm.name.$invalid).toBe(true);
        expect($scope.testForm.name.$dirty).toBe(true);
        expect(element.find('.has-error').length).toBeGreaterThan(0);
    });

    it("should not set the form group to an error state if the form is invalid but not dirty", function() {
        expect(element.find('.has-errors').length).toBe(0);
    });

    it("should do nothing if valid and dirty", function() {
        $scope.testForm.name.$dirty = true;
        $scope.$digest();

        expect(element.find('.has-errors').length).toBe(0);
    });
});

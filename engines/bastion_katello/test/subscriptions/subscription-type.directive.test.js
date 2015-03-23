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
describe('Directive: subscriptionType', function() {
    var $scope, $compile, element;

    beforeEach(module(
        'Bastion.subscriptions',
        'subscriptions/views/subscription-type.html'
    ));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        $compile = _$compile_;
        $scope = _$rootScope_;
    }));

    it("subscription type Virtual when no host", function() {
        $scope.subscription = {virt_only: true};
        element = '<div subscription-type="subscription"></div>';
        element = $compile(element)($scope);
        $scope.$digest();
        expect(element.text().trim()).toEqual("Virtual");
    });

    it("subscription type Physical when no host", function() {
        $scope.subscription = {virt_only: false};
        element = '<div subscription-type="subscription"></div>';
        element = $compile(element)($scope);
        $scope.$digest();
        expect(element.text()).toEqual("\n\n  Physical\n\n\n\n");
    });

    it("subscription type Virtual when host", function() {
        $scope.subscription = {virt_only: false, host: {}};
        element = '<div subscription-type="subscription"></div>';
        element = $compile(element)($scope);
        $scope.$digest();
        expect(element.text().trim()).toEqual("Physical");
    });

    it("subscription type Guest when host", function() {
        $scope.subscription = {virt_only: true, host: {id: 123, name: "hypervisor"}};
        element = '<div subscription-type="subscription"></div>';
        element = $compile(element)($scope);
        $scope.$digest();
        expect(element.text().trim()).toEqual("Guests of\n  hypervisor");
    });

    it("subscription type Temporary when unmapped_guest is true", function() {
        $scope.subscription = {virt_only: true, unmapped_guest: true};
        element = '<div subscription-type="subscription"></div>';
        element = $compile(element)($scope);
        $scope.$digest();
        expect(element.text().trim()).toEqual("Temporary");
    });

    it("subscription type Temporary when unmapped_guest is false", function() {
        $scope.subscription = {virt_only: true, unmapped_guest: false};
        element = '<div subscription-type="subscription"></div>';
        element = $compile(element)($scope);
        $scope.$digest();
        expect(element.text().trim()).toEqual("Virtual");
    });
});

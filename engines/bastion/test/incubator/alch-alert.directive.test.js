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

describe('Directive: alchAlert', function() {
    var scope,
        compile,
        element,
        elementScope;

    beforeEach(module('alchemy', 'incubator/views/alch-alert.html'));

    beforeEach(inject(function(_$compile_, _$rootScope_) {
        compile = _$compile_;
        scope = _$rootScope_;
    }));

    beforeEach(function() {
        element = angular.element('<div alch-alert ' +
            'success-messages="successMessages" ' +
            'info-messages="infoMessages" ' +
            'warning-messages="warningMessages" ' +
            'error-messages="errorMessages"></div>');

        scope.successMessages = [];
        scope.infoMessages = [];
        scope.warningMessages = [];
        scope.errorMessages = [];

        compile(element)(scope);
        scope.$digest();

        elementScope = element.isolateScope();
    });

    it("should display success alerts", function() {
        scope.successMessages = ['hello'];
        scope.$digest();

        expect(elementScope.alerts.length).toBe(1);
        expect(elementScope.alerts[0].message).toBe('hello');
        expect(elementScope.alerts[0].type).toBe('success');

        expect(scope.successMessages.length).toBe(0);
    });

    it("should display info alerts", function() {
        scope.infoMessages = ['hello'];
        scope.$digest();

        expect(elementScope.alerts.length).toBe(1);
        expect(elementScope.alerts[0].message).toBe('hello');
        expect(elementScope.alerts[0].type).toBe('info');

        expect(scope.infoMessages.length).toBe(0);
    });

    it("should display warning alerts", function() {
        scope.warningMessages = ['hello'];
        scope.$digest();

        expect(elementScope.alerts.length).toBe(1);
        expect(elementScope.alerts[0].message).toBe('hello');
        expect(elementScope.alerts[0].type).toBe('warning');

        expect(scope.warningMessages.length).toBe(0);
    });

    it("should display success alerts", function() {
        scope.errorMessages = ['hello'];
        scope.$digest();

        expect(elementScope.alerts.length).toBe(1);
        expect(elementScope.alerts[0].message).toBe('hello');
        expect(elementScope.alerts[0].type).toBe('danger');

        expect(scope.errorMessages.length).toBe(0);
    });

    it("provides a way to close alerts", function() {
        elementScope.alerts = ['yo!', 'hello'];
        elementScope.closeAlert(1);
        expect(elementScope.alerts.length).toBe(1);
    });

});

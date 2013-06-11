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
describe('Directive:orgSwitcher', function() {
    // Mocks
    var $scope, $compile, $httpBackend;

    var orgSwitcherElement;

    // load the widgets module
    beforeEach(module('Katello.widgets'));

    // Set up the mocks
    beforeEach(function() {
        // Mock out Routes
        module(function($provide) {
            var Routes = {
                allowedOrgsUserSessionPath: function() {
                    return "orgs/";
                }
            };
            $provide.value('Routes', Routes);
        });

        inject(function(_$compile_, _$rootScope_, _$httpBackend_) {
            $compile = _$compile_;
            $scope = _$rootScope_.$new();
            $httpBackend = _$httpBackend_;
        });
    });

    beforeEach(function() {
        orgSwitcherElement = $compile('<ul id="allowed-orgs" org-switcher style="height:31px;"></ul>')($scope);
        $scope.$digest();
    });

    describe("retrieves orgs from Routes.allowedOrgsUserSessionPath().", function() {
        var orgListHtml;

        beforeEach(function() {
            orgListHtml = '<li style="height: 10px;">1</li><li style="height: 10px;">2</li><li style="height: 10px;">3</li>';
            $httpBackend.expectGET('orgs/').respond(200, orgListHtml);
        });

        afterEach(function () {
            $httpBackend.verifyNoOutstandingExpectation();
            $httpBackend.verifyNoOutstandingRequest();
        });

        it("populates orgs from the request", function() {
            $scope.orgSwitcher.refresh();
            $httpBackend.flush();
            expect(orgSwitcherElement.html()).toBe(orgListHtml);
        });
    });

    it("provides an API to toggle it's visibility, defaulting to false.", function() {
        var orgSwitcher = $scope.orgSwitcher;
        expect(orgSwitcher.visible).toBe(false);
        orgSwitcher.toggleVisibility();
        expect(orgSwitcher.visible).toBe(true);
    });

    it("refreshes the list of orgs if visible.", function() {
        var orgSwitcher = $scope.orgSwitcher;
        spyOn(orgSwitcher, 'refresh');
        orgSwitcher.toggleVisibility();
        $scope.$digest();
        expect(orgSwitcher.refresh).toHaveBeenCalled();
    });
});

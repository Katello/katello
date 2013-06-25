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

describe('Controller: UserSessionsController', function() {
    // Mocks
    var $scope, $document, notices;

    // load the user-sessions module
    beforeEach(module('Bastion.user-sessions'));

    // Provide global notices variable
    beforeEach(module(function($provide) {
        notices = {displayNotice: function() {}};
        $provide.value('notices', notices)
    }));

    // Initialize controller
    beforeEach(inject(function($controller, $rootScope, _$document_) {
        $document = _$document_;
        $scope = $rootScope.$new();
        $controller('UserSessionsController', {$scope: $scope});
    }));

    describe("binds to the ajax:complete event", function() {
        var request = {status: null};

        // Set up spies
        beforeEach(function() {
            $scope.orgSwitcher = {
                refresh: function() {}
            };
            spyOn($scope.orgSwitcher, "refresh");
            spyOn(notices, "displayNotice");
        });

        it("refreshes the org switcher on success", function() {
            request.status = 200;
            $document.trigger("ajax:complete", request);
            expect($scope.orgSwitcher.refresh).toHaveBeenCalled();
            expect(notices.displayNotice).not.toHaveBeenCalled();
        });

        it("displays notice on error", function() {
            request.status = 403;
            $document.trigger("ajax:complete", request);
            expect($scope.orgSwitcher.refresh).not.toHaveBeenCalled();
            expect(notices.displayNotice).toHaveBeenCalled();
        });
    });
});


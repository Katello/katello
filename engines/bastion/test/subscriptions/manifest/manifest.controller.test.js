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
 **/

describe('Controller: ManifestController', function() {
    var $scope;

    beforeEach(module('Bastion.subscriptions', 'Bastion.test-mocks'));

    beforeEach(inject(function($controller, $rootScope, $injector) {
        var translate,
            Provider = $injector.get('MockResource').$new();

        translate = function(a) { return a };

        $scope = $rootScope.$new();

        $scope.$stateParams = {providerId: 1};

        $controller('ManifestController', {
            $scope: $scope,
            translate: translate,
            Provider: Provider
        });
    }));

    it("should set a provider resource on $scope", function() {
        expect($scope.provider).toBeDefined();
    });

    it("should provide a method to get history for a provider", function() {
        var provider,
            history;

        provider = {
            name: "Red Hat",
            id: 1,
            owner_imports: [
                {
                    statusMessage: "metamorphosis by kafka",
                    created: "1915-10-25"
                },
                {
                    webAppPrefix: "dickens",
                    upstreamName: "bleakhouse",
                    created: "1852-03-03"
                }
            ]
        };

        history = provider.owner_imports.slice(0);
        history.push({
            statusMessage: "Manifest from bleakhouse.",
            created: "1852-03-03"
        });

        expect($scope.manifestHistory(provider)).toEqual(history);
        expect($scope.manifestHistory(provider).length).toBe(3);
        expect($scope.manifestHistory(provider)[0]).toBe(history[0]);
        expect($scope.manifestHistory(provider)[1]).toBe(history[1]);
        expect($scope.manifestHistory(provider)[2].statusMessage).toBe(history[2].statusMessage);
        expect($scope.manifestHistory(provider)[2].created).toBe(history[2].created);
    });
});

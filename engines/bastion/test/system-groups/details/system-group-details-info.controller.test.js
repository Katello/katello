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

describe('Controller: SystemGroupDetailsInfoController', function() {
    var $scope;

    beforeEach(module(
        'Bastion.system-groups',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q');

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {systemGroupId: 1};

        $controller('SystemGroupDetailsInfoController', {
            $scope: $scope,
            $q: $q
        });
    }));

    it('isUnlimited properly detects unlimited group', function() {
        expect($scope.isUnlimited({'max_systems': -1})).toBe(true);
        expect($scope.isUnlimited({'max_systems': 0})).toBe(false);
        expect($scope.isUnlimited({'max_systems': 1})).toBe(false);
    });

    it('changing unlimited properly resets group if previously unlimited', function(){
        $scope.group = {'max_systems': -1};
        $scope.unlimitedChanged();
        expect($scope.group['max_systems']).toBe(1)
    });

    it('changing unlimited properly resets group if previously limited', function(){
        $scope.group = {'max_systems': 1};
        $scope.unlimitedChanged();
        expect($scope.group['max_systems']).toBe(-1)
    });

});

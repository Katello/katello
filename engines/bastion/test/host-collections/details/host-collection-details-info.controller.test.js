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

describe('Controller: HostCollectionDetailsInfoController', function() {
    var $scope;

    beforeEach(module(
        'Bastion.host-collections',
        'Bastion.test-mocks'
    ));

    beforeEach(inject(function($injector) {
        var $controller = $injector.get('$controller'),
            $q = $injector.get('$q');

        $scope = $injector.get('$rootScope').$new();
        $scope.$stateParams = {hostCollectionId: 1};

        $controller('HostCollectionDetailsInfoController', {
            $scope: $scope,
            $q: $q
        });
    }));

    it('isUnlimited properly detects unlimited host collection', function() {
        expect($scope.isUnlimited({'max_content_hosts': -1})).toBe(true);
        expect($scope.isUnlimited({'max_content_hosts': 0})).toBe(false);
        expect($scope.isUnlimited({'max_content_hosts': 1})).toBe(false);
    });

    it('changing unlimited properly resets host collection if previously unlimited', function(){
        $scope.hostCollection = {'max_content_hosts': -1};
        $scope.unlimitedChanged();
        expect($scope.hostCollection['max_content_hosts']).toBe(1)
    });

    it('changing unlimited properly resets host collection if previously limited', function(){
        $scope.hostCollection = {'max_content_hosts': 1};
        $scope.unlimitedChanged();
        expect($scope.hostCollection['max_content_hosts']).toBe(-1)
    });

});

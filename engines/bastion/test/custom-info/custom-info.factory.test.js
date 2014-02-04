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
 **/

describe('Factory: CustomInfo', function() {
    var $httpBackend;

    beforeEach(module('Bastion.custom-info'));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        CustomInfo = $injector.get('CustomInfo');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to update custom info', function() {
        $httpBackend.expectPUT('/api/v2/custom_info/system/1/newKey')
                    .respond({});

        CustomInfo.update({
            id: 1,
            type: 'system',
            action: 'newKey',
        }, {
            'newKey': 'keyValue',
        }, function(customInfo) {
            expect(customInfo).toBeDefined();
        });
    });

    it('provides a way to create custom info', function() {
        $httpBackend.expectPOST('/api/v2/custom_info/system/1')
                    .respond({});

        CustomInfo.save({
            id: 1,
            type: 'system'
        }, {
            'newKey': 'keyValue',
        }, function(customInfo) {
            expect(customInfo).toBeDefined();
        });
    });

    it('provides a way to delete custom info', function() {
        $httpBackend.expectDELETE('/api/v2/custom_info/system/1/newKey')
                    .respond();

        CustomInfo.delete({
            id: 1,
            type: 'system',
            action: 'newKey'
        });
    });

});


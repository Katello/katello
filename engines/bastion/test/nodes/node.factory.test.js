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

describe('Factory: Node', function() {
    var $httpBackend,
        nodes,
        Node;

    beforeEach(module('Bastion.nodes'));

    beforeEach(module(function($provide) {
        nodes = {
            records: [
                { name: 'Node1', id: 1 },
                { name: 'Node2', id: 2 }
            ],
            total: 2,
            subtotal: 2
        };
    }));

    beforeEach(inject(function($injector) {
        $httpBackend = $injector.get('$httpBackend');
        Node = $injector.get('Node');
    }));

    afterEach(function() {
        $httpBackend.flush();
        $httpBackend.verifyNoOutstandingExpectation();
        $httpBackend.verifyNoOutstandingRequest();
    });

    it('provides a way to get a list of products', function() {
        $httpBackend.expectGET('/api/nodes').respond(nodes);

        Node.query(function(nodes) {
            expect(nodes.records.length).toBe(2);
        });
    });

});


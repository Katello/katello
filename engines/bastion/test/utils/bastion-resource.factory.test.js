describe('Factory: BastionResource', function() {
    var resource;

    beforeEach(module('Bastion.utils'));

    beforeEach(inject(function($injector) {
        resource = $injector.get('BastionResource');
    }));

    it('should provide queryUnpaged method to resources', function () {
        expect(resource().queryUnpaged).toBeDefined();
    });

    it('should provide queryPaged method to resources', function () {
        expect(resource().queryPaged).toBeDefined();
    });

});

describe('Controller: ContentHostsController', function() {
    var ContentHostsHelper;
    var greenStatus = 'green host-status pficon pficon-ok status-ok';
    var yellowStatus = 'yellow host-status pficon pficon-info status-warn';
    var redStatus = 'red host-status pficon pficon-error-circle-o status-error';

    beforeEach(module('Bastion.content-hosts'));

    beforeEach(inject(function($injector) {
        ContentHostsHelper = $injector.get('ContentHostsHelper');
    }));

    it("provides a way to get the status color for the content host.", function() {
        expect(ContentHostsHelper.getHostStatusIcon("valid")).toBe(greenStatus);
        expect(ContentHostsHelper.getHostStatusIcon("partial")).toBe(yellowStatus);
        expect(ContentHostsHelper.getHostStatusIcon("error")).toBe(redStatus);
    });

    it("provides a way to get the global status color.", function() {
        expect(ContentHostsHelper.getHostStatusIcon(0)).toBe(greenStatus);
        expect(ContentHostsHelper.getHostStatusIcon(1)).toBe(yellowStatus);
        expect(ContentHostsHelper.getHostStatusIcon(2)).toBe(redStatus);
    });

    it('should convert Memory to GB', function() {
        expect(ContentHostsHelper.convertMemToGB(1020120)).toBe('0.97')
        expect(ContentHostsHelper.convertMemToGB('5946304')).toBe('5.67')
        expect(ContentHostsHelper.convertMemToGB('5 GB')).toBe('5')
    });
});

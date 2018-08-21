describe('Service: SyncPlanHelper', function() {
    var SyncPlanHelper;

    beforeEach(module('Bastion.sync-plans'));

    beforeEach(module(function($provide) {
        var translate = function (string) {
            return string
        };

        $provide.value('translate', translate);
    }));

    beforeEach(inject(function($injector) {
        SyncPlanHelper = $injector.get('SyncPlanHelper');
    }));

    it("should allow setting of the form", function () {
        var form = {name: 'blah'};
        SyncPlanHelper.setForm(form);
        expect(SyncPlanHelper.form).toBe(form);
    });

    it("should allow getting of the form", function () {
        var form = {name: 'blah'};
        SyncPlanHelper.form = form;
        expect(SyncPlanHelper.getForm()).toBe(form);
    });

    it("returns the list of valid sync plan intervals", function () {
        var intervals = SyncPlanHelper.getIntervals();
        expect(intervals.length).toBe(4);
        expect(intervals[0].id).toBeDefined();
        expect(intervals[0].value).toBeDefined();
    });

    describe('creates a sync plan', function() {
        it('should save a sync date in MM/DD/YYYY HH:MM:SS format', function() {
            var syncPlan = {};
            syncPlan.startDate = new Date('08/05/2015 00:00:00');
            syncPlan.startTime = new Date('09/09/1999 13:00:00');

            syncPlan.$save = function() {};
            spyOn(syncPlan, '$save').and.callThrough();

            SyncPlanHelper.createSyncPlan(syncPlan);

            var syncDate = new Date(syncPlan['sync_date']);

            expect(syncDate.getHours()).toBe(13);
            expect(syncDate.getMinutes()).toBe(0);
            expect(syncDate.getDate()).toBe(5);
            expect(syncDate.getMonth()).toBe(7);
            expect(syncDate.getFullYear()).toBe(2015);
            expect(syncPlan.$save).toHaveBeenCalled();
        });

        it('should save a sync date in YYYY-MM-DD HH:MM:SS format', function() {
            var syncPlan = {};
            syncPlan.startDate = new Date('2015-08-05T00:00:00');
            syncPlan.startTime = new Date('09/09/1999 13:00:00');

            syncPlan.$save = function() {};
            spyOn(syncPlan, '$save').and.callThrough();

            SyncPlanHelper.createSyncPlan(syncPlan);

            var syncDate = new Date(syncPlan['sync_date']);

            expect(syncDate.getHours()).toBe(13);
            expect(syncDate.getMinutes()).toBe(0);
            expect(syncDate.getDate()).toBe(5);
            expect(syncDate.getMonth()).toBe(7);
            expect(syncDate.getFullYear()).toBe(2015);
            expect(syncPlan.$save).toHaveBeenCalled();
        });
    });
});

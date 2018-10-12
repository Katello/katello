(function () {

    /**
     * @ngdoc service
     * @name Bastion.sync-plans.service:SyncPlanHelper
     *
     * @description
     *   Provides a helper service for Sync Plans
     *
     */
    function SyncPlanHelper(translate) {

        /**
         * Get the set form.  Allows the sharing of form data across controllers
         *
         * @param form the form to set
         */
        this.setForm = function (form) {
            this.form = form;
        };

        /**
         * Set the form.  Allows the sharing of form data across controllers
         *
         * @returns {form|*} the stored form
         */
        this.getForm = function () {
            return this.form;
        };

        /**
         * Returns the valid sync plan intervals.
         *
         * @returns {{id: string, value: *}[]}
         */
        this.getIntervals = function () {
            return [
                {id: 'hourly', value: translate('hourly')},
                {id: 'daily', value: translate('daily')},
                {id: 'weekly', value: translate('weekly')},
                {id: 'custom cron', value: translate('custom cron')}
            ];

        };

        /**
         * Create a sync plan, including setting the dates correctly.
         *
         * @returns $resource sync plan
         */
        this.createSyncPlan = function (syncPlan, success, error) {
            var syncDate = new Date(syncPlan.startDate.getTime()),
                syncTime = new Date(syncPlan.startTime || new Date());
            syncDate.setHours(syncTime.getHours());
            syncDate.setMinutes(syncTime.getMinutes());
            syncDate.setSeconds(0);

            syncPlan['sync_date'] = syncDate.toString();
            syncPlan.$save(success, error);
            return syncPlan;
        };
    }

    angular.module('Bastion.sync-plans').service('SyncPlanHelper', SyncPlanHelper);
    SyncPlanHelper.$inject = ['translate'];
})();

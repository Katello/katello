(function () {

    /**
     * @ngdoc service
     * @name Bastion.errata.service:IncrementalUpdate
     *
     * @description
     *   Provides a helper service for Incremental Updates.
     *
     */
    function IncrementalUpdate($q, $httpParamSerializer, Task, CurrentOrganization) {
        var getIdsFromBulk;

        getIdsFromBulk = function (bulkResource) {
            var ids = [];

            if (bulkResource && bulkResource.included && bulkResource.included.ids) {
                ids = bulkResource.included.ids;
            }

            return ids;
        };

        this.errataIds = [];
        this.contentHostIds = [];
        this.bulkErrata = {};
        this.bulkContentHosts = {};

        /**
         * Allows setting the Errata Ids.
         *
         * @param {Array} errataIds the errata Ids to store for update
         **/
        this.setErrataIds = function (errataIds) {
            this.errataIds = errataIds;
        };

        /**
         * Return the list of Errata Ids.
         *
         * @returns {Array} array of Errata Ids
         */
        this.getErrataIds = function () {
            return this.errataIds;
        };

        /**
         * Allows setting the Content Host Ids.
         *
         * @param {Array} contentHostIds the Content Host Ids to store for update
         **/
        this.setContentHostIds = function (contentHostIds) {
            this.contentHostIds = contentHostIds;
        };

        /**
         * Return the list of Content Host Ids.
         *
         * @returns {Array} array of Content Host Ids
         */
        this.getContentHostIds = function () {
            return this.contentHostIds;
        };

        /**
         * Allows setting the Bulk Content Hosts.
         *
         * @param {Object} bulkContentHosts the bulk selection of the content hosts.
         * @param {Array} errataIds the errata IDs to add to the bulk search
         *
         * @returns {Boolean}
         */
        this.setBulkContentHosts = function (bulkContentHosts) {
            this.bulkContentHosts = bulkContentHosts;
            this.contentHostIds = getIdsFromBulk(bulkContentHosts);
        };

        /**
         * Return the Bulk Content Hosts.
         *
         * @returns {Object} the bulk selection of the content hosts
         */
        this.getBulkContentHosts = function () {
            return this.bulkContentHosts;
        };

        /**
         * Allows setting the Bulk Errata.
         *
         * @param {Object} bulkErratas the bulk selection of the content hosts.
         *
         * @returns {Boolean}
         */
        this.setBulkErrata = function (bulkErratas) {
            this.bulkErrata = bulkErratas;
            this.errataIds = getIdsFromBulk(bulkErratas);
        };

        /**
         * Return the Bulk Errata.
         *
         * @returns {Object} the bulk selection of the content hosts
         */
        this.getBulkErrata = function () {
            return this.bulkErrata;
        };

        /**
         * Return the incremental updates that are currently running.
         *
         * @returns $promise that resolves to a list of incremental updates.
         */
        this.getIncrementalUpdates = function () {
            var searchId, taskSearchParams, taskSearchComplete,
                deferred = $q.defer();

            taskSearchParams = {
                'type': 'all',
                "resource_type": "Organization",
                "resource_id": CurrentOrganization,
                "action_types": "Actions::Katello::ContentView::IncrementalUpdates",
                "active_only": true
            };

            taskSearchComplete = function (results) {
                Task.unregisterSearch(searchId);
                deferred.resolve(results);
            };

            searchId = Task.registerSearch(taskSearchParams, taskSearchComplete);
            return deferred.promise;
        };
    }

    angular.module('Bastion.errata').service('IncrementalUpdate', IncrementalUpdate);

    IncrementalUpdate.$inject = ['$q', '$httpParamSerializer', 'Task', 'CurrentOrganization'];

})();

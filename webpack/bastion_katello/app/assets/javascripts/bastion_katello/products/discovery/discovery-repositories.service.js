(function () {

    /**
     * @ngdoc service
     * @name Bastion.products.service:DiscoveryRepositories
     *
     * @description
     *   Provides a helper service for discovery repositories.
     *
     */
    function DiscoveryRepositories() {
        this.rows = [];
        this.repositoryUrl = '';
        this.upstreamUsername = '';
        this.upstreamPassword = '';

        /**
         * Allows setting the rows.
         *
         * @param {Array} selected rows
         **/
        this.setRows = function (rows) {
            this.rows = rows;
        };

        /**
         * Return the list of rows.
         *
         * @returns {Array} array of rows
         */
        this.getRows = function () {
            return this.rows;
        };

        /**
         * Allows setting the repository URL.
         *
         * @param {Array} selected repositoryUrl
         **/
        this.setRepositoryUrl = function (repositoryUrl) {
            this.repositoryUrl = repositoryUrl;
        };

        /**
         * Return the list of repository URL.
         *
         * @returns {Array} array of repositoryUrl
         */
        this.getRepositoryUrl = function () {
            return this.repositoryUrl;
        };

        /**
         * Allows setting the upstream username.
         *
         * @param {Array} selected upstreamUsername
         **/
        this.setUpstreamUsername = function (upstreamUsername) {
            this.upstreamUsername = upstreamUsername;
        };

        /**
         * Return the list of upstream username.
         *
         * @returns {Array} array of upstreamUsername
         */
        this.getUpstreamUsername = function () {
            return this.upstreamUsername;
        };

        /**
         * Allows setting the upstream password.
         *
         * @param {Array} selected upstreamPassword
         **/
        this.setUpstreamPassword = function (upstreamPassword) {
            this.upstreamPassword = upstreamPassword;
        };

        /**
         * Return the list of upstream password.
         *
         * @returns {Array} array of upstreamPassword
         */
        this.getUpstreamPassword = function () {
            return this.upstreamPassword;
        };
    }

    angular.module('Bastion.products').service('DiscoveryRepositories', DiscoveryRepositories);

    DiscoveryRepositories.$inject = [];

})();

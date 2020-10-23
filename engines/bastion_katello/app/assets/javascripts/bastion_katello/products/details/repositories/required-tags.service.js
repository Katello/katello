
/**
 * @ngdoc service
 * @name  Bastion.products.details.repositories.service:RequiredTags
 *
 * @description
 *   Helper functions for repo requiredTags.
 */

angular
    .module('Bastion.repositories')
    .service('RequiredTags', function () {

        this.isRequiredTagSelected = function (tag, repo) {
            if (!repo.required_tags) {
                return false;
            }
            return !!repo.required_tags.find(function (reqTag) {
                return reqTag === tag;
            });
        };

        this.getRequiredTagsOptions = function (repo) {
            return [
                { name: 'Default', id: '' },
                { name: 'Red Hat Enterprise Linux 8', id: 'rhel-8' },
                { name: 'Red Hat Enterprise Linux 7', id: 'rhel-7' },
                { name: 'Red Hat Enterprise Linux 6', id: 'rhel-6' },
            ];
        };

        // return an array of required tags
        // we don't support multiple tags so this is pretty simple
        this.requiredTagsParam = function (tag) {
            return [tag];
        };

        // return the tags as comma-separated string
        this.formatRequiredTags = function (tagList) {
            var individualTags, reqTagStr;
            individualTags = this.requiredTagsParam(tagList);
            if (individualTags) {
                reqTagStr = individualTags.join(",");
            }
            return reqTagStr;
        };

    }
    );

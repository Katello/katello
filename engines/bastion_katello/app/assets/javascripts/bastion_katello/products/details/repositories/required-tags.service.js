
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

        this.getRequiredTagsOptions = function () {
            return [
                { name: 'Red Hat Enterprise Linux 8', tag: 'rhel-8', selected: undefined },
                { name: 'Red Hat Enterprise Linux 7 Server', tag: 'rhel-7-server', selected: undefined },
                { name: 'Red Hat Enterprise Linux 7 Workstation', tag: 'rhel-7-workstation', selected: undefined },
                { name: 'Red Hat Enterprise Linux 7 Client', tag: 'rhel-7-client', selected: undefined },
                { name: 'Red Hat Enterprise Linux 6 Server', tag: 'rhel-6-server', selected: undefined },
                { name: 'Red Hat Enterprise Linux 6 Workstation', tag: 'rhel-6-workstation', selected: undefined }
            ];
        };

        // return an array of required tags
        this.requiredTagsParam = function (tagList) {
            var selectedItems;
            if (!tagList) {
                return [];
            }
            selectedItems = tagList.filter(function (item) {
                return item.selected;
            });
            return selectedItems.map(function (item) {
                return item.tag;
            });
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

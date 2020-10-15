
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
          if (!repo.required_tags) return false;
          var requiredTags = repo.required_tags.split(',');
          return !!requiredTags.find(function (reqTag) {
              return reqTag === tag;
            });
        }

        this.getRequiredTagsOptions = function () {
          return [
            { name: 'Red Hat Enterprise Linux 8', tag: 'rhel-8', selected: undefined },
            { name: 'Red Hat Enterprise Linux 7 Server', tag: 'rhel-7-server', selected: undefined },
            { name: 'Red Hat Enterprise Linux 7 Workstation', tag: 'rhel-7-workstation', selected: undefined },
            { name: 'Red Hat Enterprise Linux 7 Client', tag: 'rhel-7-client', selected: undefined },
            { name: 'Red Hat Enterprise Linux 6 Server', tag: 'rhel-6-server', selected: undefined },
            { name: 'Red Hat Enterprise Linux 6 Workstation', tag: 'rhel-6-workstation', selected: undefined },
            { name: 'Red Hat Enterprise Linux 5 Server', tag: 'rhel-5-server', selected: undefined },
          ];
        }

        this.formatRequiredTags = function (tagList) {
          if (!tagList) return null;
          var selectedItems = tagList.filter(function (item) {
            return item.selected;
          })
          var individualTags = selectedItems.map(function (item) {
            return item.tag;
          })
          var reqTagStr;
          if (individualTags) reqTagStr = individualTags.join(",");
          return reqTagStr;
        };

}
);

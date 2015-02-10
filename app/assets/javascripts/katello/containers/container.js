/**
 Copyright 2014 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

var KT = KT ? KT : {};

KT.container = (function(){
    var setup = function() {
        var orgDropdown = $('#organization_id'),
            envDropdown = $('#kt_environment_id'),
            contentViewDropdown = $('#content_view_id'),
            reposDropdown = $("#repository_id"),
            tagsDropdown = $("#tag_id"),
            capsuleDropdown = $("#capsule_id");
        envDropdown.change(populateContentViews);
        contentViewDropdown.change(populateRepositories);
        reposDropdown.change(populateTags);
        tagsDropdown.change(checkNextButton);
        capsuleDropdown.change(checkNextButton);
        resetContentViews();

        orgDropdown.change(function() {
            populateEnvironments();
            populateCapsules();
        });

        if(orgDropdown.val() === "") {
            resetOrgs();
        }

        $('#hub_tab').click(function() {
            enableNext(true);
        });

        $('#registry_tab').click(function() {
            enableNext(true);
        });

        $('#katello_tab').click(function() {
            enableNext(false);
        });
    },
    getCapsule = function() {
        return $('#capsule_id').val();
    },
    getOrg = function() {
        return $('#organization_id').val();
    },
    getEnvironment = function() {
        return $('#kt_environment_id').val();
    },
    getContentView = function() {
        return $('#content_view_id').val();
    },
    getRepo = function() {
        return $('#repository_id').val();
    },
    getTag = function() {
        return $('#tag_id').val();
    },
    populateCapsules = function() {
        var capsuleDropdown = $('#capsule_id'),
            noCapsules = $("#no_capsules"),
            org = getOrg(),
            spinner = $("#load_capsules"),
            url = "/api/smart_proxies",
            params = {
                organization_id: getOrg(),
                search: "feature = \"Pulp Node\" or feature = \"Pulp\"",
                per_page: 9999999,
            };

        resetCapsules();
        if (org !== "") {
            showSpinner(spinner, true);
            $.getJSON(url, params)
                .done(function(data) {
                        if(data.length > 0) {
                            $.each(data, function(index, capsule) {
                                capsuleDropdown.append(
                                    $('<option></option>').val(capsule["id"]).html(capsule["name"]));
                            });
                            enableCapsules(true);
                        } else {
                            noCapsules.removeClass("hide");
                        }
                })
                .fail(function(resp) {
                    $("#error_capsules").removeClass("hide")
                })
                .always(function() {
                    showSpinner(spinner, false);
                });
        }
        checkNextButton();
    },
    populateEnvironments = function() {
        var environmentDropdown = $('#kt_environment_id'),
            org = getOrg(),
            spinner = $("#load_environments"),
            url = "/katello/api/organizations/" + org + "/environments";

        resetEnvironments();
        if (org !== "") {
            showSpinner(spinner, true);
            $.getJSON(url, {})
                .done(function(data) {
                        $.each(data["results"], function(index, env) {
                            environmentDropdown.append(
                                $('<option></option>').val(env["id"]).html(env["name"]));
                        });
                        enableEnvironments(true);
                })
                .fail(function(resp) {
                    $("#error_environments").removeClass("hide")
                })
                .always(function() {
                    showSpinner(spinner, false);
                });
        }
    },
    populateContentViews = function() {
        var contentViewDropdown = $('#content_view_id'),
            noCV = $("#no_content_views"),
            env = getEnvironment(),
            spinner = $("#load_content_views"),
            url = "/katello/api/organizations/" + getOrg() + "/content_views",
            params = {
                environment_id : env
            };

        resetContentViews();
        if (env !== "") {
            showSpinner(spinner, true);
            $.getJSON(url, params)
                .done(function(data) {
                        if (data["results"].length > 0) {
                            $.each(data["results"], function(index, cv) {
                                contentViewDropdown.append(
                                    $('<option></option>').val(cv["id"]).html(cv["name"]));
                            });
                            enableContentViews(true);
                        } else {
                            noCV.removeClass("hide");
                        }

                })
                .fail(function(resp) {
                    $("#error_content_views").removeClass("hide")
                })
                .always(function() {
                    showSpinner(spinner, false);
                });
        }
    },
    populateRepositories = function() {
        var reposDropdown = $("#repository_id"),
            noRepos = $("#no_repositories"),
            cv = getContentView(),
            spinner = $("#load_repositories"),
            url = "/katello/api/repositories/",
            params = {
                organization_id: getOrg(),
                content_view_id: cv,
                environment_id: getEnvironment(),
                content_type: "docker"
            };

        resetRepositories();
        if (cv !== "") {
            showSpinner(spinner, true);
            $.getJSON(url, params)
                .done(function(data) {
                        if(data["results"].length > 0) {
                            $.each(data["results"], function(index, repo) {
                                reposDropdown.append(
                                    $('<option></option>').val(repo["id"]).html(repo["name"]));
                            });
                            enableRepositories(true);
                        } else {
                            noRepos.removeClass("hide");
                        }
                })
                .fail(function(resp) {
                    $("#error_repositories").removeClass("hide")
                })
                .always(function() {
                    showSpinner(spinner, false);
                });

        }
        checkNextButton();
    },
    populateTags = function() {
        var repo = getRepo(),
            tagsDropdown = $("#tag_id"),
            spinner = $("#load_tags"),
            url = "/katello/api/repositories/" + repo + "/docker_tags",
            params = {};

        resetTags();
        if (repo !== "") {
            showSpinner(spinner, true);
            $.getJSON(url, params)
                .done(function(data) {
                        $.each(data["results"], function(index, tag) {
                            tagsDropdown.append(
                                $('<option></option>').val(tag["id"]).html(tag["name"]));
                        });
                        enableTags(true);
                })
                .fail(function(resp) {
                    $("#error_tags").removeClass("hide")
                })
                .always(function() {
                    showSpinner(spinner, false);
                });
        }
    },
    checkNextButton = function() {
        enableNext(getRepo() !== "" && getTag() !== "" && getCapsule() !== "")
    },
    resetOrgs = function () {
        resetEnvironments();
        resetCapsules();
    },
    resetEnvironments = function() {
        $("#error_environments").addClass("hide");
        resetContentViews();
        $('#kt_environment_id option[value!=""]').remove();
        enableEnvironments(false);
    },
    resetCapsules = function() {
        $("#error_capsules").addClass("hide");
        $("#no_capsules").addClass("hide");
        $('#capsule_id option[value!=""]').remove();
        enableCapsules(false);
        enableNext(false);
    },
    resetContentViews = function() {
        $("#no_content_views").addClass("hide");
        $("#error_content_views").addClass("hide");
        resetRepositories();
        $('#content_view_id option[value!=""]').remove();
        enableContentViews(false);
    },
    resetRepositories = function() {
        $("#no_repositories").addClass("hide");
        $("#error_repositories").addClass("hide");
        resetTags();
        $('#repository_id option[value!=""]').remove();
        enableRepositories(false);
    },
    resetTags = function() {
        $("#error_tags").addClass("hide");
        $('#tag_id option[value!=""]').remove();
        enableTags(false);
        enableNext(false);
    },
    enableEnvironments = function(enable) {
        $('#kt_environment_id').prop("disabled", !enable);
    },
    enableCapsules = function(enable) {
        $('#capsule_id').prop("disabled", !enable);
    },
    enableContentViews = function(enable) {
        $('#content_view_id').prop("disabled", !enable);
    },
    enableRepositories = function(enable) {
        $('#repository_id').prop("disabled", !enable);
    },
    enableTags = function(enable) {
        $('#tag_id').prop("disabled", !enable);
    },
    enableNext = function(enable) {
        $('#next_katello').prop("disabled", !enable);
    },
    showSpinner = function(spinner, show) {
        if (show) {
            spinner.removeClass("hide");
        } else {
            spinner.addClass("hide")
        }
    };

    return {
        setup: setup,
        enableNext: enableNext
    };
})();


$(document).ready(function() {
    KT.container.setup();
});

$(window).load(function() {
    KT.container.enableNext(false);
});
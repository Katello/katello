/**
 Copyright 2011 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

KT.dashboard = (function(){
    var plot = function() {
        if (KT.subscription_data) {
            $.plot($("#sub_graph"), KT.subscription_data, {
                series: {
                    pie:{
                        show: true,
                        radius: .8,
                        stroke: {
                            width: 0
                        },

                        label: {
                            show: false
                        }
                    }
                },
                legend: {
                    show: false
                }
            });
        }

    },
    register_errata = function() {
        $("#dashboard_errata").delegate(".collapsed", "click", function() {
            var btn = $(this);
            btn.parents(".errata_item").siblings().show();
            $("#dashboard_errata").find(".jspPane").resize();
            btn.removeClass("collapsed").addClass("expanded");
        });

        $("#dashboard_errata").delegate(".expanded", "click", function() {
            var btn = $(this);
            btn.parents(".errata_item").siblings().hide();
            $("#dashboard_errata").find(".jspPane").resize();
            btn.removeClass("expanded").addClass("collapsed");
        });
    },
    register_sync_progress = function() {
        $(".progressbar").each(function(){
            var bar = $(this);
            bar.progressbar({value: parseInt(bar.attr("percentage"))});
        });
    },
    widget_map = function() {
        return {
            subscriptions: plot,
            errata: register_errata,
            sync: register_sync_progress
        }
    };
    
    return {
        widget_map: widget_map()
    }

})();


$(document).ready(function() {

    //run them all if we aren't requesting them via ajax
    $.each(KT.dashboard.widget_map, function(key, value){
        value();
    });


});


//wait until the entire page is loaded, to ensure images and things are downloaded
$(window).load(function() {
    $(".loading").each(function(item) {
        var div = $(this);
        var url = div.attr("data-url");
        var id = div.attr("data-id");
        $.ajax({
            url: url,
            success: function(data){
                var parent = div.parent();
                div.replaceWith(data);

                // Add a handler for ellipsis
                parent.find(".one-line-ellipsis").ellipsis();

                KT.common.jscroll_init(parent.find('.scroll-pane'));
                KT.common.jscroll_resize(parent.find('.jspPane'));

                var proc = KT.dashboard.widget_map[id];
                if (proc) {
                    proc();
                }

            }
        });


    });

});
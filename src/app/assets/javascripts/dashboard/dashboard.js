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
    popoutSetup = function (){
        var popout = $('.dashboard_popout');
        var dropbutton = $('.dropbutton');
        var currentDropbutton = null;
        var thisPortal = null;
        dropbutton.hide();
        dropbutton.each(function(){
            currentDropbutton = $(this);
            currentDropbutton.attr('original-title',popout.html()).tipsy({
              gravity: 'n',
              fade:true,
              html:true,
              opacity: 0.9,
              trigger: 'manual',
              afterShow: function(){
                //attach some events to the current popout
                //the current portal under the dropbutton
                thisPortal = currentDropbutton.parent().parent().find('.portal').children(':first').children(':first');
                $('.tipsy').find('select.num_of_results').each(function(){
                  $(this).val(thisPortal.attr("data-quantity"));
                  $(this).unbind();
                  $(this).bind('change', function(){
                    KT.dashboard.widgetReload(thisPortal, $(this).val(), "quantity");
                    KT.dashboard.popoutClose();
                  });
                });
              }

            });
        });
        dropbutton.live('click', function(){
          KT.dashboard.popoutClose();
          currentDropbutton = $(this);
          if (!currentDropbutton.hasClass('active')){
            //make it active
            $(this).addClass('active');
            $(this).tipsy("show");
          } else {
            KT.dashboard.popoutClose();
          }
        });
        $(document).mouseup(function(e){
          var target = $(e.target);
          if(!(target.hasClass('popout'))){
            KT.dashboard.popoutClose();
          }
        });
    },
    popoutClose = function(){
      $('.dropbutton.active').tipsy('hide').removeClass('active').removeClass('showing');
    },
    widgetReload = function(theWidget, quantity, type) {
        if(quantity == undefined){quantity=-1}
        if(!typeof(type) != "string"){type="quantity"}
        var div = theWidget;
        var url = div.attr("data-url");
        var id = div.attr("data-id");

        if (id === 'errata') {
            $(document).trigger('close.tipsy');
            KT.tipsy.custom.disable_details_tooltip($('.errata-info'));
        }

        $.ajax({
            url: url+"?"+type+"="+quantity,
            success: function(data){
                var parent = div.parent();
                var newDiv = null;
                div.replaceWith(data);
                newDiv = parent.children(":first");
                newDiv.attr("data-url", url);
                parent.parent().parent().find('.dropbutton').fadeIn();

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
        widget_map: widget_map(),
        widgetReload: widgetReload,
        popoutClose : popoutClose,
        popoutSetup : popoutSetup
    }
})();


$(document).ready(function() {
    // init the system subscription status... this one is not loaded via ajax
    var proc = KT.dashboard.widget_map['subscriptions'];
    if (proc) {
        proc();
    }
    KT.dashboard.popoutSetup();
});


//wait until the entire page is loaded, to ensure images and things are downloaded
$(window).load(function() {
    $(".loading").each(function(){
       KT.dashboard.widgetReload($(this))
    });
    KT.tipsy.custom.tooltip($('.tipsy-icon.errata-info'));
});

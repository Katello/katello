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

                if (id == 'errata') {
                    register_errata();
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

        $('.errata-info').tipsy({ gravity: 'e', live : true, html : true, title : generateInfoToolTip,
                                hoverable : true, delayOut : 250, opacity : 1, delayIn : 300,
                                stickyClick : function(element, state){
                                    if (state === 'on'){
                                        $(element).addClass('details-icon-hover').removeClass('details-icon');
                                    } else {
                                        $(element).addClass('details-icon').removeClass('details-icon-hover');
                                    }
                                },
                                afterShow : function(){
                                    $('.tipsy-inner').addClass('scroll-pane');
                                    KT.common.jscroll_init($('.scroll-pane'));
                                }});

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
    },
    generateInfoToolTip = function(){
        var html = '',
            element = $(this),
            packages_list = [],
            generate_packages = function(){
                var packages = element.data('packages')[0]["packages"],
                    i = 0,
                    length = packages.length,
                    html = "";

                for(i; i < length; i += 1){
                    html += "<li>" + packages[i]["filename"] + '</li>';
                }

                return html;
            };

        packages_list = generate_packages();

        html += '<div class="item-container"><label class="fl ra">ID:</label>' + '<p>' + element.data('id') + '</p></div>';
        html += '<div class="item-container"><label class="fl ra">Title:</label>' + '<p>' + element.data('title') + '</p></div>';
        html += '<div class="item-container"><label class="fl ra">Issued:</label>' + '<p>' + element.data('issued') + '</p></div>';
        html += '<div class="item-container"><label class="fl ra">Reference:</label>' + '<p><a target="new" href="' +  element.data('reference_url') + '">' + element.data('reference_url') + '</a></p></div>';
        html += '<div class="item-container"><label class="fl ra">Description:</label>' + '<p><br/><pre>' + element.data('description') + '</pre></p></div>';
        html += '<div class="item-container"><label class="fl" style="text-align:left;">Packages:</label>' + '<ul style="margin:0 0 0 4px;" class="la"><br/>' + packages_list + '</ul></div>';

        return html;
    };
    return {
        widget_map: widget_map(),
        widgetReload: widgetReload,
        popoutClose : popoutClose,
        popoutSetup : popoutSetup
    }

})();


$(document).ready(function() {

    //run them all if we aren't requesting them via ajax
    $.each(KT.dashboard.widget_map, function(key, value){
        value();
    });
    KT.dashboard.popoutSetup();

});


//wait until the entire page is loaded, to ensure images and things are downloaded
$(window).load(function() {
    $(".loading").each(function(){
       KT.dashboard.widgetReload($(this))
    });

});

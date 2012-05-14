KT.tipsy = KT.tipsy || {};

KT.tipsy.custom = (function(){
    var errata_tooltip = function(){
         $('.errata-info').tipsy({ 
            gravity: 'e', live : true, html : true, title : KT.tipsy.templates.errata, 
            hoverable : true, delayOut : 250, opacity : 1, delayIn : 300, className : 'errata_tooltip',
            stickyClick : function(element, state){ 
                if (state === 'on'){
                    $(element).addClass('details-icon-hover').removeClass('details-icon');
                } else {
                    $(element).addClass('details-icon').removeClass('details-icon-hover');
                }
            },
            afterShow : function(){
                $('.details_container').addClass('scroll-pane');
                KT.common.jscroll_init($('.scroll-pane'));
            }});
    },
    disable_details_tooltip = function(element) {
        element.replaceWith('<span class="details-icon-nohover"></span>');
    },
    promotion_filter_tooltip = function(){
         $('.promotion_tipsify').tipsy({
            gravity: 'w', live : true, html : true, title : KT.tipsy.templates.promotion_filters,
            hoverable: true, opacity : 1,delayOut : 250, delayIn : 300, className : 'promotion_filters_tooltip',
            afterShow : function(){
                 $('.details_container').addClass('scroll-pane');
                 KT.common.jscroll_init($('.scroll-pane'));
             }});
    },
    system_packages_tooltip = function(){
        var element = $(this);

        $('.system_content_action').tipsy({
           gravity: 'e', live : true, html : true, title : KT.tipsy.templates.table_template,
           hoverable : true, delayOut : 250, opacity : 1, delayIn : 300, className : 'table_tooltip',
           afterShow : function(){
               $('.details_container').addClass('scroll-pane');
               KT.common.jscroll_init($('.scroll-pane'));
           }});

        $('.system_packages_action').tipsy({
           gravity: 'e', live : true, html : true, title : KT.tipsy.templates.table_template,
           hoverable : true, delayOut : 250, opacity : 1, delayIn : 300, className : 'table_tooltip',
           afterShow : function(){
               $('.details_container').addClass('scroll-pane');
               KT.common.jscroll_init($('.scroll-pane'));
           }});
    };
    return {
        errata_tooltip           : errata_tooltip,
        disable_details_tooltip  : disable_details_tooltip,
        promotion_filter_tooltip : promotion_filter_tooltip,
        system_packages_tooltips : system_packages_tooltip
    };
})();

KT.tipsy.templates = (function(){
    var errata = function(){
        var html = '<div class="details_container">',
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
        html += '</div>';

        return html;
    },
    promotion_filters = function(){
        var element = $(this),
            tipsy_body ="",
            content_type = element.data("content_type"),
            content_id = element.data("content_id"),
            generate_filter_rows = function(filters){
              var i = 0,
                  length = filters.length,
                  html = "";

              for(i; i < length; i += 1){
                  html += "<li>" + filters[i] + '</li>';
              }
              return html;
            };

        tipsy_body = '<div class="details_container">';
        if("product" === content_type) {
            tipsy_body +=  "<p>" + i18n.product_filter_tipsy + "</p>";
            filter = product_repo_filters["product_"+ content_id];
            if(filter !== undefined) {
                if (filter.product.length > 0) {
                    tipsy_body += '<div class="item-container"><label class="fl ra">' + i18n.applicable_product_filters + '</label><br/><ul>' +
                                    generate_filter_rows(filter.product) + "</ul> </div>";
                }
                if(KT.utils.size(filter.repo) > 0) {
                    tipsy_body +=  '<div class="item-container"><label class="fl ra"> ' + i18n.applicable_repo_filters + "</label></div><br/>";
                    KT.utils.each(filter.repo, function(repo_filters, repo_name) {
                        tipsy_body += '<div class="item-container"><label class="fl ra">' +
                                    i18n.for_repository(repo_name) +'</label><br/><ul>' +
                            generate_filter_rows(repo_filters) + "</ul> </div>";
                    });
                }
            }
        } else if ("repo" === content_type){
            tipsy_body +=  "<p>" + i18n.repo_filter_tipsy + "</p>";
            filter = product_repo_filters["repo_"+ content_id];
            if(filter !== undefined) {
                if (filter.product.length > 0) {
                    tipsy_body += '<div class="item-container"><label class="fl ra">' + i18n.applicable_product_filters + '</label><br/><ul>' +
                                    generate_filter_rows(filter.product) + "</ul> </div>";
                }
                if (filter.repo.length > 0) {
                    tipsy_body += '<div class="item-container"><label class="fl ra">' + i18n.applicable_repo_filters +
                                        '</label><br/><ul>' + generate_filter_rows(filter.repo) + "</ul> </div>";
                }
            }
        }
        return tipsy_body + '</div>';
    },
    table_template = function(){
        var html = '<div class="details_container">',
            element = $(this);

        html += '<div class="item-container">' + '<p>' + element.data('help') + '</p></div>';
        html += '</div>';
        return html;
    };

    return {
        errata            : errata,
        promotion_filters : promotion_filters,
        table_template    : table_template
    };

})();

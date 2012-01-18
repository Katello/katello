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
    };

    return {
        errata_tooltip          : errata_tooltip,
        disable_details_tooltip : disable_details_tooltip
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
    };

    return {
        errata : errata
    };

})();

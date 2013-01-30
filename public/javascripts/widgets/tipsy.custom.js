KT.tipsy = KT.tipsy || {};


KT.tipsy.custom = (function(){
    var tooltip = function(element) {
        $(element).tipsy({
           gravity: 'e', live : true, html : true, title : KT.tipsy.templates.dynamic,
           hoverable : true, closeOnScroll:true, delayOut : 250, opacity : 1, delayIn : 300,
           className : 'tooltip',
           stickyClick : function(element, state){
               if (state === 'on'){
                   $(element).addClass('tipsy-hover').removeClass('tipsy-nohover');
               } else {
                   $(element).addClass('tipsy-nohover').removeClass('tipsy-hover');
               }
           },
           afterShow : function(){
               $('.details_container').addClass('scroll-pane');
               KT.common.jscroll_init($('.scroll-pane'));
           }});
    },
    url_tooltip = function(element, direction){
        var get_url = function(elem){return elem.data().url};
        element.tipsy({
           gravity: direction, live : true, html : true, title : KT.tipsy.templates.spinner,
           url: get_url,
           hoverable : true, delayOut : 250, opacity : 1, delayIn : 300, className : 'tooltip',
           stickyClick : function(element, state){
               if (state === 'on'){
                   $(element).addClass('tipsy-hover').removeClass('tipsy-nohover');
               } else {
                   $(element).addClass('tipsy-nohover').removeClass('tipsy-hover');
               }
           },
           afterShow : function(obj, tipsy_div){
                $('.details_container').addClass('scroll-pane');
                KT.common.jscroll_init($('.scroll-pane'));
           }});
    },
    copy_tooltip = function(element) {
        $(element).tipsy({
            gravity: 'n', trigger : 'manual', html : true, title : KT.tipsy.templates.copy_form,
            delayOut : 250, opacity : 1, delayIn : 300, className : 'copy-tipsy'
        });
    },
    disable_details_tooltip = function(element) {
        element.replaceWith('<span class="details-icon-nohover"></span>');
    },
    system_packages_tooltip = function(){
        var element = $(this);

        $('.system_content_action').tipsy({
           gravity: 'e', live : true, html : true, title : KT.tipsy.templates.table_template,
           hoverable : true, delayOut : 250, opacity : 1, delayIn : 300, className : 'tooltip',
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
    },
    enable_forms_tooltips = function(){
      // Form inputs help tips
      $('form i.details-icon[data-help]').tipsy({
        gravity: 'e', live : true, html : true, title : KT.tipsy.templates.table_template,
        hoverable : true, delayOut : 250, opacity : 1, delayIn : 300, className : 'tooltip',
        afterShow : function(){
          $('.details_container').addClass('scroll-pane');
          KT.common.jscroll_init($('.scroll-pane'));
      }});
    };
    return {
        tooltip                  : tooltip,
        copy_tooltip             : copy_tooltip,
        disable_details_tooltip  : disable_details_tooltip,
        system_packages_tooltips : system_packages_tooltip,
        url_tooltip              : url_tooltip,
        enable_forms_tooltips    : enable_forms_tooltips
    };
})();

KT.tipsy.templates = (function(){
    var dynamic = function() {
      // The dynamic function will determine the template to use for rendering the tipsy based on the type of element.
      // Currently, this is assumed to be either errata-info or a simple list.
      var html, element = $(this);
      if (element.hasClass('errata-info')) {
          html = errata(element);
      }
      else if (element.attr('data-url')){
        html = url(element)
      } else if (element.hasClass('task-info')) {
          html = task(element);
      } else {
          html = list(element);
      }
      return html;
    },
    list = function(element) {
        // The list template assumes that the data shown in the template is essentially a simple list of items.
        // The items are pulled from the data-list attribute associated with the tipsy element.
        var html = '<div class="details_container">',
            items_list = [],
            generate_list = function(){
                var items_list = element.data('list'),
                    i = 0,
                    length = items_list.length,
                    html = "";

                for(i; i < length; i += 1){
                    html += "<li>" + items_list[i] + '</li>';
                }
                return html;
            };

        items_list = generate_list();

        html += '<div class="item-container"><ul style="margin:0 0 0 4px;" class="la">' + items_list + '</ul></div>';
        html += '</div>';

        return html;
    },
    errata = function(element){
        var html = '<div class="details_container">',
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
    spinner = function(){
        return '<span class="spinner" ></span>';
    },
    task = function(element) {
        var html = '<div class="details_container">';

        html += '<div class="item-container"><label class="fl ra">Result:</label>' + '<p><br/>' + element.data('result') + '</p></div>';

        html += '</div>';
        return html;
    },
    copy_form = function() {
        var element = $(this),
            html = '<div>';

        html += '<form id="copy_form" data-url="' + element.data('url') + '">';
        html += '<fieldset><div><label>' + i18n.name + '</label></div><div><input id="name_input" type="text" size="25" name="name"></div></fieldset>';
        html += '<fieldset><div><label>' + i18n.description + '</label></div><div><textarea id="description_input" rows="1" cols="31" name="description"></textarea></div></fieldset>';
        html += '<input id="copy_button" type="submit" class="fr button" value="' + i18n.copy + '">';
        html += '<input id="cancel_copy_button" type="button" class="fr button" value="' + i18n.cancel + '">';
        html += '<form>';
        html += '</div>';
        return html;
    },
    table_template = function(){
        var html = '<div class="details_container">',
            element = $(this);

        html += '<div class="item-container">' + '<p>' + element.data('help') + '</p></div>';
        html += '</div>';
        return html;
    };

    return {
        dynamic           : dynamic,
        copy_form         : copy_form,
        table_template    : table_template,
        spinner          : spinner
    };

})();

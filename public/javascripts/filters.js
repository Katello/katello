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

$(document).ready(function() {


    $('#new_filter').live('submit', function(e) {
        // disable submit to avoid duplicate clicks
        $('input[id^=filter_save]').attr("disabled", true);

        e.preventDefault();
        $(this).ajaxSubmit({success:KT.filters.success_create , error:KT.filters.failure_create});
    });

  

    $("#container").delegate("#remove_packages", 'click', function(e){
        KT.filters.remove_packages();

    });

    KT.panel.set_expand_cb(function(){
        KT.package_input.register_autocomplete();            
    })

});

KT.package_input = (function() {
    var current_input = undefined;

    var register_autocomplete = function() {
        current_input = KT.auto_complete_box({
            values:       KT.routes.auto_complete_locker_packages_path(),
            default_text: i18n.package_search_text,
            input_id:     "package_input",
            form_id:      "add_package_form",
            add_btn_id:   "add_package",
            add_cb:       KT.filters.add_package
        });
    };

    return {
        register_autocomplete:register_autocomplete
    }
})();

KT.filters = (function(){

    var success_create  = function(data){
        list.add(data);
        KT.panel.closePanel($('#panel'));        
    },
    failure_create = function(){
        $('input[id^=filter_save]').attr("disabled", false);

    },
    add_package = function(name, cleanup_cb){
        var input = $("#package_input");

        //verify the package isn't already displayed
        if ($(".package_select[value=" + name + "]").length !== 0){
            cleanup_cb();
            return;
        }
        
        disable_package_inputs();

        $.ajax({
            type: "POST",
            url: input.attr("data-url"),
            data: {packages:[name]},
            cache: false,
            success: function(data) {
                var table = $("#package_filter").find("table");
                $.each(data, function(index, item){
                    var html = "<tr><td>";
                    html+= '<input type="checkbox" class="package_select" value="' + item + '">';
                    html += item + '</td></tr>';
                    table.append(html);
                });
                table.find("tr").not(".no_sort").sortElements(function(a,b){
                        var a_html = $.trim($(a).find('td').text());
                        var b_html = $.trim($(b).find('td').text());
                        if (a_html && b_html ) {
                            return  a_html.toUpperCase() >
                                    b_html.toUpperCase() ? 1 : -1;
                        }
                });
                cleanup_cb();
                enable_package_inputs();
            }
        });
    },
    remove_packages = function() {
        var btn = $("#remove_packages");
        var pkgs = [];
        var checked = $(".package_select:checked");

        if (btn.hasClass("disabled")){
            return;
        }

        checked.each(function(index, item){
            pkgs.push($(item).val());
        });
        if (pkgs.length === 0){
            return;
        }
        disable_package_inputs();

        $.ajax({
            type: "POST",
            url: btn.attr("data-url"),
            data: {packages:pkgs},
            cache: false,
            success: function(data) {
                checked.parents("tr").remove();
                enable_package_inputs();
            }
        });
    },
    disable_package_inputs = function(){
        $("#package_filter").find("input").addClass("disabled");
        
    },
    enable_package_inputs = function(){
        $("#package_filter").find("input").removeClass("disabled");
    };
    


    return {
        success_create: success_create,
        failure_create: failure_create,
        add_package: add_package,
        remove_packages: remove_packages

    };
})();
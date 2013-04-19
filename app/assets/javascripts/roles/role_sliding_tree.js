/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

/*
 * A small javascript file needed to load things whenever a role is opened for editing
 *
 */
KT.roles = {};

KT.roles.permissionWidget = function(){

    var current_stage       = undefined,
        mode                = 'create',
        next_button         = $('#next_button'),
        previous_button     = $('#previous_button'),
        done_button         = $('#save_permission_button'),
        all_types_button    = $('#all_types'),
        all_verbs_button    = $('#all_verbs'),
        all_tags_button     = $('#all_tags'),

        progress_bar        = KT.roles.permissionWidget.progressBar,

        flow = {
            'resource_type' :   { previous  : false,
                                  next      : { stage     : 'verbs',
                            actions    : function(){
                                                      if( all_types_button.hasClass('selected') ){
                                                          flow['verbs'].container.hide();
                                                          flow['details'].container.show();
                                                          current_stage = 'details';
                                                          progress_bar.setProgress(50);
                                                          done_button.show();
                                                          next_button.hide();
                                                      } else {
                                                          progress_bar.setProgress(50);
                                                      }
                                                      previous_button.show();
                                                  }
                                                },
                                  container : $('#resource_type_container'),
                                  input     : $('#resource_type'),
                                  validate  : function(){
                                      return true;
                                  }
                                },
            'verbs'         :   { previous  : { stage     : 'resource_type',
                                                   actions    : function(){
                                                      progress_bar.setProgress(25);
                                                      previous_button.hide();
                                    next_button.show();
                                                   }
                                                 },
                                  next      : { stage     : 'tags',
                                                  actions    : function(){
                                                      if( roleActions.getCurrentOrganization() === 'global' ){
                                                          flow['tags'].container.hide();
                                                          current_stage = 'details';
                                                          flow[current_stage].container.show();
                                                          next_button.hide();
                                                          done_button.show();
                                                          previous_button.show();
                                                          progress_bar.setProgress(100);
                                                      } else if( $('#resource_type').val() === 'organizations' || only_no_tag_verbs_selected() ){
                                                          flow['tags'].container.hide();
                                                          current_stage = 'details';
                                                          flow[current_stage].container.show();
                                                          next_button.hide();
                                                          done_button.show();
                                                          previous_button.show();
                                                          progress_bar.setProgress(100);
                                                      } else {
                                                          progress_bar.setProgress(75);
                                                          done_button.hide();
                                                        next_button.show();
                                                        previous_button.show();
                                                    }
                                                  }
                                                },
                                  container : $('#verbs_container'),
                                  input     : $('#verbs'),
                                  validate  : function(){
                                        if( $('#verbs').val() === null && !all_verbs_button.hasClass('selected') ){
                                            if( !$('#verbs_container').find('span').hasClass('validation_error') ){
                                                $('#verbs_container').append('<div class="permission_widget_container"><span class="validation_error">' + i18n.verb_validation + '</span></div>');
                                            }
                                            return false;
                                        } else {
                                            $('.validation_error').parent().remove();
                                            return true;
                                        }
                                  }
                                },
            'tags'          :   { previous  : { stage     : 'verbs',
                                                   actions    : function(){
                                                      progress_bar.setProgress(50);
                                                      next_button.show();
                                                  }
                                                 },
                                  next      : { stage     : 'details',
                                                  actions    : function(){
                                                      progress_bar.setProgress(100);
                                                      done_button.show();
                                                    next_button.hide();
                                                    previous_button.show();
                                                    flow['details'].input.focus();
                                                  }
                                                },
                                  container : $('#tags_container'),
                                  input     : $('#tags'),
                                  validate  : function(){
                                        return true;
                                  }
                               },
            'details'       :   { previous  : { stage     : 'tags',
                                                   actions    : function(){
                                                       if( all_types_button.hasClass('selected') ){
                                                           current_stage = 'resource_type';
                                                           flow['details'].container.hide();
                                                           done_button.hide();
                                                           next_button.show();
                                                           previous_button.hide();
                                                           progress_bar.setProgress(25);
                                                       } else if( roleActions.getCurrentOrganization() === 'global' ) {
                                                           current_stage = 'verbs';
                                                           done_button.hide();
                                                           next_button.show();
                                                           previous_button.show();
                                                           progress_bar.setProgress(50);
                                                           flow['details'].container.hide();
                                                       } else if( $('#resource_type').val() === 'organizations' ) {
                                                           current_stage = 'verbs';
                                                           done_button.hide();
                                                           next_button.show();
                                                           previous_button.show();
                                                           progress_bar.setProgress(50);
                                            flow['details'].container.hide();
                                                       } else {
                                                          progress_bar.setProgress(75);
                                                          previous_button.show();
                                                          next_button.show();
                                                          done_button.hide();
                                    }
                                                   }
                                                 },
                                  next      : false,
                                  container : $('#details_container'),
                                  input        : $('#permission_name'),
                                  validate  : function(){
                                        if( $("#permission_name").val() === "" ){
                                            if( !$('#name_container').find('span').hasClass('validation_error') ){
                                                $('#name_container').append('<span class="validation_error">' + i18n.name_validation + '</span>');
                                                $('#permission_name').addClass("input_error");
                                            }
                                            return false;
                                        }  else {
                                            $('#details_container').find('span').remove();
                                            $('#permission_name').removeClass("input_error");
                                            return true;
                                        }
                                  }
                                }
        },

        init = function(){
            next_button.unbind('click').click(handleNext);
            $('#permission_widget').find('input').unbind('keypress').keypress(handleKeypress);
            $('#permission_widget').find('select').unbind('keypress').keypress(handleKeypress);
            previous_button.unbind('click').click(handlePrevious);
            done_button.unbind('click').click(handleDone);

            all_types_button.unbind('click').click(function(){ handleAllTypes(); });
            all_verbs_button.unbind('click').click(function(){ handleAllVerbs(); });
            all_tags_button.unbind('click').click(function(){ handleAllTags(); });
        },
        reset = function(){
            var item;

            handleAllTypes(true);

            current_stage = 'resource_type';

            KT.utils.each(flow, function(item, key){
                if( key !== current_stage ){
                    item.container.hide();
                }
            });

            progress_bar.setProgress(25);

            all_verbs_button.removeClass('selected');
            all_verbs_button.html(i18n.all);
            all_tags_button.removeClass('selected');
            all_tags_button.html(i18n.all);
            done_button.removeClass('disabled');

            next_button.show();
            done_button.hide();
            previous_button.hide();

            flow['verbs'].input.removeAttr('disabled');
            flow['tags'].input.removeAttr('disabled');

            $('#add_permission_form')[0].reset();
            $('.validation_error').remove();
        },
        handleKeypress = function(event){
            if( event.which === 13 ){
                event.preventDefault();
                if( current_stage === 'details' && $('#permission_name').is(":focus") ){
                    handleDone();
                }
            }
        },
        handleNext = function(){
            var next = flow[current_stage].next.stage,
        current = current_stage;

            if( flow[current].validate() ){
                current_stage = next;
                flow[next].container.show();
                flow[current].next.actions();
            }
        },
        handlePrevious = function(){
            var previous = flow[current_stage].previous.stage,
        current = current_stage;

            current_stage = previous;
            flow[current].container.hide();
            flow[current].previous.actions();
        },
        handleDone = function(){
            if ( done_button.hasClass('disabled') ){
                    return false;
            }

            done_button.addClass('disabled');
            roleActions.savePermission(mode,
                function(){
                    reset();
                    done_button.removeClass('disabled');
                },
                function(){
                    done_button.removeClass('disabled');
                });
        },
        set_types = function(current_organization){
            var types           = roles_breadcrumb[current_organization].permission_details,
                types_select    = flow['resource_type'].input,
                html            = "";

            types_select.empty();

            KT.utils.each(types, function(type, key){
                if( key !== "all" ){
                    if( current_organization.split('_')[0] === 'organization' ){
                        if( !type.global ){
                            html += '<option value="' + key + '">' + type.name + '</option>';
                        }
                    } else {
                        html += '<option value="' + key + '">' + type.name + '</option>';
                    }
                } else {
                    html += '<option class="hidden" value="all">' + i18n.all + '</option>';
                }
            });

            types_select.append(html);
        },
        set_verbs_and_tags = function(type, current_organization, no_tags){
            var i, length=0,
                verbs_select = flow['verbs'].input,
                tags_select = flow['tags'].input,
                verbs = roles_breadcrumb[current_organization].permission_details[type].verbs,
                tags = roles_breadcrumb[current_organization].permission_details[type].tags,
                html = '';

            length = verbs.length;

            if( no_tags === undefined ){
                verbs_select.empty();
                for( i=0; i < length; i+= 1){
                    html += '<option value="' + verbs[i].name + '">' + verbs[i].display_name + "</option>";
                }
                verbs_select.append(html);
            }

            html = '';
            flow['tags'].container.find('.info_text').remove();

            tags_select.empty();
            if( type !== 'organizations' && current_organization !== "global" && !no_tags ){
                length = tags.length;
                for( i=0; i < length; i+= 1){
                    html += '<option value="' + tags[i].name + '">' + tags[i].display_name + "</option>";
                }
                tags_select.append(html);
                tags_select.show();
                all_tags_button.show();
            }
        },
        only_no_tag_verbs_selected = function(){
            var selected                = flow['verbs'].input.find(':selected'),
                current_organization    = roleActions.getCurrentOrganization(),
                no_tag_verbs            = roles_breadcrumb[current_organization].permission_details[flow['resource_type'].input.val()].no_tag_verbs,
                selected_verbs          = KT.utils.map(selected, function(element){ return $(element).val() });

            return KT.utils.difference(selected_verbs, no_tag_verbs).length === 0 ? true : false;
        },
           add_permission = function(options){
            var opening                 = options.opening,
                current_organization    = roleActions.getCurrentOrganization(),
                button                  = $('#add_permission');

            mode = 'create';

            if( opening ){
                reset();
                set_types(current_organization);
                set_verbs_and_tags(flow['resource_type'].input.val(), current_organization);
                button.children('span').html(i18n.close_add_permission);
                button.addClass("highlighted");

                flow['resource_type'].input.unbind('change').change(function(event){
                    set_verbs_and_tags(event.currentTarget.value, current_organization);

                    if( current_stage !== 'resource_type' ){
                        current_stage = 'verbs';
                        flow['tags'].container.hide();
                        flow['details'].container.hide();
                        next_button.show();
                        done_button.hide();
                        progress_bar.setProgress(50);
                    }
                    if( all_verbs_button.hasClass('selected') ){
                        handleAllVerbs();
                    }
                    if( all_tags_button.hasClass('selected') ){
                        handleAllTags();
                    }
                });

                flow['verbs'].input.unbind('change').change(function(event){
                    if( only_no_tag_verbs_selected() ){
                        current_stage = 'verbs';
                        flow['tags'].container.hide();
                        flow['details'].container.hide();
                        next_button.show();
                        done_button.hide();
                        progress_bar.setProgress(50);
                        set_verbs_and_tags(flow['resource_type'].input.val(), current_organization, true);
                    } else {
                        if( current_stage === 'tags' ){
                            flow['tags'].container.show();
                        } else if( current_stage === 'details' ){
                            flow['tags'].container.show();
                            flow['details'].container.hide();
                            current_stage = 'tags';
                            progress_bar.setProgress(75);
                        }
                        next_button.show();
                        done_button.hide();
                        set_verbs_and_tags(flow['resource_type'].input.val(), current_organization, false);
                    }

                });

                if( current_organization === "global" ){
                    $('#permission_widget_header').html(i18n.add_header_global);
                } else {
                    $('#permission_widget_header').html(i18n.add_header_org + ' ' + roles_breadcrumb[current_organization].name);
                }
                $('#permission_widget_header').addClass('one-line-ellipsis');
            } else {
                button.children('span').html(i18n.add_permission);
                button.removeClass("highlighted");
            }

            return options;
        },
        edit_permission = function(options){
            var permission                 = roles_breadcrumb[KT.roles.tree.get_current_crumb()],
                opening                  = options.opening,
                current_organization     = roleActions.getCurrentOrganization(),
                button                     = $('#edit_permission'),
                i = 0, length = 0, values =[];

            mode = 'update';

            if( opening ){
                reset();
                button.children('span').html(i18n.close_edit_permission);
                button.addClass("highlighted");
                set_types(current_organization);

                KT.utils.each(flow, function(item, key){
                    item.container.show();
                });

                flow['resource_type'].input.val(permission.type);
                flow['details'].input.val(permission.name);
                $('#description').val(permission.description);

                flow['resource_type'].input.unbind('change').change(function(event){
                    set_verbs_and_tags(event.currentTarget.value, current_organization);

                    if( flow['resource_type'].input.val() !== 'organizations' && current_organization !== 'global' ){
                        flow['tags'].container.show();
                    } else {
                        flow['tags'].container.hide();
                    }

                    if( event.currentTarget.value === 'all' ){
                        handleAllTypes();
                    }

                    if( all_verbs_button.hasClass('selected') ){
                        handleAllVerbs();
                    }
                    if( all_tags_button.hasClass('selected') ){
                        handleAllTags();
                    }
                }).change();

                flow['verbs'].input.unbind('change').change(function(event){
                    if( only_no_tag_verbs_selected() ){
                        flow['tags'].container.hide();
                        set_verbs_and_tags(flow['resource_type'].input.val(), current_organization, true);
                    } else {
                        set_verbs_and_tags(flow['resource_type'].input.val(), current_organization, false);
                        flow['tags'].container.show();
                    }

                });

                set_verbs_and_tags(flow['resource_type'].input.val(), current_organization, false);

                if( permission.verbs === 'all' ){
                    handleAllVerbs(false);
                } else {
                    length = permission.verbs.length;
                    for( i=0; i < length; i += 1){
                                            values.push(permission.verbs[i].name);
                        flow['verbs'].input.find('option[value=' + permission.verbs[i].name + ']').attr('selected', true);
                    }
                    flow['verbs'].input.val(values);
                }

                if( permission.tags === 'all' ){
                    handleAllTags(false);
                } else {
                    length = permission.tags.length;
                    for( i=0; i < length; i += 1){
                                            values.push(permission.tags[i].name);
                        flow['tags'].input.find('option[value=' + permission.tags[i].name + ']').attr('selected', true);
                    }
                    flow['tags'].input.val(values);
                }

                if( permission.type === 'all' ){
                    flow['tags'].container.hide();
                    flow['verbs'].container.hide();
                }

                if( only_no_tag_verbs_selected() ){
                    flow['tags'].container.hide();
                }

                if( roleActions.getCurrentOrganization() === 'global' ){
                    flow['tags'].container.hide();
                }

                current_stage = 'details';
                next_button.hide();
                done_button.show();
                previous_button.hide();

                progress_bar.setProgress(100);

                $('#permission_widget_header').html(i18n.edit_permission_header + ' ' + roles_breadcrumb[current_organization].name + ' - ' + permission.name);
                $('#permission_widget_header').addClass('one-line-ellipsis');
            } else {
                button.children('span').html(i18n.edit_permission);
                button.removeClass("highlighted");
            }

            return options;
        },
        handleAllTypes = function(selected){
            selected = selected || all_types_button.hasClass('selected');

            if( !selected ){
                flow['resource_type'].input.hide();
                flow['resource_type'].input.val('all');
                $('#all_types_span').hide();
                $('<span id="all_types_selected" class="grid_5">' + i18n.all_types_selected + '</span>').insertBefore(all_types_button);
                all_types_button.html(i18n.cancel);
                all_types_button.addClass('selected');
                flow['verbs'].container.hide();
                flow['tags'].container.hide();
                previous_button.hide();

                if( mode === 'create' ){
                    current_stage = 'resource_type';

                    $('#all_types_span').hide();
                    flow['details'].container.hide();

                    progress_bar.setProgress(25);
                    done_button.hide();
                    next_button.show();
                   }
            } else {
                $('#all_types_span').show();
                flow['resource_type'].input.show();
                $('#all_types_selected').remove();
                all_types_button.html(i18n.all);
                all_types_button.removeClass('selected');
                flow['verbs'].container.show();
                flow['tags'].container.show();
                flow['resource_type'].input.val('organizations').change();

                if( mode === 'create' ){
                    flow['tags'].container.hide();
                    flow['details'].container.hide();
                    flow['verbs'].container.hide();
                    current_stage = 'resource_type';
                    next_button.show();
                    done_button.hide();
                    previous_button.hide();
                   }
            }
        },
        handleAllVerbs = function(selected){
            selected = selected || all_verbs_button.hasClass('selected');

            if( !selected ){
                flow['verbs'].input.find('option').attr('selected', 'selected');
                flow['verbs'].input.attr('disabled', 'disabled');
                all_verbs_button.html(i18n.cancel);
                all_verbs_button.addClass('selected');
            } else {
                flow['verbs'].input.find('option').removeAttr('selected');
                flow['verbs'].input.removeAttr('disabled');
                all_verbs_button.html(i18n.all);
                all_verbs_button.removeClass('selected');
            }
        },
        handleAllTags = function(selected){
            selected = selected || all_tags_button.hasClass('selected');

            if( !selected ){
                flow['tags'].input.attr('disabled', 'disabled');
                all_tags_button.html(i18n.cancel);
                all_tags_button.addClass('selected');
            } else {
                flow['tags'].input.removeAttr('disabled');
                all_tags_button.html(i18n.all);
                all_tags_button.removeClass('selected');
            }
        };

    return {
        add_permission    :  add_permission,
        edit_permission    :  edit_permission,
        init            :  init
    };

};

KT.roles.permissionWidget.progressBar = (function($){
    var init = function(progress){
            var progressbar = $('#progressbar');

            progressbar.progressbar({ value: progress });
        },
        setProgress = function(progress){
            var progressbar = $('#progressbar');

            progressbar.progressbar({ value: progress });
        };

    return {
        init         : init,
        setProgress  : setProgress
    };
})(jQuery);

var roleActions = (function($){
    var current_crumb = undefined,
        current_organization = undefined,

        role_edit = function(options){
            var name_box        = $('.edit_name_text'),
                edit_button     = $('#edit_role > span'),
                description     = $('.edit_description'),
                after_function  = undefined,
                nameBreadcrumb  = $('.tree_breadcrumb'),
                opening         = options.opening,

                setup_edit = function() {
                    var url = KT.routes.role_path($('#role_id').val()), //KT.common.rootURL() + "roles/" + $('#role_id').val(),
                        name_box = $('.edit_name_text'),
                        description = $('.edit_description'),
                        common = {
                            method      : 'PUT',
                            cancel      :  i18n.cancel,
                            submit      :  i18n.save,
                            indicator   :  i18n.saving,
                            tooltip     :  i18n.clickToEdit,
                            placeholder :  i18n.clickToEdit,
                            submitdata  :  $.extend({ authenticity_token: AUTH_TOKEN }, KT.common.getSearchParams()),
                            onerror     :  function(settings, original, xhr) {
                                original.reset();
                            }
                        };

                    name_box.each(function() {
                        var settings = {
                                type        :  'text',
                                width       :  270,
                                name        :  $(this).attr('name'),
                                onsuccess   :  function(data) {
                                      var parsed = $.parseJSON(data);
                                      roles_breadcrumb.roles.name = parsed.name;
                                      $('#list #role_' + $('#role_id').val() + ' .column_1').html(parsed.name);
                                      $('.edit_name_text').html(parsed.name);
                                      $('#roles').html(parsed.name + " \u2002\u00BB\u2002");
                                      notices.checkNotices();
                                }
                        };
                        $(this).editable( url, $.extend(settings, common));
                    });

                   description.each(function() {
                        var settings = {
                                type        :  'textarea',
                                name        :  $(this).attr('name'),
                                rows        :  5,
                                cols        :  30,
                                onsuccess   :  function(data) {
                                      var parsed = $.parseJSON(data);
                                      $('.edit_description').html(parsed.description);
                                      notices.checkNotices();
                                }
                        };
                        $(this).editable( url, $.extend(settings, common));
                    });
                };

            if ( opening ) {
                edit_button.html(i18n.close_role_details);
                edit_button.parent().addClass("highlighted");
                options['after_function'] = setup_edit;
            }
            else {
                edit_button.html(i18n.edit_role_details);
                edit_button.parent().removeClass("highlighted");
            }

            return options;
        },
        setCurrentCrumb = function(hash_id){
            current_crumb = hash_id;
        },
        getCurrentOrganization = function(){
            return current_organization;
        },
        setCurrentOrganization = function(hash_id){
            var split = hash_id.split('_');

            if( split[0] === 'organization' || split[0] === 'global' ){
                current_organization = hash_id;
                getPermissionDetails();
            } else if( split[1] === 'global' ) {
                current_organization = 'global';
                getPermissionDetails();
            } else if( split[0] === 'permission' ) {
                current_organization = 'organization_' + split[1];
                getPermissionDetails();
            } else {
                current_organization = hash_id;
            }
        },
        getPermissionDetails = function(){
            var id = current_organization.split('_')[1];

            if( !roles_breadcrumb[current_organization].permission_details && current_organization !== '' && current_organization !== undefined ){
                $('#add_permission').addClass('disabled');
                $.ajax({
                    type    : "GET",
                    url     : KT.common.rootURL() + 'roles/' + id + '/resource_type/verbs_and_scopes',
                    cache   : false,
                    dataType: 'json',
                    success : function(data){
                        if( roles_breadcrumb[current_organization] ){
                            roles_breadcrumb[current_organization].permission_details = data;
                        }
                        $('#add_permission').removeClass('disabled');
                    }
                });
            }
        },
        savePermission = function(mode, successCallback, errorCallback){
            var org_id = current_crumb.split('_')[1],
                form = $('#add_permission_form'),
                to_submit = form;

            if( current_organization !== "global" ){
                to_submit.find("#organization_id").val(org_id);
            }

            if( $('#all_verbs').hasClass('selected') ){
                to_submit = to_submit.serializeArray();
                to_submit.push({ name : 'permission[all_verbs]', value : true });
            }

            if( $('#all_tags').hasClass('selected') ){
                if( !(to_submit instanceof Array) ){
                    to_submit = to_submit.serializeArray();
                }
                to_submit.push({ name : 'permission[all_tags]', value : true });
            }

            if( to_submit instanceof Array ){
                to_submit = $.param(to_submit);
            } else {
                to_submit = to_submit.serialize();
            }

            if( mode === 'create' ){
                $.ajax({
                   type     : "PUT",
                   url      : $('#save_permission_button').attr('data-url'),
                   cache    : false,
                   data     : to_submit,
                   dataType : 'json',
                   success  : function(data){
                       $.extend(roles_breadcrumb, data);
                       KT.roles.tree.rerender_content();
                       form[0].reset();
                       roles_breadcrumb[current_organization].count += 1

                       if( data.type === "all" ){
                           roles_breadcrumb[current_organization].full_access = true
                       }

                       successCallback();
                   },
                   error    : function(){
                errorCallback();
                   }
                });
            } else if( mode === 'update' ){
                $.ajax({
                   type     : "POST",
                   url      : KT.common.rootURL() + "roles/" + $('#role_id').val() + "/permission/" + current_crumb.split('_')[2] + "/update_permission/",
                   cache    : false,
                   data     : to_submit,
                   dataType : 'json',
                   success  : function(data){
                       roles_breadcrumb[current_crumb] = data[current_crumb];
                       KT.roles.tree.rerender_content();
                       KT.roles.tree.rerender_breadcrumb();
                       form[0].reset();

                       if( data.type === "all" ){
                           roles_breadcrumb[current_organization].full_access = true
                       }

                       successCallback();
                   },
                   error    : function(){
                           errorCallback();
                   }
                });
            }
        },
        remove_permission = function(element){
            var id = element.attr('data-id');

            element.html(i18n.removing);

            $.ajax({
               type     : "DELETE",
               url      : KT.common.rootURL() + "roles/" + $('#role_id').val() + "/permission/" + id.split('_')[2] + "/destroy_permission/",
               cache    : false,
               dataType : 'json',
               success  : function(data){
                    if( roles_breadcrumb[id].type === "all" ){
                        delete roles_breadcrumb[id];
                        roles_breadcrumb[current_organization].full_access = false;

                        KT.utils.each(roles_breadcrumb, function(item, key){
                            if( key.split('_')[0] === 'permission' && key.split('_')[1] === id.split('_')[1] && item.type === 'all'){
                                roles_breadcrumb[current_organization].full_access = true;
                            }
                        });
                    } else {
                        delete roles_breadcrumb[id];
                    }
                    roles_breadcrumb[current_organization].count -= 1;
                    KT.roles.tree.rerender_content();
               },
               error     : function(){
                       element.removeClass('disabled');
               }
            });
        },
        edit_user = function(element, adding){
            var submit_data = { update_users : { adding : adding, user_id : element.attr('data-id').split('_')[1] }};

            if( adding ){
                element.html(i18n.adding);
            } else {
                element.html(i18n.removing);
            }
            $.ajax({
               type     : "PUT",
               url      : KT.common.rootURL() + "roles/" + $('#role_id').val(),
               cache    : false,
               data     : $.param(submit_data),
               dataType : 'json',
               success  : function(data){
                    if( adding ){
                        roles_breadcrumb[element.attr('data-id')].has_role = true;
                    } else {
                        roles_breadcrumb[element.attr('data-id')].has_role = false;
                    }
                    KT.roles.tree.rerender_content();
               },
               error     : function(){
                       element.removeClass('disabled');
                   KT.roles.tree.rerender_content();
               }
            });
        },
        handleContentAddRemove = function(element){
            element.addClass('disabled');

            if( element.attr('data-type') === 'permission' ){
                if( element.hasClass('remove_permission') ){
                    remove_permission(element);
                }
            } else if( element.attr('data-type') === 'user'){
                if( element.hasClass('add_user') ){
                    edit_user(element, true);
                } else if( element.hasClass('remove_user') ){
                    edit_user(element, false);
                }
            }
        },
        add_group = function(element, val, role_id){
            var submit_data = { group : val };
                $.ajax({
                    type     : "POST",
                    url      : KT.routes.create_role_ldap_groups_path(role_id),
                    cache    : false,
                    data     : $.param(submit_data),
                    dataType : 'json',
                    success  : function(data){
                        element.removeClass('disabled');
                        $.extend(roles_breadcrumb, data);
                        KT.roles.tree.rerender_content();
                     },
                     error     : function(){
                        element.removeClass('disabled');
                        KT.roles.tree.rerender_content();
                     }
                  });
        },
        ldapGroupAdd = function(element, val, role_id){
            element.addClass('disabled');
            add_group(element, val, role_id);
        },
        remove_group = function(element, role_id, group_id){
            $.ajax({
                 type     : "DELETE",
                 url      : KT.routes.destroy_role_ldap_group_path(role_id, group_id),
                 cache    : false,
                 success  : function(data){
                      element.removeClass('disabled');
                      delete roles_breadcrumb['ldap_group_' + group_id];
                      KT.roles.tree.rerender_content();
                 },
                 error     : function(){
                      element.removeClass('disabled');
                      KT.roles.tree.rerender_content();
                 }
            });
        },
        ldapGroupRemove = function(element, role_id, group_id){
            element.addClass('disabled');
            remove_group(element, role_id, group_id);
        },
        removeRole = function(button){
            button.addClass('disabled');
            $.ajax({
                type: "DELETE",
                url: button.attr('data-url'),
                cache: false,
                success: function(data){
                     // Generally a bad idea - trusting implicility the data being returned from the server
                     // This conforms with how other 'removes' on the site work - relying on a partial template
                     // to render and return the proper actions for a delete
                     eval(data);
                }
           });
     };
    return {
        getPermissionDetails    :  getPermissionDetails,
        setCurrentCrumb         :  setCurrentCrumb,
        savePermission          :  savePermission,
        handleContentAddRemove  :  handleContentAddRemove,
        ldapGroupAdd         :  ldapGroupAdd,
        ldapGroupRemove      :  ldapGroupRemove,
        setCurrentOrganization  :  setCurrentOrganization,
        getCurrentOrganization  :  getCurrentOrganization,
        removeRole              :  removeRole,
        role_edit               :  role_edit
    };

})(jQuery);

var templateLibrary = (function($){
    var listItem = function(id, name, count, notation, no_slide){
            var html ='';

            if( no_slide ){
                html += '<li class="no_slide"><div id="' + id + '">';
            } else {
                html += '<li class="slide_link"><div class="simple_link link_details" id="' + id + '">';
            }

            html += '<span class="sort_attr">'+ name;

            if( notation !== undefined && notation !== null && notation !== false ){
                html += ' (' + notation + ') ';
            }

            if( count !== undefined && count !== null && count !== false ){
                html += ' (' + count + ')';
            }

            html += '</span></div></li>';

            return html;
        },
        list = function(items, type, options){
            var html = '<ul class="filterable">',
                options = options ? options : {};
            KT.utils.each(items, function(item, key){
                if( key.split("_")[0] === type ){
                    html += listItem(key, item.name, false, false, options.no_slide);
                }
            });
            html += '</ul>';
            return html;
        },
        organizationsList = function(items, type, options){
            var html = '<ul class="filterable">',
                options = options ? options : {},
                full_access = false;

            html += listItem('global', items['global'].name, items['global'].count, false);

            KT.utils.each(items, function(item, key){
                if( key.split("_")[0] === type ){
                    full_access = item.full_access ? i18n.full_access : false;
                    html += listItem(key, item.name, item.count, full_access, options.no_slide);
                }
            });
            html += '</ul>';
            return html;
        },
        ldapGroupsList = function(ldap_groups,options) {
            var html = "";
            if (permissions.update_roles) {
              html += '<ul><li class="content_input_item"><form id="add_ldap_group_form">';
              html += '<input id="add_ldap_group_input" type="text" size="33"><form>  ';
              html += '<a id="add_ldap_group" class="fr st_button ">' + i18n.add_plus + '</a>';
              html += '<input id="add_ldap_group_input_id" type="hidden">';
              html += ' </li></ul>';
            }
            html +=  '<ul class="filterable">';
            for( item in ldap_groups){
              if( item.split("_")[0] === "ldap") {
              html += ldapGroupsListItem(ldap_groups[item].id, ldap_groups[item].name, options.show_button);
                count += 1;
              }
              }
            return html + "</ul>";
        },
        ldapGroupsListItem = function(group_id, name, showButton) {
            var anchor = "";
            if ( showButton ) {
                anchor = '<a ' + 'class="fr remove_ldap_group remove_group st_button"'
                               + 'data-type="group" data-id="' + group_id + '">';
                anchor += i18n.remove + "</a>";
            }
            return '<li >' + anchor + '<div class="simple_link" id="' + group_id + '"><span class="sort_attr">'  + name + '</span></div></li>';
        },
        permissionsList = function(permissions, organization_id, options){
            var html = '<ul class="filterable">',
                count = 0;

            KT.utils.each(permissions, function(item, key){
                if( key.split("_")[0] === "permission" && permissions[key].organization === 'organization_' + organization_id ){
                    html += permissionsListItem(key, item.name, options.show_button);
                    count += 1;
                }
            });

            if( count === 0 ){
                html += '<li class="no_slide no_hover">' + i18n.no_permissions + '</li>';
            }
            html += '</ul>';
            return html;
        },
        permissionsListItem = function(permission_id, name, showButton) {
            var anchor = "";

            if ( showButton ) {
                anchor = '<a ' + 'class="fr content_add_remove remove_permission st_button"'
                                + 'data-type="permission" data-id="' + permission_id + '">';
                            anchor += i18n.remove + "</a>";
            }

            return '<li class="slide_link">' + anchor + '<div class="simple_link link_details" id="' + permission_id + '"><span class="sort_attr">'  + name + '</span></div></li>';
        },
        permissionItem = function(permission){
            var i = 0, length = 0,
                html = '<div class="permission_detail">';

            html += '<div class="permission_detail_container"><label class="grid_3 ra">' + i18n.name_colon + '</label><span>' + permission.name + '</span></div>';
            html += '<div class="permission_detail_container"><label class="grid_3 raf">' + i18n.description_colon + '</label><span>' + permission.description + '</span></div>';
            html += '<div class="permission_detail_container"><label class="grid_3 ra">' + i18n.permission_for_colon + '</label><span>' + permission.type_name + '</span></div>';

            html += '<div class="permission_detail_container"><label class="grid_3 ra">' + i18n.verbs_colon + '</label><ul>'

            if( permission.verbs === 'all'){
                    html += '<li>' + i18n.all + '</li>';
            } else {
                length = permission.verbs.length;
                for( i=0; i < length; i += 1){
                    html += '<li>' + permission.verbs[i].display_name + '</li>';
                }
            }
            html += '</ul></div>';

            html += '<div class="permission_detail_container"><label class="grid_3 ra">' + i18n.on_colon + '</label><ul>';
            if( permission.tags === 'all' ){
                    html += '<li>' + i18n.all + '</li>';
            } else {
                length = permission.tags.length;
                for( i=0; i < length; i += 1){
                    html += '<li>' + permission.tags[i].display_name + '</li>';
                }
            }
            html += '</ul></div></div>';

            return html;
        },
        usersListItem = function(user_id, name, has_role, no_slide, showButton) {
            var anchor = "",
                html = no_slide ? '<li class="no_slide">' : '<li class="slide_link">';

            if ( showButton ) {
                anchor = '<a ' + 'class="fr content_add_remove ';
                anchor += has_role ? 'remove_user' : 'add_user';
                anchor += ' st_button" data-type="user" data-id="' + user_id + '">';
                anchor += has_role ? (i18n.remove + "</a>") : (i18n.add + "</a>");
            } else {
                anchor = "<div class=\"fr st_button\">";
                anchor += has_role ? (i18n.rule_applied + "</div>") : (i18n.rule_not_applied + "</div>");
            }

            html += anchor + '<div class="simple_link ';
            html += no_slide ? "" : "link_details";
            html += '"><span class="sort_attr">'  + name + '</span></div></li>';

            return html;
        },
        usersList = function(users, options){
            var html = '<ul class="filterable">',
                user = undefined;

            KT.utils.each(users, function(user, key){
                username = key.split("_");
                if( username[0] === "user" ){
                    html += usersListItem(key, user.name, user.has_role, options.no_slide, options.show_button);
                }
            });
            html += '</ul>';
            return html;
        },
        globalsList = function(globals, options){
            var html = '<ul class="filterable">',
                count = 0;

            KT.utils.each(globals, function(item, key){
                if( key.split("_")[0] === "permission" && key.split("_")[1] === 'global' ){
                    html += permissionsListItem(key, item.name, options.show_button);
                    count += 1;
                }
            });
            if( count === 0 ){
                html += '<li class="no_slide no_hover">' + i18n.no_global_permissions + '</li>';
            }
            html += '</ul>';
            return html;
        };

    return {
        list                :    list,
        organizationsList   :    organizationsList,
        permissionsList     :    permissionsList,
        usersList           :    usersList,
        ldapGroupsList      :    ldapGroupsList,
        globalsList         :    globalsList,
        permissionItem      :    permissionItem
    }
}(jQuery));

var rolesRenderer = (function($){
    var render = function(hash, render_cb){
            var options = {};

            if( hash === 'role_permissions' ){
                render_cb(templateLibrary.organizationsList(roles_breadcrumb, 'organization'));
            } else if( hash === 'roles' ) {
                render_cb(templateLibrary.list(roles_breadcrumb, 'role'));
            } else if( hash === 'role_users' ){
                if (permissions.create_roles || permissions.update_roles) {
                    options.show_button = true;
                }

                options.no_slide = true;
                render_cb(templateLibrary.usersList(roles_breadcrumb, options));
            } else if( hash === 'role_ldap_groups' ){
                if (permissions.create_roles || permissions.update_roles) {
                    options.show_button = true;
                }

                options.no_slide = true;
                render_cb(templateLibrary.ldapGroupsList(roles_breadcrumb, options));
            } else if( hash === 'global' ) {
                if ((!roles_breadcrumb.roles.locked) && (permissions.create_roles || permissions.update_roles)) {
                    options.show_button = true;
                }

                options.no_slide = false;
                render_cb(templateLibrary.globalsList(roles_breadcrumb, options));
            } else {
                var split = hash.split("_"),
                    page = split[0],
                    organization_id = split[1];

                render_cb(getContent(page, hash, organization_id));
            }
        },
        getContent = function(key, hash, organization_id){
            var options = {};

            if( key === 'organization' ){
                if ((!roles_breadcrumb.roles.locked) && (permissions.create_roles || permissions.update_roles)) {
                    options.show_button = true;
                }

                return templateLibrary.permissionsList(roles_breadcrumb, organization_id, options);
            } else if( key === 'permission' ){
                return templateLibrary.permissionItem(roles_breadcrumb[hash]);
            }
        },
        sort = function(hash_id) {
            $(".will_have_content").find("li").sortElements(function(a,b){
                    var a_html = $(a).find(".sort_attr").html();
                    var b_html = $(b).find(".sort_attr").html();
                    if (a_html && b_html ) {
                        return  a_html.toUpperCase() >
                                b_html.toUpperCase() ? 1 : -1;
                    }
            });

            if( hash_id === "role_permissions" ){
                $('#global').parent().prependTo($(".will_have_content ul"));
            }
        },
        setTreeHeight = function(){
            var height = $('.left_panel').height(),
                panel_main = $('#panel_main');

            panel_main.find('.sliding_list').css({ 'height' : height - 60 });
            panel_main.find('.slider').css({ 'height' : height - 60 });
            panel_main.height(height);
            panel_main.find('.jspPage').height(height);
        },
        setSizing = function(){
            var panel = $('.panel-custom'),
                width = panel.width();

            panel.find('.sliding_container').width(width);
            panel.find('.breadcrumb_filter').width(width);
            panel.find('.slider').width(width);
            panel.find('.sliding_list').width(width * 2);
            panel.find('.slide_up_container').width(width);
        },
        init = function(){
            var left_panel = $('.left_panel');

            left_panel.resize(function(){
                setSizing();
            });
            left_panel.trigger('resize');
        },
        setSummary = function(hash_id){
            var summary = $('#roles_status');

            if( hash_id === 'roles' ){
                if (permissions.create_roles || permissions.update_roles) {
                    summary.html(i18n.roles_summary);
                } else {
                    summary.html(i18n.roles_summary_readonly);
                }
            } else if( hash_id === 'role_users' ) {
                if (permissions.create_roles || permissions.update_roles) {
                    summary.html(i18n.users_summary);
                } else {
                    summary.html(i18n.users_summary_readonly);
                }

            } else if ( hash_id === 'role_permissions' ) {
                if (permissions.create_roles || permissions.update_roles) {
                    summary.html(i18n.role_permissions_summary);
                } else {
                    summary.html(i18n.role_permissions_summary_readonly);
                }
            } else if ( hash_id === 'global' || hash_id.match(/organization?/g) ){
                if (permissions.create_roles || permissions.update_roles) {
                    summary.html(i18n.permissions_summary);
                } else {
                    summary.html(i18n.permissions_summary_readonly);
                }
            } else if ( hash_id.match(/permission?/g) ){
                if (permissions.create_roles || permissions.update_roles) {
                    summary.html(i18n.permission_detail_summary);
                } else {
                    summary.html(i18n.permission_detail_readonly);
                }
            }
        },
        handleButtons = function(hash_id){
            var type = hash_id.split('_')[0],
                add_permission_button = $('#add_permission'),
                edit_permission_button = $('#edit_permission');

            if( type === 'organization' || type === 'permission' || type === 'global' ){
                add_permission_button.removeClass('disabled');
                roleActions.setCurrentOrganization(hash_id);
            } else {
                add_permission_button.addClass('disabled');
                roleActions.setCurrentOrganization('');
            }

            if( type === 'permission' ){
                edit_permission_button.removeClass('disabled');
            } else if( !edit_permission_button.hasClass('disabled') ) {
                edit_permission_button.addClass('disabled');
            }
        };

    return {
        init            :   init,
        render          :   render,
        sort            :   sort,
        setTreeHeight   :   setTreeHeight,
        setSummary      :   setSummary,
        handleButtons   :   handleButtons
    }

}(jQuery));

var pageActions = (function($){
    var toggle_list = {
            'role_edit'    :  { container     : 'role_edit',
                             button        : 'edit_role',
                             setup_fn     : roleActions.role_edit }
        },

        registerEvents = function(){
            var action_bar = KT.roles.actionBar;

            $('.content_add_remove').live('click', function(){
                if( $(this).hasClass('disabled') ){
                    return false;
                }
                roleActions.handleContentAddRemove($(this));
            });

            $('#add_ldap_group').live('click', function(){
                if( $(this).hasClass('disabled') ){
                    return false;
                }
                roleActions.ldapGroupAdd($(this), $("#add_ldap_group_input").val(), $('#role_id').val());
            });

            $('.remove_ldap_group').live('click', function(){
                if( $(this).hasClass('disabled') ){
                    return false;
                }
                roleActions.ldapGroupRemove($(this), $("#role_id").val(), $(this).data('id'));
            });

            $('#remove_role').live('click', function(){
                var button = $(this);
                KT.common.customConfirm({
                    message: button.attr('data-confirm-text'),
                    yes_callback: function(){
                        roleActions.removeRole(button);
                    }
                });
            });

            $('#remove_role').live('keypress', function(event){
                var button = $(this);
                event.preventDefault();

                if( event.which === 13 ){
                    KT.common.customConfirm({
                        message: button.attr('data-confirm-text'),
                        yes_callback: function(){
                            roleActions.removeRole(button);
                        }
                    });
                }
            });

            KT.panel.set_contract_cb(function(name){
                $.bbq.removeState("role_edit");
                $('#panel').removeClass('panel-custom');
                action_bar.reset();
            });

            KT.panel.set_switch_content_cb(function(){
                $.bbq.removeState("role_edit");
                $('#panel').removeClass('panel-custom');
                action_bar.reset();
            });
        };

    return {
        registerEvents  :  registerEvents,
        toggle_list     :  toggle_list
    };

})(jQuery);

$(document).ready(function() {

    KT.roles.actionBar = sliding_tree.ActionBar();

    pageActions.registerEvents();

    $('.left_panel').resizable('destroy');

    var find_text = function(){
      var title = $(this).attr('original-title');
      if (title.length > 0) {
        return $(this).find('.text').text() + "<br />" +  title;
      }
      else {
        return $(this).find('.text').text();
      }
    };
    $('.cs_action').tipsy({
      html : true,
      fade : true,
      gravity : 's',
      live : true,
      delayIn : 500,
      hoverable : true,
      delayOut : 50,
      title:find_text});
});

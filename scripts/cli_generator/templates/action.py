
class ${method.name(True, True)}(${resource.name(True, True)}Action):

    description = _('${method.description()}')

    def setup_parser(self, parser):
        % for p in method.params():
        parser.add_option('--${p.name()}', dest='${p.name()}', help=_("${p.help()}"))
        % endfor
        % if method.name() in ['destroy', 'show']:
        parser.add_option('--name', dest='name', help=_(" (required)"))
        % endif

    def check_options(self, validator):
        % if method.params(required=True):
        validator.require(('${"', '".join([p.name() for p in method.params(required=True)])}'))
        % else:
        #validator.require()
        % endif
        #TODO: fill the method body
        pass

    def run(self):
        #TODO: fill the method body

        % if method.name() in ['list', 'show'] and resource.has_method('create'):
        ${resource.name(True, False)} = self.api.${method.name(True, False)}()
            % for p in resource.get_method('create').params():
        self.printer.add_column('${p.name()}')
            % endfor

        #TODO: print the data
        self.printer.set_header(_("${resource.name(False, True)}"))
        self.printer.print_item(${resource.name(True, False)})
        % else:
        ${resource.name(True)} = self.api.${method.name(True)}()
        print _('${resource.name(False, True)} ...')
        % endif

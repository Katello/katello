

    ${name}_cmd = ${name}.${resource.name(True,True)}()
    % for m in resource.methods():
    ${name}_cmd.add_command('${m.name()}', ${name}.${m.name().title()}())
    % endfor
    katello_cmd.add_command('${name}', ${name}_cmd)

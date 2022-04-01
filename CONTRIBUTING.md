Contributing to Katello
=======================

```
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$7......~$$$$:......:$$$$:......$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$.    .=$$$7:     .:$$$$,      $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$.    .=$$$7:     .:$$$$,      $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$.     ........................$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$.        .....................$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$+.           . .    . .    ..=$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$I        . .... . .. .. . ..7$$$$$$$$$$$$$$$$$$$$$$$+....$$$$
$$$$$$$$$$$$$$$$$.                       ..$$$$$$$$$$$$$$$$$$$$$$$7$,   .$$$$
$$$$$$$$$$$$$$$$$7,                      .7$$$$$$$$$$$$$$?~.=I$$$$$$$=,=7$$$$
$$$$$$$$$$$$$$$$$$$..                   .?$$$$$$$$$$$$?..I$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$$$7 .                   ..$$$$$$$$$$..=$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$$$.                      .$$$$$$$7..~$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$$$.                      .$$$$$$:..$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$$~.     .....$$$..........~$$$7..+$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$$ .         .$$$.        ..$$$...$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$$.  . .     .$$$.        ..I7  ,$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$7        . ..$$$. .  .. . ..7:..,$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$.            ....          .$$$+..=$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$.                          .I$$$$I..+$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$:                           .:$$$$$$7..7$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$.                        .    $$$$$$$$7..$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$I.                             ?$$$$$$$$$$,,$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$7,.                             .$$$$$$$$$$$7,:$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$..                            ..7$$$$$$$$$$$$$~,$$$$$$$$$$$$$$$
$$7$$$$$$$$$$$                               .,$$$$$$$$$$$$$$$,I$$$$$$$$$$$$$
$$$$7$$$$$$$$: . .. . .                       .$$$$$$$$$$$$$$$$$:$$$$$$$$$$$$
$$$$$$7:$$$$$.           ...,+7$$$$$$$$$$$$I,..$$$$$$$$$$$$$$$$$$$7$$$$$$$$$$
$$$$$$$$$77$?~::::+I$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
```
---
As an open-source project, we enjoy working with the community. We've developed
some guidelines though for contributing to Katello. Please see our
[development guidelines](https://www.theforeman.org/plugins/katello/developers.html).
Also, make sure your code conforms to our style guidelines:

* [Ruby guidelines](https://theforeman.org/handbook.html#Ruby)
* [Javascript guidelines](https://theforeman.org/handbook.html#JavaScript)

Be sure to check out our README and let us know on our mailing list or IRC
if you have any questions.

---
## JS/React workflow recommendations 
### NVM/Node versions
Katello and Foreman are packaged and run CI/CD on a common version of node. 
Deviating greatly from this version (i.e., by running the latest version for example) can cause some unique errors which may be difficult to diagnose.

To avoid this issue it is recommended to install and use Node Version Manager - [nvm](https://github.com/nvm-sh/nvm).

The currently supported version of node for Katello and Foreman can be found by inspecting the *.nvmrc* file within Katello's root directory.

Once nvm is installed, ensure that both your Foreman and Katello terminal windows are running the recommended version of node by installing it: 

```
$ nvm install <recommended version>

Now using node XX.XX.XX
``` 
Now when opening a terminal window in the future you can do the following to ensure you're on the correct node version:

```
$ node -v

XX.XX.XX 

$ nvm use <recommended version>  

Now using node XX.XX.XX
```

>### Q: But I've already bundle installed and npm installed in my foreman directory with the incorrect node version, what should I do? 
>> ### A: You will need to delete your *node_modules* and *package-lock.json* in both your Katello and Foreman directories. Then re-run *npm install* within your foreman directory, first ensuring you are on the correct node version of course.

---
### Linting and Testing:
The Katello Repo's CI/CD pipeline runs both lint and React testing steps, which are required to pass for a PR to be merged.

The following commands run locally (while in the Katello directory) will help to identify any issues with linting or tests.

### Lint:  
`npx eslint webpack --fix`
### Jest Test:  
`npx jest webpack`

--- 
### Visual Studio Code 

Although, contributors are free to use any IDE they wish; below are a few settings that may be useful for those who would like a head start with their VS Code configuration.

### Settings recommendations

To be added via code>preferences>settings or via *.vscode/settings.json*
```
{
  "editor.detectIndentation": false,
  "editor.tabSize": 2,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "javascript.updateImportsOnFileMove.enabled": "always",
  "editor.formatOnSave": true,
  "terminal.integrated.scrollback": 10000,
  "[javascript]": {
    "editor.defaultFormatter": "vscode.typescript-language-features"
  },
  "[jsonc]": {
    "editor.defaultFormatter": "vscode.json-language-features"
  },
  "[scss]": {
    "editor.defaultFormatter": "michelemelluso.code-beautifier"
  },
}
```

### Extension recommendations 
To be added via the extensions tab or *.vscode/extensions.json*
```
{
  "recommendations": [
    "nucllear.vscode-extension-auto-import",
    "dbaeumer.vscode-eslint",
    "rvest.vs-code-prettier-eslint",
    "firsttris.vscode-jest-runner",
    "michelemelluso.code-beautifier",
    "steoates.autoimport"
  ]
} 
```


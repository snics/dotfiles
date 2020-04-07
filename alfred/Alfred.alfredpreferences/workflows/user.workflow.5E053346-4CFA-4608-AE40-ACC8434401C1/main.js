class Util {
    static get currentPath() {
        var currApp = Application.currentApplication();
        currApp.includeStandardAdditions = true;

        var path = $.NSString.alloc.initWithUTF8String(currApp.pathTo());

        return path.stringByDeletingLastPathComponent.js;
    }

    static escapeXML(text) {
        return text.replace(/&/g, '&amp;')
                   .replace(/'/g, '&apos;')
                   .replace(/</g, '&lt;')
                   .replace(/>/g, '&gt;')
                   .replace(/"/g, '&quot;');
    }

    static unescapeXML(text) {
        return text.replace(/&amp;/g, '&')
                   .replace(/&apos;/g, '\'')
                   .replace(/&lt;/g, '<')
                   .replace(/&gt;/g, '>')
                   .replace(/&quot;/g, '"');
    }
}

class Browser {
    constructor(bundleId) {
        this.app = Application(bundleId);
        this.key = {
            currentTab: 'currentTab',
            title: 'title',
            url: 'url'
        };
    }

    hasWindow() {
        return this.app.running() && this.app.windows.length;
    }

    get currentTab() {
        if (this.hasWindow()) {
            return this.app.windows.at(0)[this.key.currentTab]();
        } else {
            return;
        }
    }

    get currentTabInfo() {
        var tab = this.currentTab;

        if (tab) {
            return {
                title: tab[this.key.title](),
                url: tab[this.key.url]()
            };
        } else {
            return {};
        }
    }
}

class Chrome extends Browser {
    constructor() {
        super('com.google.Chrome');
        this.key.currentTab = 'activeTab';
    }
}

class Safari extends Browser {
    constructor() {
        super('com.apple.Safari');
        this.key.title = 'name';
    }
}

class Alfred {
    static generateOutput(data, templates) {
        var header = '<?xml version="1.0"?><items>';
        var footer = '</items>';
        var regExp = /\$\{([^}]+)\}/;
        var match;

        var body = templates.map(function(template) {
            var title = Util.escapeXML(template.title);
            var text = template.format;

            while (match = regExp.exec(text)) {
                text = text.replace(match[0], data[match[1]]);
            }

            text = Util.escapeXML(text);

            return `<item arg="${text}"><title>${title}</title><subtitle>${text}</subtitle><text type="copy">${text}</text></item>`
        }).join('');

        return header + body + footer;
    }
}

class Addressive {
    get data() {
        var processes = Application('System Events').processes;

        if (processes.byName('Google Chrome').exists()) {
            return new Chrome().currentTabInfo;
        } else if (processes.byName('Safari').exists()) {
            return new Safari().currentTabInfo;
        }
    }

    get templates() {
        // return $.NSString.stringWithContentsOfFile(Util.currentPath + '/config.json').js;
        return JSON.parse($.NSString.stringWithContentsOfFile('/Users/fallroot/Projects/Alfred\ Workflows/Addressive/src/config.json').js) || [];
    }

    run() {
        var data = this.data;
        var templates = this.templates;

        if (!data || !templates) {
            return;
        }

        return Alfred.generateOutput(data, templates);
    }
}

function run() {
    return new Addressive().run();
}

run();

{BufferedNodeProcess} = require 'atom'
{$} = require 'space-pen'

configDefaults =
  rootPath: atom.config.get('docapp.rootPath')
  databaseCache: true
  regenerateDelay: 10
  logLevel: 0

Docpad = require(configDefaults.rootPath+'/node_modules/docpad')

class Generator
  decorator = null
  instance = null

  @runChild: (callback)->
    options =
      cwd: atom.config.get('docapp.rootPath')
      detached: true

    args = ['watch']
    stderr = (err) ->
      console.error(err)
    stdout = (data)->
      console.log(data)
    exit = (data)->
      console.log(data)

    child = new BufferedNodeProcess
      command: '/var/www/atom/docapp/lib/generators/docpad-child.js'
#      command: '/var/www/atom/project/node_modules/docpad/out/bin/docpad.js'
      args: args
      options: options
      stdout: stdout
      stderr: stderr
      exit: exit
    child.onWillThrowError (error) ->
      console.error(error)

  @run: (callback) ->
    decorator ?= @
    if instance?
      if instance == 'already running'
        setTimeout () =>
          @.run(callback)
        , 1000
      else
        callback()
    else
      console.time('docpad-run')
      instance = 'already running'
      Docpad.createInstance configDefaults, (err, docpadInstance) ->
        return console.log(err.stack)  if err
        docpadInstance.on 'notify', (opts, next) ->
          if opts.options.title == "Website generating..." and decorator.HtmlTab?.htmlTabView?.open
            atom.nprogress.start()
          console.log(opts.options.title, opts.message)
          next()
        docpadInstance.on 'generateBefore', (opts, next) ->
          atom.nprogress.start() if decorator.HtmlTab?.htmlTabView?.open
          next()
        docpadInstance.on 'generateAfter', (opts, next) ->
          decorator.HtmlTab.reload() if decorator.HtmlTab?.htmlTabView?.open
          atom.nprogress.done()
          next()
        docpadInstance.on 'docpadDestroy', (opts, next) ->
          instance = null
          next()
        docpadInstance.action 'watch', (err) ->
#        docpadInstance.action 'genetate watch', (err) ->
#        docpadInstance.action 'load ready  watch', (err) ->
          console.log(err.stack) if err
          instance = docpadInstance
          console.timeEnd('docpad-run')
          callback()


  @activatePreview: (callback)->
    callback()




  @deployGhpages: (callback) ->
    configDefaults.env = 'static'
    Docpad.createInstance configDefaults, (err, docpadInstance) ->
      return console.log(err.stack)  if err
      docpadInstance.on 'notify', (opt) ->
        console.log(opt.options.title)
      docpadInstance.getPlugin('ghpages').deployToGithubPages callback



module.exports = Generator




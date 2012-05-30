fs   = require 'fs'
Path = require 'path'

LRPlugin = require './plugin'

AnalysisEngine = require '../model/analyzer'

class Graph


class LRPluginManager

  constructor: (@folders) ->
    unless @folders.length?
      throw new Error("No plugin folders specified")
    @analysisSchema = new AnalysisEngine.Schema()

    @analysisSchema.addProjectVarDef 'outputPaths', 'list'
    @analysisSchema.addProjectAnalyzer "Compute output paths", (project, emit) ->

      allCompilablePaths = []
      # todo

      for compilablePath in allCompilablePaths

        candidateNames = ['foo.bar.css', 'foo.bar']
        candidateDirsWithAuto = ['**/some/dir']
        candidateDirs = ['...']

        candidatePaths = [] # merge names and dirs

        # add to the graph with a rank
        for candidatePath in candidatePaths
          rank = 42 #...
          emit 'outputPaths', [compilablePath, candidatePath, rank]

      # the data structure should figure out the actual paths per file


  rescan: (callback) ->
    pluginFolders = []
    for folder in @folders
      for entry in fs.readdirSync(folder) when entry.endsWith('.lrplugin')
        pluginFolders.push Path.join(folder, entry)

    @plugins = []
    await
      for pluginFolder in pluginFolders
        plugin = new LRPlugin(pluginFolder)
        plugin.initialize @analysisSchema, defer(err)
        return callback(err) if err
        @plugins.push(plugin)

    @compilersById = {}
    for plugin in @plugins
      Object.merge @compilersById, plugin.compilers
    @compilers = (compiler for own _, compiler of @compilersById)

    @extensionsToMonitor = []
    @fileAndFolderNamesToIgnore = []
    for plugin in @plugins
      @extensionsToMonitor.pushAll plugin.extensionsToMonitor
      @fileAndFolderNamesToIgnore.pushAll plugin.fileAndFolderNamesToIgnore

    callback(null)


module.exports = LRPluginManager

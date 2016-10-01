_         = require 'lodash'
path      = require 'path'
commander = require 'commander'
colors    = require 'colors/safe'

HTMLToPDF   = require './'
packageJSON = require './package.json'

class Command
  printMissing: (message) =>
    commander.outputHelp()
    console.error colors.red message if message?
    process.exit 1

  run: =>
    commander
      .version packageJSON.version
      .option '-i --include <path>..<path>', 'path to either a javascript asset, or a css asset'
      .option '--page-size [size]', "'A3', 'A4', 'Legal', 'Letter' or 'Tabloid'"
      .option '--margin-type [n]', "Specify the type of margins to use: 0 - default, 1 - none, 2 - minimum"
      .option '--landscape', "If set it will change orientation to landscape from portriat"
      .option '--print-background', 'Whether to print CSS backgrounds'
      .option '-t --template [template]', "The template to used. Defaults to html5bp."
      .option '-d --render-delay [millis]', 'Delay before rendering the PDF (give HTML and CSS a chance to load)'
      .option '-o --output <path>', 'Path of where to save the PDF'
      .usage '[options] <path/to/html-file-path>'
      .parse process.argv

    inputPath = _.first commander.args
    outputPath = commander.output
    @printMissing 'Missing input path first argument' unless inputPath?
    @printMissing 'Missing -o, --output-path argument' unless outputPath?

    { pageSize, template, renderDelay, marginType } = commander
    printBackground = commander.printBackground?
    landscape = commander.landscape?

    includeAssets = _.compact _.castArray(commander.include?.split(','))
    include = _.map includeAssets, (filePath) =>
      type = path.extname(filePath).replace('.', '')
      return @printMissing 'Invalid asset path' unless type in [ 'css', 'js' ]
      return { type, filePath }
    console.log include

    options = {
      inputPath,
      outputPath,
      template,
      renderDelay,
      include,
      options: {
        landscape,
        printBackground,
        pageSize,
        marginType,
      }
    }

    new HTMLToPDF(options).build @die

module.exports = Command

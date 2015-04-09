# How to

**[NodeJS](http://nodejs.org/) v0.10.x is required**

## Install [GruntJS](http://gruntjs.com/)

```bash
npm install -g grunt-cli
```
**More Info at [GruntJS: Getting Started](https://github.com/gruntjs/grunt/wiki/Getting-started)**

## Install Dependencies

```bash
npm install
brew install sassc
```

## Compile the project

Create a `config.json` using `config.json.example`
Update with your configs:

* `root`: The root URL for every call (i.e. "http://analice.me/"). Can use relative paths like `"/"` or `""`(blank)
* `version`: WebAPI version, this is going to be appended into the url.  (i.e. `"api/v2/"`) - resulting in `http://analice.me/api/v2/`
* `poolingStatusTime`: milliseconds for refreshing the documents list

Run the following command at root of project to compile

```bash
grunt
```

And the following to minify

```bash
grunt dist
```

*grunt command will compile the project and leave the compiled files in `/dist`*

### FileSystem Watcher

> Only for Develop Environment

To set a watcher, so you wont need to be running `grunt` every time a change is made, run:

```bash
grunt watch
```

*So, everytime a file is saved inside `/app` it will run the compilation again*

### Using Mockup Server

Open a terminal and run test server:

```bash
grunt serve
```

This will let some mockup resources on `http://localhost:3001`
i.e. `http://localhost:3001/documents`

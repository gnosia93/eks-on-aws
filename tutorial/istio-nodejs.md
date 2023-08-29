## 개발환경 구성 ##

#### 1. node 설치 ####
```
brew install node
```

#### 2. 프로젝트 생성 ####
```
$ npm init
This utility will walk you through creating a package.json file.
It only covers the most common items, and tries to guess sensible defaults.

See `npm help init` for definitive documentation on these fields
and exactly what they do.

Use `npm install <pkg>` afterwards to install a package and
save it as a dependency in the package.json file.

Press ^C at any time to quit.
package name: (soonbeom) point
```
```
npm install --save express
```

## Express 개발 ##
#### package.json ####
```
{
  "name": "point",
  "version": "1.0.0",
  "description": "",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

#### app.js ####
```
const express = require('express');
const app = express();

app.get("/point", (req, res) => {
    res.json(
        {
            success: true,
        }
    );
});

app.listen(3000, () => {
    console.log("Server running at http://localhost:3000"); 
});
```

## 레퍼런스 ##

* [node express](https://blog.codefactory.ai/nodejs/creating-server-with-express/express-intro/)
  
* [node.js Controller, Service, Repository](https://jin-coder.tistory.com/entry/nodejs-Controller-Service-Repository)

* [VSCode node 개발환경 구성](https://devmoony.tistory.com/151)
  
* [Homebrew 를 통해 node, npm, yarn 설치](https://butter-ring.tistory.com/17)

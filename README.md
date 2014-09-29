# Hooklift Boxes
This project contains Packer templates that generate Hooklift boxes for different providers. Initially only VMWare is supported.


## Building and packaging
Make sure you have [Packer](http://www.packer.io/intro/getting-started/setup.html) installed. Then you can explore the options to build, package and release Hooklift boxes.

```
NAME:
   Make.sh - Builds Hooklift boxes

USAGE:
   ./make.sh <target> <template> <provider> Available providers are the same seen for builders in Packer.

TARGETS:
    list    List available Packer templates
    build   Builds a box for a given provider. By default, it builds all boxes for all providers

EXAMPLES:
    $ ./make.sh list

    Available templates:
    ✱ coreos/coreos-324.1.0.json
    ✱ coreos/coreos-alpha.json
    ✱ coreos/coreos-stable.json
    ✱ coreos/coreos-beta.json

    # While working on templates you will find yourself running this often
    $ ./make.sh build coreos/coreos-stable.json vmware-iso
```


## Releasing new versions
Once you run `./make.sh build` boxes will be generated at `./output`. Create a Github Release and upload the boxes following the same versioning convention.


# License

(The MIT License)

Copyright 2014 - Cloudescape . All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

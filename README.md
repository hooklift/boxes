# Dobby Boxes
This project contains Packer templates that generate Dobby boxes for different providers. Initially only VMWare is supported. There is also a Go tool to aid the process.


## Packaging and releasing boxes
Make sure you have [Packer](http://www.packer.io/intro/getting-started/setup.html) installed. Then you can explore the options to build, package and release Dobby boxes.

```
USAGE:
   make <target> [-provider=vmware-iso] 

TARGETS:
	list	List available Packer templates
	build	Builds a box for a given provider. By default, it builds all boxes for VMware
	release	Tags version, generates changelog, creates release and uploads release artifacts to Github
	all	    Builds all the boxes for all the providers
	help	this :)
```

### Examples
```
$ go build -o make
$ ./make list
Available templates:
✱ coreos/coreos-324.1.0.json
✱ coreos/coreos-alpha.json
✱ coreos/coreos-beta.json

$ ./make build coreos/coreos-324.1.0.json -provider=vmware-iso
$ ./make release coreos v0.3.0 -provider=vmware-iso

```

## Releasing new versions
Each developer has to have a GITHUB_TOKEN configured as environment variable in order for Dobby's make
tool to upload box's artifacts to Github.

```
echo "GITHUB_TOKEN=<THE TOKEN>" >> ~/.{zshrc,bashrc}
```


# License

(The MIT License)

Copyright 2014 - Cloudescape . All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
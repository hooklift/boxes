package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
)

// Dobby's boxes builder and release manager
// Why Go for this?
// Makefiles are much more concise but less readable
// and completely extrange for most people.
//
// On the other hand, shell scripts are nice and familiar
// but they are not easy to make portable; and in making them so,
// become bloated, hacky and non-deterministic.

var token string = os.Getenv("GITHUB_TOKEN")
var provider string

func init() {
	//Disables timestamp
	log.SetFlags(0)
	flag.StringVar(&provider, "provider", "vmware", "Builds a box for this provider")
}

// Helper function to list available packer templates
func templates() ([]string, error) {
	return filepath.Glob("**/*.json")
}

// Tags version, generates changelog, creates release and uploads
// release artifacts to Github
func release(box, version string) {
	if token == "" {
		log.Fatal("Github token not found. Please contact @c4milo to get one")
	}
	// Creates tag
	// Generates Changelog // https://coderwall.com/p/5cv5lg
	// Creates Release
	// Uploads assets
}

// Runs packer build on given os template
func build(box string) {
	cwd, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}

	//box variable comes in this format: coreos/coreos-v324.1.0.json
	osdir, template := filepath.Split(box)
	os.Chdir(osdir)
	defer os.Chdir(cwd)

	cmd := exec.Command("packer", "build", "-only="+provider, template)
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		log.Fatal(err)
	}

	rd := bufio.NewReader(stdout)
	if err := cmd.Start(); err != nil {
		log.Fatal("Buffer Error:", err)
	}

	for {
		str, err := rd.ReadString('\n')
		if err != nil {
			log.Fatal("Read Error:", err)
			return
		}
		fmt.Println(str)
	}
}

// Lists available templates
func list() {
	log.Println("Available templates: ")

	tmpls, err := templates()
	if err != nil {
		log.Fatal(err)
	}

	for _, t := range tmpls {
		log.Println("✱ " + t)
	}
}

// Builds all the templates for all the providers
func all() {
	log.Println("Building all the templates for all the providers...")

	tmpls, err := templates()
	if err != nil {
		log.Fatal(err)
	}

	for _, t := range tmpls {
		build(t)
	}
}

func usage() {
	log.Println(`
NAME:
   Make - Builds Dobby boxes and manages releases

USAGE:
   make <target> [-provider=vmware] Available providers are: vmware, vsphere, aws

TARGETS:
	list	List available Packer templates
	build	Builds a box for a given provider. By default, it builds all boxes for vmware
	release	Tags version, generates changelog, creates release and uploads release artifacts to Github
	all	Builds all the boxes for all the providers
	help	this :)
`)
}

func main() {
	flag.Parse()

	args := os.Args
	if len(args) == 1 {
		usage()
		os.Exit(0)
	}

	switch args[1] {
	case "list":
		list()
	case "build":
		if len(args) >= 3 {
			tmpl := args[2]
			build(tmpl)
		} else {
			all()
		}
	case "all":
		all()
	case "release":
	case "help":
		usage()
	}

	// go build -o make
	// make list
	// make build coreos/coreos-v324.1.0.json -provider=vmware
	// make all
	// make release coreos v0.3.0 -provider=vmware
	// make release coreos v0.3.0 -provider=vsphere
	// make release coreos v0.3.0 -provider=kvm
}

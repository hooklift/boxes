package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

// Dobby's boxes builder and release manager
//
// Why Go for this?
// Makefiles are much more concise but less readable
// and completely extrange for most people.
//
// On the other hand, shell scripts are nice and familiar
// but they are not easy to make portable; and in making them so,
// become bloated, hacky and non-deterministic.
//
// The above said, this Go version isn't perfect either but hopefully
// it will improve as we move along without too much magic and clear intent.

var token string = os.Getenv("GITHUB_TOKEN")
var provider string

func init() {
	//Disables timestamp
	log.SetFlags(0)
	flag.StringVar(&provider, "provider", "", "Builds a box for this provider")
}

// Helper function to list available packer templates
func templates() ([]string, error) {
	return filepath.Glob("**/*.json")
}

// Tags version, generates changelog, creates release and uploads
// release artifacts to Github
func release(path, version string) {
	fmt.Println("Releasing...")
	cwd, _ := os.Getwd()

	// TODO(c4milo). Validate that it is a valid semver version

	osName, osVersion, template := disect(path)
	version = version + "-" + osVersion
	template = strings.TrimSuffix(template, ".json")

	runCommand(exec.Command("git", "add", "--all"))
	runCommand(exec.Command("git", "commit", "-m", "[make] Preparing to release version "+version))
	runCommand(exec.Command("git", "push", "origin", "master"))

	// Creates Release using github API
	ghRelease(version)

	outputDir := "output"

	providers, _ := ioutil.ReadDir(outputDir)

	for _, p := range providers {
		pname := p.Name()
		os.Chdir(outputDir + "/" + pname)

		rel := osName + "-" + version + "-" + pname
		runCommand(exec.Command("tar", "cvzf", rel+".box", template))

		// Upload Box
		os.Chdir(cwd)
	}

	// Edit release to add Changelog
	// git log v2.1.0...v2.1.1 --pretty=format:'<li> <a href="http://github.com/jerel/<project>/commit/%H">view commit &bull;</a> %s</li> ' --reverse | grep "#changelog"
}

func ghReleaseUpload(releaseId string) {
	// curl -H "Authorization: token TOKEN" \
	//     -H "Accept: application/vnd.github.manifold-preview" \
	//     -H "Content-Type: application/zip" \
	//     --data-binary @build/mac/package.zip \
	//     "https://uploads.github.com/repos/hubot/singularity/releases/123/assets?name=1.0.0-mac.zip"
}

func ghRelease(version, name, desc string) {
	if token == "" {
		log.Fatal("Github token not found. Please contact @c4milo to get one")
	}

	url := "https://api.github.com/repos/c4milo/dobby-boxes/releases"

	release := fmt.Sprintf(`
		{
		  "tag_name": "%s",
		  "target_commitish": "master",
		  "name": "%s",
		  "body": "%s",
		  "draft": %t,
		  "prerelease": %t
		}
	`, version, name, desc, true, false)
}

// Disects template path
// path variable comes in this format: coreos/coreos-324.1.0.json
func disect(path string) (string, string, string) {
	osdir, template := filepath.Split(path)

	osdir = strings.TrimSuffix(osdir, "/")
	fileParts := strings.Split(template, "-")
	if len(fileParts) != 2 {
		log.Fatalf("Unable to determine OS version from: %s", template)
	}

	// normalizes Packer parameters
	basename := fileParts[1]
	version := strings.TrimSuffix(basename, filepath.Ext(basename))

	return osdir, version, template
}

// Runs packer build on given os template
func build(path string) {
	cwd, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}

	osdir, version, template := disect(path)
	os.Chdir(osdir)
	defer os.Chdir(cwd)

	//This variable is used by OEM scripts in order
	//to download the specific version of the OS, if needed.
	os.Setenv("OS_VERSION", version)

	only := ""
	if provider != "" {
		only = "-only=" + provider + " "
	}

	cmd := exec.Command("packer", "build", only+template)
	runCommand(cmd)
}

// Runs a command piping output to stdout
func runCommand(cmd *exec.Cmd) {
	log.Printf("Running %s %v...\n", cmd.Path, cmd.Args[1:])

	stdout, err := cmd.StdoutPipe()
	if err != nil {
		log.Fatal(err)
	}

	rd := bufio.NewReader(stdout)

	if err := cmd.Start(); err != nil {
		log.Fatal(err)
	}

	for {
		str, err := rd.ReadString('\n')
		if err != nil {
			if err != io.EOF {
				log.Fatal(err)
			}
			break
		}
		fmt.Print(cmd.Args[0] + " ==> " + str)
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
   make <target> [-provider=vmware] Available providers are the same seen in Packer.

TARGETS:
	list	List available Packer templates
	build	Builds a box for a given provider. By default, it builds all boxes for vmware
	release	Tags version, generates changelog, creates release and uploads release artifacts to Github
	all	Builds all the boxes for all the providers
	help	this :)

EXAMPLES:
	# Makes sure you compile first, unless you want to use 'go run make.go'
	$ go build -o make
	$ ./make list

	Available templates:
	✱ coreos/coreos-324.1.0.json
	✱ coreos/coreos-alpha.json
	✱ coreos/coreos-beta.json

	# While working on templates you will find yourself running this often
	$ ./make build coreos/coreos-324.1.0.json -provider=vmware-iso

	# Creates a Github release, tagging it as v0.3.0-324.1.0
	# It also adds a changelog to the release description
	# and uploads artifacts for ALL supported providers
	$ ./make release coreos/coreos-324.1.0.json v0.3.0
`)
}

func main() {
	flag.Parse()

	args := os.Args
	argsn := len(args)

	if argsn == 1 {
		usage()
		os.Exit(0)
	}

	switch args[1] {
	case "list":
		list()
	case "build":
		if argsn >= 3 {
			tmpl := args[2]
			build(tmpl)
		} else {
			all()
		}
	case "all":
		all()
	case "release":
		if argsn < 4 {
			usage()
			os.Exit(0)
		}
		tmpl := args[2]
		version := args[3]
		build(tmpl)
		release(tmpl, version)
	case "help":
		usage()
	default:
		usage()
	}
}

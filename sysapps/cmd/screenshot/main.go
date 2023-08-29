package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"time"

	"github.com/gen2brain/beeep"
)

var (
	snip = flag.Bool("snip", false, "Snip the screen")
)

func command(name string, args ...string) *exec.Cmd {
	cmd := exec.Command(name, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd
}

// checks if there is a Pictures directory in the home directory, if not
// it creates one and returns the path
func pictures() string {
	home, err := os.UserHomeDir()
	if err != nil {
		log.Fatalf("Screenshot: %v", err)
	}
	pics := filepath.Join(home, "Pictures")
	if _, err := os.Stat(pics); os.IsNotExist(err) {
		if err := os.Mkdir(pics, 0664); err != nil {
			log.Fatalf("Screenshot: %v", err)
		}
	}
	return pics
}

func main() {
	flag.Parse()
	shot := fmt.Sprintf("Screenshot_%s.png", time.Now().Format("2006-01-02_15-04-05.000"))
	pic := filepath.Join(pictures(), shot)

	if *snip {
		if err := command("scrot", "-s", "-o", pic).Run(); err != nil {
			log.Fatal("Screnshot snip: %v", err)
		}
	} else {
		if err := command("scrot", "-o", pic).Run(); err != nil {
			log.Fatal("Screenshot: %v", err)
		}
	}

	if err := beeep.Notify("", shot, pic); err != nil {
		log.Fatalf("Screenshot: %v", err)
	}
}

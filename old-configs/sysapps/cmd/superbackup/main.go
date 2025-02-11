/*
SuperProductivity Backup Utility
superProductivity takes regular backups of its state, this utility just takes
that backup, makes it into a tarball and then pushes it off to Google drive.

Usage:

	superbackup
*/
package main

import (
	"archive/tar"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"runtime"
	"strings"
)

func backupDir() (string, error) {
	switch runtime.GOOS {
	case "linux":
		u, err := os.UserConfigDir()
		if err != nil {
			return "", fmt.Errorf("failed to get config dir: %v", err)
		}
		return filepath.Join(u, "superProductivity", "backups"), nil
	}
	return "", fmt.Errorf("os not supported")
}

func tarBackup(to io.Writer) error {
	backups, err := backupDir()
	if err != nil {
		return err
	}

	tw := tar.NewWriter(to)
	defer tw.Close()

	return filepath.Walk(backups, func(file string, fi os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !fi.Mode().IsRegular() {
			return nil
		}

		header, err := tar.FileInfoHeader(fi, fi.Name())
		if err != nil {
			return err
		}

		header.Name = strings.TrimPrefix(strings.Replace(file, backups, "", -1), string(filepath.Separator))

		if err := tw.WriteHeader(header); err != nil {
			return err
		}

		f, err := os.Open(file)
		if err != nil {
			return err
		}
		if _, err := io.Copy(tw, f); err != nil {
			return err
		}
		f.Close()
		return nil
	})
}

func main() {
	temp, err := os.CreateTemp(".", "backups.tar")
	if err != nil {
		log.Fatal(err)
	}

	if err := tarBackup(temp); err != nil {
		log.Fatal(err)
	}
}

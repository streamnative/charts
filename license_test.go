// Copyright (c) 2019 - 2024 StreamNative, Inc.. All Rights Reserved..

package main

import (
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
)

var goFileCheck = regexp.MustCompile(`// Copyright \(c\) 2019 - 2024 StreamNative, Inc\.\. All Rights Reserved\.\.

`)

var otherCheck = regexp.MustCompile(`#
# Copyright \(c\) 2019 - 2024 StreamNative, Inc\.\. All Rights Reserved\.\.
#
`)

var skip = map[string]bool{
	"charts/function-mesh-operator/crds": true,
	"charts/pulsar-operator/crds":        true,
	"test-values":                        true,
}

func TestLicense(t *testing.T) {
	err := filepath.Walk(".", func(path string, fi os.FileInfo, err error) error {

		for k, _ := range skip {
			if strings.Contains(path, k) {
				return nil
			}
		}

		if skip[path] {
			return nil
		}

		if err != nil {
			return err
		}

		switch filepath.Ext(path) {
		case ".go":
			src, err := os.ReadFile(path)
			if err != nil {
				return nil
			}

			// Find license
			if !goFileCheck.Match(src) {
				t.Errorf("%v: license header not present", path)
				return nil
			}
		case ".yaml":
			fallthrough
		case ".conf":
			src, err := os.ReadFile(path)
			if err != nil {
				return nil
			}

			// Find license
			if !otherCheck.Match(src) {
				t.Errorf("%v: license header not present", path)
				return nil
			}

		default:
			return nil
		}

		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
}

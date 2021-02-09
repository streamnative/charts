// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

// Partial structure of a Kubernetes DaemonSet object
// Only contains fields we will actively be using, to make JSON parsing nicer
type DaemonSet struct {
	Kind   string `json:"kind"`
	Status struct {
		DesiredNumberScheduled int `json:"desiredNumberScheduled"`
		NumberReady            int `json:"numberReady"`
	} `json:"status"`
}

// Return a *DaemonSet and the relevant state its in
func getDaemonSet(transportPtr *http.Transport, server string, headers map[string]string, namespace string, daemonSet string) (*DaemonSet, error) {
	client := &http.Client{Transport: transportPtr}
	url := server + "/apis/apps/v1/namespaces/" + namespace + "/daemonsets/" + daemonSet

	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}

	for k, v := range headers {
		req.Header.Add(k, v)
	}

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	ds := &DaemonSet{}
	data, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	err = json.Unmarshal(data, &ds)

	if ds.Kind != "DaemonSet" {
		// Something went wrong!
		return nil, fmt.Errorf(fmt.Sprintf("Can not parse API response as DaemonSet: %s", string(data)))
	}

	return ds, err
}

func isImagesPresent(ds *DaemonSet) bool {
	desired := ds.Status.DesiredNumberScheduled
	ready := ds.Status.NumberReady

	log.Printf("%d of %d nodes currently has the required images.", ready, desired)

	return desired == ready
}

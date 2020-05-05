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

// 
// Program used to delay a helm upgrade process until all relevant nodes have
// pulled required images. It is an image-awaiter. It can simply wait because
// the hook-image-puller daemonset that will get the images pulled is already
// started when this job starts. When all images are pulled, this job exits.

/*
K8s API options - currently using 1.9
- K8s 1.8 API: curl http://localhost:8080/apis/apps/v1beta2/namespaces/<ns>/demonsets/<ds>
- K8s 1.9 API: curl http://localhost:8080/apis/apps/v1/namespaces/<ns>/demonsets/<ds>
*/

package main

import (
	"crypto/tls"
	"crypto/x509"
	"flag"
	"io/ioutil"
	"log"
	"net/http"
	"time"
)

// Return a HTTPS transport that has TLS configuration specified properly
func makeHTTPTransport(debug bool, caPath string, clientCertPath string, clientKeyPath string) (*http.Transport, error) {
	idleConnTimeout := 30 * 60 * time.Second

	// If you debug through a kubectl proxy, certificates etc. isn't required
	if debug {
		transportPtr := &http.Transport{IdleConnTimeout: idleConnTimeout}
		return transportPtr, nil
	}

	// Load client cert/key if they exist
	certificates := []tls.Certificate{}

	if clientCertPath != "" && clientKeyPath != "" {
		cert, err := tls.LoadX509KeyPair(clientCertPath, clientKeyPath)
		if err != nil {
			return nil, err
		}
		certificates = append(certificates, cert)
	}

	// Load CA cert
	caCert, err := ioutil.ReadFile(caPath)
	if err != nil {
		return nil, err
	}
	caCertPool := x509.NewCertPool()
	caCertPool.AppendCertsFromPEM(caCert)

	// Setup HTTPS transport
	tlsConfig := &tls.Config{
		Certificates: certificates,
		RootCAs:      caCertPool,
	}
	tlsConfig.BuildNameToCertificate()
	transportPtr := &http.Transport{TLSClientConfig: tlsConfig, IdleConnTimeout: idleConnTimeout}

	return transportPtr, nil
}

func makeHeaders(debug bool, authTokenPath string) (map[string]string, error) {
	if debug {
		return map[string]string{}, nil
	}

	authToken, err := ioutil.ReadFile(authTokenPath)
	if err != nil {
		return nil, err
	}
	return map[string]string{
		"Authorization": "Bearer " + string(authToken),
	}, nil
}

func main() {
	var caPath, clientCertPath, clientKeyPath, authTokenPath, apiServerAddress, namespace, daemonSet string
	flag.StringVar(&caPath, "ca-path", "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt", "Path to CA bundle used to verify kubernetes master")
	flag.StringVar(&clientCertPath, "client-certificate-path", "", "Path to client certificate used to authenticate with kubernetes server")
	flag.StringVar(&clientKeyPath, "client-key-path", "", "Path to client certificate key used to authenticate with kubernetes server")
	flag.StringVar(&authTokenPath, "auth-token-path", "/var/run/secrets/kubernetes.io/serviceaccount/token", "Auth Token to use when making API requests")
	flag.StringVar(&apiServerAddress, "api-server-address", "", "Address of the Kubernetes API Server to contact")
	flag.StringVar(&namespace, "namespace", "", "Namespace of the DaemonSet that will perform image pulling")
	flag.StringVar(&daemonSet, "daemonset", "hook-image-puller", "The name DaemonSet that will perform image pulling")
	var debug bool
	flag.BoolVar(&debug, "debug", false, "Communicate through a 'kubectl proxy --port 8080' setup instead.")

	flag.Parse()

	if debug {
		apiServerAddress = "http://localhost:8080"
	}

	transportPtr, err := makeHTTPTransport(debug, caPath, clientCertPath, clientKeyPath)
	if err != nil {
		log.Fatal(err)
	}

	headers, err := makeHeaders(debug, authTokenPath)
	if err != nil {
		log.Fatal(err)
	}

	for {
		ds, err := getDaemonSet(transportPtr, apiServerAddress, headers, namespace, daemonSet)
		if err != nil {
			log.Fatal(err)
		}

		if isImagesPresent(ds) {
			log.Printf("All images present on all nodes!")
			break
		}

		time.Sleep(2 * time.Second)
	}
}
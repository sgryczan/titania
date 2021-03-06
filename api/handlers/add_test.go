package handlers

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/sgryczan/titania/api/models"
)

var exampleHost = models.Host{
	"ff:ff:ff:ff:ff:ff",
	models.HostConfig{
		"http://10.117.30.30/images/linux/CentOS-8.1.1911-x86_64-boot/isolinux/vmlinuz",
		[]string{
			"http://10.117.30.30/images/linux/CentOS-8.1.1911-x86_64-boot/isolinux/initrd.img",
		},
		"ip=dhcp inst.repo=http://10.117.30.30/images/linux/CentOS-8.1.1911-x86_64-dvd1 inst.ks=https://tengu-boot.s3-us-west-2.amazonaws.com/centos8/centos8.cfg",
	},
}

func TestAddHandler(t *testing.T) {
	targetDir := "inv/"
	err := os.Mkdir(targetDir, 0777)
	defer os.RemoveAll(targetDir)

	rawJSON, err := json.Marshal(exampleHost)
	if err != nil {
		t.Fatalf("error marshalling json: %v", err)
	}

	req, err := http.NewRequest("POST", "/host/"+exampleHost.MacAddr, bytes.NewBuffer(rawJSON))
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(AddHandler)

	handler.ServeHTTP(rr, req)
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned status code %v want %v", status, http.StatusOK)
	}

	expected := fmt.Sprintf("Added item: %v\n", exampleHost.MacAddr)
	if rr.Body.String() != expected {
		t.Errorf("handler returned unexpected body: got %v\n want \n%v",
			rr.Body.String(), expected)
	}
}

var exampleEvent = models.MachineEvent{
	Details: map[string]string{
		"arch":    "IA32",
		"macAddr": "1a:2b:3c:4d:5e:6f",
	},
	MacAddr: "1A:2B:3C:4D:5E:6F",
	Type:    "iPXE",
}

func TestAddBootedHostsHandler(t *testing.T) {
	targetDir := "inventory/"
	err := os.Mkdir(targetDir, 0777)
	defer os.RemoveAll(targetDir)

	rawJSON, err := json.Marshal(exampleEvent)
	if err != nil {
		t.Fatalf("error marshalling json: %v", err)
	}

	req, err := http.NewRequest("POST", "/v1/inventory", bytes.NewBuffer(rawJSON))
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(AddBootedHostHandler)

	handler.ServeHTTP(rr, req)
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned status code %v want %v", status, http.StatusOK)
	}

	expected := fmt.Sprintf("Added event type to booted hosts inventory: %s\n", exampleEvent.Type)
	if rr.Body.String() != expected {
		t.Errorf("handler returned unexpected body: got %v\n want \n%v",
			rr.Body.String(), expected)
	}
}

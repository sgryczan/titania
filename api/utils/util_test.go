package utils

import (
	"fmt"
	"io/ioutil"
	"os"
	"testing"

	"github.com/google/go-cmp/cmp"
	"github.com/sgryczan/titania/api/models"
	"k8s.io/apimachinery/pkg/util/json"
)

var validateJSONCases = []struct {
	Name        string
	Input       string
	ExpectValid bool
}{
	{"simple valid json", `{"id": "test"}`, true},
	{"simple invalid json", `{"id": "test}`, false},
}

/* func TestValidateJSON(t *testing.T) {
	for _, case := range validateJSONCases {
		result := ValidateJSON
	}
} */

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

var exampleEvent = models.MachineEvent{
	Details: map[string]interface{}{
		"arch":    "IA32",
		"macAddr": "1a:2b:3c:4d:5e:6f",
	},
	MacAddr: "1A:2B:3C:4D:5E:6F",
	Type:    "iPXE",
}

func TestWriteHostToFile(t *testing.T) {
	targetDir := "inv/"
	err := os.Mkdir(targetDir, 0777)
	defer os.RemoveAll(targetDir)

	host := exampleHost

	err = WriteHostToFile(host)

	file, err := ioutil.ReadFile(targetDir + "/" + host.MacAddr)

	if err != nil {
		t.Fatalf("Failed to write file: %v", err)
	}

	// We read the file. Does it contain the expected contents?
	fileHost := models.HostConfig{}
	err = json.Unmarshal([]byte(file), &fileHost)

	if err != nil {
		t.Fatalf("Failed to unmarshal file contents into HostConfig: %v", err)
	}

	if !(cmp.Equal(fileHost, host.Config)) {
		t.Fatalf("Structs are not equal. Got %v expected %v", fileHost, host.Config)
	}

}

func TestUpdateBootedHostInventory(t *testing.T) {
	targetDir := "inventory/"
	err := os.Mkdir(targetDir, 0777)
	defer os.RemoveAll(targetDir)

	event := exampleEvent

	err = UpdateBootedHostInventory(&event)

	file, err := ioutil.ReadFile(targetDir + "/" + event.MacAddr)

	if err != nil {
		t.Fatalf("Failed to write file: %v", err)
	}

	// We read the file. Does it contain the expected contents?
	fileInv := models.BootedHostsInventory{}
	err = json.Unmarshal([]byte(file), &fileInv)

	es := models.BootedHostsInventory{}
	es.Events = append(es.Events, exampleEvent)
	if err != nil {
		t.Fatalf("Failed to unmarshal file contents into HostConfig: %v", err)
	}

	if !(cmp.Equal(fileInv, es)) {
		t.Fatalf("Structs are not equal. Got %v expected %v", fileInv, es)
	}

}

func TestReadHostFromFile(t *testing.T) {
	targetDir := "inv/"
	err := os.Mkdir(targetDir, 0777)
	defer os.RemoveAll(targetDir)
	if err != nil {
		t.Fatalf("failed to create inventory directory: %v", err)
	}

	err = WriteHostToFile(exampleHost)
	if err != nil {
		t.Fatalf("failed to write host to file: %v", err)
	}

	testHost, err := ReadHostFromFile(exampleHost.MacAddr)
	if err != nil {
		t.Fatalf("failed to read host from file: %v", err)
	}

	if !(cmp.Equal(*testHost, exampleHost)) {
		t.Fatalf("Structs are not equal. Got %v expected %v", testHost, exampleHost)
	}
}

func TestReadBootedHostsInventoryFromFile(t *testing.T) {
	targetDir := "inventory/"
	err := os.Mkdir(targetDir, 0777)
	defer os.RemoveAll(targetDir)
	if err != nil {
		t.Fatalf("failed to create inventory directory: %v", err)
	}

	err = UpdateBootedHostInventory(&exampleEvent)
	if err != nil {
		t.Fatalf("failed to write host to file: %v", err)
	}

	testHost, err := ReadBootedHostsInventoryFromFile(fmt.Sprintf("%s/%s", targetDir, exampleEvent.MacAddr))
	if err != nil {
		t.Fatalf("failed to read host from file: %v", err)
	}

	es := models.BootedHostsInventory{}
	es.Events = append(es.Events, exampleEvent)
	if !(cmp.Equal(*testHost, es)) {
		t.Fatalf("Structs are not equal. Got diff \n%v", cmp.Diff(*testHost, es))
	}
}

func TestListHostFiles(t *testing.T) {
	targetDir := "inv/"
	err := os.Mkdir(targetDir, 0777)
	defer os.RemoveAll(targetDir)
	if err != nil {
		t.Fatalf("failed to create inventory directory: %v", err)
	}

	err = WriteHostToFile(exampleHost)
	if err != nil {
		t.Fatalf("failed to write host to file: %v", err)
	}

	expected := []string{exampleHost.MacAddr}
	files, err := ListHostFiles()
	if err != nil {
		t.Fatalf("failed to list host files: %v", err)
	}
	if !(cmp.Equal(expected, files)) {
		t.Fatalf("Slices are not equal. Got %v expected %v", files, expected)
	}
}

func TestListInventoryFiles(t *testing.T) {
	targetDir := "inventory/"
	err := os.Mkdir(targetDir, 0777)
	defer os.RemoveAll(targetDir)
	if err != nil {
		t.Fatalf("failed to create inventory directory: %v", err)
	}

	err = UpdateBootedHostInventory(&exampleEvent)
	if err != nil {
		t.Fatalf("failed to write host to file: %v", err)
	}

	expected := []string{exampleEvent.MacAddr}
	files, err := ListInventoryFiles()
	if err != nil {
		t.Fatalf("failed to list host files: %v", err)
	}
	if !(cmp.Equal(expected, files)) {
		t.Fatalf("Slices are not equal. Got %v expected %v", files, expected)
	}
}

func TestDeleteHostFile(t *testing.T) {
	targetDir := "inv/"
	err := os.Mkdir(targetDir, 0777)
	defer os.RemoveAll(targetDir)
	if err != nil {
		t.Fatalf("failed to create inventory directory: %v", err)
	}

	err = WriteHostToFile(exampleHost)
	if err != nil {
		t.Fatalf("failed to write host to file: %v", err)
	}

	err = DeleteHostFile(exampleHost.MacAddr)
	if err != nil {
		t.Fatalf("failed to delete host file: %v", err)
	}

	expected := []string{}
	files, err := ListHostFiles()
	if err != nil {
		t.Fatalf("failed to list host files: %v", err)
	}
	if !(cmp.Equal(expected, files)) {
		t.Fatalf("Slices are not equal. Got %v expected %v", files, expected)
	}
}

func TestDeleteInventoryFile(t *testing.T) {
	targetDir := "inventory/"
	err := os.Mkdir(targetDir, 0777)
	defer os.RemoveAll(targetDir)
	if err != nil {
		t.Fatalf("failed to create inventory directory: %v", err)
	}

	err = UpdateBootedHostInventory(&exampleEvent)
	if err != nil {
		t.Fatalf("failed to write host to file: %v", err)
	}

	err = DeleteInventoryFile(exampleEvent.MacAddr)
	if err != nil {
		t.Fatalf("failed to delete host file: %v", err)
	}

	expected := []string{}
	files, err := ListInventoryFiles()
	if err != nil {
		t.Fatalf("failed to list host files: %v", err)
	}
	if !(cmp.Equal(expected, files)) {
		t.Fatalf("Slices are not equal. Got %v expected %v", files, expected)
	}
}

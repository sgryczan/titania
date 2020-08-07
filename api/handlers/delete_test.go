package handlers

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/sgryczan/titania/api/utils"
)

func TestDeleteHandler(t *testing.T) {
	// set up a temp inventory dir
	targetDir := "inv/"
	err := os.Mkdir(targetDir, 0777)
	defer os.RemoveAll(targetDir)

	err = utils.WriteHostToFile(exampleHost)
	if err != nil {
		t.Fatalf("%v", err)
	}

	req, err := http.NewRequest("DELETE", "/host/"+exampleHost.MacAddr, nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(DeleteHandler)

	handler.ServeHTTP(rr, req)
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned status code %v want %v", status, http.StatusOK)
	}

	expected := fmt.Sprintf("Deleted host: %v\n", exampleHost.MacAddr)
	if rr.Body.String() != string(expected) {
		t.Errorf("handler returned unexpected body: got %v\n want \n%v",
			rr.Body.String(), expected)
	}
}

func TestDeleteInventoryHandler(t *testing.T) {
	// set up a temp inventory dir
	targetDir := "inventory/"
	err := os.Mkdir(targetDir, 0777)
	defer os.RemoveAll(targetDir)

	err = utils.UpdateBootedHostInventory(&exampleEvent)
	if err != nil {
		t.Fatalf("%v", err)
	}

	req, err := http.NewRequest("DELETE", "/v1/inventory/"+exampleEvent.MacAddr, nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(DeleteInventoryHandler)

	handler.ServeHTTP(rr, req)
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned status code %v want %v", status, http.StatusOK)
	}

	expected := fmt.Sprintf("Deleted event history for host: %v\n", exampleEvent.MacAddr)
	if rr.Body.String() != string(expected) {
		t.Errorf("handler returned unexpected body: got %v\n want \n%v",
			rr.Body.String(), expected)
	}
}

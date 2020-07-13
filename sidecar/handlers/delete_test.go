package handlers

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/utils"
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

package handlers

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/sgryczan/titania/api/utils"
)

func TestReadHandler(t *testing.T) {
	// set up a temp inventory dir
	targetDir := "inv/"
	err := os.Mkdir(targetDir, 0777)
	defer os.RemoveAll(targetDir)

	err = utils.WriteHostToFile(exampleHost)
	if err != nil {
		t.Fatalf("%v", err)
	}

	req, err := http.NewRequest("GET", "/host/"+exampleHost.MacAddr, nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(ReadHandler)

	handler.ServeHTTP(rr, req)
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned status code %v want %v", status, http.StatusOK)
	}

	expected, err := json.MarshalIndent(exampleHost.Config, "", "  ")
	if rr.Body.String() != string(expected) {
		t.Errorf("handler returned unexpected body: got %v\n want \n%v",
			rr.Body.String(), expected)
	}
}

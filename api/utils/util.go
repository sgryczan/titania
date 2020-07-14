package utils

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/sgryczan/titania/api/models"
)

// ValidateJSON gracefully handles JSON Decoder-related errors
func ValidateJSON(err error, w http.ResponseWriter) bool {
	if err != nil {
		var syntaxError *json.SyntaxError
		var unmarshalTypeError *json.UnmarshalTypeError

		switch {
		// Catch any syntax errors in the JSON and send an error message
		// which interpolates the location of the problem to make it
		// easier for the client to fix.
		case errors.As(err, &syntaxError):
			msg := fmt.Sprintf("Request body contains badly-formed JSON (at position %d)", syntaxError.Offset)
			http.Error(w, msg, http.StatusBadRequest)

		// In some circumstances Decode() may also return an
		// io.ErrUnexpectedEOF error for syntax errors in the JSON. There
		// is an open issue regarding this at
		// https://github.com/golang/go/issues/25956.
		case errors.Is(err, io.ErrUnexpectedEOF):
			msg := fmt.Sprintf("Request body contains badly-formed JSON")
			http.Error(w, msg, http.StatusBadRequest)

		// Catch any type errors, like trying to assign a string in the
		// JSON request body to a int field in our Person struct. We can
		// interpolate the relevant field name and position into the error
		// message to make it easier for the client to fix.
		case errors.As(err, &unmarshalTypeError):
			msg := fmt.Sprintf("Request body contains an invalid value for the %q field (at position %d)", unmarshalTypeError.Field, unmarshalTypeError.Offset)
			http.Error(w, msg, http.StatusBadRequest)

		// Catch the error caused by extra unexpected fields in the request
		// body. We extract the field name from the error message and
		// interpolate it in our custom error message. There is an open
		// issue at https://github.com/golang/go/issues/29035 regarding
		// turning this into a sentinel error.
		case strings.HasPrefix(err.Error(), "json: unknown field "):
			fieldName := strings.TrimPrefix(err.Error(), "json: unknown field ")
			msg := fmt.Sprintf("Request body contains unknown field %s", fieldName)
			http.Error(w, msg, http.StatusBadRequest)

		// An io.EOF error is returned by Decode() if the request body is
		// empty.
		case errors.Is(err, io.EOF):
			msg := "Request body must not be empty"
			http.Error(w, msg, http.StatusBadRequest)

		// Catch the error caused by the request body being too large. Again
		// there is an open issue regarding turning this into a sentinel
		// error at https://github.com/golang/go/issues/30715.
		case err.Error() == "http: request body too large":
			msg := "Request body must not be larger than 1MB"
			http.Error(w, msg, http.StatusRequestEntityTooLarge)

		// Otherwise default to logging the error and sending a 500 Internal
		// Server Error response.
		default:
			log.Println(err.Error())
			http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		}
		return false
	}
	return true
}

// WriteHostToFile writes host configs to file
func WriteHostToFile(h models.Host) error {

	file, err := json.MarshalIndent(h.Config, "", "  ")
	if err != nil {
		log.Print(err.Error())
		return err
	}
	err = ioutil.WriteFile("inv/"+h.MacAddr, file, 0644)
	return err
}

// ReadHostFromFile reads a hostConfig from a file
func ReadHostFromFile(mac string) (*models.Host, error) {

	file, err := ioutil.ReadFile("inv/" + mac)
	if err != nil {
		log.Print(err.Error())
		return nil, err
	}

	hostConfig := models.HostConfig{}
	host := models.Host{}

	err = json.Unmarshal([]byte(file), &hostConfig)
	if err != nil {
		log.Print(err.Error())
		return nil, err
	}

	host.MacAddr = mac
	host.Config = hostConfig

	return &host, nil
}

//ListHostFiles lists all hosts in inventory
func ListHostFiles() ([]string, error) {
	dir := "inv/"
	files := []string{}

	children, err := ioutil.ReadDir(dir)
	if err != nil {
		log.Fatal(err)
	}

	for _, file := range children {
		files = append(files, file.Name())
	}
	log.Printf("[ListHostFiles] - %s", files)
	return files, nil
}

// DeleteHostFile deletes an inventory file for target MAC
func DeleteHostFile(mac string) error {
	var err error
	dir := "inv/"

	log.Printf("[DeleteHostFile] - Deleting %s", mac)
	err = os.Remove(dir + mac)
	if err != nil {
		return err
	}
	return nil
}

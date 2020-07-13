package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
)

// Version holds the package version
var Version string

type aboutResponse struct {
	Version string
}

// AboutHandler returns information about the api
func AboutHandler(w http.ResponseWriter, r *http.Request) {
	// swagger:operation GET /about About About
	//
	// Returns information about the application
	// ---
	// consumes:
	// - text/plain
	// produces:
	// - text/plain
	//
	// responses:
	//   '200':
	//     description: About
	//     type: string
	w.WriteHeader(http.StatusOK)
	data := &aboutResponse{
		Version: Version,
	}
	res, _ := json.Marshal(data)

	fmt.Fprintf(w, "%s", res)
}

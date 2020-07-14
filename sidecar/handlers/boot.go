package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"path/filepath"

	"github.com/sgryczan/titania/api/utils"
)

// BootHandler handles host boot requests from Pixiecore
func BootHandler(w http.ResponseWriter, r *http.Request) {
	// swagger:operation GET /v1/boot/{mac} BootConfig boot
	//
	// Retrieves the boot details of a given host
	// ---
	// consumes:
	// - text/plain
	// produces:
	// - application/json
	// parameters:
	// - name: mac
	//   in: path
	//   description: MAC of host config to be returned.
	//   required: true
	//   type: string
	// responses:
	//   '200':
	//     description: MAC details retrieved successfully
	//     type: string
	//   '404':
	//     description: MAC not found
	//     type: string

	mac := filepath.Base(r.URL.Path)

	log.Printf("GET /v1/boot/%s\n", mac)
	log.Printf("Checking for boot config for %s", mac)

	host, err := utils.ReadHostFromFile(mac)
	if err != nil {
		log.Print(err.Error())
		w.WriteHeader(http.StatusNotFound)
		fmt.Fprintf(w, "config for mac %s not found", mac)
		return
	}

	res, err := json.MarshalIndent(host.Config, "", "  ")

	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "%s", res)
	log.Print(fmt.Sprintf("retrieved config for host: %v\n", mac))

}

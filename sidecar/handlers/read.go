package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"path/filepath"

	"bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/utils"
)

// ReadHandler handles host additions
func ReadHandler(w http.ResponseWriter, r *http.Request) {
	// swagger:operation GET /host/{mac} BootConfig read
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
	// responses:
	//   '400':
	//     description: MAC configuration not found
	//     type: string

	mac := filepath.Base(r.URL.Path)
	fmt.Printf("GET /host/%s\n", mac)

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

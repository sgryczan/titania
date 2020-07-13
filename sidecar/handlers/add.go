package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"path/filepath"

	"bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/models"
	"bitbucket.ngage.netapp.com/scm/hcit/pixiecore-dynamic-rom/sidecar/utils"
)

// AddHandler handles host additions
func AddHandler(w http.ResponseWriter, r *http.Request) {
	// swagger:operation POST /host/{mac} BootConfig create
	//
	// Adds a bootable host to the inventory
	// ---
	// consumes:
	// - application/json
	// produces:
	// - text/plain
	// parameters:
	// - name: mac
	//   in: path
	//   description: MAC of host config to be added.
	//   required: true
	//   type: string
	// - name: payload
	//   in: body
	//   description: hostConfig object
	//   required: true
	//   schema:
	//     "$ref": "#/definitions/HostConfig"
	// responses:
	//   '200':
	//     description: MAC added successfully
	//     type: string

	hostConfig := &models.HostConfig{}
	err := json.NewDecoder(r.Body).Decode(&hostConfig)
	if !(utils.ValidateJSON(err, w)) {
		return
	}

	mac := filepath.Base(r.URL.Path)

	host := models.Host{
		MacAddr: mac,
		Config:  *hostConfig,
	}
	fmt.Printf("%+v\n", host)

	_, err = json.Marshal(host)
	if err != nil {
		log.Print("Error marshalling json")
	}

	err = utils.WriteHostToFile(host)
	if err != nil {
		log.Print(err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "Added item: %v\n", mac)
	log.Print(fmt.Sprintf("added item: %v\n", mac))
}

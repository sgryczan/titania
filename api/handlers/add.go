package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"path/filepath"
	"time"

	"github.com/sgryczan/titania/api/models"
	"github.com/sgryczan/titania/api/utils"
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

// AddBootedHostHandler adds a host to the slice of booted hosts
func AddBootedHostHandler(w http.ResponseWriter, r *http.Request) {
	// swagger:operation POST /v1/inventory Inventory Inventory
	//
	// Add a booted host to host inventory
	// ---
	// consumes:
	// - application/json
	// produces:
	// - text/plain
	// parameters:
	// - name: payload
	//   in: body
	//   description: Booted machine. Should include a MAC address and architecture
	//   required: true
	//   schema:
	//     "$ref": "#/definitions/MachineEvent"
	// responses:
	//   '200':
	//     description: Machine added successfully
	//     type: string
	event := &models.MachineEvent{}
	err := json.NewDecoder(r.Body).Decode(&event)
	event.Date = time.Now().Format(time.RFC3339)
	if !(utils.ValidateJSON(err, w)) {
		return
	}

	//bootedHosts = append(bootedHosts, *machine)
	// Write host to file
	err = utils.UpdateBootedHostInventory(event)
	if err != nil {
		log.Print(err.Error())
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "Added event type to booted hosts inventory: %s\n", event.Type)
}

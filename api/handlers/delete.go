package handlers

import (
	"fmt"
	"log"
	"net/http"
	"path/filepath"

	"github.com/sgryczan/titania/api/utils"
)

// DeleteHandler deletes host configs
func DeleteHandler(w http.ResponseWriter, r *http.Request) {
	// swagger:operation DELETE /host/{mac} BootConfig delete
	//
	// Remove a host from inventory
	// ---
	// consumes:
	// - text/plain
	// produces:
	// - text/plain
	// parameters:
	// - name: mac
	//   in: path
	//   description: MAC of host config to be deleted.
	//   required: true
	//   type: string
	// responses:
	//   '200':
	//     description: Host removed successfully
	//     type: string

	mac := filepath.Base(r.URL.Path)
	err := utils.DeleteHostFile(mac)
	if err != nil {
		log.Print(err.Error())
		http.Error(w, fmt.Sprintf("No config found for host: %s", mac), http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "Deleted host: %v\n", mac)
	log.Print(fmt.Sprintf("deleted host: %v\n", mac))
}

// DeleteInventoryHandler deletes inventory configs
func DeleteInventoryHandler(w http.ResponseWriter, r *http.Request) {
	// swagger:operation DELETE /v1/inventory/{mac} Inventory delete
	//
	// Remove event history for a given host
	// ---
	// consumes:
	// - text/plain
	// produces:
	// - text/plain
	// parameters:
	// - name: mac
	//   in: path
	//   description: Delete events for this MAC.
	//   required: true
	//   type: string
	// responses:
	//   '200':
	//     description: Host removed successfully
	//     type: string

	mac := filepath.Base(r.URL.Path)
	err := utils.DeleteInventoryFile(mac)
	if err != nil {
		log.Print(err.Error())
		http.Error(w, fmt.Sprintf("No event file found for host: %s", mac), http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "Deleted event history for host: %v\n", mac)
	log.Print(fmt.Sprintf("deleted inventory file: %v\n", mac))
}

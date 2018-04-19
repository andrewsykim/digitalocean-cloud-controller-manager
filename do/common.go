/*
Copyright 2017 DigitalOcean

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package do

import (
	"fmt"

	"k8s.io/api/core/v1"

	"github.com/digitalocean/godo"
	"github.com/digitalocean/godo/context"
)

const apiPerPage = 100

func allDropletList(ctx context.Context, client *godo.Client) ([]godo.Droplet, error) {
	list := []godo.Droplet{}

	opt := &godo.ListOptions{PerPage: apiPerPage}
	for {
		droplets, resp, err := client.Droplets.List(ctx, opt)
		if err != nil {
			return nil, err
		}

		if resp == nil {
			return nil, fmt.Errorf("droplets list request returned no response ")
		}

		list = append(list, droplets...)

		// if we are at the last page, break out the for loop
		if resp.Links == nil || resp.Links.IsLastPage() {
			break
		}

		page, err := resp.Links.CurrentPage()
		if err != nil {
			return nil, err
		}

		opt.Page = page + 1
	}

	return list, nil
}

// nodeAddresses returns a []v1.NodeAddress from droplet.
func nodeAddresses(droplet *godo.Droplet) ([]v1.NodeAddress, error) {
	var addresses []v1.NodeAddress
	addresses = append(addresses, v1.NodeAddress{Type: v1.NodeHostName, Address: droplet.Name})

	publicIP, err := droplet.PublicIPv4()
	if err != nil {
		return nil, fmt.Errorf("could not get public ip: %v", err)
	}

	if publicIP != "" {
		addresses = append(addresses, v1.NodeAddress{Type: v1.NodeExternalIP, Address: publicIP})
	}

	privateIP, err := droplet.PrivateIPv4()
	if err != nil {
		return nil, fmt.Errorf("could not get private ip: %v", err)
	}

	if privateIP != "" {
		addresses = append(addresses, v1.NodeAddress{Type: v1.NodeInternalIP, Address: privateIP})
	}

	return addresses, nil
}

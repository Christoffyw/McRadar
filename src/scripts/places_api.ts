import type { Coordinate } from 'ol/coordinate';
import API_KEY from './secret';

var requestHeaders: Headers = new Headers();
function load() {
    requestHeaders.append("Content-Type", "application/json");
    requestHeaders.append("X-Goog-Api-Key", API_KEY);
    requestHeaders.append("X-Goog-Fieldmask", "places.displayName,places.location,places.formattedAddress");
}

export default async function requestMCD(coordinate: Coordinate, radius: number) {
  var raw = JSON.stringify({
      "textQuery": "McDonald's",
      "maxResultCount": 10,
      "locationBias": {
        "circle": {
          "center": {
            "latitude": coordinate[1],
            "longitude": coordinate[0]
          },
          "radius": radius
        }
      }
    });
  
  var requestOptions: RequestInit = {
    method: 'POST',
    headers: requestHeaders,
    body: raw
  };
    
  let response: Response = await fetch("https://places.googleapis.com/v1/places:searchText", requestOptions);
  let json = await response.json();
  return json;   
}
load();

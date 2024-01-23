<script setup lang="ts">
import type { Marker } from '@/types';
import { onMounted, ref } from 'vue';
import type { Coordinate } from 'ol/coordinate'
import { fromLonLat } from 'ol/proj'; // Import the fromLonLat function
import  requestMCD from '../scripts/places_api.ts';
import test_data from '@/scripts/example_data';

let location: Coordinate = [-80.46610037619588,43.39310096168964];
let mcdLocations = ref<Coordinate[]>([[-80.55875739999999,43.433288499999996], [-80.41385079999999,43.3867925]]);
const center = ref(fromLonLat(location));
const projection = ref('EPSG:3857');
const zoom = ref(15);
const rotation = ref(0);
const markerIcon = "/logo.png";

onMounted(async () => {
  let data = await requestMCD(location, 2500); // test_data;
  let MCDs = [];
  for(var i = 0; i < data.places.length; i++) {
    MCDs.push([data.places[i].location.longitude, data.places[i].location.latitude])
  }
  mcdLocations.value = MCDs;
})

</script>

<template>
  <ol-map
    :loadTilesWhileAnimating="true"
    :loadTilesWhileInteracting="true"
    style="width: 100vh; height: 100vh;"
  >
    <ol-view
      ref="view"
      :center="center"
      :rotation="rotation"
      :zoom="zoom"
      :projection="projection"
    />

    <ol-tile-layer>
      <ol-source-osm />
    </ol-tile-layer>

    <ol-vector-layer>
      <ol-source-vector>
        <ol-feature v-for="mcd in mcdLocations">
          <ol-geom-point :coordinates="[fromLonLat(mcd)[0], fromLonLat(mcd)[1]]"></ol-geom-point>
          <ol-style>
            <ol-style-icon :src="markerIcon" :scale="0.05"></ol-style-icon>
          </ol-style>
        </ol-feature>
      </ol-source-vector>
    </ol-vector-layer>
  </ol-map>
</template>
  

<style scoped>
html,
body {
  margin: 0;
  height: 100%;
}

#map {
  position: absolute;
  top: 0;
  bottom: 0;
  width: 100%;
}
</style>
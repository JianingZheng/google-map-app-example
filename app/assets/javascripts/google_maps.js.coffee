#= require underscore
#= require backbone

$ ->
  class LocationMap extends Backbone.View
    initialize: () =>
      latlng = new google.maps.LatLng(33,33)
      mapOptitions = {
      zoom: 4,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
      }
      @map = new google.maps.Map(@el, mapOptitions)

      for location in @collection
        @renderMarker(location)

    renderMarker: (location) ->
      markerView = new MarkerView(model: location)
      markerView.render(@map)

  class MarkerView extends Backbone.View
    render: (map) ->
      new google.maps.Marker(
        position: new google.maps.LatLng(@model.latitude, @model.longitude),
        map: map
      )

  if $('#google-map').length
    location_map = new LocationMap(el: $("#google-map"), collection: JSON.parse(window.location_collection))

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
      map = new google.maps.Map(@el, mapOptitions)


  if $('#google-map').length
    location_map = new LocationMap(el: $("#google-map"))

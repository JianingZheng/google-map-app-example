# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require underscore
#= require backbone
#= require handlebars-runtime
#= require templates/locations/search_bar_field

$ ->
  class LocationInputField extends Backbone.View
    template:
      HandlebarsTemplates['locations/search_bar_field']

    initialize: ->
      this.model.bind("autocomplete_complete", this.onAutocompleteComplete);
      this.model.bind("geocode_complete", this.onGeocoderComplete);

    events:
      "keydown #location-query-field": "onKeydown"

    onKeydown: (event) ->
      if event.keyCode == 13
        this.model.geocode()
        event.preventDefault()
        return true

    render: ->
      context = this.model.toJSON()
      this.$el.html(@template(context))
      @autocomplete = new Autocomplete(this.model)

    onAutocompleteComplete: =>
      this.render()

    onGeocoderComplete: =>
      this.render()
      if this.model.get("geocoder_success")
        this.$el.closest('form').submit()
      else
        alert('We did not understand that location.')
      return true


  class GeoSubmitButton extends Backbone.View
    events:
      "click .submit-button" : "codeAndSubmit"

    codeAndSubmit: ->
      this.model.geocode()
      return false


  class Location extends Backbone.Model
    defaults:
      geocoder_success: true
      geocoded: false
      kind: 'local'

    toJSON: ->
      json =  Backbone.Model.prototype.toJSON.apply(this, arguments)
      json.isLocal = this.isLocal()
      json.isNational = this.isNational()
      return json

    isLocal: ->
      ('local' == this.get('kind'))

    isNational: ->
      ('national' == this.get('kind'))

    geocode: ->
      this.set({geocoded: false, query:this.query_value() })
      if this.query_value()
        gc = new Geocoder(this)
        gc.lookup(this.query_value())
      else
        this.clearAttributes()
        this.trigger("geocode_complete")

    query_field: ->
      $('#location-query-field')

    query_field_element: ->
      this.query_field()[0]

    query_value: ->
      this.query_field().val()

    clearAttributes: ->
      this.set(
        types: []
        latitude: null
        longitude: null
        locality: null
        region: null
        country: null
        postal_code: null
        street: null
      )

    processGeocode: (response, status) ->
      geocoder_success = (status == google.maps.GeocoderStatus.OK)
      if geocoder_success
        response = _.first(response)
        this.fromGoogleResponse(response, status)
      else
        this.clearAttributes()
        this.set(
          geocoder_status: status
          geocoder_success: geocoder_success
          geocoded: true
        )
      this.trigger("geocode_complete")

    processAutocomplete: (response) ->
      this.fromGoogleResponse(response)
      this.trigger("autocomplete_complete")

    fromGoogleResponse: (response, status = google.maps.GeocoderStatus.OK) ->
      new_values =
        geocoder_success: (status == google.maps.GeocoderStatus.OK)
        geocoder_status: google.maps.GeocoderStatus.OK
        geocoded: true
        types: response.types
        latitude: response.geometry.location.lat()
        longitude: response.geometry.location.lng()

      for address_component in response.address_components
        for type in address_component.types
          switch(type)
            when "locality" then _.extend(new_values, {locality: address_component.short_name})
            when "administrative_area_level_1" then  _.extend(new_values, {region: address_component.short_name})
            when "country" then _.extend(new_values, {country: address_component.short_name})
            when "postal_code" then _.extend(new_values, {postal_code: address_component.short_name})
            when "route"
              if (typeof new_values.street  == 'undefined')
                _.extend(new_values, {street: address_component.short_name})
            when "street_address" then _.extend(new_values, {street: address_component.short_name})

      this.set(new_values)

  class Geocoder
    constructor: (@loc) ->
      @client = new google.maps.Geocoder

    lookup: (query) ->
      @client.geocode({'address': query}, this.processLocations);

    processLocations: (response, status) =>
      @loc.processGeocode(response, status)

  class Autocomplete
    constructor: (@loc) ->
      autocomplete = new google.maps.places.Autocomplete(@loc.query_field_element())
      google.maps.event.addListener autocomplete, 'place_changed', =>
        @loc.set({query: @loc.query_value()})
        place = autocomplete.getPlace()
        if place.geometry != undefined
          @loc.processAutocomplete(place)


  if $('.location-search-box').length
    loc = new Location
    field = new LocationInputField(model: loc, el: $('#location-search-container'))
    nearEffortSearchButton = new GeoSubmitButton( model: loc, el:$('#location-search-container'))
    autocomplete = new Autocomplete(loc)


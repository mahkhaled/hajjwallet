#= require jsuri
class window.Spree
  @ready: (callback) ->
    jQuery(document).ready(callback)

    # fire ready callbacks also on turbolinks page change event
    jQuery(document).on 'page:load', ->
      callback(jQuery)

  @mountedAt: ->
    window.SpreePaths.mounted_at

  @adminPath: ->
    window.SpreePaths.admin

  @pathFor: (path) ->
    locationOrigin = "#{window.location.protocol}//#{window.location.hostname}" + (if window.location.port then ":#{window.location.port}" else "")
    @url("#{locationOrigin}#{@mountedAt()}#{path}", @url_params).toString()

  @adminPathFor: (path) ->
    @pathFor("#{@adminPath()}#{path}")

  # Helper function to take a URL and add query parameters to it
  # Uses the JSUri library from here: https://github.com/derek-watson/jsUri
  # Thanks to Jake Moffat for the suggestion: https://twitter.com/jakeonrails/statuses/321776992221544449
  @url: (uri, query) ->
    if uri.path == undefined
      uri = new Uri(uri)
    if query
      $.each query, (key, value) ->
        uri.addQueryParam(key, value)
    return uri

  # This function automatically appends the API token
  # for the user to the end of any URL.
  # Immediately after, this string is then passed to jQuery.ajax.
  #
  # ajax works in two ways in jQuery:
  #
  # $.ajax("url", {settings: 'go here'})
  # or:
  # $.ajax({url: "url", settings: 'go here'})
  #
  # This function will support both of these calls.
  @ajax: (url_or_settings, settings) ->
    if (typeof(url_or_settings) == "string")
      $.ajax(Spree.url(url_or_settings).toString(), settings)
    else
      url = url_or_settings['url']
      delete url_or_settings['url']
      $.ajax(Spree.url(url).toString(), url_or_settings)

  @routes:
    states_search: @pathFor('api/v1/states')
    apply_coupon_code: (order_id) ->
      Spree.pathFor("api/v1/orders/#{order_id}/apply_coupon_code")

  @url_params:
    {}
